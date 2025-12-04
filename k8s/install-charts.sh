#!/bin/bash

set -e

# Format: "name|repo_name|repo_url|chart_name|version|namespace|extra_flags"
CHARTS=(
  "CSI Driver SMB|csi-driver-smb|https://raw.githubusercontent.com/kubernetes-csi/csi-driver-smb/master/charts|csi-driver-smb/csi-driver-smb|1.19.1|kube-system|"
  "cert-manager|cert-manager|oci://quay.io/jetstack/charts|oci://quay.io/jetstack/charts/cert-manager|v1.16.1|cert-manager|--create-namespace --set crds.enabled=true"
  "Prometheus Operator|kube-prometheus-stack|https://prometheus-community.github.io/helm-charts|kube-prometheus-stack/kube-prometheus-stack|67.4.0|monitoring|--create-namespace --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false"
)

install_repo_chart() {
  local display_name="$1"
  local repo_name="$2"
  local repo_url="$3"
  local chart_name="$4"
  local version="$5"
  local namespace="$6"
  local extra_flags="$7"

  echo ""
  echo "Checking ${display_name}..."
  
  if helm list -n "$namespace" -q | grep -q "^${repo_name}$"; then
    echo "⊙ ${display_name} is already installed, skipping..."
    return 0
  fi
  
  echo "Installing ${display_name}..."
  
  if [[ ! "$repo_url" =~ ^oci:// ]]; then
    helm repo add "$repo_name" "$repo_url" 2>/dev/null || true
    helm repo update "$repo_name"
  fi
  
  helm install "$repo_name" "$chart_name" \
    --namespace "$namespace" \
    --version "$version" \
    $extra_flags

  echo "✓ ${display_name} installed successfully"
}

echo "==================================="
echo "Installing Helm Charts"
echo "==================================="

for chart in "${CHARTS[@]}"; do
  IFS='|' read -r name repo_name repo_url chart_name version namespace extra_flags <<< "$chart"
  install_repo_chart "$name" "$repo_name" "$repo_url" "$chart_name" "$version" "$namespace" "$extra_flags"
done

echo ""
echo "==================================="
echo "All Helm charts installed successfully!"
echo "==================================="
