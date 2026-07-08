resource "aws_security_group" "app_server" {
  name   = "${var.project_name}-app-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [var.alb_sg_id]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-app-sg"
  }
}
resource "aws_instance" "app_server" {
  ami           = "ami-0c02fb55956c7d316"
  instance_type = var.instance_type
  subnet_id     = var.public_subnet_id
  key_name      = var.key_name
user_data = <<-EOF
  #!/bin/bash
  yum update -y
  amazon-linux-extras install nginx1 -y

  # Instalar Node.js
  curl -sL https://rpm.nodesource.com/setup_18.x | bash -
  yum install -y nodejs git

  # Clonar repo (contiene backend/ y frontend/)
  cd /home/ec2-user
  git clone -b mongodb https://github.com/TakeshiNR/MEVN_Terraform_1055C.git
  cd MEVN_Terraform_1055C

  # Backend: API en :3000, bajo /api/tasks
  cd backend
  echo "PORT=3000" > .env
  echo "MONGO_URI=mongodb://10.0.2.8:27017/gestor_tareas" >> .env
  npm install
  npm start &

  # Frontend: build estatico servido por Nginx, API relativa (mismo origen)
  cd ../frontend
  echo "VITE_API_URL=/api/tasks" > .env.production
  npm install
  npm run build
  rm -rf /usr/share/nginx/html/*
  cp -r dist/* /usr/share/nginx/html/

  # Nginx: sirve el frontend y hace proxy de /api/ al backend en localhost:3000
  cat <<'NGINXCONF' > /etc/nginx/nginx.conf
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

include /usr/share/nginx/modules/*.conf;

events {
    worker_connections 1024;
}

http {
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   65;
    types_hash_max_size 4096;

    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;

    include /etc/nginx/conf.d/*.conf;
}
NGINXCONF

  cat <<'NGINXAPP' > /etc/nginx/conf.d/app.conf
server {
    listen 80 default_server;
    server_name _;

    location / {
        root /usr/share/nginx/html;
        try_files $uri $uri/ /index.html;
    }

    location /api/ {
        proxy_pass http://127.0.0.1:3000/api/;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
NGINXAPP

  systemctl enable nginx
  systemctl restart nginx
EOF

  vpc_security_group_ids = [aws_security_group.app_server.id]

  tags = {
    Name = "${var.project_name}-app-server"
  }
}