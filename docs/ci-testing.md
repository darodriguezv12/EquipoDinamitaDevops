# Pruebas Unitarias

Este proyecto incluye un conjunto de pruebas unitarias para validar el comportamiento de los endpoints principales de la API REST.

## Objetivo

Validar rapidamente que los endpoints principales de la API REST sigan funcionando despues de cambios en el codigo, sin depender de una base de datos externa ni de servicios desplegados en AWS.

## Estrategia usada

Las pruebas se ejecutan con `pytest` sobre una aplicacion Flask creada en modo de prueba. Para aislar cada caso de prueba se usa una base de datos SQLite en memoria:

- no requiere levantar PostgreSQL,
- no depende de Docker ni de servicios desplegados en AWS,
- se crea desde cero en cada prueba,
- se limpia automaticamente al finalizar cada caso.

Esto permite que la suite sea rapida, reproducible y facil de ejecutar en cualquier ambiente de desarrollo.

## Cobertura actual

La suite valida los siguientes escenarios:

1. `GET /ping` responde `200` con el mensaje `pong`.
2. `POST /blacklists` crea correctamente un registro cuando se envia un token valido.
3. `POST /blacklists` responde `401` cuando no se envia autenticacion.
4. `POST /blacklists` responde `400` cuando `app_uuid` no tiene formato UUID.
5. `GET /blacklists/{email}` responde `200` e indica `is_blacklisted=true` cuando el correo existe.
6. `GET /blacklists/{email}` responde `200` e indica `is_blacklisted=false` cuando el correo no existe.
7. `GET /blacklists/{email}` responde `401` cuando no se envia autenticacion.

## Archivos involucrados

- `tests/conftest.py`: fixtures, cliente HTTP de Flask y configuracion de base de datos en memoria.
- `tests/test_routes.py`: escenarios unitarios de los endpoints.
- `app/__init__.py`: permite inyectar configuracion de prueba en la aplicacion.

## Ejecucion local

Instalar dependencias:

```powershell
python -m pip install -r requirements.txt
```

Ejecutar la suite:

```powershell
python -m pytest tests -q
```

## Uso dentro del pipeline

En la Entrega 3, esta suite se ejecuta durante la fase `pre_build` de AWS CodeBuild. Si alguna prueba falla, CodeBuild termina con error y CodePipeline no continua hacia la etapa de despliegue.

Esto se uso para documentar el escenario de CI fallido: una prueba del endpoint `/ping` fue modificada temporalmente para esperar un codigo `500`, aunque la API respondia `200 OK`. El pipeline fallo en CodeBuild con `assert 200 == 500`, demostrando que la etapa de integracion continua detiene cambios defectuosos antes del despliegue.
