# Media Services Monitoring

This directory contains Prometheus ServiceMonitor definitions for all media services in the stack.

## Overview

The monitoring setup uses the Prometheus Operator (via kube-prometheus-stack) to automatically discover and scrape metrics from all media services.

## Components

### ServiceMonitors

ServiceMonitor custom resources are created for each media service:

- `sonarr` - TV show management
- `radarr` - Movie management
- `lidarr` - Music management
- `prowlarr` - Indexer management
- `qbittorrent` - Torrent client
- `sabnzbd` - Usenet client
- `flaresolverr` - Cloudflare bypass
- `jellyfin` - Media server
- `jellyseerr` - Media request management
- `profilarr` - Profile management
- `stash` - Media organization
- `cloudcmd` - File manager
- `homepage` - Dashboard
- `sonobarr` - Audio management
- `glance` - Overview dashboard
- `whisparr` - Adult content management

## Deployment

### Prerequisites

1. Install Prometheus Operator using the Helm chart:

```bash
cd /Users/kalekber/code/homelab/k8s
./install-charts.sh
```

This will deploy `kube-prometheus-stack` in the `monitoring` namespace.

### Deploy ServiceMonitors

The ServiceMonitors are automatically deployed as part of the media-services kustomization:

```bash
kubectl apply -k /Users/kalekber/code/homelab/k8s/media-services/
```

## Configuration

### ServiceMonitor Settings

Each ServiceMonitor is configured with:

- **Interval**: 30s - How often to scrape metrics
- **Scrape Timeout**: 10s - Maximum time to wait for scrape
- **Port**: http - Uses the service's http port
- **Path**: / - Root path for metrics (applications may expose metrics at different paths)

### Label Selector

All ServiceMonitors use the `release: kube-prometheus-stack` label to ensure they are discovered by the Prometheus Operator.

## Verification

### Check ServiceMonitor Status

```bash
kubectl get servicemonitors -n media-services
```

### Check Prometheus Targets

Access the Prometheus UI and navigate to Status → Targets to verify all media services are being scraped.

```bash
kubectl port-forward -n monitoring svc/kube-prometheus-stack-prometheus 9090:9090
```

Then open http://localhost:9090/targets

### Check Service Discovery

```bash
kubectl get servicemonitors -n media-services -o yaml
```

## Troubleshooting

### ServiceMonitor Not Discovered

1. Verify the ServiceMonitor has the correct `release: kube-prometheus-stack` label
2. Check that the namespace label selector in Prometheus configuration allows `media-services`
3. Verify the service exists and has matching labels

```bash
kubectl get svc -n media-services -l app=<service-name>
```

### No Metrics Available

Some applications may not expose Prometheus-compatible metrics by default. You may need to:

1. Configure exporters for applications that don't expose metrics natively
2. Update the `path` in the ServiceMonitor to match where metrics are exposed
3. Enable metrics in the application configuration

### Check Prometheus Logs

```bash
kubectl logs -n monitoring -l app.kubernetes.io/name=prometheus -f
```

## Customization

### Adjust Scrape Interval

Edit the ServiceMonitor and change the `interval` field:

```yaml
spec:
  endpoints:
  - port: http
    interval: 60s  # Changed from 30s
```

### Add Metric Relabeling

Add relabeling rules to transform or filter metrics:

```yaml
spec:
  endpoints:
  - port: http
    metricRelabelings:
    - sourceLabels: [__name__]
      regex: 'unwanted_metric.*'
      action: drop
```

## Notes

- The `serviceMonitorSelectorNilUsesHelmValues=false` flag in the Helm installation ensures Prometheus discovers all ServiceMonitors regardless of labels
- ServiceMonitors are namespace-scoped and must be in the same namespace as their target services
- The Prometheus Operator automatically reloads configuration when ServiceMonitors are added or modified
