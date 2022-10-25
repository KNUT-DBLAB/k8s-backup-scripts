#!/bin/bash
printf "kubeinst-common begin\n"

# 01 - kernels and netbridge

sudo modprobe overlay
sudo modprobe br_netfilter

echo "net.bridge.bridge-nf-call-iptables = 1" | sudo tee -a /etc/sysctl.d/99-kubernetes-cri.conf
echo "net.ipv4.ip_forward = 1" | sudo tee -a /etc/sysctl.d/99-kubernetes-cri.conf
echo "net.bridge.bridge-nf-call-ip6tables = 1" | sudo tee -a /etc/sysctl.d/99-kubernetes-cri.conf

sudo sysctl --system

# deprecated-02
# Already done in template

# sudo apt-get update
# sudo apt-get install -y apt-transport-https ca-certificates curl

# sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

# echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
# sudo apt-get update

# 02 - Prepare CRI-O

export OS=xUbuntu_22.04
export VERSION=1.24

echo 'deb http://deb.debian.org/debian buster-backports main' >/etc/apt/sources.list.d/backports.list
apt update
apt install -y -t buster-backports libseccomp2 || apt update -y -t buster-backports libseccomp2

echo "deb [signed-by=/usr/share/keyrings/libcontainers-archive-keyring.gpg] https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/ /" >/etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
echo "deb [signed-by=/usr/share/keyrings/libcontainers-crio-archive-keyring.gpg] https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$VERSION/$OS/ /" >/etc/apt/sources.list.d/devel:kubic:libcontainers:stable:cri-o:$VERSION.list

mkdir -p /usr/share/keyrings
curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/Release.key | gpg --dearmor -o /usr/share/keyrings/libcontainers-archive-keyring.gpg
curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$VERSION/$OS/Release.key | gpg --dearmor -o /usr/share/keyrings/libcontainers-crio-archive-keyring.gpg

# apt update
# apt-get install cri-o cri-o-runc

# 03 - Update and install

# apt-get install cri-o cri-o-runc podman buildah --no-install-recommends -y
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
