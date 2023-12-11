#!/bin/bash

# Reference: https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#k8s-install-0

# Set k8s version
# export K8S_VERSION=1.27.3-00

# Install required packages
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl

# Download gpg key
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Add to repository
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
