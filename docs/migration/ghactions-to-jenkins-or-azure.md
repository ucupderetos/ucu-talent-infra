# Migración de CI/CD: de GitHub Actions a Azure DevOps o Jenkins

En este documeto se explica como sería el proceso de migrar los pipelines actuales del backend en Java y frontend en Next.js, ambos con Docker y despliegados en Google Cloud Run desde GitHub Actions hacia Azure DevOps o hacia un servidor Jenkins.

En los tres casos, la lógica de fondo es la misma:

1. Correr los tests.
2. Construir la imagen Docker y escanearla en busca de vulnerabilidades.
3. Si el código llega a la rama `dev` o `main`, construir la imagen final, subirla al registro de imágenes de Google Cloud y desplegarla en Cloud Run.

Lo que cambia entre plataformas no es esa lógica, sino donde están las configuraciones , cómo se guardan los secrets y las keys, y quién corre los procesos.

## 1. Migrar a Azure DevOps

Azure DevOps es muy parecido a GitHub Actions ya que también se define un flujo de trabajo automático que se dispara con un cambio en el repositorio, y ese flujo se organiza en capas como si fuesen jobs de Github actions.

Qué cambiaría:

- Los workflows actuales pasarían a llamarse "pipelines", y en vez de tener un archivo por proceso, normalmente se centraliza todo en un único archivo de pipeline con distintas etapas (tests, construcción de la imagen, despliegue a dev o a prod).
- Los secrets almacenados en el Secret Manager de GCP se guardan en un espacio llamado "grupo de variables", que puede estar conectado a una bóveda de secretos de Azure para mayor seguridad. Es el reemplazo directo de los secretos y variables que hoy están en GitHub.
- Las aprobaciones antes de desplegar a producción tienen un equivalente directo en Azure: se puede configurar que el despliegue a producción quede pausado hasta que una persona lo apruebe manualmente.
- La ejecución puede hacerse en máquinas administradas por Microsoft, como github levanta un `ubuntu-latest`, sin necesidad de mantener servidores propios.
- La key de la cuenta de servicio que hoy está guardada como secreto de GitHub, se configuran como una "conexión de servicio" hacia Google Cloud dentro de Azure DevOps.

En resumen: la migración a Azure DevOps es la más "natural", porque el workflow es prácticamente el mismo. El esfuerzo principal está en reconfigurar dónde se guardan los secretos y en traducir cada paso a su equivalente en Azure.

## 2. Migrar a un servidor Jenkins

Jenkins es un servidor que hay que instalar y mantener, propio o en una máquina virtual, y habria que instalar las herramientas necesarias como Docker por ejemplo antes de poder ejecutar cualquier pipeline.

Qué cambiaría:

- Cada repositorio tendría un archivo de definición de pipeline propio, que Jenkins detecta automáticamente y ejecuta cuando hay cambios en el código. El concepto es similar al de los workflows de GitHub, pero la sintaxis y la forma de organizarlo son distintas.
- Las credenciales y contraseñas se pueden guardan en un almacén de credenciales dentro del propio Jenkins. Cada pipeline las consulta desde ahí en el momento que las necesita.
- Las aprobaciones manuales antes de producción no vienen automáticamente incluidas como en GitHub o Azure; hay que agregarlas explícitamente como un paso de "pausa" dentro del pipeline, donde alguien debe confirmar antes de continuar.
- La ejecución del pipeline depende de los servidores propios: a diferencia de GitHub o Azure, aquí es necesario mantener, actualizar y asegurar el servidor Jenkins y sus agentes de trabajo, incluyendo instalar y mantener actualizadas todas las herramientas que usan los pipelines.

En resumen: migrar a Jenkins da más control sobre la infraestructura, lo que es muy util para no depender tanto de un proveedor de nube, pero da mucho más trabajo de mantenimiento, ya que hay que administrar el servidor mismo, no solo la configuración de los pipelines.

## 3. Cómo elegir entre las dos opciones

| Si priorizas... | Conviene más... |
|---|---|
| Mantener el mismo workflow y tocar lo menos posible | Azure DevOps |
| No depender de servidores propios ni de su mantenimiento | Azure DevOps |
| Tener control total sobre dónde y cómo corre el pipeline | Jenkins |
| Evitar costos de un servicio en la nube y ya contar con un servidor propio disponible | Jenkins |
| Minimizar el trabajo de mantenimiento del equipo | Azure DevOps |
