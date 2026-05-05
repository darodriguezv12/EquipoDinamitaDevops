# Script de infraestructura academica

Este script en Go ayuda a reducir consumo de creditos de AWS sin destruir el entorno de Terraform. Funciona igual en Windows, macOS y Linux siempre que Go y AWS CLI esten instalados.

## Pausar

```powershell
go run .\scripts\stop-or-resume-infra.go stop
```

Esto establece el `desired count` del servicio ECS en `0`. En la practica apaga las tareas Fargate del microservicio.

## Reanudar

```powershell
go run .\scripts\stop-or-resume-infra.go start
```

Esto vuelve a establecer el `desired count` del servicio ECS en `1`.

## Configuracion

Puedes personalizar los nombres con flags:

```powershell
go run .\scripts\stop-or-resume-infra.go `
  -region us-east-1 `
  -cluster blacklist-api-dev-cluster `
  -service blacklist-api-dev-service `
  stop
```

El script tambien lee estas variables de entorno cuando se omiten los flags: `REGION`, `CLUSTER_NAME`, `SERVICE_NAME` y `DESIRED_COUNT`.

## Nota importante sobre costos

Este script no apaga RDS porque tarda varios minutos en detenerse y arrancar de nuevo. Tampoco elimina el Application Load Balancer, el repositorio ECR, la VPC ni los security groups. RDS y el ALB pueden seguir generando costos mientras existan.

Para obtener el menor costo despues de recopilar evidencias, destruye el entorno:

```powershell
terraform -chdir="terraform\environments\dev" destroy
```
