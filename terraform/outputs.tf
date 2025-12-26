output "service_url" {
  description = "Cloud Run service URL"
  value       = google_cloud_run_v2_service.service.uri
}

output "artifact_registry_repo" {
  description = "Artifact Registry repository ID"
  value       = google_artifact_registry_repository.repo.repository_id
}
