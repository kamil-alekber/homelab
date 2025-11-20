# Sonobarr

Sonobarr is an AI-powered music discovery tool that integrates with Lidarr to help you discover and add new artists to your music library.

## Features

- AI-powered artist recommendations using OpenAI
- Integration with Last.fm for music discovery
- YouTube integration for music exploration
- Automatic album discovery and addition to Lidarr
- Web-based interface for managing discoveries

## Configuration

### Prerequisites

1. **Lidarr**: Must be running and accessible within the cluster
2. **API Keys**: Configure the following API keys in the secret:
   - `lidarr_api_key` (required)
   - `last_fm_api_key` and `last_fm_api_secret` (optional)
   - `youtube_api_key` (optional)
   - `openai_api_key` (optional)
   - `sonobarr_superadmin_password` (required)

### Secret Configuration

Edit `secret.yml` and populate the following fields:

```yaml
stringData:
  lidarr_api_key: "your-lidarr-api-key"
  sonobarr_superadmin_password: "your-secure-password"
  # Optional
  last_fm_api_key: "your-lastfm-key"
  last_fm_api_secret: "your-lastfm-secret"
  youtube_api_key: "your-youtube-key"
  openai_api_key: "your-openai-key"
```

### Environment Variables

The deployment is configured with the following key settings:

- **Lidarr Integration**:
  - `LIDARR_ADDRESS`: Points to the in-cluster Lidarr service
  - `ROOT_FOLDER_PATH`: `/data/music/` (matches shared storage structure)
  
- **Discovery Settings**:
  - `SIMILAR_ARTIST_BATCH_SIZE`: 10
  - `AUTO_START`: false (manual discovery trigger)
  - `OPENAI_MODEL`: gpt-4o-mini

- **Super Admin**:
  - Username: `admin`
  - Password: From secret
  - Display Name: `Super Admin`

## Deployment

### Deploy Sonobarr

```bash
# Deploy only Sonobarr
kubectl apply -k k8s/media-services/sonobarr/

# Or deploy with all media services
kubectl apply -k k8s/media-services/
```

### Verify Deployment

```bash
# Check pod status
kubectl get pods -n media-services -l app=sonobarr

# Check service
kubectl get svc -n media-services -l app=sonobarr

# View logs
kubectl logs -n media-services -l app=sonobarr -f
```

## Access

Once deployed, Sonobarr will be accessible at:
- **URL**: https://sonobarr.clusterlab.cc
- **Login**: Use the admin credentials configured in the secret

## Storage

Sonobarr uses the shared media storage PVC (`media-shared-storage`) with the following mounts:

- **Config**: `/storage/shared/sonobarr/config` - Application configuration and database
- **Media**: `/data` - Read-only access to media library (same as Lidarr)

## Resources

- **Requests**: 256Mi memory, 100m CPU
- **Limits**: 512Mi memory, 500m CPU

## Integration with Lidarr

Sonobarr connects to Lidarr using the in-cluster service URL:
```
http://lidarr.media-services.svc.cluster.local
```

Make sure to:
1. Get your Lidarr API key from Lidarr Settings → General
2. Add it to the `sonobarr-secrets` secret
3. Verify that Lidarr is accessible from within the cluster

## Troubleshooting

### Cannot connect to Lidarr
```bash
# Test connectivity from sonobarr pod
kubectl exec -n media-services -it deploy/sonobarr -- wget -O- http://lidarr.media-services.svc.cluster.local/ping
```

### View application logs
```bash
kubectl logs -n media-services -l app=sonobarr --tail=100 -f
```

### Check secret configuration
```bash
kubectl get secret sonobarr-secrets -n media-services -o yaml
```

## Links

- [Sonobarr GitHub](https://github.com/Dodelidoo-Labs/sonobarr)
- [Sonobarr Documentation](https://github.com/Dodelidoo-Labs/sonobarr/blob/develop/README.md)
