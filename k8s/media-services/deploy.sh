#!/bin/bash
# Media Services Deployment Script
# Usage: ./deploy.sh [apply|delete|restart|status]

set -e

NAMESPACE="media-services"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

function print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

function print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

function print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

function check_prerequisites() {
    print_info "Checking prerequisites..."
    
    # Check if kubectl is installed
    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl is not installed"
        exit 1
    fi
    
    # Check if kustomize is available
    if ! kubectl kustomize --help &> /dev/null; then
        print_error "kubectl kustomize is not available"
        exit 1
    fi
    
    # Check if storage class exists
    if ! kubectl get storageclass samba-storage &> /dev/null; then
        print_warning "samba-storage StorageClass not found. Make sure to deploy storage configuration first."
    fi
    
    print_info "Prerequisites check completed"
}

function deploy() {
    print_info "Deploying media services..."
    kubectl apply -k "$SCRIPT_DIR"
    print_info "Waiting for deployments to be ready..."
    kubectl wait --for=condition=available --timeout=300s \
        deployment/sonarr \
        deployment/radarr \
        deployment/lidarr \
        deployment/qbittorrent \
        deployment/sabnzbd \
        -n "$NAMESPACE" 2>/dev/null || print_warning "Some deployments are not ready yet"
    print_info "Deployment completed"
}

function delete() {
    print_warning "Deleting media services..."
    read -p "Are you sure you want to delete all media services? (yes/no): " confirm
    if [ "$confirm" = "yes" ]; then
        kubectl delete -k "$SCRIPT_DIR"
        print_info "Deletion completed"
    else
        print_info "Deletion cancelled"
    fi
}

function restart() {
    print_info "Restarting media services..."
    kubectl rollout restart deployment/sonarr -n "$NAMESPACE"
    kubectl rollout restart deployment/radarr -n "$NAMESPACE"
    kubectl rollout restart deployment/lidarr -n "$NAMESPACE"
    kubectl rollout restart deployment/qbittorrent -n "$NAMESPACE"
    kubectl rollout restart deployment/sabnzbd -n "$NAMESPACE"
    print_info "Restart initiated. Use 'status' command to check progress."
}

function status() {
    print_info "Media Services Status:"
    echo ""
    
    # Check namespace
    if kubectl get namespace "$NAMESPACE" &> /dev/null; then
        print_info "Namespace: $NAMESPACE ✓"
    else
        print_error "Namespace: $NAMESPACE ✗"
        return 1
    fi
    
    echo ""
    print_info "PersistentVolumeClaim:"
    kubectl get pvc -n "$NAMESPACE" 2>/dev/null || print_warning "No PVCs found"
    
    echo ""
    print_info "Deployments:"
    kubectl get deployments -n "$NAMESPACE" 2>/dev/null || print_warning "No deployments found"
    
    echo ""
    print_info "Pods:"
    kubectl get pods -n "$NAMESPACE" 2>/dev/null || print_warning "No pods found"
    
    echo ""
    print_info "Services:"
    kubectl get svc -n "$NAMESPACE" 2>/dev/null || print_warning "No services found"
}

function show_logs() {
    if [ -z "$2" ]; then
        print_error "Service name required. Available: sonarr, radarr, lidarr, qbittorrent, sabnzbd"
        exit 1
    fi
    
    SERVICE=$2
    print_info "Showing logs for $SERVICE..."
    kubectl logs -n "$NAMESPACE" -l app="$SERVICE" --tail=100 -f
}

function port_forward() {
    if [ -z "$2" ]; then
        print_error "Service name required. Available: sonarr, radarr, lidarr, qbittorrent, sabnzbd"
        exit 1
    fi
    
    SERVICE=$2
    case $SERVICE in
        sonarr)
            PORT=8989
            ;;
        radarr)
            PORT=7878
            ;;
        lidarr)
            PORT=8686
            ;;
        qbittorrent|sabnzbd)
            PORT=8080
            ;;
        *)
            print_error "Unknown service: $SERVICE"
            exit 1
            ;;
    esac
    
    print_info "Port forwarding $SERVICE on localhost:$PORT"
    print_info "Press Ctrl+C to stop"
    kubectl port-forward -n "$NAMESPACE" "svc/$SERVICE" "$PORT:$PORT"
}

# Main script
case ${1:-status} in
    apply|deploy)
        check_prerequisites
        deploy
        status
        ;;
    delete|remove)
        delete
        ;;
    restart)
        restart
        ;;
    status)
        status
        ;;
    logs)
        show_logs "$@"
        ;;
    port-forward|pf)
        port_forward "$@"
        ;;
    *)
        echo "Usage: $0 {apply|delete|restart|status|logs|port-forward} [service-name]"
        echo ""
        echo "Commands:"
        echo "  apply          - Deploy all media services"
        echo "  delete         - Remove all media services"
        echo "  restart        - Restart all services"
        echo "  status         - Show current status"
        echo "  logs <service> - Show logs for a specific service"
        echo "  port-forward <service> - Port forward to a specific service"
        echo ""
        echo "Services: sonarr, radarr, lidarr, qbittorrent, sabnzbd"
        exit 1
        ;;
esac
