#!/bin/bash

# Set k8s version
export K8S_VERSION=1.27.3-00

sudo apt update
sudo apt install -y kubeadm=$K8S_VERSION kubelet=$K8S_VERSION kubectl=$K8S_VERSION cri-o cri-o-runc podman
sudo apt-mark hold kubelet kubeadm kubectl
