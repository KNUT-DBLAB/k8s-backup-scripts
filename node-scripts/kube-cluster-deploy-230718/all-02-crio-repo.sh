#!/bin/bash

# Install CRI-O as CRI
# https://github.com/cri-o/cri-o/blob/main/install.md#apt-based-operating-systems

# Set OS, k8s version
export OS=xUbuntu_22.04
export VERSION=1.27

# Install libseccomp
sudo echo 'deb http://deb.debian.org/debian buster-backports main' >/etc/apt/sources.list.d/backports.list
sudo apt update
sudo apt install -y -t buster-backports libseccomp2 || apt update -y -t buster-backports libseccomp2

# Install CRI-O
sudo echo "deb [signed-by=/usr/share/keyrings/libcontainers-archive-keyring.gpg] https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/ /" >/etc/apt/sources.list.d/devel-kubic-libcontainers-stable.list
sudo echo "deb [signed-by=/usr/share/keyrings/libcontainers-crio-archive-keyring.gpg] https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$VERSION/$OS/ /" >/etc/apt/sources.list.d/devel-kubic-libcontainers-stable-cri-o-$VERSION.list

sudo mkdir -p /usr/share/keyrings
sudo curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/Release.key | gpg --dearmor -o /usr/share/keyrings/libcontainers-archive-keyring.gpg
sudo curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$VERSION/$OS/Release.key | gpg --dearmor -o /usr/share/keyrings/libcontainers-crio-archive-keyring.gpg
