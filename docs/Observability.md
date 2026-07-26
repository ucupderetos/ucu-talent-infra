# Observabilidad del proyecto

## Objetivo

Implementar una estrategia básica de obserbavilidad para el portal laboral utilizando los servicios de Google Cloud Platform, con el fin de monitorear el estado de la infraestructura, detectar problemas de rendimiento y facilitar el diagnóstico de errores.

---

## Cloud Logging

Cloud Logging es el servicio de Google Cloud que se encarfa de almacenar los registrios (logs) generados por la infraestructura y la aplicación.

Los logs registran los eventos como:

- Solicitudes recibidas.
- Errores de la aplicación.
- Inicio y finalización de servicios.
- Eventos de Cloud Run y Cloud SQL.

Cloud Logging se utilza para investigar errores e incidentes, ayudando al equipo de desarrollo a  identificar rápidamente la causa de un probema.

---

## Cloud Moitoring

Cloud Monitoring es el que recopila métricas de los recusos desplegados y las presenta a través de gráficos en tiempo real.

Entre las métricas monitoreadas se encuentran:

- Uso de CPU.
- Uso de memoria.
- Latencia de las solicitudes.
- Uso del disco.
- Cantidad de conexiones.

Cloud Monitoring se utiliza para conocer el estado de la infraestructura y detectar posibles problemas problemas de rendimiento antes de que los usuarios sean afectados.

---

## Dahboard

Un Dashboard es un panel de visualización que reúne en un solo lugar las principales métricas de los recursos de la infraestructura.

Su objetivo es facilitar el monitoreo en tiempo real del estado de los servicios, permitiendo identificar rápidamente comportamientos fuera de lo normal, analizar el rendimiento y apoyar la investigación cuando se genera una alerta o un incidente.

Para este proyecto se crearon dos dashboards: uno para **Cloud Run** y otro para **Cloud SQL**, cada uno con las métricas más relevantes de los recursos que monitorea.

---

### Dashboard de Cloud Run

Se creó un dashboard dedicado al monitoreo del servicio **Cloud Run**, con el objetivo de visualizar en tiempo real el estado y rendimiento de la aplicación desplegada.

Las métricas incluidas son:

- High CPU Usage Policy
- High Memory Usage Policy
- High Request Latency Policy
- HTTP 5xx Error Alert Policy

Este dashboard permite detectar aumentos en la carga del servicio, problemas de rendimiento y posibles degradaciones en los tiempos de respuesta.

---

### Dashboard de Cloud SQL

Se creó un dashboard dedicado al monitoreo de la instancia de **Cloud SQL**, permitiendo supervisar en tiempo real el estado y rendimiento de la base de datos.

Las métricas incluidas son:

- High CPU Usage Policy 
- High Memory Usage Policy 
- High Disk Usage Policy
- High Connection Count Policy .

Este dashboard facilita la detección de saturación de recursos, incrementos en la carga de la base de datos y otros comportamientos que puedan afectar el funcionamiento de la aplicación.

---

## Alert Policies

Las AlertPolicies generan una notificación cuando una métrica supera un umbral previamente configurado; Con el objetivo de detectar problemas automaticamente sin estar revisando constantemente el dashboard.

## Alertas configuradas

### Cloud Run

#### High CPU Usage Policy

**Umbral:** 90 %

Detecta una alta utilización del procesador del backend.

---

#### High Memory Usage Policy

**Umbral:** 90 %

Detecta un consumo elevado de memoria del servicio.

---

#### High Request Latency Policy

**Umbral:** 1000 ms

Detecta respuestas lentas del backend que pueden afectar la experiencia del usuario.

---

#### HTTP 5xx Error Alert

**Filtro:** Response Code Class = 5xx

**Umbral:** Más de una respuesta HTTP

Detecta cuando la aplicación comienza a devolver errores internos del servidor.

---

### Cloud SQL

#### High CPU Usage Policy

**Umbral:** 90 %

Detecta una alta carga del procesador de la base de datos.

---

#### High Memory Usage Policy

**Umbral:** 90 %

Detecta un consumo elevado de memoria de la base de datos.

---

#### High Disk Usage Policy

**Umbral:** 90 %

Detecta cuando el almacenamiento disponible comienza a ser insuficiente.

---

#### High Connection Count Policy

**Umbral:** 90 conexiones

Detecta una cantidad elevada de conexiones simultáneas a la base de datos.

---

## Error Reporting

Error Reporting es un servocio de Google Cloud que recopila, agrupa y muestra automáticamente los errores generados por las aplicaciones que ejecutan servicios como cloud Run.

Error Reporting se utiliza para analizar los registros enviados a Cloud Logging e identifica excepciones, errores y fallos repetitivos. Estos son agrupados automáticamente, mostrando:

- Tipo de error.
- Cantidad de occurrencias.
- Fecha y hora de la prueba y última aparición.
- Traza del error.
- Servicio y versión afectados.

