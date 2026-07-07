resource "aws_instance" "app" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  key_name               = var.key_pair_name

  user_data = <<EOF
#!/bin/bash
# Redirigir de inmediato toda la salida a un archivo de log propio para monitorear el despliegue
exec > >(tee /var/log/user-data-deployment.log|logger -t user-data -s2>/dev/tty) 2>&1

echo "=== Iniciando actualización e instalación de paquetes ==="
dnf update -y
dnf install -y nginx git nodejs

echo "=== Configurando Nginx ==="
systemctl enable nginx
systemctl start nginx

echo "=== Clonando repositorio desde GitHub ==="
git clone https://github.com/RAPC3/mean-app.git /opt/mean-app

echo "=== Instalando dependencias del Backend ==="
cd /opt/mean-app/backend
npm install

echo "=== Instalando dependencias del Frontend y compilando ==="
cd /opt/mean-app/frontend
npm install
npm run build

echo "=== Iniciar backend con PM2 ==="
cd /opt/mean-app/backend
npm install -g pm2
pm2 start server.js
pm2 startup systemd -u root --hp /root
pm2 save

echo "=== Despliegue finalizado con éxito ==="
EOF

  tags = {
    Name = "mean-app-instance"
  }
}