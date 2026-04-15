# Buildspec para CodeBuild

El archivo `buildspec.yml` ahora queda orientado al flujo del tutorial con `CodeBuild + ECR + CodePipeline + Elastic Beanstalk`.

## Flujo configurado

1. Instala dependencias de Python desde `requirements.txt`.
2. Ejecuta las pruebas unitarias con `pytest`.
3. Construye la imagen Docker de la API.
4. Publica la imagen en Amazon ECR.
5. Genera el bundle de despliegue que Elastic Beanstalk espera recibir desde CodePipeline.

## Variables configuradas

- `AWS_DEFAULT_REGION=us-east-1`
- `IMAGE_REPO_URI=383962123552.dkr.ecr.us-east-1.amazonaws.com/proyecto`

Con esto el build usa directamente el repositorio ECR del proyecto y solo calcula el tag desde el commit actual.

## Artefacto generado

El output del build ya no es un `zip` anidado como `beanstalk.zip`.

CodeBuild deja en su artefacto final estos archivos:

- `docker-compose.yml`
- `Dockerrun.aws.json`
- `nginx/default.conf`
- `image-detail.env`

Ese artefacto es el que CodePipeline puede entregar directamente a Elastic Beanstalk.

## Archivos relacionados

- `docker-compose.local.yaml`: desarrollo local con PostgreSQL.
- `docker-compose.yml`: stack local con Nginx.
- `docker-compose.eb.yml`: plantilla para generar el `docker-compose.yml` de Elastic Beanstalk usando la imagen publicada en ECR.

## Nota importante

Para que Elastic Beanstalk pueda descargar la imagen privada desde ECR, el perfil de instancia del entorno debe tener permisos de lectura, por ejemplo la politica administrada `AmazonEC2ContainerRegistryReadOnly`.
