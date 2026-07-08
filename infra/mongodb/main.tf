resource "aws_security_group" "mongodb" {
  name   = "${var.project_name}-mongodb-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port       = 27017
    to_port         = 27017
    protocol        = "tcp"
    security_groups = [var.app_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-mongodb-sg"
  }
}
resource "aws_instance" "mongodb" {
  ami           = "ami-0c02fb55956c7d316"
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.mongodb.id]

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    cat <<'REPO' > /etc/yum.repos.d/mongodb-org-6.0.repo
    [mongodb-org-6.0]
    name=MongoDB Repository
    baseurl=https://repo.mongodb.org/yum/amazon/2/mongodb-org/6.0/x86_64/
    gpgcheck=1
    enabled=1
    gpgkey=https://www.mongodb.org/static/pgp/server-6.0.asc
    REPO
    yum install -y mongodb-org
    sed -i 's/bindIp: 127.0.0.1/bindIp: 0.0.0.0/' /etc/mongod.conf
    systemctl start mongod
    systemctl enable mongod
    echo "MongoDB iniciado" >> /var/log/user-data.log
  EOF

  tags = {
    Name = "${var.project_name}-mongodb"
  }
}