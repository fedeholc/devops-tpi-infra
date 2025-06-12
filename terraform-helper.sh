#!/bin/bash

# Script auxiliar para gestionar la infraestructura con Terraform
# Uso: ./terraform-helper.sh [init|plan|apply|destroy|output|ssh]

set -e

TERRAFORM_DIR="terraform"
TFVARS_FILE="$TERRAFORM_DIR/terraform.tfvars"
TFVARS_EXAMPLE="$TERRAFORM_DIR/terraform.tfvars.example"

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para mostrar ayuda
show_help() {
    echo -e "${BLUE}DevOps TPI - Terraform Helper Script${NC}"
    echo ""
    echo "Uso: $0 [comando]"
    echo ""
    echo "Comandos disponibles:"
    echo "  init     - Inicializar Terraform"
    echo "  plan     - Mostrar plan de ejecución"
    echo "  apply    - Aplicar cambios de infraestructura"
    echo "  destroy  - Destruir toda la infraestructura"
    echo "  output   - Mostrar outputs de Terraform"
    echo "  ssh      - Conectarse por SSH a la instancia"
    echo "  status   - Verificar estado de la aplicación"
    echo "  update   - Actualizar aplicación en la instancia"
    echo "  logs     - Ver logs de la aplicación"
    echo "  help     - Mostrar esta ayuda"
    echo ""
}

# Función para verificar prerequisitos
check_prerequisites() {
    echo -e "${BLUE}Verificando prerequisitos...${NC}"
    
    # Verificar Terraform
    if ! command -v terraform &> /dev/null; then
        echo -e "${RED}Error: Terraform no está instalado${NC}"
        exit 1
    fi
    
    # Verificar AWS CLI
    if ! command -v aws &> /dev/null; then
        echo -e "${RED}Error: AWS CLI no está instalado${NC}"
        exit 1
    fi
    
    # Verificar credenciales AWS
    if ! aws sts get-caller-identity &> /dev/null; then
        echo -e "${RED}Error: Credenciales AWS no configuradas${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✓ Prerequisitos verificados${NC}"
}

# Función para configurar terraform.tfvars
setup_tfvars() {
    if [[ ! -f "$TFVARS_FILE" ]]; then
        echo -e "${YELLOW}Archivo terraform.tfvars no encontrado${NC}"
        echo -e "${BLUE}Creando desde el ejemplo...${NC}"
        
        if [[ -f "$TFVARS_EXAMPLE" ]]; then
            cp "$TFVARS_EXAMPLE" "$TFVARS_FILE"
            echo -e "${GREEN}✓ Archivo terraform.tfvars creado${NC}"
            echo -e "${YELLOW}⚠️  Por favor, edita terraform.tfvars con tus configuraciones antes de continuar${NC}"
            echo -e "${BLUE}Abriendo archivo para edición...${NC}"
            ${EDITOR:-nano} "$TFVARS_FILE"
        else
            echo -e "${RED}Error: Archivo terraform.tfvars.example no encontrado${NC}"
            exit 1
        fi
    fi
}

# Función para ejecutar comandos Terraform
run_terraform() {
    local command=$1
    
    cd "$TERRAFORM_DIR"
    
    case $command in
        "init")
            echo -e "${BLUE}Inicializando Terraform...${NC}"
            terraform init
            ;;
        "plan")
            echo -e "${BLUE}Generando plan de ejecución...${NC}"
            terraform plan
            ;;
        "apply")
            echo -e "${BLUE}Aplicando configuración de infraestructura...${NC}"
            terraform apply
            ;;
        "destroy")
            echo -e "${RED}⚠️  ADVERTENCIA: Esto destruirá TODA la infraestructura${NC}"
            read -p "¿Estás seguro? (escribe 'yes' para confirmar): " confirm
            if [[ $confirm == "yes" ]]; then
                terraform destroy
            else
                echo "Operación cancelada"
            fi
            ;;
        "output")
            echo -e "${BLUE}Mostrando outputs de Terraform...${NC}"
            terraform output
            ;;
        *)
            echo -e "${RED}Comando Terraform no reconocido: $command${NC}"
            exit 1
            ;;
    esac
    
    cd ..
}

# Función para conectarse por SSH
ssh_connect() {
    echo -e "${BLUE}Conectándose a la instancia...${NC}"
    cd "$TERRAFORM_DIR"
    
    if terraform state list | grep -q "aws_instance.devops_tpi_server"; then
        SSH_COMMAND=$(terraform output -raw ssh_connection_command 2>/dev/null)
        if [[ $? -eq 0 ]]; then
            echo -e "${GREEN}Ejecutando: $SSH_COMMAND${NC}"
            eval "$SSH_COMMAND"
        else
            echo -e "${RED}Error: No se pudo obtener el comando SSH${NC}"
            exit 1
        fi
    else
        echo -e "${RED}Error: No hay instancia desplegada${NC}"
        exit 1
    fi
    
    cd ..
}

# Función para verificar estado de la aplicación
check_status() {
    echo -e "${BLUE}Verificando estado de la aplicación...${NC}"
    cd "$TERRAFORM_DIR"
    
    if terraform state list | grep -q "aws_instance.devops_tpi_server"; then
        INSTANCE_IP=$(terraform output -raw instance_public_ip 2>/dev/null)
        if [[ $? -eq 0 ]]; then
            echo -e "${BLUE}IP de la instancia: $INSTANCE_IP${NC}"
            echo -e "${BLUE}URL de la aplicación: http://$INSTANCE_IP${NC}"
            
            # Verificar si la aplicación responde
            if curl -s --connect-timeout 5 "http://$INSTANCE_IP" > /dev/null; then
                echo -e "${GREEN}✓ Aplicación respondiendo correctamente${NC}"
            else
                echo -e "${YELLOW}⚠️  Aplicación no responde (puede estar iniciando)${NC}"
            fi
        else
            echo -e "${RED}Error: No se pudo obtener la IP de la instancia${NC}"
        fi
    else
        echo -e "${RED}Error: No hay instancia desplegada${NC}"
    fi
    
    cd ..
}

# Función para actualizar la aplicación
update_app() {
    echo -e "${BLUE}Actualizando aplicación en la instancia...${NC}"
    cd "$TERRAFORM_DIR"
    
    if terraform state list | grep -q "aws_instance.devops_tpi_server"; then
        INSTANCE_IP=$(terraform output -raw instance_public_ip 2>/dev/null)
        if [[ $? -eq 0 ]]; then
            echo -e "${BLUE}Ejecutando script de actualización...${NC}"
            ssh -i ~/.ssh/id_rsa ubuntu@$INSTANCE_IP "cd /home/ubuntu/app && ./update-app.sh"
            echo -e "${GREEN}✓ Aplicación actualizada${NC}"
        else
            echo -e "${RED}Error: No se pudo obtener la IP de la instancia${NC}"
        fi
    else
        echo -e "${RED}Error: No hay instancia desplegada${NC}"
    fi
    
    cd ..
}

# Función para ver logs
view_logs() {
    echo -e "${BLUE}Mostrando logs de la aplicación...${NC}"
    cd "$TERRAFORM_DIR"
    
    if terraform state list | grep -q "aws_instance.devops_tpi_server"; then
        INSTANCE_IP=$(terraform output -raw instance_public_ip 2>/dev/null)
        if [[ $? -eq 0 ]]; then
            ssh -i ~/.ssh/id_rsa ubuntu@$INSTANCE_IP "cd /home/ubuntu/app && docker-compose logs -f --tail=50"
        else
            echo -e "${RED}Error: No se pudo obtener la IP de la instancia${NC}"
        fi
    else
        echo -e "${RED}Error: No hay instancia desplegada${NC}"
    fi
    
    cd ..
}

# Script principal
main() {
    local command=${1:-help}
    
    case $command in
        "help"|"-h"|"--help")
            show_help
            ;;
        "init"|"plan"|"apply"|"destroy"|"output")
            check_prerequisites
            setup_tfvars
            run_terraform "$command"
            ;;
        "ssh")
            ssh_connect
            ;;
        "status")
            check_status
            ;;
        "update")
            update_app
            ;;
        "logs")
            view_logs
            ;;
        *)
            echo -e "${RED}Comando no reconocido: $command${NC}"
            show_help
            exit 1
            ;;
    esac
}

# Ejecutar script principal
main "$@"
