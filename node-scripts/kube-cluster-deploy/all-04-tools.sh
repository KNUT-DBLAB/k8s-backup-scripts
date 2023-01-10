#!/bin/bash
export K8S_VERSION=1.24.7-00

apt update
apt install -y kubeadm=$K8S_VERSION kubelet=$K8S_VERSION kubectl=$K8S_VERSION cri-o cri-o-runc podman buildah

sudo apt-mark hold kubelet kubeadm kubectl

printf "Waiting 5 secs before daemon-reload...\n"
sleep 5
sudo systemctl daemon-reload
printf "Waiting 5 secs before enable crio...\n"
sleep 5
sudo systemctl enable crio
printf "Waiting 5 secs before start crio...\n"
sleep 5
sudo systemctl start crio
printf "kubeinst-common done\n"
