# 01

sudo modprobe overlay
sudo modprobe br_netfilter

echo "net.bridge.bridge-nf-call-iptables = 1" | sudo tee -a /etc/sysctl.d/99-kubernetes-cri.conf
echo "net.ipv4.ip_forward = 1" | sudo tee -a /etc/sysctl.d/99-kubernetes-cri.conf
echo "net.bridge.bridge-nf-call-ip6tables = 1" | sudo tee -a /etc/sysctl.d/99-kubernetes-cri.conf

sudo sysctl --system

# 02

sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl

sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# sudo apt-get update

# 03

export OS=xUbuntu_22.04
export VERSION=1.24

echo "deb [signed-by=/usr/share/keyrings/libcontainers-archive-keyring.gpg] https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/ /" >/etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
echo "deb [signed-by=/usr/share/keyrings/libcontainers-crio-archive-keyring.gpg] https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$VERSION/$OS/ /" >/etc/apt/sources.list.d/devel:kubic:libcontainers:stable:cri-o:$VERSION.list

mkdir -p /usr/share/keyrings
curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/Release.key | gpg --dearmor -o /usr/share/keyrings/libcontainers-archive-keyring.gpg
curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$VERSION/$OS/Release.key | gpg --dearmor -o /usr/share/keyrings/libcontainers-crio-archive-keyring.gpg

apt-get update

# 04

# apt-get install cri-o cri-o-runc podman buildah --no-install-recommends -y
apt-get install cri-o cri-o-runc podman buildah -y

sleep 3

sudo systemctl daemon-reload

sudo systemctl enable crio

sudo systemctl start crio

# 05

sudo apt-get install -y kubeadm=1.24.3-00 kubelet=1.24.3-00 kubectl=1.24.3-00

sudo apt-mark hold kubelet kubeadm kubectl
