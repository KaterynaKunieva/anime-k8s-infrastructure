# Anime Microservices Infrastructure

This repository is the central hub for orchestrating the Anime Application.
It manages production deployment to Google Cloud Platform (GCP) using Google Kubernetes Engine (GKE).

## System Architecture

System follows a microservices architecture pattern, consisting of the following components:

- [React Redux App SPA](https://github.com/KaterynaKunieva/anime-react-redux-app)
- [Spring Boot Anime & Author API](https://github.com/KaterynaKunieva/anime-spring-rest-api)
- [Node.js Episodes REST API](https://github.com/KaterynaKunieva/anime-node-js-rest-api)
- [Spring Boot Email Service (RabbitMQ & Elasticsearch)](https://github.com/KaterynaKunieva/email-service-rabbitmq-elasticsearch)
- [Spring Boot Google OAuth2 Gateway](https://github.com/KaterynaKunieva/anime-oauth-gateway)

## CI/CD Workflow

The project uses a distributed CI/CD strategy across multiple repositories, orchestrated via GitHub Actions.

### Build & Push (Service Repositories)

Each individual service repository contains a build-and-push script. On every commit to the main or master branch:

- The Docker image is built and pushed to the GitHub Container Registry (GHCR)
- A repository_dispatch event is sent to this infrastructure repository to trigger the deployment

### Global Deployment (Infrastructure Repository)

The Deployment to GKE workflow acts as the final orchestrator. It performs the following tasks:

- Authenticates to Google Cloud
- Configures kubectl for the GKE cluster
- Ensures required infrastructure components exist (Nginx Ingress, namespaces, application secrets)
- Dynamically updates kustomize manifests with new image versions
- Applies manifests to the cluster
- Selectively restarts affected deployments
- Supports automated triggers from service repositories and manual deployments with fine-grained service selection

## Kubernetes Configuration (Kustomize)

The repository uses Kustomize to manage Kubernetes manifests, enabling the CI/CD pipeline to update container image versions dynamically during deployment.

**Manifest Organization:**
- Each microservice is defined by a deployment.yml with container configuration, resource limits, and health probes
- Corresponding service.yml files handle internal networking
- The command `kubectl apply -k kustomize/` assembles all manifests and applies them to the cluster as a single, consistent deployment

**Health & Resource Management:**
- All deployments include livenessProbe and readinessProbe for automatic detection and restart of unhealthy containers
- CPU and memory limits are defined for every service to ensure fair resource usage and prevent any single component from exhausting cluster resources

## Ingress

**Traffic Routing:**
- The Ingress controller listens for incoming requests on `${INGRESS_HOST}`
- Requests starting with /api or /oauth are forwarded to the OAuth Gateway
- All other requests (/) are routed to the Frontend React application on port 80

**Security & Isolation:**
- All backend services are exposed as ClusterIP
- Services are accessible only from within the cluster or via the Ingress
- Internal APIs remain isolated and secure