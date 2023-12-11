#!/bin/bash
kubeadm init --pod-network-cidr="10.244.0.0/16" --cri-socket="unix:///var/run/crio/crio.sock"
