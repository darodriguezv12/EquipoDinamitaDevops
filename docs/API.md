# API Reference - Email Blacklist Microservice

## Autenticación

Todos los endpoints requieren el siguiente header:

```
Authorization: Bearer <STATIC_TOKEN>
```

El token estático está definido en la variable de entorno `STATIC_TOKEN` del archivo `.env`.

**Token por defecto (desarrollo):** `blacklist-secret-token-2026`

---

## Endpoints

### POST /blacklists

Agrega un correo electrónico a la lista negra global de la organización.

**URL:** `POST http://localhost:5001/blacklists`

#### Headers

| Header          | Valor                | Requerido |
|-----------------|----------------------|-----------|
| `Authorization` | `Bearer <token>`     | Sí        |
| `Content-Type`  | `application/json`   | Sí        |

#### Body (JSON)

| Campo            | Tipo   | Requerido | Descripción                              |
|------------------|--------|-----------|------------------------------------------|
| `email`          | String | Sí        | Dirección de correo a agregar            |
| `app_uuid`       | String | Sí        | UUID de la aplicación que hace la solicitud |
| `blocked_reason` | String | No        | Razón del bloqueo (máximo 255 caracteres) |

> El microservicio registra automáticamente la IP del solicitante y la fecha/hora UTC de la solicitud.

#### Ejemplo de Request

```json
{
  "email": "usuario@ejemplo.com",
  "app_uuid": "550e8400-e29b-41d4-a716-446655440000",
  "blocked_reason": "Envío masivo de spam detectado"
}
```

---

#### Respuestas

##### 201 Created — Email agregado exitosamente

```json
{
  "mensaje": "Correo electrónico agregado exitosamente a la lista negra"
}
```

##### 400 Bad Request — Datos de entrada inválidos

Ocurre cuando falta el campo `email`, `app_uuid` no es un UUID válido, o `blocked_reason` supera los 255 caracteres.

```json
{
  "mensaje": "Datos de entrada inválidos",
  "errores": {
    "email": ["Missing data for required field."],
    "app_uuid": ["Not a valid UUID."]
  }
}
```

##### 401 Unauthorized — Token inválido o ausente

```json
{
  "mensaje": "Token de autenticación inválido o ausente"
}
```

##### 409 Conflict — Email ya registrado

```json
{
  "mensaje": "El correo electrónico ya se encuentra en la lista negra"
}
```

---

## Ejemplos con cURL

**Agregar email (éxito):**
```bash
curl -X POST http://localhost:5001/blacklists \
  -H "Authorization: Bearer blacklist-secret-token-2026" \
  -H "Content-Type: application/json" \
  -d '{"email":"usuario@ejemplo.com","app_uuid":"550e8400-e29b-41d4-a716-446655440000","blocked_reason":"Spam"}'
```

**Sin token (401):**
```bash
curl -X POST http://localhost:5001/blacklists \
  -H "Content-Type: application/json" \
  -d '{"email":"otro@ejemplo.com","app_uuid":"550e8400-e29b-41d4-a716-446655440000"}'
```

**Datos inválidos (400):**
```bash
curl -X POST http://localhost:5001/blacklists \
  -H "Authorization: Bearer blacklist-secret-token-2026" \
  -H "Content-Type: application/json" \
  -d '{"app_uuid":"no-es-uuid"}'
```

---

## Postman

Importar el archivo `postman_collection.json` en Postman. La colección incluye 4 escenarios preconfigurados:

| Escenario                        | Código esperado |
|----------------------------------|-----------------|
| Agregar email nuevo              | 201             |
| Agregar email duplicado          | 409             |
| Solicitud sin token              | 401             |
| Body inválido (sin email)        | 400             |

La variable `{{token}}` de la colección ya tiene el valor del token de desarrollo. Cambiarla desde **Collection Variables** si se usa un token diferente.
