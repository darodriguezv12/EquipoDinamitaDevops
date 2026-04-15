# Buildspec para CodeBuild

El archivo `buildspec.yml` implementa el proceso de integracion continua de la Entrega 2.

## Flujo configurado

1. Instala dependencias de Python desde `requirements.txt`.
2. Ejecuta las pruebas unitarias con `pytest`.
3. Construye la imagen Docker de la API.
4. Publica la imagen en Amazon ECR.
5. Expone el contenido del repositorio como artefacto del build

## Variables configuradas

- `AWS_DEFAULT_REGION=us-east-1`
- `IMAGE_REPO_URI=383962123552.dkr.ecr.us-east-1.amazonaws.com/proyecto`

Con esto el build usa directamente el repositorio ECR del proyecto y calcula el tag desde el commit actual.

## Artefacto generado

El artefacto principal del proceso es la imagen Docker publicada en Amazon ECR.

Adicionalmente, durante el `post_build` se genera `image-detail.env` con:

- `IMAGE_REPO_URI`
- `IMAGE_TAG`
- `IMAGE_URI`

El bloque `artifacts` usa `**/*`, por lo que CodePipeline conserva el contenido del repositorio como salida del build.

## Nota operativa

El `Dockerfile` usa como imagen base `public.ecr.aws/docker/library/python:3.11-slim` para evitar el limite de descargas anonimas de Docker Hub dentro de CodeBuild.
