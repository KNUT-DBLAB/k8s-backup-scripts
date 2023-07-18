#!/bin/bash

# Reference: https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#k8s-install-0

# Set k8s version
export K8S_VERSION=1.27.3-00

# Install required packages
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl

# Download gpg key
sudo curl -fsSLo /etc/apt/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg --create-dirs

# Add to repository
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt update
sudo apt install -y kubeadm=$K8S_VERSION kubelet=$K8S_VERSION kubectl=$K8S_VERSION cri-o cri-o-runc podman buildah
sudo apt-mark hold kubelet kubeadm kubectl
