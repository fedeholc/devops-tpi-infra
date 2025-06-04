# Docker Compose Configuration Guide

Este directorio contiene configuraciones de Docker Compose para diferentes entornos:

## Archivos disponibles:

### `docker-compose.yml` (Producción - por defecto)

- Usa imágenes de Docker Hub
- Para deployment en servidores de producción
- **Uso:** `docker-compose up`

### `docker-compose.dev.yml` (Desarrollo con build local)

- Construye las imágenes desde carpetas locales
- Monta volúmenes para desarrollo
- **Uso:** `docker-compose -f docker-compose.dev.yml up`

## Comandos útiles:

```bash
# Desarrollo con build local
docker-compose -f docker-compose.dev.yml up

# Producción (o probar imágenes)
docker-compose up

# Con rebuild forzado (desarrollo)
docker-compose -f docker-compose.dev.yml up --build

# En background
docker-compose -f docker-compose.dev.yml up -d

# Ver logs
docker-compose -f docker-compose.dev.yml logs -f

# Parar servicios
docker-compose -f docker-compose.dev.yml down
```

## Flujo de trabajo recomendado:

1. **Desarrollo diario:** Usa `docker-compose.dev.yml`
2. **Pruebas con imágenes:** Usa `docker-compose.yml`
3. **En servidor:** Usa `docker-compose.yml`
