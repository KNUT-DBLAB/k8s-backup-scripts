# k8s cluster deploy scripts

## Before you start

### Environment requirements

1. All nodes need to be available to access from each other with IP addresses
2. There should be no IP address collision with CIDR 10.244.0.0/16 (Flannel CNI uses this IP CIDR)
3. All nodes need to turn off swap memory

### Installation info

- Installs _CRI-O_ as CRI(Container Runtime Interface): _docker_ is not required
  - _podman_, CLI for container is recommended. Install it with `apt get`
- Installs _Flannel_ as CNI(Container Network Interface)

## Step by step

### For all nodes

#### 1. `all-01-kernel.sh`

- Enables some kernels needed

#### 2. `all-02-cri.sh`

- Prepares _CRI-O_ installation
- **YOU NEED TO CHECK OS VERSION AND K8S VERSION**
  - Refer supported version in [this link](https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/)
  - Refer supported k8s version in [this link](http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/)
  - In the script file, edit line number 2, 3 like below

      ```bash
      export OS=xUbuntu_22.04
      export VERSION=1.24
      ```

#### 3. `all-03-gpg.sh`

- Prepares gpg key for k8s CLI tools

#### 4. `all-04-tools.sh`

- Installs k8s CLI tools
- **YOU NEED TO CHECK K8S VERSION**
  - Check the version for `kubectl` with `apt-cache policy kubectl`
  - In the script file, edit line number 2 like below

      ```bash
      export K8S_VERSION=1.24.7-00
      ```

### For Control-Plane only

#### 1. `cp-01-kubeadm-init.sh`

- Starts initialize k8s cluster
- It takes about 5 minutes...?
- Look out for output. There will be scripts for...
  - Adding user to access the cluster
  - Join worker nodes to the cluster

#### 2. `cp-02-kubeconfig.sh`

- It's copy of script that adds user to access the cluster.

#### 3. `cp-03-flannel.sh`

- Applies _Flannel_ CNI to the cluster.

## After running these scripts

1. Join worker nodes with the script you got from initialize output.
