#!/bin/bash
# =============================================================================
# Arranque de la capa BACKEND (API Express).
# artifact-hash: ${artifact_hash}  (cambia cuando cambia backend.zip -> fuerza
# reemplazo de la instancia via user_data_replace_on_change, ver compute/main.tf)
#
# Descarga el codigo (backend/ empaquetado) desde S3 -no hay git clone-, lo
# instala y lo arranca con pm2, pasandole la cadena de conexion a MongoDB
# (IP privada de la instancia creada por el modulo ../mongodb).
# =============================================================================
set -eux

# El "nodejs" por defecto de Amazon Linux 2023 (dnf) es v18, pero
# mongoose/bson exigen Node >= 20.19. Se instala Node 22.x LTS via NodeSource.
curl -fsSL https://rpm.nodesource.com/setup_22.x | bash -
dnf install -y nodejs unzip awscli
npm install -g pm2

mkdir -p /opt/backend

S3_KEY="${s3_key}"
if [ -n "$S3_KEY" ]; then
  aws s3 cp "s3://${s3_bucket}/$S3_KEY" /tmp/backend.zip --region "${aws_region}"
  unzip -o /tmp/backend.zip -d /opt/backend

  cat > /opt/backend/.env <<ENVFILE
PORT=${backend_port}
MONGO_URI=mongodb://${mongo_host}:${mongo_port}/${mongo_db}
ENVFILE

  cd /opt/backend
  npm ci --omit=dev
  pm2 start npm --name backend -- start
  pm2 save
  env PATH=$PATH:/usr/bin pm2 startup systemd -u ec2-user --hp /home/ec2-user
else
  echo "Backend aun no implementado (backend/package.json no existe) - se omite el despliegue" >> /var/log/user-data.log
fi

echo "Inicio de arranque - capa BACKEND" >> /var/log/user-data.log
