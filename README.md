# Cloud Run Flask Demo (Terraform + Cloud Build)

This repo contains a minimal Flask API and infrastructure-as-code to deploy it to Google Cloud Run using Terraform and Cloud Build.

## What’s included

- **Flask API**: `app/main.py`
- **Container build**: `Dockerfile`
- **Cloud Build pipeline**: `cloudbuild.yaml`
- **Terraform**: `terraform/` (Cloud Run service, Artifact Registry, IAM)

## Prerequisites

- Google Cloud project
- `gcloud` authenticated
- Terraform >= 1.4

## Terraform: provision Cloud Run and Artifact Registry

```bash
cd terraform
terraform init
terraform apply \
  -var="project_id=YOUR_PROJECT_ID" \
  -var="region=us-central1" \
  -var="service_name=flask-demo" \
  -var="artifact_repo=demo-repo"
```

Terraform creates the Cloud Run service (with a placeholder image) and the Artifact Registry repo. It also grants Cloud Build the permissions it needs to deploy.

## Cloud Build: build + deploy

From the repo root:

```bash
gcloud builds submit \
  --config cloudbuild.yaml \
  --substitutions _REGION=us-central1,_SERVICE=flask-demo,_REPO=demo-repo,_IMAGE=flask-api
```

## Demo endpoints

- `GET /` — summary + links
- `GET /health` — health check
- `GET /echo/<value>` — echo input

Example:

```bash
curl https://YOUR_CLOUD_RUN_URL/health
```
