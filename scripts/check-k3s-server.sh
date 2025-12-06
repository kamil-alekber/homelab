#!/bin/bash

# K3s Server Health Check Script
# Usage: ./check-k3s-server.sh [server-ip]

SERVER_IP="${1:-192.168.8.248}"

echo "=========================================="
echo "K3s Server Health Check"
echo "Server: ${SERVER_IP}"
echo "=========================================="
echo ""

# Check if server is reachable
echo "1. Testing connectivity to ${SERVER_IP}..."
if ping -c 1 -W 2 ${SERVER_IP} > /dev/null 2>&1; then
    echo "✓ Server is reachable"
else
    echo "✗ Server is not reachable"
    exit 1
fi
echo ""

# Check if K3s API is responding
echo "2. Testing Kubernetes API (port 6443)..."
if nc -z -w 2 ${SERVER_IP} 6443 > /dev/null 2>&1; then
    echo "✓ Kubernetes API port is open"
else
    echo "✗ Kubernetes API port is not accessible"
    exit 1
fi
echo ""

# Check k3s service via SSH
echo "3. Checking k3s service status..."
ssh root@${SERVER_IP} "systemctl is-active k3s" > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✓ k3s service is active"
else
    echo "✗ k3s service is not active"
    ssh root@${SERVER_IP} "systemctl status k3s --no-pager" 2>/dev/null
    exit 1
fi
echo ""

# Get kubeconfig and check cluster
echo "4. Fetching kubeconfig..."
TEMP_KUBECONFIG=$(mktemp)
scp -q root@${SERVER_IP}:/etc/rancher/k3s/k3s.yaml ${TEMP_KUBECONFIG} 2>/dev/null

if [ $? -eq 0 ]; then
    echo "✓ Kubeconfig retrieved"
    sed -i '' "s/127.0.0.1/${SERVER_IP}/g" ${TEMP_KUBECONFIG}
    
    echo ""
    echo "5. Checking cluster nodes..."
    kubectl --kubeconfig=${TEMP_KUBECONFIG} get nodes
    
    echo ""
    echo "6. Checking system pods..."
    kubectl --kubeconfig=${TEMP_KUBECONFIG} get pods -n kube-system
    
    echo ""
    echo "7. Cluster Info:"
    kubectl --kubeconfig=${TEMP_KUBECONFIG} cluster-info
    
    rm ${TEMP_KUBECONFIG}
else
    echo "✗ Failed to retrieve kubeconfig"
    exit 1
fi

echo ""
echo "=========================================="
echo "✓ K3s server is healthy and operational!"
echo "=========================================="
