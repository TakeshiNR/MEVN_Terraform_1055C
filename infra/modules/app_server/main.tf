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
  systemctl start nginx
  systemctl enable nginx

  # Instalar Node.js
  curl -sL https://rpm.nodesource.com/setup_18.x | bash -
  yum install -y nodejs

  # Clonar repo y correr backend
  cd /home/ec2-user
  git clone -b backend-udl https://github.com/TakeshiNR/MEVN_Terraform_1055C.git
  cd MEVN_Terraform_1055C/backend
  echo "PORT=3000" > .env
  echo "MONGO_URI=mongodb://10.0.2.8:27017/gestor_tareas" >> .env
  npm install
  npm start &
EOF

  vpc_security_group_ids = [aws_security_group.app_server.id]

  tags = {
    Name = "${var.project_name}-app-server"
  }
}