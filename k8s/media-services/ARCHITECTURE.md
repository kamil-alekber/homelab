# Media Services Architecture

## Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                      Kubernetes Cluster                              │
│                                                                       │
│  ┌───────────────────────────────────────────────────────────────┐  │
│  │              Namespace: media-services                        │  │
│  │                                                               │  │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐       │  │
│  │  │   Sonarr     │  │   Radarr     │  │   Lidarr     │       │  │
│  │  │   :8989      │  │   :7878      │  │   :8686      │       │  │
│  │  │              │  │              │  │              │       │  │
│  │  │  TV Shows    │  │   Movies     │  │   Music      │       │  │
│  │  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘       │  │
│  │         │                  │                  │               │  │
│  │         └──────────────────┼──────────────────┘               │  │
│  │                            │                                  │  │
│  │         ┌──────────────────┴──────────────────┐              │  │
│  │         │                                      │              │  │
│  │  ┌──────▼──────────┐              ┌───────────▼──────┐       │  │
│  │  │  qBittorrent    │              │    SABnzbd       │       │  │
│  │  │    :8080        │              │    :8080         │       │  │
│  │  │    :6881        │              │                  │       │  │
│  │  │                 │              │                  │       │  │
│  │  │ Torrent Client  │              │  Usenet Client   │       │  │
│  │  └────────┬────────┘              └─────────┬────────┘       │  │
│  │           │                                  │                │  │
│  │           └──────────────┬───────────────────┘                │  │
│  │                          │                                    │  │
│  │                          ▼                                    │  │
│  │           ┌──────────────────────────┐                        │  │
│  │           │  media-shared-storage    │                        │  │
│  │           │  (PersistentVolumeClaim) │                        │  │
│  │           │  StorageClass:           │                        │  │
│  │           │  samba-storage           │                        │  │
│  │           └──────────┬───────────────┘                        │  │
│  │                      │                                        │  │
│  └──────────────────────┼────────────────────────────────────────┘  │
│                         │                                            │
└─────────────────────────┼────────────────────────────────────────────┘
                          │
                          ▼
           ┌──────────────────────────────┐
           │   Samba/CIFS Storage Server   │
           │   //192.168.8.221            │
           │                              │
           │  /media-shared-storage/      │
           │  ├── config/                 │
           │  │   ├── sonarr/             │
           │  │   ├── radarr/             │
           │  │   ├── lidarr/             │
           │  │   ├── qbittorrent/        │
           │  │   └── sabnzbd/            │
           │  ├── downloads/              │
           │  │   ├── torrents/           │
           │  │   └── usenet/             │
           │  └── media/                  │
           │      ├── tv/                 │
           │      ├── movies/             │
           │      └── music/              │
           └──────────────────────────────┘
```

## Data Flow

### 1. Content Request
```
User → Sonarr/Radarr/Lidarr → Search → Indexers
```

### 2. Download Initiation
```
Sonarr/Radarr/Lidarr → qBittorrent/SABnzbd → Start Download
```

### 3. Download Process
```
qBittorrent/SABnzbd → Download Files → /downloads/ (Shared Storage)
```

### 4. Import Process
```
Sonarr/Radarr/Lidarr → Monitor /downloads/ → Move to /media/ → Update Library
```

### 5. Media Access
```
Media Player (Jellyfin/Plex/etc.) → Read from /media/ → Stream to User
```

## Service Communication

All services communicate using Kubernetes DNS:
- `sonarr.media-services.svc.cluster.local:8989`
- `radarr.media-services.svc.cluster.local:7878`
- `lidarr.media-services.svc.cluster.local:8686`
- `qbittorrent.media-services.svc.cluster.local:8080`
- `sabnzbd.media-services.svc.cluster.local:8080`

## Storage Paths

### Sonarr
- Config: `/config/sonarr/`
- TV Shows: `/media/tv/`
- Downloads: `/downloads/`

### Radarr
- Config: `/config/radarr/`
- Movies: `/media/movies/`
- Downloads: `/downloads/`

### Lidarr
- Config: `/config/lidarr/`
- Music: `/media/music/`
- Downloads: `/downloads/`

### qBittorrent
- Config: `/config/qbittorrent/`
- Downloads: `/downloads/torrents/`

### SABnzbd
- Config: `/config/sabnzbd/`
- Downloads: `/downloads/usenet/`
- Incomplete: `/downloads/usenet/incomplete/`

## Network Policies (Future Enhancement)

```yaml
# Allow *arr services to communicate with download clients
Sonarr/Radarr/Lidarr → qBittorrent:8080
Sonarr/Radarr/Lidarr → SABnzbd:8080

# Allow download clients to access internet
qBittorrent → Internet (6881/tcp, 6881/udp)
SABnzbd → Internet (443/tcp)

# Allow Ingress to access services
Ingress → All Services
```

## High Availability Considerations

Current setup uses:
- **Strategy: Recreate** - Ensures only one pod per service
- **ReadWriteMany PVC** - Allows future horizontal scaling
- **Persistent Configuration** - Config survives pod restarts

For true HA:
1. Use StatefulSets instead of Deployments
2. Configure proper health checks
3. Implement backup strategies for config directories
4. Consider using a database for metadata (PostgreSQL)

## Monitoring

Recommended monitoring points:
- Pod status and restarts
- PVC capacity and usage
- Download client queue size
- API response times
- Failed downloads/imports

## Security

Current security measures:
- Services isolated in dedicated namespace
- ClusterIP services (not exposed externally by default)
- Configurable PUID/PGID for file permissions
- Storage credentials stored in Kubernetes secrets

Recommended improvements:
- Enable network policies
- Use authentication for all services
- Implement TLS for ingress
- Regular security updates for images
