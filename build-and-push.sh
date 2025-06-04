#!/bin/bash

# Script para construir y subir imágenes a Docker Hub
# Uso: ./build-and-push.sh [version]

DOCKERHUB_USERNAME="fedeholc"
VERSION=${1:-"latest"}

echo "🔑 Verificando login en Docker Hub..."
if ! sudo docker info | grep -q "Username"; then
    echo "⚠️  No estás logueado en Docker Hub. Ejecutando login..."
    sudo docker login
fi

echo "🏗️ Construyendo imagen del backend..."
cd ../backend
sudo docker build -t $DOCKERHUB_USERNAME/pp4-backend:$VERSION .

if [ $? -eq 0 ]; then
    echo "📤 Subiendo imagen del backend..."
    sudo docker push $DOCKERHUB_USERNAME/pp4-backend:$VERSION
else
    echo "❌ Error al construir la imagen del backend"
    exit 1
fi

echo "🏗️ Construyendo imagen del frontend..."
cd ../frontend
sudo docker build -t $DOCKERHUB_USERNAME/pp4-frontend:$VERSION .

if [ $? -eq 0 ]; then
    echo "📤 Subiendo imagen del frontend..."
    sudo docker push $DOCKERHUB_USERNAME/pp4-frontend:$VERSION
else
    echo "❌ Error al construir la imagen del frontend"
    exit 1
fi

echo "✅ ¡Todas las imágenes han sido subidas exitosamente!"
echo "📋 Imágenes creadas:"
echo "   - $DOCKERHUB_USERNAME/pp4-backend:$VERSION"
echo "   - $DOCKERHUB_USERNAME/pp4-frontend:$VERSION"

# Volver al directorio infra
cd ../infra
