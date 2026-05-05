# Script de infraestructura académica

Este script en Go ayuda a reducir el consumo de créditos de AWS sin destruir el entorno de Terraform. Funciona igual en Windows, macOS y Linux siempre que Go y AWS CLI estén instalados.

## Pausar

```powershell
go run .\scripts\academic-infra.go stop
```

Esto establece el `desired count` del servicio ECS en `0` y detiene la instancia RDS cuando está disponible.

## Reanudar

```powershell
go run .\scripts\academic-infra.go start
```

Esto inicia RDS, espera hasta que esté disponible y vuelve a establecer el `desired count` del servicio ECS en `1`.

## Configuración

Puedes personalizar los nombres con flags:

```powershell
go run .\scripts\academic-infra.go `
  -region us-east-1 `
  -cluster blacklist-api-dev-cluster `
  -service blacklist-api-dev-service `
  -db blacklist-api-dev-postgres `
  stop
```

El script también lee estas variables de entorno cuando se omiten los flags: `REGION`, `CLUSTER_NAME`, `SERVICE_NAME`, `DB_INSTANCE_IDENTIFIER` y `DESIRED_COUNT`.

## Nota importante sobre costos

Este script no elimina el Application Load Balancer, el repositorio ECR, la VPC ni los security groups. El ALB aún puede generar costos mientras exista. Para obtener el menor costo después de recopilar evidencias, destruye el entorno:

```powershell
terraform -chdir="terraform\environments\dev" destroy
```
