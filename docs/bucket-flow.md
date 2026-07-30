# Bucket Flow

## Descripción

Para guardar las fotos de perfil de los usuarios y CVs utilizamos un bucket en **Google Cloud Storage** de **GCP**.

### Flow

- El Cliente (Frontend) sube un CV o foto de perfil realizando una peticion HTTPS al Backend, el Back es el encargado de subir el archivo al bucket mediante el **SDK** de **Google Cloud**.

- Luego de subido el archivo, el bucket genera una url con el archivo la cual es enviada al back.

- Esta url no es accesible al publico, por lo que el back con la Service Account que viene por Default en la instancia de Cloud Run (Compute Engine) solicita al bucket esta url firmada para que sea accesible durante cierto tiempo.

- Bucket devuelve la url firmada accesible.

#### Cabe aclarar que este flujo de la funcionalidad solo esta permitido en las aplicaciones desplegadas, ya que localmente preferimos no compartirles a los dev la key de la Service Account por temas de seguridad.

---

### Diagrama de Secuencia

![Bucket flow](diagrams/bucket-flow.png)
