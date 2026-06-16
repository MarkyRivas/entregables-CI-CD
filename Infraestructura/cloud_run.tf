terraform {
  required_version = ">= 1.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

provider "google" {

  project = "proyecto-semilla-449200" 
  region  = "us-central1"
}

resource "google_project_service" "run" {
  project = "proyecto-semilla-449200"
  service = "run.googleapis.com"
}

resource "google_project_service" "artifact_registry" {
  project = "proyecto-semilla-449200"
  service = "artifactregistry.googleapis.com"
}

resource "google_cloud_run_service" "fast_api_test" {
  name     = "fast-api-test"
  location = "us-central1"

  template {
    spec {
      containers {
        image = "us-central1-docker.pkg.dev/proyecto-semilla-449200/cloud-run-source-deploy/fast-api-test@sha256:84b743c283ae6c35282436b120eef036c37c0345ff25b451dc6113fe33d4d0bc"

        ports {
          container_port = 8000
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  depends_on = [
    google_project_service.run,
    google_project_service.artifact_registry,
  ]
}
