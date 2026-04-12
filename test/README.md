# Tests

Coleccion Postman y ambientes de prueba para la API de blacklist.

La coleccion documenta y prueba las especificaciones de la entrega:

- `POST /blacklists` con `email`, `app_uuid` y `blocked_reason` (opcional).
- `GET /blacklists/{email}` con respuesta `is_blacklisted` y `blocked_reason`.

Ejecutar con Newman:

```powershell
newman run test\blacklist.postman_collection.json -e test\blacklist-local.postman_environment.json
```

Si Newman no esta instalado globalmente:

```powershell
npx newman run test\blacklist.postman_collection.json -e test\blacklist-local.postman_environment.json
```

Para AWS, usar el environment:

```powershell
npx newman run test\blacklist.postman_collection.json -e test\blacklist-aws.postman_environment.json
```

Antes de correrlo, cambiar `baseUrl` y `apiToken` en ese archivo.

La coleccion ya incluye pruebas para validar que:

- el `POST /blacklists` acepte `blocked_reason` en el cuerpo,
- el `GET /blacklists/{email}` retorne `blocked_reason` para correos existentes,
- el `GET /blacklists/{email}` retorne `blocked_reason: null` para correos inexistentes.

## Archivos utiles para la entrega

- Coleccion Postman: `test\blacklist.postman_collection.json`
- Environment local: `test\blacklist-local.postman_environment.json`
- Environment AWS: `test\blacklist-aws.postman_environment.json`
- Especificacion OpenAPI: `docs\api-spec.yaml`
- Guia para publicacion en Postman: `docs\postman-deliverable.md`


