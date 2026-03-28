# EquipoDinamitaDevops - Email Blacklist Microservice

Microservicio Flask para gestionar la lista negra global de correos electrónicos de la organización. Permite a sistemas internos agregar emails a la lista negra a través de una API REST centralizada.

---

## Requisitos previos

- Python 3.9+
- Docker (PostgreSQL corre en contenedor para ejecución local)
- Acceso a la consola de AWS para el despliegue

---

## Ejecución local

### 1. Levantar PostgreSQL con Docker

```bash
docker run -d \
  --name postgres \
  -e POSTGRES_PASSWORD=password \
  -p 5432:5432 \
  postgres
```

### 2. Crear la base de datos y el usuario de la aplicación

```bash
# Crear base de datos
docker exec -e PGPASSWORD=password postgres psql -U postgres -c "CREATE DATABASE \"email-blacklist-db\";"

# Crear usuario y darle permisos
docker exec -e PGPASSWORD=password postgres psql -U postgres -c "CREATE USER blacklist_user WITH PASSWORD 'blacklist_pass123';"
docker exec -e PGPASSWORD=password postgres psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE \"email-blacklist-db\" TO blacklist_user;"
docker exec -e PGPASSWORD=password postgres psql -U postgres -d "email-blacklist-db" -c "GRANT ALL ON SCHEMA public TO blacklist_user;"
```

### 3. Configurar el entorno virtual e instalar dependencias

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

### 4. Configurar variables de entorno

```bash
cp .env.example .env
```

El archivo `.env` debe quedar así:

```
DATABASE_URL=postgresql://blacklist_user:blacklist_pass123@localhost:5432/email-blacklist-db
STATIC_TOKEN=blacklist-secret-token-2026
FLASK_APP=run.py
FLASK_ENV=development
FLASK_DEBUG=True
```

### 5. Aplicar las migraciones (crear tablas)

```bash
flask db upgrade
```

Esto crea la tabla `blacklists` en la base de datos local.

### 6. Iniciar el servidor

```bash
python run.py
```

El servidor queda disponible en `http://localhost:5001`.

---

## Credenciales PostgreSQL local

| Parámetro        | Valor                                                                              |
|------------------|------------------------------------------------------------------------------------|
| Host             | `localhost`                                                                        |
| Puerto           | `5432`                                                                             |
| Base de datos    | `email-blacklist-db`                                                               |
| Superusuario     | `postgres` / `password`                                                            |
| Usuario app      | `blacklist_user` / `blacklist_pass123`                                             |
| URL de conexión  | `postgresql://blacklist_user:blacklist_pass123@localhost:5432/email-blacklist-db`  |

---

## Modificar el esquema de la base de datos

Cuando necesites agregar o cambiar columnas en el modelo:

1. Modifica `app/models/blacklist.py` con el cambio deseado
2. Genera el archivo de migración:
   ```bash
   flask db migrate -m "descripcion del cambio"
   ```
3. Revisa el archivo generado en `migrations/versions/` para confirmar que el cambio es correcto
4. Aplica la migración localmente:
   ```bash
   flask db upgrade
   ```
5. Aplica la migración en el RDS siguiendo el paso 2 de la sección de despliegue (acceso temporal → `flask db upgrade` apuntando al RDS → cerrar acceso)

Para revertir la última migración:

```bash
flask db downgrade
```

---

## Despliegue en AWS (Elastic Beanstalk + RDS)

### 1. Crear la instancia RDS

Ir a **RDS → Create database**:

- Engine: **PostgreSQL**
- Template: **Free tier**
- DB instance identifier: `email-blacklist-db`
- Master username: `postgres`
- Master password: `password`
- Public access: **No**
- VPC: dejar la **Default VPC**
- VPC security group: dejar el **default** que AWS asigna automáticamente

Una vez creada, copiar el **Endpoint** (ej: `email-blacklist-db.xxxx.us-east-2.rds.amazonaws.com`).

---

### 2. Inicializar la base de datos desde local

RDS crea la instancia pero no la base de datos ni las tablas. Hay que hacerlo manualmente desde tu máquina.

**Abrir acceso temporal:** ir a **EC2 → Security Groups → default → Inbound rules → Edit inbound rules → Add rule**:
- Type: `PostgreSQL` / Port: `5432` / Source: **My IP**

Luego ejecutar con el entorno virtual activo:

```bash
source .venv/bin/activate

# Crear la base de datos
psql -h <RDS_ENDPOINT> -U postgres -c "CREATE DATABASE \"email-blacklist-db\";"

# Aplicar las migraciones (crea la tabla blacklists)
DATABASE_URL="postgresql://postgres:password@<RDS_ENDPOINT>:5432/email-blacklist-db" \
STATIC_TOKEN="blacklist-secret-token-2026" \
FLASK_APP=run.py \
flask db upgrade
```

Si no tienes `psql`, crear la base de datos con Python antes de correr las migraciones:

```bash
python3 -c "
import psycopg2
from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT
conn = psycopg2.connect(host='<RDS_ENDPOINT>', port=5432, database='postgres', user='postgres', password='password', connect_timeout=10)
conn.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
cur = conn.cursor()
cur.execute('CREATE DATABASE \"email-blacklist-db\"')
cur.close()
conn.close()
print('Base de datos creada')
"
```

**Cerrar acceso:** eliminar la regla de tu IP del inbound rule una vez terminado.

> **Cada vez que modifiques el esquema** (nuevo `flask db migrate`), repetir: abrir acceso temporal → `flask db upgrade` → cerrar acceso.

---

### 3. Generar el ZIP del proyecto

```bash
zip -r app.zip . \
  -x "*.git*" \
  -x ".venv/*" \
  -x "__pycache__/*" \
  -x "*.pyc" \
  -x ".env" \
  -x "*.db"
```

---

### 4. Crear la aplicación en Elastic Beanstalk

Ir a **Elastic Beanstalk → Create application** y completar el wizard:

**Step 1 - Configure environment:**
- Environment tier: **Web server environment**
- Application name: `email-blacklist`
- Platform: **Python**
- Platform branch: **Python 3.9** (o la más reciente disponible)
- Application code: **Upload your code** → subir el `app.zip` generado en el paso anterior

**Step 4 - Configure networking** *(dentro del mismo wizard, antes de crear)*:
- VPC: seleccionar la **Default VPC** *(la misma que usó el RDS)*
- Instance subnets: seleccionar todas las subnets disponibles

---

### 5. Permitir que Elastic Beanstalk se conecte al RDS

Al crearse el environment, AWS le asigna automáticamente un security group (empieza con `awseb-`). Hay que agregarlo al security group **default** del RDS para que pueda conectarse:

1. Ir a **EC2 → Security Groups → default → Inbound rules → Edit inbound rules → Add rule**:
   - Type: `PostgreSQL` / Port: `5432` / Source: security group del EB (`awseb-...`)
2. Guardar

---

### 6. Configurar variables de entorno en Elastic Beanstalk

En la consola de EB, ir a **Configuration → Software → Environment properties** y agregar:

| Clave          | Valor                                                                              |
|----------------|------------------------------------------------------------------------------------|
| `DATABASE_URL` | `postgresql://postgres:password@<RDS_ENDPOINT>:5432/email-blacklist-db`           |
| `STATIC_TOKEN` | `blacklist-secret-token-2026`                                                      |
| `FLASK_APP`    | `run.py`                                                                           |
| `FLASK_ENV`    | `development`                                                                      |
| `FLASK_DEBUG`  | `True`                                                                             |

Guardar - EB reiniciará la aplicación automáticamente.

---

### 7. Verificar el despliegue

Una vez que el environment muestre estado **Ok**, obtener la URL en la consola de EB y probar:

```bash
# Debe devolver 201
curl -X POST http://<EB_URL>/blacklists \
  -H "Authorization: Bearer blacklist-secret-token-2026" \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","app_uuid":"550e8400-e29b-41d4-a716-446655440000","blocked_reason":"Prueba"}'

# Debe devolver 401 (sin token)
curl -X POST http://<EB_URL>/blacklists \
  -H "Content-Type: application/json" \
  -d '{"email":"otro@example.com","app_uuid":"550e8400-e29b-41d4-a716-446655440000"}'
```

---

### Credenciales RDS actuales (Ejemplo)

| Parámetro       | Valor                                                                                  |
|-----------------|----------------------------------------------------------------------------------------|
| Endpoint        | `email-blacklist-db.123.us-east-2.rds.amazonaws.com`                        |
| Puerto          | `5432`                                                                                 |
| Base de datos   | `email-blacklist-db`                                                                   |
| Usuario         | `postgres` / `password`                                                                |
| URL de conexión | `postgresql://postgres:password@email-blacklist-db.123.us-east-2.rds.amazonaws.com:5432/email-blacklist-db` |

---

## Estructura del proyecto

```
├── .ebextensions/
│   └── env.config           # Variables de entorno para EB
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
├── migrations/              # Migraciones Flask-Migrate / Alembic
├── .env.example             # Plantilla de variables de entorno
├── config.py                # Configuración Flask
├── Procfile                 # Comando de arranque para EB (gunicorn)
├── postman_collection.json  # Colección Postman con 4 escenarios
├── requirements.txt         # Dependencias Python
└── run.py                   # Entry point
```

---

## Documentación de la API

Ver [`docs/API.md`](docs/API.md) para la referencia completa de endpoints, parámetros y ejemplos.

## Colección Postman

Importar `postman_collection.json` en Postman. Incluye 4 escenarios cubriendo los códigos 201, 400, 401 y 409.

---

## Variables de entorno

| Variable        | Descripción                              |
|-----------------|------------------------------------------|
| `DATABASE_URL`  | URL de conexión a PostgreSQL             |
| `STATIC_TOKEN`  | Token Bearer estático para autenticación |
| `FLASK_APP`     | Entry point de Flask (`run.py`)          |
| `FLASK_ENV`     | Entorno (`development` / `production`)   |
| `FLASK_DEBUG`   | Modo debug (`True` / `False`)            |

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
| gunicorn           | 23.0.0   |
