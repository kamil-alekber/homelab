# Quick Start Guide

This guide will help you get your media services stack up and running quickly.

## Step 1: Prerequisites

Ensure the following are in place:

1. **Samba Storage Backend is running**
   ```bash
   # Verify your Samba server is accessible
   ping 192.168.8.221
   ```

2. **SMB CSI Driver is installed**
   ```bash
   kubectl get pods -n kube-system | grep csi-smb
   ```

3. **Storage configuration is deployed**
   ```bash
   kubectl apply -k ../storage/
   kubectl get storageclass samba-storage
   ```

## Step 2: Deploy Media Services

### Option A: Using the Deploy Script (Recommended)

```bash
cd k8s/media-services
./deploy.sh apply
```

### Option B: Using kubectl directly

```bash
kubectl apply -k k8s/media-services/
```

## Step 3: Verify Deployment

```bash
# Check deployment status
./deploy.sh status

# Or manually
kubectl get all -n media-services
```

Wait for all pods to be in `Running` state:
```bash
kubectl wait --for=condition=available --timeout=300s \
  deployment --all -n media-services
```

## Step 4: Access Services

### For Testing (Port Forward)

```bash
# Sonarr
./deploy.sh port-forward sonarr
# Access at http://localhost:8989

# Radarr
./deploy.sh port-forward radarr
# Access at http://localhost:7878

# Lidarr
./deploy.sh port-forward lidarr
# Access at http://localhost:8686

# qBittorrent
./deploy.sh port-forward qbittorrent
# Access at http://localhost:8080

# SABnzbd
./deploy.sh port-forward sabnzbd
# Access at http://localhost:8080
```

### For Production (Create Ingress)

Create ingress resources for each service. Example:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: sonarr
  namespace: media-services
spec:
  rules:
  - host: sonarr.yourdomain.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: sonarr
            port:
              number: 8989
```

## Step 5: Initial Configuration

### 1. Sonarr (http://localhost:8989)

1. Complete the setup wizard
2. Add download client:
   - Settings → Download Clients → Add qBittorrent
   - Host: `qbittorrent.media-services.svc.cluster.local`
   - Port: `8080`
   - Category: `tv` (optional)
3. Add root folder: `/tv`
4. Configure indexers (Settings → Indexers)

### 2. Radarr (http://localhost:7878)

1. Complete the setup wizard
2. Add download client:
   - Settings → Download Clients → Add qBittorrent
   - Host: `qbittorrent.media-services.svc.cluster.local`
   - Port: `8080`
   - Category: `movies` (optional)
3. Add root folder: `/movies`
4. Configure indexers (Settings → Indexers)

### 3. Lidarr (http://localhost:8686)

1. Complete the setup wizard
2. Add download client:
   - Settings → Download Clients → Add qBittorrent or SABnzbd
   - Host: `qbittorrent.media-services.svc.cluster.local` or `sabnzbd.media-services.svc.cluster.local`
   - Port: `8080`
   - Category: `music` (optional)
3. Add root folder: `/music`
4. Configure indexers (Settings → Indexers)

### 4. qBittorrent (http://localhost:8080)

1. Default credentials: `admin` / `adminadmin` (change immediately!)
2. Configure downloads path: `/downloads`
3. Enable categories if desired:
   - tv → `/downloads/tv`
   - movies → `/downloads/movies`
   - music → `/downloads/music`
4. Configure connection settings for port 6881

### 5. SABnzbd (http://localhost:8080)

1. Complete the setup wizard
2. Configure Usenet server (provide your Usenet provider details)
3. Set download folders:
   - Temporary: `/incomplete-downloads`
   - Completed: `/downloads`
4. Enable categories if desired

## Step 6: Integration Test

1. In Sonarr, add a TV show
2. Search for an episode
3. Send it to qBittorrent
4. Monitor the download in qBittorrent
5. Once complete, verify Sonarr moves it to `/tv`

## Common Commands

```bash
# View logs
./deploy.sh logs sonarr
./deploy.sh logs radarr
./deploy.sh logs qbittorrent

# Restart a service
kubectl rollout restart deployment/sonarr -n media-services

# Check PVC usage
kubectl exec -n media-services deployment/sonarr -- df -h /config /tv /downloads

# Delete everything (careful!)
./deploy.sh delete
```

## Troubleshooting

### Pods stuck in Pending
- Check PVC status: `kubectl get pvc -n media-services`
- Verify storage class exists: `kubectl get storageclass`
- Check events: `kubectl get events -n media-services`

### Permission denied errors
- Verify PUID/PGID in deployments match your storage permissions
- Check Samba share permissions
- Review mount options in storage class

### Services can't communicate
- Verify all pods are running: `kubectl get pods -n media-services`
- Test DNS resolution from a pod:
  ```bash
  kubectl exec -n media-services deployment/sonarr -- \
    nslookup qbittorrent.media-services.svc.cluster.local
  ```

### Storage full
- Check PVC size: `kubectl get pvc -n media-services`
- Monitor usage from any pod:
  ```bash
  kubectl exec -n media-services deployment/sonarr -- df -h
  ```

## Next Steps

1. **Security**: Configure authentication for all services
2. **Monitoring**: Set up Prometheus/Grafana for monitoring
3. **Backup**: Implement automated backups of `/config` directory
4. **Ingress**: Configure proper ingress with TLS certificates
5. **Indexers**: Configure Prowlarr for centralized indexer management
6. **Media Server**: Deploy Jellyfin or Plex to consume the media

## Additional Resources

- [Sonarr Wiki](https://wiki.servarr.com/sonarr)
- [Radarr Wiki](https://wiki.servarr.com/radarr)
- [Lidarr Wiki](https://wiki.servarr.com/lidarr)
- [qBittorrent Documentation](https://github.com/qbittorrent/qBittorrent/wiki)
- [SABnzbd Documentation](https://sabnzbd.org/wiki/)
- [TRaSH Guides](https://trash-guides.info/) - Excellent guides for optimal configuration
