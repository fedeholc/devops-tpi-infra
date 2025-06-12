# Seminario de Actualización dev ops - 3°B <!-- omit in toc -->

## Trabajo Práctico Integrador <!-- omit in toc -->

### Equipo:

- **Federico Holc** (comisión B)
- **Iris Zamora** (comisión A)
- **Martín López** (comisión B)
- **Agustina Kopistinski** (comisión A)

---

# Tabla de Contenidos <!-- omit in toc -->

- [Descripción del proyecto](#descripción-del-proyecto)
- [Proyecto corriendo online](#proyecto-corriendo-online)
- [Repositorios en GitHub](#repositorios-en-github)
  - [Frontend](#frontend)
  - [Backend](#backend)
  - [Infraestructura y documentación](#infraestructura-y-documentación)
- [Integración con Docker Compose](#integración-con-docker-compose)
  - [docker-compose.dev.yml (Desarrollo Local)](#docker-composedevyml-desarrollo-local)
  - [docker-compose.yml (Producción)](#docker-composeyml-producción)
  - [Servicios Comunes](#servicios-comunes)
- [Infraestructura como Código con Terraform](#infraestructura-como-código-con-terraform)
  - [Prerequisitos para Terraform](#prerequisitos-para-terraform)
  - [Configuración de Terraform](#configuración-de-terraform)
  - [Despliegue con Terraform](#despliegue-con-terraform)
  - [Gestión de la infraestructura](#gestión-de-la-infraestructura)
- [Instrucciones para correr la aplicación localmente](#instrucciones-para-correr-la-aplicación-localmente)
  - [Prerrequisitos](#prerrequisitos)
  - [Para correr el entorno de desarrollo local:](#para-correr-el-entorno-de-desarrollo-local)
  - [Para correr localmente utilizando las imágenes de Docker Hub (producción):](#para-correr-localmente-utilizando-las-imágenes-de-docker-hub-producción)
- [Despliegue automático a producción (AWS EC2) con GitHub Actions](#despliegue-automático-a-producción-aws-ec2-con-github-actions)
- [Diagrama del docker-compose funcionando en producción](#diagrama-del-docker-compose-funcionando-en-producción)
- [Diagrama del pipeline del frontend](#diagrama-del-pipeline-del-frontend)
- [Diagrama del pipeline del backend](#diagrama-del-pipeline-del-backend)
- [Capturas del pipeline en ejecución](#capturas-del-pipeline-en-ejecución)
- [Infraestructura mínima con Terraform](#infraestructura-mínima-con-terraform)
  - [Pasos para usar Terraform](#pasos-para-usar-terraform)
  - [Notas](#notas)
- [Conclusiones y roles del equipo](#conclusiones-y-roles-del-equipo)
  - [Conclusiones generales](#conclusiones-generales)
  - [Trabajo en equipo y roles](#trabajo-en-equipo-y-roles)
  - [Dificultades encontradas](#dificultades-encontradas)
  - [Aprendizajes principales](#aprendizajes-principales)

---

## Descripción del proyecto

Este proyecto contiene la aplicación web desarrollada para la materia Prácticas Profesionalizantes IV (PP4), junto con las herramientas necesarias para poder tener un entorno de desarrollo y despliegue automatizado utilizando prácticas de DevOps: contenerización, integración continua, y entega/despliegue continuo (CI/CD).

La aplicación cuenta con un frontend desarrollado en React y un backend desarrollado en Node.js con Express. El frontend consume una API proporcionada por el backend, que a su vez interactúa con una base de datos MySQL.
El frontend y el backend se encuentran en repositorios separados, pero se orquestan juntos utilizando Docker Compose.

## Proyecto corriendo online

Se puede acceder a la aplicación en producción (instancia EC2 en AWS) en el siguiente enlace:

http://18.220.163.22/

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
- Capturas del pipeline en ejecución.
- Archivo docker compose para orquestar los contenedores del frontend, backend, base de datos y servidor Nginx.
- Archivos con scripts de MySql para crear la base de datos y las tablas necesarias.
- Script para automatizar build y despliegue de los contenedores.
- Script de Terraform para crear los recursos en AWS.

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

## Infraestructura como Código con Terraform

Este proyecto incluye una configuración completa de Terraform para automatizar el despliegue de la infraestructura en AWS. Terraform permite crear, modificar y versionar la infraestructura de manera declarativa y reproducible.

### Prerequisitos para Terraform

1. **Terraform instalado** (versión >= 1.0):

   ```bash
   # En Ubuntu/Debian
   wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
   echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
   sudo apt update && sudo apt install terraform
   ```

2. **AWS CLI configurado** con credenciales válidas:

   ```bash
   # Instalar AWS CLI
   curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
   unzip awscliv2.zip
   sudo ./aws/install

   # Configurar credenciales
   aws configure
   ```

3. **Par de claves SSH** para acceso a la instancia:
   ```bash
   # Generar claves SSH si no las tienes
   ssh-keygen -t rsa -b 4096 -C "tu-email@ejemplo.com"
   ```

### Configuración de Terraform

1. **Navegar al directorio de Terraform:**

   ```bash
   cd terraform/
   ```

2. **Crear archivo de variables personalizado:**

   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

3. **Editar `terraform.tfvars` con tus configuraciones:**
   ```hcl
   aws_region = "us-east-2"           # Región de AWS
   environment = "prod"               # Ambiente de despliegue
   instance_type = "t3.micro"         # Tipo de instancia (free tier elegible)
   volume_size = 20                   # Tamaño del disco en GB
   public_key_path = "~/.ssh/id_rsa.pub"  # Ruta a tu clave pública SSH
   project_name = "devops-tpi"        # Nombre del proyecto
   ```

### Despliegue con Terraform

1. **Inicializar Terraform:**

   ```bash
   terraform init
   ```

2. **Revisar el plan de ejecución:**

   ```bash
   terraform plan
   ```

3. **Aplicar la configuración:**

   ```bash
   terraform apply
   ```

   Terraform te mostrará los recursos que va a crear y pedirá confirmación. Escribe `yes` para continuar.

4. **Obtener información de la infraestructura creada:**
   ```bash
   terraform output
   ```

### Gestión de la infraestructura

**Recursos que crea Terraform:**

- **Instancia EC2** con Ubuntu 22.04 LTS
- **Security Group** con puertos necesarios abiertos (22, 80, 3000, 5000, 3307)
- **Elastic IP** para IP pública estática
- **Key Pair** para acceso SSH
- **Configuración automática** de Docker, Docker Compose y la aplicación

**Comandos útiles:**

```bash
# Ver el estado actual de la infraestructura
terraform show

# Actualizar la infraestructura (si cambias archivos .tf)
terraform plan
terraform apply

# Destruir toda la infraestructura
terraform destroy

# Ver outputs (IP pública, comandos SSH, etc.)
terraform output

# Conectarse a la instancia por SSH
terraform output -raw ssh_connection_command
```

**Actualización automática de la aplicación:**

- La instancia incluye un script `/home/ubuntu/app/update-app.sh` que puedes usar para actualizar las imágenes Docker
- El pipeline de CI/CD puede ejecutar este script automáticamente vía SSH

**Monitoreo y logs:**

```bash
# Conectarse a la instancia
ssh -i ~/.ssh/id_rsa ubuntu@$(terraform output -raw instance_public_ip)

# Ver logs de la aplicación
cd /home/ubuntu/app
docker-compose logs -f

# Ver estado de los contenedores
docker-compose ps
```

**Script Helper de Terraform:**

Para facilitar el uso de Terraform, se incluye un script auxiliar `terraform-helper.sh` que automatiza las tareas más comunes:

```bash
# Hacer el script ejecutable (solo la primera vez)
chmod +x terraform-helper.sh

# Comandos disponibles:
./terraform-helper.sh init      # Inicializar Terraform
./terraform-helper.sh plan      # Ver plan de ejecución
./terraform-helper.sh apply     # Desplegar infraestructura
./terraform-helper.sh output    # Ver información de la infraestructura
./terraform-helper.sh ssh       # Conectarse por SSH a la instancia
./terraform-helper.sh status    # Verificar estado de la aplicación
./terraform-helper.sh update    # Actualizar aplicación en la instancia
./terraform-helper.sh logs      # Ver logs de la aplicación
./terraform-helper.sh destroy   # Destruir infraestructura
./terraform-helper.sh help      # Mostrar ayuda
```

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

![diagrama docker-compose](diagrama-docker-compose.png)

## Diagrama del pipeline del frontend

![diagrama pipeline frontend](diagrama-pipeline-frontend.png)

## Diagrama del pipeline del backend

![diagrama pipeline backend](diagrama-pipeline-backend.png)

## Capturas del pipeline en ejecución

- Archivos con las imágenes de las capturas del pipeline del frontend: ver carpeta `capturas-pipeline-frontend/`
- Archivos con las imágenes de las capturas del pipeline del backend: ver carpeta `capturas-pipeline-backend/`

**Pipeline Frontend**

![pipeline front](./capturas-pipeline-frontend/captura-pipeline-frontend-01.png)
![pipeline front](./capturas-pipeline-frontend/captura-pipeline-frontend-02.png)
![pipeline front](./capturas-pipeline-frontend/captura-pipeline-frontend-03.png)
![pipeline front](./capturas-pipeline-frontend/captura-pipeline-frontend-04.png)
![pipeline front](./capturas-pipeline-frontend/captura-pipeline-frontend-05.png)
![pipeline front](./capturas-pipeline-frontend/captura-pipeline-frontend-06.png)
![pipeline front](./capturas-pipeline-frontend/captura-pipeline-frontend-07.png)
![pipeline front](./capturas-pipeline-frontend/captura-pipeline-frontend-08.png)
![pipeline front](./capturas-pipeline-frontend/captura-pipeline-frontend-09.png)

**Pipeline Backend**

![pipeline back](./capturas-pipeline-backend/captura-pipeline-backend-01.png)
![pipeline back](./capturas-pipeline-backend/captura-pipeline-backend-02.png)
![pipeline back](./capturas-pipeline-backend/captura-pipeline-backend-03.png)
![pipeline back](./capturas-pipeline-backend/captura-pipeline-backend-04.png)
![pipeline back](./capturas-pipeline-backend/captura-pipeline-backend-05.png)
![pipeline back](./capturas-pipeline-backend/captura-pipeline-backend-06.png)
![pipeline back](./capturas-pipeline-backend/captura-pipeline-backend-07.png)
![pipeline back](./capturas-pipeline-backend/captura-pipeline-backend-08.png)
![pipeline back](./capturas-pipeline-backend/captura-pipeline-backend-09.png)

## Infraestructura mínima con Terraform

Se incluye un archivo de ejemplo `terraform-ec2.tf` para crear la infraestructura básica necesaria para desplegar este proyecto en AWS usando una instancia EC2 lista para Docker Compose.
En la práctica no lo utilizamos porque estabamos utilizando el plan gratuito de AWS y temíamos que si creabamos otra instancia nos comenzaran a cobrar, pero es un ejemplo funcional que puede ser utilizado para desplegar la aplicación en una instancia EC2.
Este archivo crea una instancia EC2 con Ubuntu 22.04, un grupo de seguridad con los puertos necesarios abiertos (SSH, HTTP, y los puertos utilizados por la aplicación), y un Elastic IP para acceso público.

### Pasos para usar Terraform

1. **Instalar Terraform y AWS CLI**

   - Terraform: https://learn.hashicorp.com/tutorials/terraform/install-cli
   - AWS CLI: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html

2. **Configurar las credenciales de AWS**

   ```bash
   aws configure
   ```

3. **Asegúrarsee de tener una clave SSH pública**

   ```bash
   ls ~/.ssh/id_rsa.pub
   # Si no existe, generar una:
   ssh-keygen -t rsa -b 4096 -C "tu-email@ejemplo.com"
   ```

4. **Inicializar y aplicar Terraform**

   ```bash
   terraform init
   terraform apply
   # Escribir 'yes' cuando lo solicite
   ```

5. **Conectarse a la instancia**

   - Al finalizar, Terraform mostrará la IP pública y el comando SSH para conectarte:
     ```bash
     ssh -i ~/.ssh/id_rsa ubuntu@<IP_PUBLICA>
     ```

6. **Desplegar la aplicación**
   - Una vez conectado, se puede clonar este repositorio y levantar los servicios:
     ```bash
     git clone <URL_DEL_REPO> app
     cd app
     docker-compose up -d
     ```

### Notas

- El archivo `terraform-ec2.tf` crea:
  - Una instancia EC2 Ubuntu 22.04
  - Un grupo de seguridad con puertos abiertos para SSH (22), HTTP (80), y los puertos usados por la app (3000, 5000, 3307)
  - Un Elastic IP
  - Instala Docker y Docker Compose automáticamente
- Se pueden modificar los valores de las variables al inicio del archivo para personalizar la región, tipo de instancia, nombre de clave, etc.
- Para destruir la infraestructura:
  ```bash
  terraform destroy
  ```

## Conclusiones y roles del equipo

### Conclusiones generales

El desarrollo de este trabajo práctico integrador nos permitió aplicar en un proyecto real los conceptos fundamentales de DevOps, desde la contenerización de aplicaciones hasta la automatización del despliegue en la nube. Pudimos experimentar de primera mano cómo las herramientas y buenas prácticas de DevOps facilitan la integración y entrega continua, mejorando la calidad y la velocidad del desarrollo.

### Trabajo en equipo y roles

No hicimos una división formal de roles. Comenzamos generando el esqueleto del proyecto de manera colaborativa, podría decirse que en vivo y en directo mientras estabamos reunidos. Luego hicimos una lista de tareas pendientes y cada uno fue tomando las que podía ir haciendo. A medida que avanzábamos, nos ayudábamos mutuamente con las dudas y problemas que iban surgiendo.
Algunos de los roles y tareas que asumimos fueron:

- **Federico Holc**: configuración de Docker Compose, para modo producción y modo desarrollo.
- **Iris Zamora**: implementación de GitHub Actions para el backend y frontend,
- **Agustina Kopistinski**: configuración de la base de datos MySQL, pruebas y validación de la aplicación.
- **Martín López**: configuración de la infraestructura en AWS.

### Dificultades encontradas

Durante el desarrollo del trabajo nos enfrentamos a varios desafíos:

- **Configuración de Docker Compose:** al principio, tuvimos dificultades para definir correctamente los servicios y las redes en Docker Compose, especialmente para lograr que el backend se conectara correctamente a la base de datos MySQL y que Nginx funcionara como proxy reverso.
- **Despliegue en AWS:** la automatización del despliegue en AWS y la configuración de la instancia EC2 requirió investigar sobre permisos, claves SSH y reglas de seguridad.
- **Integración de GitHub Actions:** configurar correctamente los pipelines de CI/CD para que construyeran las imágenes, las subieran a Docker Hub y luego actualizaran la instancia en AWS fue un proceso de prueba y error.
- **Coordinación del equipo:** como trabajamos en paralelo en diferentes partes (frontend, backend, infraestructura), fue necesario coordinar bien los cambios y mantener una comunicación constante para evitar conflictos y asegurar la integración de todos los componentes.

### Aprendizajes principales

- **Automatización:** Aprendimos la importancia de automatizar tanto el despliegue como la infraestructura, lo que reduce errores y acelera la entrega de nuevas versiones.
- **Contenerización:** Docker nos facilitó la portabilidad y la replicación del entorno de desarrollo y producción.
- **CI/CD:** Implementar pipelines de integración y entrega continua nos ayudó a detectar errores rápidamente y a mantener la calidad del código.
- **Trabajo colaborativo:** La experiencia de trabajar en equipo, usando Git y GitHub, nos enseñó la importancia de las buenas prácticas de colaboración y comunicación.

---
