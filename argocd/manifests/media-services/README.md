# k8s-media-services

This project contains Kubernetes manifests for deploying media services: Sonarr, Radarr, and Prowlarr. Each service has its own set of manifests for deployment, service, ingress, and TLS certificate management.

## Services Overview

### Sonarr
- **Deployment**: `sonarr/deployment.yml`
  - Defines the Kubernetes deployment for Sonarr, specifying the number of replicas, container image, and ports to expose.
  
- **Service**: `sonarr/service.yml`
  - Defines the Kubernetes service for Sonarr, detailing how to access the application and the ports to use.
  
- **Ingress**: `sonarr/ingress.yml`
  - Defines the ingress resource for Sonarr, specifying the rules for routing external traffic to the Sonarr service.
  
- **TLS Certificate**: `sonarr/tls.certificate.yml`
  - Defines the TLS certificate for Sonarr, specifying the secret name and the issuer reference for certificate management.

### Radarr
- **Deployment**: `radarr/deployment.yml`
  - Defines the Kubernetes deployment for Radarr, similar to the Sonarr deployment, with its own specifications for replicas, container image, and ports.
  
- **Service**: `radarr/service.yml`
  - Defines the Kubernetes service for Radarr, detailing how to access the application and the ports to use.
  
- **Ingress**: `radarr/ingress.yml`
  - Defines the ingress resource for Radarr, specifying the rules for routing external traffic to the Radarr service.
  
- **TLS Certificate**: `radarr/tls.certificate.yml`
  - Defines the TLS certificate for Radarr, specifying the secret name and the issuer reference for certificate management.

### Prowlarr
- **Deployment**: `prowlarr/deployment.yml`
  - Defines the Kubernetes deployment for Prowlarr, specifying the number of replicas, container image, and ports to expose.
  
- **Service**: `prowlarr/service.yml`
  - Defines the Kubernetes service for Prowlarr, specifying how to access the application and the ports to use.
  
- **Ingress**: `prowlarr/ingress.yml`
  - Defines the ingress resource for Prowlarr, specifying the rules for routing external traffic to the Prowlarr service.
  
- **TLS Certificate**: `prowlarr/tls.certificate.yml`
  - Defines the TLS certificate for Prowlarr, specifying the secret name and the issuer reference for certificate management.

## Prerequisites
- A Kubernetes cluster up and running.
- `kubectl` configured to interact with your cluster.
- Cert-manager installed for managing TLS certificates.

## Deployment Instructions
1. Clone this repository to your local machine.
2. Navigate to the directory of the service you want to deploy (e.g., `cd sonarr`).
3. Apply the manifests in the following order:
   - TLS Certificate: `kubectl apply -f tls.certificate.yml`
   - Deployment: `kubectl apply -f deployment.yml`
   - Service: `kubectl apply -f service.yml`
   - Ingress: `kubectl apply -f ingress.yml`
4. Repeat the above steps for Radarr and Prowlarr.

## Notes
- Ensure that the DNS records for the services are correctly configured to point to your ingress controller.
- Monitor the pods and services using `kubectl get pods` and `kubectl get services` to ensure everything is running smoothly.