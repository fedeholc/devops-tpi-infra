# Seminario de Actualización dev ops - 3°B <!-- omit in toc -->

## Trabajo Práctico Integrador <!-- omit in toc -->

### Equipo:

- **Federico Holc** (comisión B)
- **Iris Zamora** (comisión A)
- **Martín López** (comisión B)
- **Agustina Kopistinski** (comisión A)

Entregables

1. Repositorio en GitHub/GitLab con:
   • Código fuente de la app.
   • Dockerfile y docker-compose.
   • Scripts de CI/CD.
   • Capturas del pipeline en ejecución. //TODO: pendiente

2. Documento PDF o README con:
   • Descripción del proyecto.
   • Instrucciones para correrlo localmente con Docker.
   • Diagrama del pipeline DevOps.  
   • Conclusiones y roles del equipo. //TODO: pendiente

//TODO faltarían los puntos opcionales:

6. Infraestructura como Código (IaC) – Opcional avanzado
   ●​ Usar Terraform o Ansible para provisionar infraestructura.
7. Monitoreo – Opcional
   ●​ Agregar Prometheus + Grafana, o integración con logs.

---

# Tabla de Contenidos <!-- omit in toc -->

- [Descripción del proyecto](#descripción-del-proyecto)
- [Repositorios en GitHub](#repositorios-en-github)
  - [Frontend](#frontend)
  - [Backend](#backend)
  - [Infraestructura y documentación](#infraestructura-y-documentación)
- [Integración con Docker Compose](#integración-con-docker-compose)
  - [docker-compose.dev.yml (Desarrollo Local)](#docker-composedevyml-desarrollo-local)
  - [docker-compose.yml (Producción)](#docker-composeyml-producción)
  - [Servicios Comunes](#servicios-comunes)
- [Instrucciones para correr la aplicación localmente](#instrucciones-para-correr-la-aplicación-localmente)
  - [Prerrequisitos](#prerrequisitos)
  - [Para correr el entorno de desarrollo local:](#para-correr-el-entorno-de-desarrollo-local)
  - [Para correr localmente utilizando las imágenes de Docker Hub (producción):](#para-correr-localmente-utilizando-las-imágenes-de-docker-hub-producción)
- [Despliegue automático a producción (AWS EC2) con GitHub Actions](#despliegue-automático-a-producción-aws-ec2-con-github-actions)
- [Diagrama del docker-compose funcionando en producción](#diagrama-del-docker-compose-funcionando-en-producción)
- [Diagrama del pipeline del frontend](#diagrama-del-pipeline-del-frontend)
- [Diagrama del pipeline del backend](#diagrama-del-pipeline-del-backend)

---

## Descripción del proyecto

Este proyecto contiene la aplicación web desarrollada para la materia Prácticas Profesionalizantes IV (PP4), junto con las herramientas necesarias para poder tener un entorno de desarrollo y despliegue automatizado utilizando prácticas de DevOps: contenerización, integración continua, y entega/despliegue continuo (CI/CD).

La aplicación cuenta con un frontend desarrollado en React y un backend desarrollado en Node.js con Express. El frontend consume una API proporcionada por el backend, que a su vez interactúa con una base de datos MySQL.
El frontend y el backend se encuentran en repositorios separados, pero se orquestan juntos utilizando Docker Compose.

## Repositorios en GitHub

### Frontend

https://github.com/fedeholc/devops-tpi-front

Contiene el frontend de la aplicación, desarrollado con React. Incluye el Dockerfile y los scripts de CI/CD (en GitHub Actions) para su despliegue automático.

### Backend

https://github.com/fedeholc/devops-tpi-backend

Contiene el backend de la aplicación, desarrollado con Node.js y Express. Incluye el Dockerfile y los scripts de CI/CD (en GitHub Actions) para su despliegue automático.

### Infraestructura y documentación

https://github.com/fedeholc/devops-tpi-infra

Contiene:

- Documentación del proyecto.
- Diagrama del docker-compose funcionando en producción.
- Diagrama del pipeline del frontend.
- Diagrama del pipeline del backend.
- Capturas del pipeline en ejecución. **PENDIENTE**
- Archivo docker compose para orquestar los contenedores del frontend, backend, base de datos y servidor Nginx.
- Archivos con scripts de MySql para crear la base de datos y las tablas necesarias.
- Script para automatizar build y despliegue de los contenedores.
- Scripts de Terraform para crear los recursos en AWS. **PENDIENTE**

## Integración con Docker Compose

Además de los repositorios del frontend y backend, tenemos el repositorio de infraestructura que contiene los archivos de docker-compose para orquestar los contenedores del frontend, backend, base de datos y servidor Nginx.
Decidimos utilizar dos archivos distintos de docker-compose, uno para desarrollo local y otro para producción. La diferencia principal entre ambos que en el entorno de desarrollo se levantan los servicios desde el código fuente local, mientras que en producción se utilizan imágenes pre-construidas.

### docker-compose.dev.yml (Desarrollo Local)

Este archivo está configurado para el desarrollo local:

- **Frontend**: Se construye desde la carpeta `../frontend` usando `build: ../frontend`
- **Backend**: Se construye desde la carpeta `../backend` usando `build: ../backend`
- **MySQL**: Base de datos con inicialización automática usando scripts SQL
- **Nginx**: Servidor web como proxy reverso
- **Características específicas**:
  - El backend monta el archivo `.env` local para configuración
  - Expone puertos individuales para cada servicio (3000 para frontend, 5000 para backend)

### docker-compose.yml (Producción)

Este archivo está configurado para el entorno de producción:

- **Frontend**: Usa la imagen `fedeholc/pp4-frontend:latest` desde Docker Hub
- **Backend**: Usa la imagen `fedeholc/pp4-backend:latest` desde Docker Hub
- **MySQL**: Misma configuración que desarrollo con inicialización automática
- **Nginx**: Servidor web como proxy reverso
- **Características específicas**:
  - No requiere código fuente local
  - Utiliza imágenes desde Docker Hub
  - Variables de entorno definidas directamente en el compose

### Servicios Comunes

Ambos archivos comparten la siguiente arquitectura:

- **Nginx (Puerto 80)**: Actúa como proxy reverso y balanceador de carga
- **MySQL (Puerto 3307)**: Base de datos con inicialización automática mediante scripts SQL ubicados en `./sql/`
- **Volúmenes persistentes**: `mysql-data` para mantener los datos de la base de datos
- **Red interna**: Todos los servicios se comunican a través de la red Docker interna

## Instrucciones para correr la aplicación localmente

### Prerrequisitos

- Docker y Docker Compose instalados
- Git para clonar los repositorios

### Para correr el entorno de desarrollo local:

1. **Clonar los repositorios necesarios:**

   ```bash
   # Crear directorio padre
   mkdir devops-tpi && cd devops-tpi

   # Clonar los tres repositorios
   git clone https://github.com/fedeholc/devops-tpi-front frontend
   git clone https://github.com/fedeholc/devops-tpi-backend backend
   git clone https://github.com/fedeholc/devops-tpi-infra infra
   ```

2. **Configurar el archivo .env del backend:**

   ```bash
   cd backend
   cp .env.example .env
   # Editar .env con las configuraciones necesarias
   ```

3. **Ejecutar el entorno de desarrollo:**

   ```bash
   cd ../infra
   docker-compose -f docker-compose.dev.yml up --build
   ```

4. **Acceder a la aplicación:**
   - Frontend: http://localhost:3000
   - Backend API: http://localhost:5000
   - Base de datos MySQL: localhost:3307
   - Aplicación completa (vía Nginx): http://localhost

### Para correr localmente utilizando las imágenes de Docker Hub (producción):

1. **Clonar solo el repositorio de infraestructura:**

   ```bash
   git clone https://github.com/fedeholc/devops-tpi-infra
   cd devops-tpi-infra
   ```

2. **Ejecutar el entorno de producción:**

   ```bash
   docker-compose up -d
   ```

3. **Verificar que los servicios estén corriendo:**

   ```bash
   docker-compose ps
   ```

4. **Acceder a la aplicación:**
   - Aplicación completa: http://localhost

## Despliegue automático a producción (AWS EC2) con GitHub Actions

Decidimos utilizar AWS para desplegar la aplicación en producción ya que ofrece una instancia EC2 gratuita durante un mes, en la cual es posible correr los contenedores de Docker y docker-compose.

El despliegue automático a producción se realiza mediante GitHub Actions (frontend y backend tienen sus respectivos archivos llamados `ci-cd.yml`).
Los workflows se activan al hacer push a la rama `main` de los repositorios. El proceso incluye:

1. **Build Test**: verifica que la aplicación compile correctamente. Primero corre los tests utilizando `vitest`y luego realiza el build de producción.
2. **Build and Push**: construye la imagen Docker y la sube a Docker Hub.
3. **Deploy**: se conecta a la instancia EC2 mediante SSH y actualiza los contenedores con las nuevas imágenes.
4. **Infraestructura en EC2**: utiliza docker-compose para levantar los servicios de Nginx, frontend, backend y MySQL.
5. **Servicios en ejecución**: Nginx actúa como proxy reverso, y MySQL se inicializa con los scripts necesarios.
6. **Flujo de datos en producción:** el frontend se comunica con el backend a través de Nginx, y el backend interactúa con la base de datos MySQL.

## Diagrama del docker-compose funcionando en producción

![alt text](diagrama-docker-compose.png)

## Diagrama del pipeline del frontend

![alt text](diagrama-pipeline-frontend.png)

## Diagrama del pipeline del backend

![alt text](diagrama-pipeline-backend.png)
