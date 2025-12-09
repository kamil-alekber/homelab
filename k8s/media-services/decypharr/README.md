# Decypharr - WebDAV Cloud Storage Mounter

## Overview
Decypharr (cy01/blackhole) is a WebDAV-based cloud storage mounter that enables mounting Real-Debrid or other WebDAV sources as local filesystems using FUSE.

## Kubernetes Deployment

### Special Requirements

#### 1. Privileged Container
Decypharr requires privileged access to mount FUSE filesystems:
```yaml
securityContext:
  privileged: true
  capabilities:
    add:
    - SYS_ADMIN
```

#### 2. Mount Propagation
The deployment uses `Bidirectional` mount propagation to ensure FUSE mounts are visible to both the container and the host:
```yaml
volumeMounts:
- name: shared-storage
  mountPath: /mnt
  mountPropagation: Bidirectional
```

#### 3. Device Access
The container needs access to `/dev/fuse` which is automatically available in Kubernetes nodes.

### NixOS Configuration

No additional packages or kernel modules are required on NixOS hosts for WebDAV/FUSE support:
- **FUSE support**: Already included in the Linux kernel
- **WebDAV client**: Handled by the container image
- **Existing kernel modules**: `br_netfilter` and `overlay` (already configured for K3s)

The existing K3s configuration in `nix/modules/k3s-server.nix` and `nix/modules/k3s-agent.nix` is sufficient.

## Configuration

### Initial Setup
1. Deploy the manifests: `kubectl apply -k k8s/media-services/decypharr/`
2. Access the web interface at `https://decypharr.clusterlab.cc`
3. Create a `config.json` file in `/storage/shared/decypharr/`

### Example config.json
```json
{
  "webdav": {
    "url": "https://your-webdav-server.com/dav/",
    "username": "your-username",
    "password": "your-password"
  },
  "mount_point": "/mnt/webdav",
  "options": {
    "allow_other": true,
    "auto_unmount": true
  }
}
```

## Storage Structure
```
/storage/shared/decypharr/     - Configuration files (config.json)
/mnt/                          - WebDAV mount points (bidirectional)
```

## Integration

### Homepage Dashboard
Decypharr is integrated into the homepage dashboard under "Download Clients" category.

### Use with *arr Apps
Configure Sonarr/Radarr/etc to use the mounted WebDAV paths for downloading content from Real-Debrid.

## Troubleshooting

### Check Pod Logs
```bash
kubectl logs -n media-services -l app=decypharr
```

### Verify FUSE Support
```bash
kubectl exec -n media-services -it deployment/decypharr -- ls -la /dev/fuse
```

### Check Mount Status
```bash
kubectl exec -n media-services -it deployment/decypharr -- mount | grep fuse
```

## Security Considerations

**WARNING**: This deployment uses privileged containers which have security implications:
- Only deploy in trusted environments
- Consider network policies to restrict access
- Regularly update the container image
- Use secrets management for WebDAV credentials

## Resources
- Container Image: cy01/blackhole:latest
- Port: 8282
- Resources: 256Mi-1Gi RAM, 100m-1000m CPU
