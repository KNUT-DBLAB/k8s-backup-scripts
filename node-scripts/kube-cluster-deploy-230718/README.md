# k8s cluster deploy scripts

1. [k8s cluster deploy scripts](#k8s-cluster-deploy-scripts)
   1. [Before you start](#before-you-start)
      1. [Environment requirements](#environment-requirements)
      2. [Installation info](#installation-info)
   2. [Step by step](#step-by-step)
      1. [For all nodes](#for-all-nodes)
         1. [1. `all-01-kernel.sh`](#1-all-01-kernelsh)
         2. [2. `all-02-cri.sh`](#2-all-02-crish)
         3. [3. `all-03-k8s-tools.sh`](#3-all-03-k8s-toolssh)
      2. [For Control-Plane only](#for-control-plane-only)
         1. [1. `cp-01-kubeadm-init.sh`](#1-cp-01-kubeadm-initsh)
         2. [2. `cp-02-kubeconfig.sh`](#2-cp-02-kubeconfigsh)
         3. [3. `cp-03-flannel.sh`](#3-cp-03-flannelsh)
   3. [After running these scripts](#after-running-these-scripts)
   4. [When re-deploying after reset](#when-re-deploying-after-reset)
      1. [Delete or edit residues](#delete-or-edit-residues)
      2. [Reinstalling tools (kubelet, CRI) will not generate config files](#reinstalling-tools-kubelet-cri-will-not-generate-config-files)

---

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
- If you need to set specific IP address for internal network, add `--apiserver-advertise-address`, `--control-plane-endpoint` options
  - Ref: <https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-init/#options>
- It takes about 5 minutes...?
- Look out for output. There will be scripts for...
  - Adding user to access the cluster
  - Join worker nodes to the cluster
- After the deployment, if there are some error system log(`journalctl`) telling kubelet can't find CRI socket, reset the cluster in proper way(`kubeadm reset`), and re-deploy with `--cri-socket` option

#### 2. `cp-02-kubeconfig.sh`

- It's copy of script that adds user to access the cluster.

#### 3. `cp-03-flannel.sh`

- Applies _Flannel_ CNI to the cluster.

## After running these scripts

1. Join worker nodes with the script you got from initialize output.
2. If you need to set specific IP address for internal network between nodes, you have to _*MANUALLY*_ edit kubelet config file
   1. Append `--node-ip={ip}` option to very last line of the config file, `/etc/systemd/system/kubelet.service.d/10-kubelet.conf`

## When re-deploying after reset

### Delete or edit residues

Even after running `kubeadm reset`, some files will not deleted, especially kubelet config files.

- `/etc/systemd/system/kubelet.service.d`
- `/opt/cni/net.d`

### Reinstalling tools (kubelet, CRI) will not generate config files

When you deleted some config files, You need to manually create it.

- kubelet
  - `/etc/systemd/system/kubelet.service.d/10-kubelet.conf`
  - Refer this link to get the default config: <https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/kubelet-integration/>
- CRI
  - `/etc/containers/policy.json`
  - Refer this link to get the default config: <https://insights-core.readthedocs.io/en/latest/shared_parsers_catalog/containers_policy.html>
