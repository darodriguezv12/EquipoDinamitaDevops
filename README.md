# Blacklist API

API REST en Flask para registrar y consultar correos en una lista negra. El proyecto incluye pruebas unitarias, ejecucion local con Docker y un flujo de integracion y entrega continua en AWS con CodePipeline, CodeBuild, ECR, CodeDeploy y ECS/Fargate.

## Stack

- Python 3.11
- Flask
- SQLAlchemy
- PostgreSQL
- Docker
- AWS CodeBuild
- AWS CodePipeline
- Amazon ECR
- AWS CodeDeploy
- Amazon ECS/Fargate
- Application Load Balancer
- Amazon RDS

## Ejecucion local

### Desarrollo con PostgreSQL

```bash
docker compose -f docker-compose.local.yaml up --build
```

La API queda disponible en `http://localhost:5000`.

### Stack con Nginx

```bash
docker compose up --build
```

La API queda disponible en `http://localhost`.

## Variables de entorno

Variables principales usadas por la aplicacion:

- `DATABASE_URL`
- `API_TOKEN`
- `DB_INIT_RETRIES`
- `DB_INIT_DELAY`

En AWS, las variables de ejecucion de la aplicacion se inyectan en la task definition de ECS/Fargate. Las variables del proceso de build se configuran en `buildspec.yml` o en el proyecto de CodeBuild.

## Pruebas unitarias

Las pruebas se ejecutan con `pytest` y usan SQLite en memoria para no depender de PostgreSQL ni de servicios de AWS.

```powershell
python -m pip install -r requirements.txt
python -m pytest tests -q
```

Cobertura actual de endpoints:

- `GET /ping`
- `POST /blacklists`
- `GET /blacklists/<email>`

Detalles en [docs/ci-testing.md](./docs/ci-testing.md).

## Integracion y entrega continua en AWS

Para la Entrega 3 se configuro un pipeline de CI/CD con este flujo:

1. GitHub detecta cambios en la rama principal.
2. CodePipeline inicia la ejecucion mediante AWS CodeConnections.
3. CodeBuild instala dependencias y ejecuta `pytest`.
4. Si las pruebas pasan, se construye la imagen Docker.
5. La imagen se publica en Amazon ECR.
6. CodeBuild genera los artefactos `appspec.json`, `taskdef.json` e `imageDetail.json`.
7. CodeDeploy actualiza el servicio en ECS/Fargate con despliegue Blue/Green.

Archivo principal de configuracion:

- [buildspec.yml](./buildspec.yml)

Notas del build:

- [docs/buildspec-notes.md](./docs/buildspec-notes.md)

## Despliegue en AWS

La aplicacion se encuentra desplegada en Amazon ECS usando Fargate y se expone mediante un Application Load Balancer publico. La imagen del microservicio se almacena en Amazon ECR y el despliegue continuo se realiza con AWS CodeDeploy.

El entorno de infraestructura se define en Terraform:

- [terraform/environments/dev/README.md](./terraform/environments/dev/README.md)

Endpoint AWS actual usado por Newman:

- `http://blacklist-api-dev-alb-1334000577.us-east-1.elb.amazonaws.com`

## Pruebas funcionales con Newman

La coleccion de Postman puede ejecutarse localmente o contra AWS usando Newman:

```powershell
npx newman run test\blacklist.postman_collection.json -e test\blacklist-local.postman_environment.json
npx newman run test\blacklist.postman_collection.json -e test\blacklist-aws.postman_environment.json
```

La coleccion valida disponibilidad, autenticacion, creacion de entradas, validacion de UUID y consulta de correos existentes e inexistentes.

## Escenarios documentados para Entrega 3

1. Pipeline de CI fallido: se introdujo una falla controlada en una prueba unitaria para validar que CodeBuild detiene el pipeline.
2. Pipeline de CI exitoso y CD exitoso: las pruebas pasan, la imagen se publica en ECR y CodeDeploy actualiza ECS/Fargate correctamente.
3. Pipeline de CI exitoso y CD fallido: la construccion pasa, pero CodeDeploy falla por una configuracion invalida de despliegue.

Las evidencias locales generadas para el documento se encuentran en `evidence/`.

## Entregables de la Entrega 3

- [Documento de pruebas unitarias](./docs/ci-testing.md)
- [Guion del video](./docs/video-entrega-3-guion.md)
- [Coleccion de Postman](https://www.postman.com/alejandro-4321861/workspace/devops-proyecto)
- [Video](https://drive.google.com/file/d/1HBUtQUEyZmiDbN3cuISqRBW9TwqmNWQK/view?usp=sharing)

## Entregables de la Entrega 2

- [Documento de pruebas unitarias](./docs/ci-testing.md)
- [Video](https://drive.google.com/file/d/1IByl3_jYrMDbYMCuHIsQZNOfqGymp8qP/view?usp=sharing)
- [Coleccion de Postman](https://www.postman.com/alejandro-4321861/workspace/devops-proyecto)

## Entregables de la Entrega 1

- [Coleccion de Postman](https://www.postman.com/alejandro-4321861/workspace/devops-proyecto)
- [Documento de despliegue](https://drive.google.com/file/d/17wGlASZGHUbFJBfp3k0dMMYEIW-CTGSW/view?usp=sharing)
- [Video](https://drive.google.com/file/d/1S01QFyaB5HB-JJEae6z8rHJn01yRIEGG/view?usp=sharing)
