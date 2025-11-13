# Kubernetes Storage - Samba Integration

This directory contains Kubernetes manifests for integrating the Samba storage server (`storage-01`) with your K3s cluster.

## Overview

The storage setup provides:
- **Samba/CIFS** shares for media, backups, and shared files
- **NFS** export for K8s persistent volumes
- **ReadWriteMany** access mode for multiple pod access
- **Proper permissions** (775/664) for multi-application access

## Files

- `samba-secret.yml` - Credentials for Samba authentication
- `storageclass.yml` - StorageClass definitions for SMB/CIFS/NFS
- `samba-pv.yml` - PersistentVolume definitions
- `samba-pvc.yml` - PersistentVolumeClaim definitions
- `example-deployment.yml` - Example workloads using the storage

## Prerequisites

### Option 1: SMB CSI Driver (Recommended)

Install the SMB CSI driver for better SMB/CIFS support:

```bash
# See csi-driver-smb.yml for detailed installation instructions

# Using Helm (recommended):
helm repo add csi-driver-smb https://raw.githubusercontent.com/kubernetes-csi/csi-driver-smb/master/charts
helm install csi-driver-smb csi-driver-smb/csi-driver-smb --namespace kube-system --version v1.13.0

# Verify installation:
kubectl get csidrivers
# Should show: smb.csi.k8s.io
```

### Option 2: NFS CSI Driver (Alternative)

For NFS-based storage:

```bash
helm repo add csi-driver-nfs https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/master/charts
helm install csi-driver-nfs csi-driver-nfs/csi-driver-nfs --namespace kube-system --version v4.5.0

# Verify installation:
kubectl get csidrivers
# Should show: nfs.csi.k8s.io
```

### Option 3: Built-in CIFS Support

K3s/K8s has built-in CIFS support, but requires CIFS utils on each node. With NixOS/Colmena, this is already configured in `k3s-agent.nix`.

### Samba Server Configuration

Ensure your NixOS storage node (storage-01) is configured with:
- **IP Address**: 192.168.8.221
- **Shares**: /media, /shared, /backups
- **Samba User**: samba
- **Password**: sfwMtZUJTFrcJRs4CUU7aQ==

This is automatically configured in `nix/modules/samba.nix`.

## Deployment Steps

### 1. Update Configuration

**Update IP addresses** in the manifests:

```bash
# In samba-pv.yml, update storage server address:
source: "//storage-01/media"  # or use IP: //192.168.1.20/media
```

**Set Samba credentials** in `samba-secret.yml`:

```yaml
stringData:
  username: samba
  password: "your-secure-password"  # Match password from storage-01 node
```

### 2. Deploy Storage Resources

```bash
# Create namespaces and secrets
kubectl apply -f samba-secret.yml

# Create StorageClass
kubectl apply -f storageclass.yml

# Create PersistentVolumes
kubectl apply -f samba-pv.yml

# Create PersistentVolumeClaims
kubectl apply -f samba-pvc.yml

# Verify
kubectl get pv,pvc -n storage
kubectl get pv,pvc -n media-services
```

### 3. Initialize Storage Structure

Run the setup job to create directory structure:

```bash
kubectl apply -f example-deployment.yml
# This will create the job "setup-media-storage"

# Check job status
kubectl get jobs -n media-services
kubectl logs -n media-services job/setup-media-storage
```

### 4. Verify Storage Access

Test the storage with an example pod:

```bash
# Deploy example app
kubectl apply -f example-deployment.yml

# Check if pod is running
kubectl get pods -n media-services

# Check storage contents
kubectl exec -n media-services deployment/media-app-example -- ls -lah /media
```

## Using Storage in Your Applications

### Basic Volume Mount

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
  namespace: media-services
spec:
  template:
    spec:
      securityContext:
        fsGroup: 1000  # Important for file permissions
      
      containers:
      - name: app
        image: my-app:latest
        volumeMounts:
        - name: media
          mountPath: /data/media
        
        securityContext:
          runAsUser: 1000
          runAsGroup: 1000
      
      volumes:
      - name: media
        persistentVolumeClaim:
          claimName: media-storage
```

### Mount Specific Subdirectory

```yaml
volumeMounts:
- name: media
  mountPath: /data/movies
  subPath: movies  # Mount only /media/movies
```

### Multiple Applications Sharing Storage

```yaml
# App 1: Sonarr (TV shows)
volumeMounts:
- name: media
  mountPath: /tv
  subPath: tv

# App 2: Radarr (Movies)
volumeMounts:
- name: media
  mountPath: /movies
  subPath: movies

# App 3: Jellyfin (All media)
volumeMounts:
- name: media
  mountPath: /media
  # No subPath - full access
```

## Permission Management

### Recommended Permission Structure

- **Directories**: `775` (rwxrwxr-x)
- **Files**: `664` (rw-rw-r--)
- **User/Group**: `1000:1000`

### Setting Permissions in Pods

Use an init container or Job:

```yaml
initContainers:
- name: fix-permissions
  image: busybox
  command: ["sh", "-c"]
  args:
    - |
      chmod -R 775 /media
      find /media -type f -exec chmod 664 {} \;
  volumeMounts:
  - name: media
    mountPath: /media
  securityContext:
    runAsUser: 1000
    runAsGroup: 1000
```

## Common Applications Configuration

### Jellyfin

```yaml
volumeMounts:
- name: media-storage
  mountPath: /media
  readOnly: true  # Read-only for safety
- name: media-storage
  mountPath: /config
  subPath: .metadata/jellyfin
```

### Sonarr/Radarr

```yaml
volumeMounts:
- name: media-storage
  mountPath: /tv
  subPath: tv
- name: media-storage
  mountPath: /downloads
  subPath: downloads/tv
```

### qBittorrent/SABnzbd

```yaml
volumeMounts:
- name: media-storage
  mountPath: /downloads
  subPath: downloads
  # Full read-write access needed
```

## Troubleshooting

### Pods stuck in `Pending` state

```bash
# Check PVC status
kubectl describe pvc media-storage -n media-services

# Check if PV is bound
kubectl get pv samba-media-pv

# Check node has CIFS utils
kubectl get nodes
ssh node-name "which mount.cifs"
```

### Permission denied errors

```bash
# Check pod security context
kubectl get pod <pod-name> -n media-services -o yaml | grep -A 10 securityContext

# Check actual permissions on storage
kubectl exec -n media-services <pod-name> -- ls -la /media

# Verify fsGroup is set
# fsGroup: 1000 should be in pod spec
```

### Mount failures

```bash
# Check pod events
kubectl describe pod <pod-name> -n media-services

# Check if CSI driver is running
kubectl get pods -n kube-system | grep csi

# Test Samba connectivity from node
ssh node-name
smbclient //storage-01/media -U samba
```

### Storage not writable

1. Verify Samba user has write permissions on storage-01
2. Check mount options include `rw` (read-write)
3. Verify `dir_mode=0777` and `file_mode=0666` in mount options
4. Check pod `securityContext.fsGroup` matches storage group

## Integration with Existing Media Services

Update your existing media service deployments to use the shared storage:

```bash
# Example: Update Jellyfin to use Samba storage
kubectl patch deployment jellyfin -n media-services --type='json' -p='[
  {
    "op": "add",
    "path": "/spec/template/spec/volumes/-",
    "value": {
      "name": "media-storage",
      "persistentVolumeClaim": {"claimName": "media-storage"}
    }
  }
]'
```

## Storage Monitoring

Monitor storage usage:

```bash
# Check storage usage from any pod
kubectl exec -n media-services <pod-name> -- df -h /media

# Or directly on storage-01
ssh root@storage-01 df -h /storage
```

## Backup Considerations

- PVs are set to `Retain` policy - data persists after PVC deletion
- Data is stored on `storage-01` at `/storage/media`
- Backup the storage node directly for best performance
- Consider using Velero for K8s resource backups

## Security Notes

⚠️ **Important**:
- Change default Samba password in `samba-secret.yml`
- Use Sealed Secrets or External Secrets Operator for production
- Consider network policies to restrict storage access
- Regular security audits of file permissions

## Next Steps

1. Deploy your media applications (Jellyfin, Sonarr, Radarr, etc.)
2. Update their configurations to use the shared storage PVC
3. Set up backup strategy for `/storage` on storage-01
4. Configure monitoring and alerts for storage capacity

## References

- [SMB CSI Driver](https://github.com/kubernetes-csi/csi-driver-smb)
- [NFS CSI Driver](https://github.com/kubernetes-csi/csi-driver-nfs)
- [Kubernetes Storage](https://kubernetes.io/docs/concepts/storage/)
