#!/bin/bash

# ==========================================
# Script para renovar certificados SSL (Docker a Docker)
# ==========================================

NGINX_CONTAINER_NAME="mi_nginx" #nombre del contenedor de Nginx
LOG_FILE="/var/log/certbot_renewal.log"

echo "========================================" >> "$LOG_FILE"
echo "Iniciando proceso de renovación: $(date)" >> "$LOG_FILE"

# Renovar certs 
echo "Ejecutando certbot renew vía Docker..." >> "$LOG_FILE"
docker run --rm \
  -v "/etc/letsencrypt:/etc/letsencrypt" \
  -v "/var/lib/letsencrypt:/var/lib/letsencrypt" \
  -v "/var/www/certbot:/var/www/certbot" \
  certbot/certbot renew >> "$LOG_FILE" 2>&1

CERTBOT_STATUS=$?

if [ $CERTBOT_STATUS -eq 0 ]; then
    echo "Renovación evaluada/exitosa. Recargando Nginx en caliente..." >> "$LOG_FILE"
    # Recargar Nginx indicando su nombre de contenedor
    docker exec "$NGINX_CONTAINER_NAME" nginx -s reload >> "$LOG_FILE" 2>&1
    echo "Nginx recargado con éxito." >> "$LOG_FILE"
else
    echo "ATENCIÓN: Hubo un error al intentar renovar el certificado." >> "$LOG_FILE"
fi

echo "Proceso finalizado: $(date)" >> "$LOG_FILE"
echo "========================================" >> "$LOG_FILE"