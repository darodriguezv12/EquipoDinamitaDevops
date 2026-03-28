# EquipoDinamitaDevops - Email Blacklist Microservice

Microservicio Flask para gestionar la lista negra global de correos electrónicos de la organización. Permite a sistemas internos agregar emails a la lista negra a través de una API REST centralizada.

---

## Requisitos previos

- Python 3.9+
- Docker (PostgreSQL corre en contenedor)
- El contenedor PostgreSQL debe estar activo en `localhost:5432`

---

## Configuración de PostgreSQL (ejecución local)

El contenedor PostgreSQL se inició con `POSTGRES_PASSWORD=password`. Los siguientes comandos configuran la base de datos y el usuario de la aplicación para correr el servicio localmente:

```bash
# Crear base de datos, usuario y permisos
docker exec -e PGPASSWORD=password <nombre_contenedor> psql -U postgres -c "CREATE DATABASE email-blacklist-db;"
docker exec -e PGPASSWORD=password <nombre_contenedor> psql -U postgres -c "CREATE USER blacklist_user WITH PASSWORD 'blacklist_pass123';"
docker exec -e PGPASSWORD=password <nombre_contenedor> psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE email-blacklist-db TO blacklist_user;"
docker exec -e PGPASSWORD=password <nombre_contenedor> psql -U postgres -d email-blacklist-db -c "GRANT ALL ON SCHEMA public TO blacklist_user;"
```

Reemplazar `<nombre_contenedor>` con el nombre real del contenedor (`docker ps` para verlo).

### Credenciales

| Parámetro          | Valor                   |
|--------------------|-------------------------|
| Host               | `localhost`             |
| Puerto             | `5432`                  |
| Superusuario       | `postgres`              |
| Contraseña super   | `password`              |
| Base de datos      | `email-blacklist-db`    |
| Usuario app        | `blacklist_user`        |
| Contraseña app     | `blacklist_pass123`     |
| URL de conexión    | `postgresql://blacklist_user:blacklist_pass123@localhost:5432/email-blacklist-db` |

---

## Variables de entorno

Copiar `.env.example` a `.env` y ajustar según el entorno:

```bash
cp .env.example .env
```

| Variable        | Descripción                              | Valor por defecto                                                                 |
|-----------------|------------------------------------------|-----------------------------------------------------------------------------------|
| `DATABASE_URL`  | URL de conexión a PostgreSQL             | `postgresql://blacklist_user:blacklist_pass123@localhost:5432/email-blacklist-db` |
| `STATIC_TOKEN`  | Token Bearer estático para autenticación | `blacklist-secret-token-2026`                                                     |
| `FLASK_APP`     | Entry point de Flask                     | `run.py`                                                                          |
| `FLASK_ENV`     | Entorno de ejecución                     | `development`                                                                     |
| `FLASK_DEBUG`   | Modo debug                               | `True`                                                                            |

---

## Instalación y ejecución local

```bash
# 1. Crear y activar entorno virtual
python3 -m venv .venv
source .venv/bin/activate

# 2. Instalar dependencias
pip install -r requirements.txt

# 3. Configurar variables de entorno
cp .env.example .env

# 4. Aplicar migraciones (crear tablas)
flask db upgrade

# 5. Iniciar el servidor
python run.py
```

El servidor quedará disponible en `http://localhost:5001`.

> **Primera vez:** si la carpeta `migrations/` no existe, ejecutar `flask db init` y luego `flask db migrate -m "Initial"` antes de `flask db upgrade`.

---

## Estructura del proyecto

```
├── .ebextensions/
│   └── db-migrate.config    # Migraciones automáticas en EB
├── app/
│   ├── __init__.py          # App
│   ├── models/
│   │   └── blacklist.py     # Modelo SQLAlchemy
│   ├── routes/
│   │   └── blacklist.py     # Endpoint POST /blacklists
│   └── schemas/
│       └── blacklist.py     # Schemas Marshmallow
├── docs/
│   └── API.md               # Documentación de la API
├── migrations/              # Migraciones Flask-Migrate
├── .env.example             # Plantilla de variables
├── config.py                # Configuración Flask
├── Procfile                 # Comando de arranque para EB
├── postman_collection.json  # Colección Postman
├── requirements.txt         # Dependencias Python
└── run.py                   # Entry point
```

---

## Documentación de la API

Ver [`docs/API.md`](docs/API.md) para la referencia completa de endpoints, parámetros y ejemplos.

## Colección Postman

Importar `postman_collection.json` en Postman. Incluye 4 escenarios de prueba cubriendo los códigos 201, 400, 401 y 409.

---

## Tech stack

| Tecnología         | Versión  |
|--------------------|----------|
| Python             | 3.9+     |
| Flask              | 3.1.0    |
| Flask-SQLAlchemy   | 3.1.1    |
| Flask-RESTful      | 0.3.10   |
| Flask-Marshmallow  | 1.2.1    |
| marshmallow        | 3.23.2   |
| Flask-Migrate      | 4.1.0    |
| Flask-JWT-Extended | 4.7.1    |
| Werkzeug           | 3.1.3    |
| PostgreSQL         | latest   |
