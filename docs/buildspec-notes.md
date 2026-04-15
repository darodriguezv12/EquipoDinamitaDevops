# Buildspec para CodeBuild

El archivo `buildspec.yml` queda orientado a la Entrega 2, enfocada en integracion continua con `CodeBuild + ECR`.

## Flujo configurado

1. Instala dependencias de Python desde `requirements.txt`.
2. Ejecuta las pruebas unitarias con `pytest`.
3. Construye la imagen Docker de la API.
4. Publica la imagen en Amazon ECR.
5. Genera un archivo de metadatos del artefacto para dejar evidencia del resultado del build.

## Variables configuradas

- `AWS_DEFAULT_REGION=us-east-1`
- `IMAGE_REPO_URI=383962123552.dkr.ecr.us-east-1.amazonaws.com/proyecto`

Con esto el build usa directamente el repositorio ECR del proyecto y solo calcula el tag desde el commit actual.

## Artefacto generado

El artefacto principal del proceso es la imagen Docker publicada en Amazon ECR.

Adicionalmente, CodeBuild expone como output un archivo `image-detail.env` con:

- `IMAGE_REPO_URI`
- `IMAGE_TAG`
- `IMAGE_URI`

Esto deja trazabilidad del artefacto construido sin implementar despliegue automatizado.
