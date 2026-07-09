#!/bin/bash
# =============================================================================
# Arranque de la capa WEB (Vue compilado, servido por Nginx).
# artifact-hash: ${artifact_hash}  (cambia cuando cambia frontend.zip -> fuerza
# reemplazo de la instancia via user_data_replace_on_change, ver compute/main.tf)
#
# Descarga el build (frontend/dist empaquetado) desde S3 -no hay git clone- y
# configura Nginx para servir los estaticos y proxyar /api/ hacia la capa
# backend (asi coincide con VITE_API_URL=/api/tasks de frontend/.env.production).
# =============================================================================
set -eux

dnf install -y nginx unzip awscli

S3_KEY="${s3_key}"
if [ -n "$S3_KEY" ]; then
  aws s3 cp "s3://${s3_bucket}/$S3_KEY" /tmp/frontend.zip --region "${aws_region}"
  rm -rf /usr/share/nginx/html/*
  unzip -o /tmp/frontend.zip -d /usr/share/nginx/html
else
  echo "Frontend aun no compilado (frontend/dist no existe) - se omite el despliegue" >> /var/log/user-data.log
fi

cat > /etc/nginx/conf.d/app.conf <<'NGINXCONF'
upstream backend_api {
%{ for ip in backend_ips ~}
    server ${ip}:${backend_port};
%{ endfor ~}
}

server {
    listen 80;
    root /usr/share/nginx/html;
    index index.html;

    location /api/ {
        # Sin barra final en el destino: nginx reenvia la URI original tal
        # cual (incluido el prefijo /api/), porque el backend monta sus
        # rutas en app.use('/api/tasks', ...), no en '/tasks'.
        proxy_pass http://backend_api;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

    location / {
        try_files $uri $uri/ /index.html;
    }
}
NGINXCONF

systemctl enable nginx
systemctl restart nginx
echo "Inicio de arranque - capa WEB" >> /var/log/user-data.log
