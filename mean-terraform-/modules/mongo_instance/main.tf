resource "aws_instance" "mongo" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  key_name               = var.key_pair_name

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              # Instalacion basica de MongoDB (ejemplo para Amazon Linux)
              cat <<MONGO_REPO > /etc/yum.repos.d/mongodb-org-6.0.repo
              [mongodb-org-6.0]
              name=MongoDB Repository
              baseurl=https://repo.mongodb.org/yum/amazon/2/mongodb-org/6.0/x86_64/
              gpgcheck=1
              enabled=1
              gpgkey=https://www.mongodb.org/static/pgp/server-6.0.asc
              MONGO_REPO

              yum install -y mongodb-org
              systemctl enable mongod
              systemctl start mongod
              EOF

  tags = {
    Name = "mean-mongo-instance"
  }
}

