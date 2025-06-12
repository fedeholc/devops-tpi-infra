#!/bin/bash

# Script de inicialización para la instancia EC2
# Este script instala Docker, Docker Compose y configura la aplicación

set -e

# Actualizar el sistema
apt-get update
apt-get upgrade -y

# Instalar dependencias
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    unzip

# Instalar Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io

# Instalar Docker Compose
DOCKER_COMPOSE_VERSION="2.21.0"
curl -L "https://github.com/docker/compose/releases/download/v$${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Crear enlace simbólico para compatibilidad
ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose

# Añadir usuario ubuntu al grupo docker
usermod -aG docker ubuntu

# Habilitar Docker para que inicie automáticamente
systemctl enable docker
systemctl start docker

# Crear directorio para la aplicación
mkdir -p /home/ubuntu/app
mkdir -p /home/ubuntu/app/sql
chown -R ubuntu:ubuntu /home/ubuntu/app

# Crear archivos de configuración desde las variables de Terraform
echo "${docker_compose_content}" | base64 -d > /home/ubuntu/app/docker-compose.yml
echo "${nginx_conf_content}" | base64 -d > /home/ubuntu/app/nginx.conf
echo "${db_init_content}" | base64 -d > /home/ubuntu/app/sql/db-init.sql
echo "${db_schema_content}" | base64 -d > /home/ubuntu/app/sql/db-schema.sql
echo "${db_seeds_content}" | base64 -d > /home/ubuntu/app/sql/db-seeds.sql

# Ajustar permisos
chown -R ubuntu:ubuntu /home/ubuntu/app

# Cambiar al directorio de la aplicación y iniciar los contenedores
cd /home/ubuntu/app

# Esperar a que Docker esté completamente iniciado
sleep 30

# Descargar las imágenes más recientes
docker-compose pull

# Iniciar la aplicación
docker-compose up -d

# Crear script de actualización para CI/CD
cat > /home/ubuntu/app/update-app.sh << 'EOF'
#!/bin/bash
cd /home/ubuntu/app
docker-compose pull
docker-compose up -d --remove-orphans
docker system prune -f
EOF

chmod +x /home/ubuntu/app/update-app.sh
chown ubuntu:ubuntu /home/ubuntu/app/update-app.sh

# Crear servicio systemd para la aplicación (opcional)
cat > /etc/systemd/system/devops-tpi.service << 'EOF'
[Unit]
Description=DevOps TPI Application
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/home/ubuntu/app
ExecStart=/usr/local/bin/docker-compose up -d
ExecStop=/usr/local/bin/docker-compose down
TimeoutStartSec=0
User=ubuntu
Group=ubuntu

[Install]
WantedBy=multi-user.target
EOF

systemctl enable devops-tpi.service

# Log de finalización
echo "Instalación completada $(date)" >> /var/log/user-data.log
