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
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_instance" "app_server" {
  ami           = data.aws_ami.al2023.id
  instance_type = var.instance_type
  subnet_id     = var.public_subnet_id
  key_name      = var.key_name

  root_block_device {
    volume_size = 10
    volume_type = "gp3"
  }
user_data = <<-EOF
  #!/bin/bash
  yum update -y
  yum install -y nginx git

  # Swap: t2.micro tiene 1GB RAM, npm install/build puede quedarse sin memoria
  fallocate -l 1G /swapfile
  chmod 600 /swapfile
  mkswap /swapfile
  swapon /swapfile

  # Instalar Node.js 22 (el frontend requiere ^22.18.0 || >=24.12.0)
  curl -fsSL https://rpm.nodesource.com/setup_22.x | bash -
  yum install -y nodejs

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