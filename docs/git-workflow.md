# Git Workflow

Este proyecto utiliza Git flow como estrategia de control de versiones.

## Ramas

| Rama | Descripción |
|----------|---------------|
| main |  |
| dev |  |
| feature/* | Se usa para desarrollar nuevas funcionalidades |
| bugfix/* | Se usa para corregir errores en entornos de desarrollo o pruebas(dev) |
| hotfix/* | Se usa para corregir errores críticos en produccion (main) |
| release/* | Se usa para preparar una nueva versión antes de publicarla |
| refactor/* | Se usa para reorganizar o mejorar la estructura del codigo sin modificarle el funcionamiento |
| chore/* | Se usa para tareas de mantenimiento, configurción o actualizacion de dependencias |
| docs/* | Se usa para cambios exclusivos en la documentación |

## Cómo contribuir

1. Actualizar la rama dev.
2. Crear una nueva rama.
3. Realizar los cambios.
4. Hacer commit.
5. Subir la rama al repositorio.
6. Crear un Pull Request hacia dev.
7. Esperar la aprobación.
8. Hacer merge.

## Reglas

* No realizar push directo a **main** o a **dev**.
* Todos los cambios realizados deben pasar por un Pull request.
* Se requiere al menos una aprobacion antes del merge.
