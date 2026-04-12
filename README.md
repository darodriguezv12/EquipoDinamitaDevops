# Blacklist API

API REST en Flask para registrar y consultar correos en una lista negra, con PostgreSQL y despliegue vía Docker (y Nginx como reverse proxy en el stack completo).

## Requisitos

- Docker y Docker Compose

## Ejecución local (desarrollo)

Levanta la app en el puerto **5000** con Postgres incluido:

```bash
docker compose -f docker-compose.local.yaml up --build
```

Variables ya definidas en el compose: `DATABASE_URL`, `API_TOKEN` (por defecto `mi-token-secreto`).

- Health: `GET http://localhost:5000/ping`
- API protegida con header `Authorization: Bearer <API_TOKEN>`

## Stack con Nginx (puerto 80)

El archivo `docker-compose.yml` expone la app detrás de Nginx. Define en el entorno (por ejemplo un archivo `.env` en la raíz del proyecto):

- `DATABASE_URL`
- `API_TOKEN`
- `DB_INIT_RETRIES` y `DB_INIT_DELAY` (opcionales, según tu configuración)

```bash
docker compose up --build
```

La app queda accesible en **http://localhost** (según `nginx/default.conf`).

## Documentación y pruebas

- Especificación OpenAPI: [`docs/api-spec.yaml`](docs/api-spec.yaml)
- Colección Postman y notas: [`test/README.md`](test/README.md)

## Stack

Python 3, Flask, SQLAlchemy, PostgreSQL, Gunicorn, Nginx.



# Entregables entrega 1 
- [Colleción de postman](https://www.postman.com/alejandro-4321861/workspace/devops-proyecto)
- [Documento de despliegue](https://drive.google.com/file/d/17wGlASZGHUbFJBfp3k0dMMYEIW-CTGSW/view?usp=sharing)
- [Video](https://drive.google.com/file/d/1S01QFyaB5HB-JJEae6z8rHJn01yRIEGG/view?usp=sharing)
