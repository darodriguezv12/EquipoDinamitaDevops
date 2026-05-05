# Entorno Terraform de desarrollo

Este directorio contiene la definición del ambiente `dev` que aprovisiona en AWS la infraestructura inicial para ejecutar la API de lista negra en Flask sobre ECS/Fargate. La configuración está pensada para una entrega académica: funcional, sencilla de explicar y con costos controlados.

## Arquitectura

Terraform crea una infraestructura dedicada para el proyecto, sin reutilizar recursos de entregas anteriores:

- Una VPC propia con CIDR `10.20.0.0/16`.
- Dos subredes públicas en `us-east-1a` y `us-east-1b`.
- Un Internet Gateway y una tabla de rutas pública con salida a `0.0.0.0/0`.
- Un Application Load Balancer público escuchando por HTTP en el puerto `80`.
- Dos target groups HTTP, `blue` y `green`, usados por CodeDeploy para despliegues Blue/Green.
- Un clúster ECS con una tarea Fargate que ejecuta el contenedor de la API.
- Un repositorio ECR llamado `proyecto-1-blacklist-api-dev` para publicar la imagen Docker.
- Una base de datos PostgreSQL en RDS para persistencia de datos.
- Security groups separados para ALB, ECS y RDS.
- Logs de la aplicación en CloudWatch.
- Roles IAM mínimos para ejecución de tareas ECS, CodeBuild, CodePipeline y CodeDeploy.

El flujo de tráfico esperado es:

```text
Internet
  -> ALB público :80
  -> Target group blue
  -> ECS Fargate :5000
  -> RDS PostgreSQL :5432
```

## Red

El módulo de red crea una VPC dedicada con DNS habilitado. Dentro de esa VPC se crean dos subredes públicas, una por zona de disponibilidad, y ambas tienen asignación automática de IP pública.

No se crea NAT Gateway de forma intencional. Esto reduce costos para el ambiente académico, pero implica que las tareas Fargate se ejecutan con IP pública para poder descargar imágenes desde ECR, enviar logs a CloudWatch y comunicarse con APIs de AWS por HTTPS.

## Seguridad

La comunicación entre componentes se controla con tres security groups:

- `alb-sg`: permite tráfico HTTP desde internet al ALB por el puerto `80`.
- `ecs-sg`: permite tráfico desde el ALB hacia la aplicación por el puerto `5000`.
- `rds-sg`: permite PostgreSQL por el puerto `5432` solo desde las tareas ECS.

RDS no es públicamente accesible. Aunque usa el subnet group construido con las subredes públicas, el acceso queda restringido por el security group y por la propiedad `publicly_accessible = false`.

## Balanceador de carga

El ALB se crea como balanceador público y expone la API por HTTP. El listener del puerto `80` apunta inicialmente al target group `blue`.

Se crean dos target groups:

- `blue`: target group activo usado por el servicio ECS inicial.
- `green`: target group secundario usado por CodeDeploy durante los despliegues Blue/Green.

Ambos target groups usan health checks HTTP contra `/ping`, esperando respuesta `200`.

## Contenedores

La API se ejecuta en ECS Fargate con estos valores por defecto:

- `desired_count = 1`
- `task_cpu = 256`
- `task_memory = 512`
- `container_port = 5000`
- `container_image_tag = latest`

La definición de tarea inyecta estas variables de entorno al contenedor:

- `API_TOKEN`: token Bearer esperado por la API.
- `DATABASE_URL`: cadena de conexión PostgreSQL construida con el endpoint de RDS.
- `DB_INIT_RETRIES`: número de reintentos para inicializar la base de datos.
- `DB_INIT_DELAY`: espera entre reintentos.

Los logs del contenedor se envían a CloudWatch en el log group `/ecs/blacklist-api-dev`, con retención de `3` días por defecto.

## Imagen Docker

Terraform crea el repositorio ECR `proyecto-1-blacklist-api-dev` con:

- Escaneo de imágenes al hacer push.
- Cifrado AES256 administrado por AWS.
- Política de ciclo de vida para conservar pocas imágenes.
- Eliminación automática de imágenes antiguas sin etiqueta.

El primer despliegue de ECS espera que la etiqueta configurada en `container_image_tag` exista en ECR. Antes de esperar que el servicio quede saludable, se debe construir y publicar la imagen Docker en el valor entregado por el output `ecr_repository_url`.

## Base de datos

La base de datos se aprovisiona con RDS PostgreSQL:

- Motor `postgres`, versión `15`.
- Instancia `db.t3.micro` por defecto.
- Almacenamiento inicial de `20` GiB en `gp2`.
- Single-AZ.
- Sin backups automáticos.
- Sin protección contra eliminación.
- Sin snapshot final al destruir.
- Sin Performance Insights.

Estos valores reducen costos y simplifican la entrega, pero no representan una configuración recomendada para producción.

## Variables principales

Antes de aplicar, revisa `terraform.tfvars` y reemplaza los valores de ejemplo:

```hcl
api_token   = "change-me-academic-token"
db_password = "change-me-db-password-123"
```

Las variables más relevantes del entorno son:

- `aws_region`: región de AWS, por defecto `us-east-1`.
- `project_name`: prefijo lógico del proyecto, por defecto `blacklist-api`.
- `environment`: nombre del ambiente, por defecto `dev`.
- `app_port`: puerto de la API Flask, por defecto `5000`.
- `health_check_path`: endpoint de health check, por defecto `/ping`.
- `ecr_repository_name`: repositorio donde se publica la imagen.
- `container_image_tag`: etiqueta inicial que ECS buscará en ECR.
- `ecs_desired_count`: número de tareas Fargate, limitado a `1` para bajo costo.
- `db_name`, `db_username` y `db_password`: credenciales y nombre de la base de datos.

No subas credenciales reales al repositorio. Los valores actuales son placeholders para el ambiente académico.

## Aplicar infraestructura

Desde este directorio ejecuta:

```powershell
terraform init
terraform fmt -check -recursive
terraform validate
terraform plan
terraform apply
```

Después del `apply`, usa los outputs principales:

- `ecr_repository_url`: URL del repositorio donde se debe publicar la imagen Docker.
- `alb_dns_name`: DNS público para consumir la API.
- `ecs_cluster_name`: nombre del clúster ECS.
- `ecs_service_name`: nombre del servicio ECS.
- `rds_endpoint`: endpoint privado de PostgreSQL.
- `blue_target_group_arn` y `green_target_group_arn`: target groups del balanceador.
- `codepipeline_name`: nombre del pipeline Source-Build-Deploy.
- `codebuild_project_name`: nombre del proyecto CodeBuild.

## Costos y limpieza

Este ambiente está optimizado para bajo costo, pero no es gratuito por definición. El ALB, las tareas Fargate, RDS, CloudWatch y el almacenamiento de ECR pueden generar cobros mientras existan.

La elegibilidad para Free Tier o Free Plan depende de la cuenta de AWS y de las condiciones vigentes. AWS documenta las opciones de RDS en [Amazon RDS Free Tier](https://aws.amazon.com/rds/free/) y los costos de Fargate en [AWS Fargate pricing](https://aws.amazon.com/es/fargate/pricing/).

Cuando el ambiente no se necesite, destrúyelo:

```powershell
terraform destroy
```

## Limitaciones del ambiente

Este diseño es adecuado para desarrollo y demostración académica. No incluye HTTPS, dominios personalizados, NAT Gateway, subredes privadas para ECS, alta disponibilidad real de base de datos, backups, secretos administrados con Secrets Manager ni políticas completas de observabilidad.

Para producción habría que endurecer la red, mover workloads a subredes privadas, habilitar TLS, gestionar secretos fuera de variables de entorno, configurar backups, monitoreo, alarmas y una estrategia formal de despliegue Blue/Green.
