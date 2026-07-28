# Implemenetación de la solución de Monitoring en otros entornos

La solución de Monitoring fue desarrollada utilizando Google Cloud Platform (GCP). Sin embargo, la misma estrategia de observabilidad puede ser aplicada en otros entornos utilizando herramientas equivalentes.

En esta sección se describe como podría implementarse la solución tanto en Microsoft Azure como en un Data Center (On-Premises), manteniendo los mismos objetivos de monitoreo.

---

## Implementación en Microsoft Azure

Microsoft Azure dispone de un conjunto de servicios administrados que permiten construir una solución de Monitoring equivalente a la que fue implementada en Google Cloud Platform. Estos servicios recopilan la información de la infraestructura y las aplicaciones para facilitar la supervisión en tiempo real y la detección de incidentes.

| Función | Servicio en Azure |
| ------- | ----------------- |
| Monitoreo de métricas | Azure Monitor |
| Gestión de logs | Log Analytics |
| Alertas | Azure Monitor Alerts |
| Dashboards | Azure Dashboards o Azure Workbooks |
| Error Reporting | Application Insights |

---

### Monitoreo de métricas

**Azure Monitor** recopila automáticamente métricas provenientes de los recursos desplegados en la nube, como máquinas virtuales, contenedores, bases de datos y aplicaciones.

Para una infraestructura similar a la utilizada en este proyecto, las principales métricas serían:

- Utilización de CPU.
- Utilización de memoria.
- Cantidad de solicitudes recibidas.
- Latencia de las solicitudes.
- Tasa de errores HTTP.
- Cantidad de conexiones activas a la base de datos.
- Uso de almacenamiento.

Estas métricas permiten conocer el estado general de la infraestructura y detectar posibles degradaciones en el rendimiento antes de que afecten a los usuarios.

---

### Dashboards

La información recopilada por **Azure Monitor** también puede organizarse a través de dashboards personalizados en **Azure Dashboards** o **Azure Workbooks**, al igual que en GCP. Aquí tambien una buena practica sería separar los paneles a los distintos ambientes (DEV y PROD), donde cada dashboard podria incluir:

- Uso de CPU.
- Uso de memoria.
- Latencia de las solicitudes.
- Cantidad de solicitudes.
- Errores HTTP.
- Estado de la base de datos.

Esto facilita el análisis del estado de cada ambiente y simplifica la detección de incidentes.

---

### Gestión de logs

Los registros generados por las aplicaciones y los servicios son enviados automáticamente a **Log Analytics**, donde quedan almacenados para después poder consultarlos.

En este servicio es posible:

- Buscar registros especificos.
- Filtrar registros por recurso.
- Analizar solicitudes realizadas.
- Investigar errores.
- Consultar el historial de errores.

Durante una investigación de incidentes, los logs permiten identificar con precisión qué ocurrió, cuándo y qué componente fue involucrado.

---

### Error Reporting (lo más cercano)

Azure no cuenta con el servicio Error Reporting como en GCP, pero lo más cercano a en Azure es **Application Insights**, un servicio al monitoreo del comportamiento de las aplicaciones, en donde el servicio registra automáticamente:

- Excepciones.
- Solicitudes fallidas.
- Dependencias externas.
- Tiempos de respuesta.
- Rendimiento de la aplicación.
- Stack traces (trazas de las excepciones).

En donde la información recopilada facilita la identificación de errores de software y permite reducir el tiempo necesario para diagnosticar incidentes.

---

### Alertas

Azure Monitor permite definir reglas en **Azure Monitor Alerts** que generan alertas cuando una metrica supera un umbral previamente establecido.

Cuando una condición se cumple, al igual que GCP, Azure genera un incidente y envia nitificaciones a través de Action Groups, utilizando un correo electrónico, Microsoft Teams o SMS. 

Las políticas de alerta pueden configurarse para supervisar métricas como el uso de CPU, memoria, latencia, errores HTTP o el estado de la base de datos, permitiendo detectar problemas de forma temprana.

---

## Implementación en un Data Center (On-Premises)

A diferencia de las plataformas cloud como Google Cloud Platform (GCP) o Microsoft Azure, un Data Center (On-Premises) no dispone de servicios administrados para el monitoreo de la infraestructura. En estos entornos, la observabilidad se consigue a través un conjunto de herramientas especializadas que permiten recopilar métricas, gestionar logs, visualizar el estado de los sistemas y detectar incidentes.

Una solución de monitoreo en un Data Center podría estar compuesta por las siguientes herramientas:

| Función | Herramienta |
| ------- | ----------- |
| Monitoreo de métricas | Prometheus |
| Gestión de logs | Elasticsearch + Kibana |
| Alertas | Alertmanager |
| Dashboards | Grafana |
| Recolección de logs | Fluent Bit o Filebeat |
| Error Reporting | Application Performance Monitoring (APM) |

---

### Monitoreo de métricas

El monitoreo de métricas es realizado por **Prometheus**, una herramienta encargada de recopilar información sobre el estado y el rendimiento de servidores, aplicaciones y bases de datos.

Entre las principales métricas que pueden supervisarse se encuentran:

- Utilización de CPU.
- Utilización de memoria.
- Cantidad de solicitudes.
- Latencia de las solicitudes.
- Tasa de errores HTTP.
- Cantidad de conexiones activas a la base de datos.
- Uso de almacenamiento.

Estas métricas nos permiten evaluar el estado de la infraestructura y detectar posibles problemas de rendimiento o disponibilidad.

---

### Dashboards

Las métricas recopiladas por Prometheus pueden visualizarse mediante **Grafana**, una plataforma utilizada para crear dashboards interactivos.

Al igual que en GCP, una buena práctica consiste en separar los dashboards por ambiente (DEV y PROD), permitiendo visualizar de forma independiente el comportamiento de cada entorno.

Cada dashboard podría incluir información como:

- Uso de CPU.
- Uso de memoria.
- Latencia de las solicitudes.
- Cantidad de solicitudes.
- Errores HTTP.
- Estado de la base de datos.

Esta organización facilita la supervisión de la infraestructura y la detección de incidentes.

---

### Gestión de logs

La gestión de logs puede realizarse mediante herramientas como **Fluent Bit** o **Filebeat**, responsables de recopilar los registros generados por aplicaciones y servidores.

Posteriormente, los registros son almacenados en **Elasticsearch** y consultados mediante **Kibana**, permitiendo:

- Buscar registros específicos.
- Filtrar eventos por servidor o aplicación.
- Analizar solicitudes realizadas.
- Investigar errores.
- Consultar el historial de eventos.

Durante una investigación de incidentes, los logs permiten identificar qué ocurrió, cuándo ocurrió y qué componente estuvo involucrado.

---

### Error Reporting

En un Data Center no existe un servicio específico equivalente a **Error Reporting** de GCP o **Application Insights** de Azure.

La identificación de errores se basa principalmente en la información registrada en los logs y, cuando la solución lo incorpora, en herramientas de **Application Performance Monitoring (APM)**.

Entre la información que puede obtenerse se encuentra:

- Excepciones.
- Errores de aplicación.
- Solicitudes fallidas.
- Tiempos de respuesta.
- Stack traces (cuando la aplicación los registra).

Esta información facilita el análisis de incidentes y ayuda a determinar el origen de los errores detectados.

---

### Alertas

La gestión de alertas es realizada por **Alertmanager**, herramienta encargada de procesar las alertas generadas a partir de las métricas recopiladas por Prometheus.

Estas alertas permiten identificar situaciones que requieren atención, como:

- Uso elevado de CPU.
- Uso elevado de memoria.
- Poco espacio disponible en disco.
- Latencia elevada.
- Servicios no disponibles.
- Alto número de errores HTTP.

Cuando se detecta alguna de estas condiciones, Alertmanager puede enviar notificaciones mediante distintos canales, como correo electrónico, Microsoft Teams o Slack.