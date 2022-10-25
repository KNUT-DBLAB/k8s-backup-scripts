export K8S_VERSION=1.24.7-00

sudo apt install -y kubeadm=$K8S_VERSION kubelet=$K8S_VERSION kubectl=$K8S_VERSION

sudo apt-mark hold kubelet kubeadm kubectl
