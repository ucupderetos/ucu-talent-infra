# Git Workflow

Este proyecto utiliza Git flow como estrategia de control de versiones.

## ¿Qué es Git Flow?

Es una estrategia de trabajo para organizar el desarrollo de un proyecto utilizando ramas en Git. El objetivo de esto es permitir que varios desarrolladores trabajen en paralelo sin afectar la estabilidad del codigo principal.

Cada cambio se desarrolla en ramas inependientes y una ves revisado y aprovado mediante un Pull Request, se integra ala rama correspondiente

## Nomenclatura de Ramas

Todas las ramas se crean a partir de **dev**, excepto las ramas **hotfix/** que se crean a partir de **main** para corregir errores críticos en producción.

La estructura del nombre de una rama es la siguiente:

**tipo/descripción**

En donde:
**tipo**: indica el tipo de rama.
**descripción**: describe brevemente la tarea a realizar en la rama.

| Tipo de rama | Descripción |
|----------|---------------|
| main | Contiene la versión estable del proyecto |
| dev | Es la rama principal de desarrollo donde se guardan los cambios aprobados |
| feature/* | Se usa para desarrollar nuevas funcionalidades |
| bugfix/* | Se usa para corregir errores en entornos de desarrollo o pruebas(dev) |
| hotfix/* | Se usa para corregir errores críticos en producción (main) |
| release/* | Se usa para preparar una nueva versión antes de publicarla |
| refactor/* | Se usa para reorganizar o mejorar la estructura del codigo sin modificarle el funcionamiento |
| chore/* | Se usa para tareas de mantenimiento, configurción o actualización de dependencias |
| docs/* | Se usa para cambios exclusivos en la documentación |

## Cómo contribuir

1. Actualizar la rama **dev**.
2. Crear una nueva rama.
3. Realizar los cambios.
4. Hacer commit.
5. Subir la rama al repositorio.
6. Crear un Pull Request hacia **dev**.
7. Esperar la aprobación.
8. Hacer merge.
9. Actualizar la rama **dev** local.
10. 
eliminar la rama utilizada.

## Reglas

* No realizar push directo a **main** o a **dev**.
* Todos los cambios realizados deben pasar por un Pull request.
* Se requiere al menos una aprobacion antes del merge.
