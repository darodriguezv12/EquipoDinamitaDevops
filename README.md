# Blacklist API

API REST en Flask para registrar y consultar correos en una lista negra. El proyecto incluye pruebas unitarias, ejecucion local con Docker y un flujo de integracion continua en AWS con CodePipeline, CodeBuild, ECR y una aplicacion desplegada en Elastic Beanstalk.

## Stack

- Python 3.11
- Flask
- SQLAlchemy
- PostgreSQL
- Docker
- AWS CodeBuild
- AWS CodePipeline
- Amazon ECR
- AWS Elastic Beanstalk

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

En AWS, las variables de ejecucion de la aplicacion deben configurarse en Elastic Beanstalk. Las variables del proceso de build se configuran en `buildspec.yml` o en el proyecto de CodeBuild.

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

Detalles en [docs/ci-testing.md](/C:/Users/aleja/Documents/projects/uni/devops/proyecto-1/docs/ci-testing.md:1).

## Integracion continua en AWS

Para la Entrega 2 se configuro un pipeline de CI con este flujo:

1. GitHub detecta cambios en la rama principal.
2. CodePipeline inicia la ejecucion.
3. CodeBuild instala dependencias y ejecuta `pytest`.
4. Si las pruebas pasan, se construye la imagen Docker.
5. La imagen se publica en Amazon ECR.
6. El pipeline conserva el contenido del repositorio como artefacto del build.

Archivo principal de configuracion:

- [buildspec.yml](/C:/Users/aleja/Documents/projects/uni/devops/proyecto-1/buildspec.yml:1)

Notas del build:

- [docs/buildspec-notes.md](/C:/Users/aleja/Documents/projects/uni/devops/proyecto-1/docs/buildspec-notes.md:1)

## Despliegue en AWS

La aplicacion se encuentra desplegada en AWS Elastic Beanstalk y accesible desde Postman, como lo exige la entrega. El alcance del pipeline configurado en esta entrega es CI; no se documenta despliegue automatizado como requisito de la rubrica.

## Entregables de la Entrega 2

Para cerrar la entrega, el equipo debe evidenciar:

- Aplicacion ejecutandose en AWS Elastic Beanstalk y accesible por Postman.
- Repositorio en GitHub con el codigo fuente, pruebas y `buildspec.yml`.
- Pipeline de CI en AWS disparado por commit a `master` o la rama configurada.
- Un build exitoso documentado con capturas.
- Un build fallido documentado con capturas.
- Documento PDF `Proyecto 1 entrega 2 – Documento.pdf`.
- Video de sustentacion de maximo 10 minutos.

## Evidencias recomendadas

Capturas utiles para el documento y el video:

- Endpoints funcionando en Postman contra la URL de Beanstalk.
- Suite de pruebas en el repositorio.
- Ejecucion exitosa de CodeBuild.
- Ejecucion fallida de CodeBuild.
- Imagen publicada en ECR.
- Configuracion del pipeline en CodePipeline.
- Aplicacion/version activa en Elastic Beanstalk.

## Entregables de la Entrega 1

- [Coleccion de Postman](https://www.postman.com/alejandro-4321861/workspace/devops-proyecto)
- [Documento de despliegue](https://drive.google.com/file/d/17wGlASZGHUbFJBfp3k0dMMYEIW-CTGSW/view?usp=sharing)
- [Video](https://drive.google.com/file/d/1S01QFyaB5HB-JJEae6z8rHJn01yRIEGG/view?usp=sharing)
