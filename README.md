# Prueba Técnica: Despliegue de Aplicación en GCP con CI/CD

Este repositorio contiene la solución a la prueba técnica para el rol de DevOps / SRE, abarcando la contenerización de una aplicación, la definición de infraestructura y la automatización del ciclo de vida mediante un pipeline de CI/CD.

## 1. Arquitectura Propuesta

La solución plantea una arquitectura Serverless orientada a contenedores, diseñada para ser escalable, segura y de bajo mantenimiento operativo. 

El flujo de la arquitectura es el siguiente:
1. El desarrollador hace un `push` a la rama `main` del repositorio en GitHub.
2. **GitHub Actions** intercepta el evento, ejecuta validaciones de código (linting) y construye la imagen Docker.
3. La imagen validada se sube de forma segura a **Artifact Registry**.
4. Finalmente, GitHub Actions actualiza el servicio en **Cloud Run**, desplegando la nueva versión del contenedor y exponiendo un endpoint HTTPS.

## 2. Servicios de GCP Utilizados

* **Artifact Registry:** Actúa como el repositorio central y privado para las imágenes Docker. Se integra de manera nativa con el esquema de Identity and Access Management (IAM) de Google Cloud.
* **Cloud Run:** Servicio de computación gestionado que ejecuta contenedores de forma serverless. 
* **IAM (Identity and Access Management):** Utilizado a través de una Service Account (Workload Identity o JSON Key) con permisos de mínimo privilegio (Artifact Registry Writer y Cloud Run Developer) para permitir que GitHub Actions interactúe con la nube.

## 3. Justificación de la Solución

* **Eficiencia en Costos y Escalabilidad:** Al utilizar Cloud Run, la infraestructura escala a cero cuando no recibe tráfico, lo cual es ideal tanto para pruebas de concepto ("Hello World") como para entornos de producción con tráfico variable, evitando el sobreaprovisionamiento (a diferencia de gestionar un cluster de GKE).
* **Mantenimiento (NoOps):** Se delega el parcheo del sistema operativo y la gestión de la red subyacente a Google Cloud, permitiendo al equipo de SRE enfocarse en la observabilidad, seguridad y confiabilidad de los despliegues.
* **Seguridad y Mejores Prácticas:** La validación del `Dockerfile` mediante `hadolint` en el pipeline previene vulnerabilidades desde la etapa de integración. Además, el pipeline mantiene las credenciales fuera del código utilizando GitHub Secrets.

## 4. Pipeline de Integración y Despliegue Continuo (CI/CD)

El ciclo de vida de la aplicación está automatizado mediante GitHub Actions (API/.github/workflows/ci-cd.yml). Cada vez que se realiza un push a la rama main, se ejecuta el siguiente flujo:

Validación: Linting del Dockerfile utilizando hadolint.

Autenticación: Conexión segura a Google Cloud mediante Service Accounts configuradas en GitHub Secrets (GCP_PROJECT_ID y GCP_CREDENTIALS).

Construcción y Registro: Compilación de la imagen Docker y publicación en Artifact Registry.

Despliegue: Actualización automática del servicio en Cloud Run, redirigiendo el tráfico a la nueva revisión.



## 5. Desarrollo y Pruebas Locales

### Entorno Docker Tradicional

Si deseas construir y ejecutar la imagen en tu entorno local:

1. Construir la imagen:
   ```bash
   docker build -t hello-world-app:local .
   ```

2. Ejecutar el contenedor:
   ```bash
   docker run -d -p 8000:8000 hello-world-app:local
   ```

### Entorno Kubernetes Local (Minikube)

Para simular u orquestar el entorno en un clúster local de Kubernetes:

Iniciar el clúster y configurar el entorno de Docker para apuntar a Minikube:

```bash
minikube start
eval $(minikube docker-env)
```

Construir la imagen dentro del entorno de Minikube:

```bash
docker build -t hello-world-app:k8s .
```

Aplicar los manifiestos de despliegue (Deployment y Service):

```bash
kubectl apply -f k8s/
```

## 6. Infraestructura como Código (Terraform)

La definición de la infraestructura necesaria en GCP está centralizada en la carpeta /infraestructura. Para validar o inicializar este entorno (se requiere configurar en el archivo cloud_run.tf  los parametros  'project' e 'image' ):

Inicializar el backend y los proveedores:

```bash
terraform init
```

Validar que la sintaxis y la configuración sean correctas:

```bash
terraform validate
```

Generar el plan de ejecución para verificar los recursos a crear:

```bash
terraform plan
```


## 7. Seguridad y Análisis de Vulnerabilidades (DevSecOps)

Como buena práctica de seguridad y mitigación de riesgos, se utilizó Trivy para realizar análisis estático de vulnerabilidades:

Escaneo de la Imagen Docker:

```bash
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy image hello-world-app:local
```


Autor: Marky Alan Rivas Zamora