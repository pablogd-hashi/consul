#!/bin/bash

## REMEMBER TO SET this on every new subscription

az account set --subscription 

# Function to list all available clusters and resource groups
list_clusters() {
    echo "Available clusters:"
    az aks list --query '[].{ClusterName:name, ResourceGroup:resourceGroup}' -o table
}

# Function to display progress messages
progress_message() {
    echo "===== $1 ====="
}

# Function to provision AKS cluster
provision_cluster() {
    local clusterName="$1"
    local resourceGroup="$2"
    local location="$3"
    local nodeCount="$4"

    # Check if the resource group exists, if not, create it
    if ! az group show --name $resourceGroup &>/dev/null; then
        progress_message "Creating resource group $resourceGroup..."
        az group create --name $resourceGroup --location $location
    else
        progress_message "Resource group $resourceGroup already exists."
    fi

    progress_message "Creating AKS cluster $clusterName..."
    # Create AKS cluster
    az aks create \
        --resource-group $resourceGroup \
        --name $clusterName \
        --node-count $nodeCount \
        --enable-addons monitoring \
        --generate-ssh-keys

    progress_message "Retrieving credentials for cluster $clusterName..."
    # Get credentials to connect to the cluster
    az aks get-credentials --resource-group $resourceGroup --name $clusterName

    progress_message "Installing Consul using Helm..."
    # Install Consul using Helm
    
    helm repo add hashicorp https://helm.releases.hashicorp.com
    if [ "$numClusters" -gt 1 ]; then
        kubectl create ns consul
        # helm install consul -n consul hashicorp/consul -f ../06-consul/helm/values_ent.yaml --set "global.datacenter=$clusterName"
        #  #Create secret for Enterprise
        # secret=
        # kubectl create secret generic -n consul consul-ent-license --from-literal="key=${secret}"
    
    else 
         kubectl create ns consul
        # helm install consul -n consul hashicorp/consul -f consul/config/helm_values_oss.yaml
        #  #Create secret for Enterprise
        # secret=$(cat consul/config/consul.hclic)
        # kubectl create secret generic -n consul consul-ent-license --from-literal="key=${secret}"
    
    fi

    progress_message " Installing Grafana"
    helm install prometheus prometheus-community/prometheus -f ../08-grafana-loki-prometheus/loki_stack.yaml

    progress_message "Installing Vault using Helm..."
    # Install Vault using Helm in production mode
    helm install vault hashicorp/vault --set "server.dev.enabled=false"

    progress_message "Installing nginx ingress controller..."
    # Install nginx ingress controller
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.0.0/deploy/static/provider/cloud/deploy.yaml

    # progress_message "Deploying HashiCups demo app..."
    # # Deploy HashiCups demo app
    # kubectl create ns hashicups
    # kubectl apply -n hashicups -f consul/hashicups/

    echo "AKS cluster $clusterName is provisioned in $location with $nodeCount nodes."
}

# Function to delete AKS cluster
delete_cluster() {
    local clusterName="$1"
    local resourceGroup="$2"

    progress_message "Deleting AKS cluster $clusterName..."
    # Delete AKS cluster
    az aks delete --resource-group $resourceGroup --name $clusterName --yes

    echo "AKS cluster $clusterName is deleted."
}

# Menu to select action
echo "Choose an action:"
echo "1. Provision AKS cluster(s)"
echo "2. Delete AKS cluster(s)"
read -p "Enter your choice: " choice

case $choice in
    1)
        # Provision AKS cluster(s)
        read -p "Enter the number of clusters to provision: " numClusters
        read -p "Enter the location (e.g., eastus): " location

        for ((i=1; i<=$numClusters; i++)); do
            read -p "Enter the cluster name for cluster $i: " clusterName
            read -p "Enter the resource group for cluster $i: " resourceGroup
            read -p "Enter the node count for cluster $i: " nodeCount

            provision_cluster "$clusterName" "$resourceGroup" "$location" "$nodeCount"
        done
        ;;
    2)
        # Delete AKS cluster(s)
        list_clusters
        read -p "Enter the cluster name to delete: " clusterName
        read -p "Enter the resource group to delete: " resourceGroup

        delete_cluster "$clusterName" "$resourceGroup"
        ;;
    *)
        echo "Invalid choice"
        ;;
esac
