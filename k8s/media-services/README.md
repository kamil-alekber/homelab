# Media Services

This directory contains Kubernetes manifests for a complete media automation stack using Kustomize for configuration management.

## Architecture

### Services Included

- **Sonarr** (Port 8989) - TV show management and automation
- **Radarr** (Port 7878) - Movie management and automation
- **Lidarr** (Port 8686) - Music management and automation
- **Prowlarr** (Port 9696) - Indexer manager for Sonarr, Radarr, and Lidarr
- **qBittorrent** (Port 8080, 6881) - Torrent download client
- **SABnzbd** (Port 8080) - Usenet download client

### Storage Architecture

All services share a single PersistentVolumeClaim (`media-shared-storage`) backed by Samba storage, with the following directory structure:

```
/media-shared-storage/
├── config/
│   ├── sonarr/       # Sonarr configuration
│   ├── radarr/       # Radarr configuration
│   ├── lidarr/       # Lidarr configuration
│   ├── prowlarr/     # Prowlarr configuration
│   ├── qbittorrent/  # qBittorrent configuration
│   └── sabnzbd/      # SABnzbd configuration
├── downloads/
│   ├── torrents/     # qBittorrent downloads
│   └── usenet/       # SABnzbd downloads
│       ├── complete/
│       └── incomplete/
└── media/
    ├── tv/           # TV shows (Sonarr)
    ├── movies/       # Movies (Radarr)
    └── music/        # Music (Lidarr)
```

## Prerequisites

1. **Samba Storage**: Ensure the Samba storage class is configured (see `../storage/storageclass.yml`)
2. **Samba CSI Driver**: The SMB CSI driver must be installed in your cluster
3. **Storage Backend**: A Samba/CIFS share accessible at the configured address

## Deployment

### Deploy All Services

To deploy all media services at once:

```bash
kubectl apply -k k8s/media-services/
```

### Deploy Individual Services

To deploy specific services:

```bash
# Deploy only Sonarr
kubectl apply -k k8s/media-services/sonarr/

# Deploy only Radarr
kubectl apply -k k8s/media-services/radarr/

# Deploy only Lidarr
kubectl apply -k k8s/media-services/lidarr/

# Deploy only qBittorrent
kubectl apply -k k8s/media-services/qbittorrent/

# Deploy only SABnzbd
kubectl apply -k k8s/media-services/sabnzbd/
```

### Verify Deployment

```bash
# Check all pods in media-services namespace
kubectl get pods -n media-services

# Check services
kubectl get svc -n media-services

# Check PVC
kubectl get pvc -n media-services
```

## Configuration

### Environment Variables

All services use the following common environment variables:
- `PUID=1000` - User ID for file permissions
- `PGID=1000` - Group ID for file permissions
- `TZ=UTC` - Timezone (adjust as needed)

### Resource Limits

Default resource allocations:

| Service      | CPU Request | CPU Limit | Memory Request | Memory Limit |
|--------------|-------------|-----------|----------------|--------------|
| Sonarr       | 100m        | 500m      | 256Mi          | 512Mi        |
| Radarr       | 100m        | 500m      | 256Mi          | 512Mi        |
| Lidarr       | 100m        | 500m      | 256Mi          | 512Mi        |
| qBittorrent  | 200m        | 1000m     | 512Mi          | 2Gi          |
| SABnzbd      | 200m        | 1000m     | 512Mi          | 2Gi          |

Adjust these in the respective `deployment.yml` files if needed.

## Accessing Services

Services are exposed via ClusterIP. To access them:

### Port Forwarding (for testing)

```bash
kubectl port-forward -n media-services svc/sonarr 8989:8989
kubectl port-forward -n media-services svc/radarr 7878:7878
kubectl port-forward -n media-services svc/lidarr 8686:8686
kubectl port-forward -n media-services svc/qbittorrent 8080:8080
kubectl port-forward -n media-services svc/sabnzbd 8080:8080
```

### Ingress (recommended)

Create Ingress resources to expose services externally. Example ingress can be added to each service directory.

## Integration

### Configure Download Clients

In Sonarr/Radarr/Lidarr, configure download clients:

**qBittorrent:**
- Host: `qbittorrent.media-services.svc.cluster.local`
- Port: `8080`
- Category: Set appropriate category for each service

**SABnzbd:**
- Host: `sabnzbd.media-services.svc.cluster.local`
- Port: `8080`
- Category: Set appropriate category for each service

### Configure Media Paths

Ensure all services use consistent paths:
- **Sonarr**: Root folder `/tv`
- **Radarr**: Root folder `/movies`
- **Lidarr**: Root folder `/music`
- **Download clients**: Map download folders to `/downloads`

## Maintenance

### Update Images

To update a service to the latest image:

```bash
kubectl rollout restart deployment/sonarr -n media-services
kubectl rollout restart deployment/radarr -n media-services
kubectl rollout restart deployment/lidarr -n media-services
kubectl rollout restart deployment/qbittorrent -n media-services
kubectl rollout restart deployment/sabnzbd -n media-services
```

### Backup Configurations

All configurations are stored in the Samba share under `/config/`. Regular backups of this directory are recommended.

### Check Logs

```bash
kubectl logs -n media-services deployment/sonarr
kubectl logs -n media-services deployment/radarr
kubectl logs -n media-services deployment/lidarr
kubectl logs -n media-services deployment/qbittorrent
kubectl logs -n media-services deployment/sabnzbd
```

## Troubleshooting

### PVC Not Binding

Check if the Samba storage class exists and credentials are configured:

```bash
kubectl get storageclass samba-storage
kubectl get secret -n storage samba-credentials
```

### Permission Issues

If you encounter permission issues, verify that:
1. PUID/PGID match the ownership of the Samba share
2. The Samba share allows write access for the configured user
3. Mount options in the StorageClass include appropriate permissions

### Service Won't Start

Check pod events and logs:

```bash
kubectl describe pod -n media-services <pod-name>
kubectl logs -n media-services <pod-name>
```

## Customization with Kustomize

### Adding Overlays

Create environment-specific overlays (dev, prod) in separate directories:

```bash
mkdir -p k8s/media-services/overlays/prod
```

Create a `kustomization.yaml` in the overlay directory that references the base:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

bases:
  - ../../

patchesStrategicMerge:
  - custom-resources.yaml
```

### Modifying Resources

Use Kustomize patches to modify deployments without editing the base files.

## Reference

- Storage Configuration: `../storage/`
- Samba CSI Driver: https://github.com/kubernetes-csi/csi-driver-smb
- LinuxServer.io Images: https://docs.linuxserver.io/
