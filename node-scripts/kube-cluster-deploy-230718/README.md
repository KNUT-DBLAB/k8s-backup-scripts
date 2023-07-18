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
  - Supported latest version now is `1.26`
  - In the script file, edit line number 6 like below

      ```bash
      export VERSION=1.26
      ```

#### 3. `all-03-k8s-tools.sh`

- Installs k8s CLI tools
- **YOU NEED TO CHECK K8S VERSION**
  - Latest version now is `1.26.0-00`
  - In the script file, edit line number 6 like below

      ```bash
      export K8S_VERSION=1.26.0-00
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
