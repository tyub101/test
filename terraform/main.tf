terraform {
  required_version = ">= 1.4.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

data "google_project" "project" {}

locals {
  cloudbuild_sa = "${data.google_project.project.number}@cloudbuild.gserviceaccount.com"
}

resource "google_project_service" "services" {
  for_each = toset([
    "run.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudbuild.googleapis.com",
  ])

  project            = var.project_id
  service            = each.value
  disable_on_destroy = false
}

resource "google_artifact_registry_repository" "repo" {
  location      = var.region
  repository_id = var.artifact_repo
  description   = "Artifact Registry for Cloud Run demo"
  format        = "DOCKER"

  depends_on = [google_project_service.services]
}

resource "google_service_account" "run_service" {
  account_id   = "${var.service_name}-sa"
  display_name = "Cloud Run service account for ${var.service_name}"
}

resource "google_cloud_run_v2_service" "service" {
  name     = var.service_name
  location = var.region

  template {
    containers {
      image = "us-docker.pkg.dev/cloudrun/container/hello"
    }

    service_account = google_service_account.run_service.email
  }

  depends_on = [google_project_service.services]
}

resource "google_project_iam_member" "cloudbuild_run_admin" {
  project = var.project_id
  role    = "roles/run.admin"
  member  = "serviceAccount:${local.cloudbuild_sa}"
}

resource "google_project_iam_member" "cloudbuild_artifact_writer" {
  project = var.project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${local.cloudbuild_sa}"
}

resource "google_service_account_iam_member" "cloudbuild_sa_user" {
  service_account_id = google_service_account.run_service.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${local.cloudbuild_sa}"
}
