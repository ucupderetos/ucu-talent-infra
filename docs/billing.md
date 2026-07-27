# Costos por uso de la infraestructura (mensual)

Con el objetivo de conocer el consumo de los recursos utilizados por la infraestructura desplegada en Google Cloud Platform (GCP), se consultó el reporte de facturación correspondiente por mes. Los valores presentados representan el costo por uso de cada uno de los servicios durante el período analizado.

| Servicio | Costo por uso (USD) |
|----------|---------------|
| Artifact Registry | $0.07 |
| Cloud Run | $1.32 |
| Cloud DNS | $0.23 |
| Cloud SQL | $52.44 |
| **Total** | **$54.06** |

> **Nota:** Los costos corresponden al consumo registrado durante el período mensual analizado. El monto facturado puede variar debido a la aplicación de créditos promocionales, beneficios del Free Tier u otros descuentos otorgados por Google Cloud Platform (GCP).

Durante el período analizado, **Cloud SQL** representó el mayor costo de la infraestructura, debido a que mantiene una instancia en ejecución para el almacenamiento y gestión de la base de datos. En comparación, los costos de **Cloud Run**, **Cloud DNS** y **Artifact Registry** fueron considerablemente menores, ya que dependen del nivel de utilización de cada servicio.