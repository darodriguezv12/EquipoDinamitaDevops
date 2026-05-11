# Buildspec para CodeBuild y CodeDeploy Blue/Green

El archivo `buildspec.yml` implementa la integracion continua y prepara los artefactos que usa CodePipeline para desplegar el servicio ECS/Fargate mediante CodeDeploy Blue/Green.

## Flujo configurado

1. Instala dependencias de Python desde `requirements.txt`.
2. Ejecuta las pruebas unitarias con `pytest`.
3. Construye la imagen Docker de la API para `linux/amd64`.
4. Publica la imagen en Amazon ECR.
5. Genera `imageDetail.json`, `appspec.json` y `taskdef.json` para que la accion `CodeDeployToECS` haga el despliegue Blue/Green.

## Variables configuradas

- `AWS_DEFAULT_REGION=us-east-1`
- `IMAGE_REPO_URI=383962123552.dkr.ecr.us-east-1.amazonaws.com/proyecto-1-blacklist-api-dev`
- `CONTAINER_NAME=app`
- `ECS_CLUSTER_NAME=blacklist-api-dev-cluster`
- `ECS_SERVICE_NAME=blacklist-api-dev-service`

Con esto el build usa directamente el repositorio ECR del proyecto y calcula el tag desde el commit actual.

## Artefactos generados

- Imagen Docker publicada en Amazon ECR.
- `imageDetail.json`, con la URI de la imagen publicada.
- `appspec.json`, con el contenedor `app` y el puerto `5000`.
- `taskdef.json`, generado desde la task definition actual y con la imagen reemplazada por `<IMAGE1_NAME>`.

El bloque `artifacts` exporta solamente los archivos que necesita el despliegue Blue/Green. La task definition se genera dinamicamente para no versionar secretos como `DATABASE_URL` o `API_TOKEN`.

## Nota operativa

El `Dockerfile` usa como imagen base `public.ecr.aws/docker/library/python:3.11-slim` para evitar el limite de descargas anonimas de Docker Hub dentro de CodeBuild.

## Escenarios de validacion

Durante la Entrega 3 se usaron cambios controlados para documentar tres comportamientos del pipeline:

- CI fallido: una prueba unitaria esperaba un codigo HTTP incorrecto y CodeBuild fallo en `PRE_BUILD`.
- CI/CD exitoso: las pruebas pasaron, la imagen fue publicada en ECR y CodeDeploy actualizo ECS/Fargate.
- CI exitoso/CD fallido: CodeBuild fue exitoso, pero CodeDeploy fallo al recibir una configuracion de puerto invalida en el artefacto de despliegue.

El estado normal del archivo debe conservar `ContainerPort = 5000`, que corresponde al puerto expuesto por la aplicacion Flask.
