# Buildspec para CodeBuild

El archivo `buildspec.yml` queda preparado para integracion continua con `CodeBuild + ECR`, siguiendo el enfoque del tutorial.

## Flujo configurado

1. Instala dependencias de Python desde `requirements.txt`.
2. Ejecuta las pruebas unitarias con `pytest`.
3. Construye la imagen Docker de la API.
4. Publica la imagen en Amazon ECR.
5. Expone como artefacto el contenido del repositorio para reutilizarlo en etapas posteriores del pipeline.

## Variables configuradas

- `AWS_DEFAULT_REGION=us-east-1`
- `IMAGE_REPO_URI=383962123552.dkr.ecr.us-east-1.amazonaws.com/proyecto`

Con esto el build usa directamente el repositorio ECR del proyecto y solo calcula el tag desde el commit actual.

## Artefacto generado

El artefacto principal del proceso es la imagen Docker publicada en Amazon ECR.

El bloque `artifacts` usa `**/*`, por lo que el pipeline conserva el contenido del repositorio junto con ese archivo de trazabilidad, igual que en el tutorial.
