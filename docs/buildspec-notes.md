# Buildspec para CodeBuild

El archivo `buildspec.yml` define el comportamiento del proceso de construccion en AWS CodeBuild.

## Flujo configurado

1. Instala dependencias de Python desde `requirements.txt`.
2. Ejecuta las pruebas unitarias con `pytest`.
3. Genera un artefacto comprimido llamado `beanstalk.zip`.

## Comando de pruebas

```powershell
python -m pytest tests -q
```

## Artefacto generado

El build produce `beanstalk.zip`, que puede almacenarse como salida del proceso de CI para una etapa posterior de despliegue manual.

## Alcance

Este archivo solo cubre integracion continua:

- instala dependencias,
- valida el codigo con pruebas,
- genera el artefacto.

No realiza despliegues automaticos.
