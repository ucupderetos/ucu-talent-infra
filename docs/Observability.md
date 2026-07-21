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

# Dahboard

Dashboard es un panel que muestra en tiempo real las métricas más importanttes del sistema.

Se configuraron las siguientes metricas:

### Cloud Run

- CPU utilization.
- Memory utilization.
- Request latency

### Cloud SQL

- CPU utilization
- Disk utilization
- Connection count

Esto con el objetivo de visualizr el estado desde un único panel.

---

## Alert Policies

Las AlertPolicies generan una notificación cuando una métrica supera un umbral previamente configurado; Con el objetivo de detectar problemas automaticamente sin estar revisando constantemente el dashboard.

## Alertas configuradas

### Cloud Run

#### High CPU Usage Policy

**Umbral:** 80 %

Detecta una alta utilización del procesador del backend.

---

#### High Memory Usage Policy

**Umbral:** 80 %

Detecta un consumo elevado de memoria del servicio.

---

#### High Request Latency Policy

**Umbral:** 1000 ms

Detecta respuestas lentas del backend que pueden afectar la experiencia del usuario.

---

#### HTTP 5xx Error Rate

Filtro: Response Code Class = 5xx

Umbral: Más de una respuesta HTTP

Detecta cuando la aplicación comienza a devolver errores internos del servidor.

---

### Cloud SQL

#### High CPU Usage Policy

**Umbral:** 80 %

Detecta una alta carga del procesador de la base de datos.

---

#### High Memory Usage Policy

**Umbral:** 80 %

Detecta un consumo elevado de memoria de la base de datos.

---

#### High Disk Usage Policy

**Umbral:** 90 %

Detecta cuando el almacenamiento disponible comienza a ser insuficiente.

---

#### High Connection Count Policy

**Umbral:** 80 conexiones

Detecta una cantidad elevada de conexiones simultáneas a la base de datos.

---
