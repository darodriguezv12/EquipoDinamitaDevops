# Documentacion de API con Postman

Este repositorio ya incluye los insumos minimos para la entrega de documentacion de la API REST en Postman:

- Coleccion: `test/blacklist.postman_collection.json`
- Environment local: `test/blacklist-local.postman_environment.json`
- Environment AWS: `test/blacklist-aws.postman_environment.json`
- Especificacion OpenAPI de apoyo: `docs/api-spec.yaml`

## Endpoints documentados

1. `GET /ping`
   - Verifica que el servicio este activo.
   - No requiere autenticacion.

2. `POST /blacklists`
   - Crea un correo en la lista negra.
   - Requiere `Authorization: Bearer <token>`.
   - Campos del cuerpo JSON: `email` (requerido), `app_uuid` (requerido), `blocked_reason` (opcional, maximo 255 caracteres).
   - Retorna `application/json` con un mensaje de confirmacion cuando el registro es creado o rechazado.

3. `GET /blacklists/{email}`
   - Consulta si un correo se encuentra en blacklist.
   - Requiere `Authorization: Bearer <token>`.
   - Retorna `application/json` con `is_blacklisted` y `blocked_reason`.

## Escenarios de prueba incluidos en la coleccion

1. Disponibilidad del servicio con `GET /ping`
2. Creacion exitosa de un registro en blacklist con `blocked_reason`
3. Rechazo por falta de token
4. Rechazo por `app_uuid` invalido
5. Consulta de correo existente con validacion de `blocked_reason`
6. Consulta de correo inexistente con `blocked_reason = null`
7. Rechazo de consulta sin token

## Como importarlo en Postman

1. Crear un workspace compartido del equipo.
2. Importar la coleccion `test/blacklist.postman_collection.json`.
3. Importar el environment correspondiente:
   - `test/blacklist-local.postman_environment.json`
   - `test/blacklist-aws.postman_environment.json`
4. Ajustar las variables `baseUrl`, `apiToken`, `testEmail`, `appUuid` y `blockedReason`.
5. Ejecutar manualmente la coleccion o usar el Collection Runner.

## Como publicar la documentacion

1. Abrir la coleccion en Postman.
2. Verificar que cada request conserve su descripcion y ejemplos.
3. Usar la opcion de publicar documentacion de la coleccion.
4. Copiar la URL publicada y anexarla al informe de arquitectura.

## Nota para el informe

Puede citarse asi:

> La documentacion de la API REST y los escenarios de prueba fueron construidos en Postman a partir de la coleccion compartida del equipo. La coleccion incluye la descripcion de cada endpoint, parametros de prueba, autenticacion, ejemplos de solicitudes y respuestas, asi como escenarios de validacion exitosos y de error.
