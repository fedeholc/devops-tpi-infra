# Terraform Infrastructure - DevOps TPI

Este directorio contiene la configuración de Terraform para automatizar el despliegue de la infraestructura del proyecto DevOps TPI en AWS.

## Estructura de archivos

```
terraform/
├── main.tf                    # Configuración principal de recursos AWS
├── variables.tf               # Definición de variables
├── outputs.tf                 # Outputs útiles después del despliegue
├── user_data.sh              # Script de inicialización de la instancia EC2
├── terraform.tfvars.example  # Archivo de ejemplo para variables
├── .gitignore                # Archivos a ignorar en Git
└── README.md                 # Esta documentación
```

## Recursos que se crean

- **EC2 Instance**: Servidor Ubuntu 22.04 LTS con Docker preinstalado
- **Security Group**: Reglas de firewall para puertos 22, 80, 3000, 5000, 3307
- **Elastic IP**: IP pública estática para la instancia
- **Key Pair**: Par de claves SSH para acceso seguro
- **EBS Volume**: Volumen encriptado de 20GB (configurable)

## Configuración inicial

1. **Copiar archivo de variables:**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. **Editar `terraform.tfvars` con tus valores:**
   ```hcl
   aws_region      = "us-east-2"
   environment     = "prod"
   instance_type   = "t3.micro"
   volume_size     = 20
   public_key_path = "~/.ssh/id_rsa.pub"
   project_name    = "devops-tpi"
   ```

## Comandos principales

```bash
# Inicializar Terraform
terraform init

# Ver qué se va a crear/modificar
terraform plan

# Aplicar cambios
terraform apply

# Ver información de la infraestructura
terraform output

# Destruir infraestructura
terraform destroy
```

## Outputs disponibles

Después del despliegue exitoso, puedes obtener:

- `instance_public_ip`: IP pública de la instancia
- `ssh_connection_command`: Comando para conectarse por SSH
- `application_url`: URL de la aplicación web
- `instance_id`: ID de la instancia EC2
- `security_group_id`: ID del Security Group

## Configuración automática

El script `user_data.sh` se ejecuta automáticamente al crear la instancia y:

1. Instala Docker y Docker Compose
2. Configura el usuario ubuntu en el grupo docker
3. Crea la estructura de directorios necesaria
4. Copia los archivos de configuración (docker-compose.yml, nginx.conf, SQL scripts)
5. Inicia la aplicación automáticamente
6. Crea un script de actualización para CI/CD

## Integración con CI/CD

La instancia incluye un script `/home/ubuntu/app/update-app.sh` que puede ser ejecutado desde tus pipelines de GitHub Actions para actualizar la aplicación:

```bash
# En tu workflow de GitHub Actions
- name: Deploy to EC2
  run: |
    ssh -i ${{ secrets.SSH_PRIVATE_KEY }} ubuntu@${{ secrets.EC2_IP }} \
    "cd /home/ubuntu/app && ./update-app.sh"
```

## Seguridad

- El Security Group solo permite tráfico en puertos específicos
- El volumen EBS está encriptado
- Se recomienda usar claves SSH fuertes
- Las credenciales de AWS deben manejarse de forma segura

## Costos estimados

Para una instancia `t3.micro` en free tier:
- Instancia EC2: Gratis por 12 meses (750 horas/mes)
- Elastic IP: Gratis mientras esté asociada a una instancia en ejecución
- EBS (20GB): ~$2 USD/mes
- Transferencia de datos: Primer 1GB/mes gratis

## Troubleshooting

### Error de credenciales AWS
```bash
# Verificar configuración de AWS CLI
aws configure list
aws sts get-caller-identity
```

### Error de clave SSH
```bash
# Verificar que existe la clave pública
ls -la ~/.ssh/id_rsa.pub

# Generar nueva clave si es necesario
ssh-keygen -t rsa -b 4096 -C "tu-email@ejemplo.com"
```

### La aplicación no inicia
```bash
# Conectarse a la instancia y verificar logs
ssh -i ~/.ssh/id_rsa ubuntu@$(terraform output -raw instance_public_ip)
cd /home/ubuntu/app
docker-compose logs -f
```

### Recrear la infraestructura
```bash
# Si algo sale mal, puedes destruir y recrear
terraform destroy -auto-approve
terraform apply -auto-approve
```

## Variables disponibles

| Variable | Descripción | Valor por defecto |
|----------|-------------|-------------------|
| `aws_region` | Región de AWS | `us-east-2` |
| `environment` | Ambiente de despliegue | `prod` |
| `instance_type` | Tipo de instancia EC2 | `t3.micro` |
| `volume_size` | Tamaño del volumen EBS en GB | `20` |
| `public_key_path` | Ruta a la clave pública SSH | `~/.ssh/id_rsa.pub` |
| `project_name` | Nombre del proyecto | `devops-tpi` |
