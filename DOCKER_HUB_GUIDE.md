# Guía para crear y subir imágenes a Docker Hub

## Prerequisitos

1. **Cuenta en Docker Hub:** Asegúrate de tener una cuenta en [Docker Hub](https://hub.docker.com)
2. **Docker instalado:** Docker debe estar instalado y corriendo en tu sistema
3. **Login en Docker Hub:** Ejecuta el login antes de pushear

```bash
docker login
```

## Construcción y subida de imágenes

### 1. Backend

```bash
# Navegar al directorio del backend
cd backend

# Construir la imagen
docker build -t username/pp4-backend:latest .

# Opcional: Crear tag con versión específica
docker tag username/pp4-backend:latest username/pp4-backend:v1.0.0

# Subir la imagen a Docker Hub
docker push username/pp4-backend:latest

# Opcional: Subir también la versión específica
docker push username/pp4-backend:v1.0.0
```

### 2. Frontend

```bash
# Navegar al directorio del frontend
cd ../frontend

# Construir la imagen
docker build -t username/pp4-frontend:latest .

# Opcional: Crear tag con versión específica
docker tag username/pp4-frontend:latest username/pp4-frontend:v1.0.0

# Subir la imagen a Docker Hub
docker push username/pp4-frontend:latest

# Opcional: Subir también la versión específica
docker push username/pp4-frontend:v1.0.0
```

## Script automatizado

Puedes crear un script para automatizar todo el proceso:

```bash
#!/bin/bash

# Script para construir y subir imágenes a Docker Hub

DOCKERHUB_USERNAME="username"
VERSION="latest"

echo "🔑 Haciendo login en Docker Hub..."
docker login

echo "🏗️ Construyendo imagen del backend..."
cd backend
docker build -t $DOCKERHUB_USERNAME/pp4-backend:$VERSION .

echo "📤 Subiendo imagen del backend..."
docker push $DOCKERHUB_USERNAME/pp4-backend:$VERSION

echo "🏗️ Construyendo imagen del frontend..."
cd ../frontend
docker build -t $DOCKERHUB_USERNAME/pp4-frontend:$VERSION .

echo "📤 Subiendo imagen del frontend..."
docker push $DOCKERHUB_USERNAME/pp4-frontend:$VERSION

echo "✅ ¡Todas las imágenes han sido subidas exitosamente!"

# Volver al directorio raíz
cd ..
```

## Comandos útiles

```bash
# Ver imágenes locales
docker images

# Eliminar imagen local
docker rmi username/pp4-backend:latest

# Ver información de una imagen
docker inspect username/pp4-backend:latest

# Descargar imagen desde Docker Hub
docker pull username/pp4-backend:latest

# Ejecutar imagen localmente para probar
docker run -p 5000:5000 username/pp4-backend:latest
docker run -p 3000:80 username/pp4-frontend:latest
```

## Notas importantes

1. **Reemplaza `username`** con tu nombre de usuario real de Docker Hub
2. **Variables de entorno:** El backend NO incluye el archivo `.env` en la imagen, usa las variables de entorno del docker-compose
3. **Configuración de producción:** En producción, el backend toma la configuración de DB desde las variables de entorno definidas en docker-compose.yml
4. **Tamaño de imagen:** Se usa `.dockerignore` para excluir archivos innecesarios
5. **Versiones:** Es buena práctica usar tags de versión además de `latest`
6. **CI/CD:** Considera automatizar este proceso con GitHub Actions

## Variables de entorno en producción

El backend está configurado para leer variables de entorno directamente, no el archivo `.env`.
Las variables se definen en `docker-compose.yml`:

```yaml
backend:
  image: username/pp4-backend:latest
  environment:
    - DB_HOST=mysql # En lugar de localhost
    - DB_USER=root
    - DB_PASSWORD=1234FH80*
    - DB_NAME=pp4
    - DB_PORT=3306
    - ADDRESS=backend # En lugar de localhost
```

## Archivos importantes

- **`.dockerignore`** en backend: Excluye el `.env` y otros archivos innecesarios
- **Variables de entorno**: Definidas en docker-compose para cada entorno

## Verificación

Después de subir las imágenes, puedes verificar que estén disponibles:

- Ve a https://hub.docker.com/u/username
- Deberías ver `pp4-backend` y `pp4-frontend` en tu lista de repositorios

## Troubleshooting

- **Error de permisos:** Asegúrate de estar logueado con `docker login`
- **Imagen muy grande:** Revisa tu `.dockerignore` y optimiza el Dockerfile
- **Error de build:** Verifica que todos los archivos necesarios estén presentes
