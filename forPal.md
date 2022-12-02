# For Pal, what I did to make k8s environment

- [For Pal, what I did to make k8s environment](#for-pal-what-i-did-to-make-k8s-environment)
  - [1. Setup Virtual machine environment](#1-setup-virtual-machine-environment)
  - [2. Prepare kubespray](#2-prepare-kubespray)
  - [3. Set `kubectl` in `dev-01`](#3-set-kubectl-in-dev-01)

## 1. Setup Virtual machine environment

- In short
  - Make 1 VM for development, 3 VMs for k8s cluster
  - Turn off Secure boot
  - Set static MAC address, manually setup the VMs' IP addresses
  - Set ssh keys
    - From Host(Your Windows) to Dev VM: use `pal` account
    - From Host to nodes(cp, worker01, worker02): use `pal` account
    - From Dev VM to nodes: use `root` account

1. Installed Hyper-V
    1. Windows Control Panel - Programs and Features - Turn Windows features on or off - Select all of "Hyper-V"
2. Make a network for virtual machines
    1. You can just follow this document: <https://learn.microsoft.com/en-us/virtualization/hyper-v-on-windows/user-guide/setup-nat-network>
3. Create a new virtual machine for development on Hyper-V, just one VM at first
    1. `dev-01` (For development)
        1. Generation: 2
        2. Memory: 1024MB(1GB), Dynamic
        3. Network: A network that we made in above
        4. Virtual Hard disk: Make a new one with 20GB, in default location in C drive
        5. Installation Options - Install an operating system from a bootable CD/CD-ROM - Select Ubuntu-Server ISO file
4. Configure `dev-01` settings
    1. In Hyper-V GUI, in the list of VMs, right click `dev-01` - "Settings"
    2. Security - **TURN OFF** Secure boot
    3. Checkpoints - Uncheck "Enable checkpoints"
5. Boot up `dev-01` and set up the OS
    1. Network - Set up manually, not DHCP
        1. Subnet mask: `172.20.0.0/24` (Means `172.20.0.xxx` range)
        2. Gateway: `172.20.0.1`
        3. IPv4: `172.20.0.200`
        4. DNS(?): 8.8.8.8
    2. Wait for setup done
    3. Shutdown the VM
6. Right the `dev-01` - Settings
    1. Network - Advanced Features - MAC address to Static, and change a little to have meaning, and we will set other VMs' MAC addresses according to this address. It's just for later convenience.
    2. Hard drive - Find the location of Virtual hard disk, open up with explorer
        1. There should be only 1 file named `dev-01.vhdx`
        2. Duplicate the file 3 more, for `k8s-01-cp`, `k8s-01-worker01`, `k8s-01-worker02`
7. Create 3 new virtual machines for k8s cluster
    1. k8s-01-cp (For Control-Plane of k8s cluster)
        1. Generation: 2
        2. Memory: 2048MB(2GB)=Minimum requirement of k8s, **DO NOT USE Dynamic**
        3. Network: Same network
        4. Virtual Hard disk: Select the disk file we copied
    2. k8s-01-worker01 (For the first worker of k8s cluster)
        1. Same as CP
    3. k8s-01-worker02 (For the second worker)
        1. Same as CP
8. Configure 3 new VM(nodes)
    1. Turn off secure boot
    2. Turn off checkpoints
    3. Set static MAC addresses near CP's one
9. Boot up a node, configure hostname and IP addresses **1 by 1** (to avoid hostname and IP conflict)
    1. `sudo hostnamectl hostname k8s-01-cp`
    2. `sudo vim /etc/netplan/00-network~.yaml`
        1. Change `172.20.0.200/24` to `172.20.0.10/24`
    3. `sudo netplan apply`
    4. `sudo reboot now`
    5. Repeat for all nodes
10. Make ssh-key from your host PC
    1. In cmd or powershell, `ssh-keygen`
    2. Just press enter, enter...
    3. 2 files will be in `C:\Users\(yourname)\.ssh\`
        1. `id_rsa`: "Private" key of your host PC, you don't need to move this file
        2. `id_rsa.pub`: "Public" key of your host PC, copy this to remote nodes
    4. Copy `id_rsa.pub` to all VMs, and append the data to VMs' `/home/pal/.ssh/authorized_keys`
11. Make ssh-key from `dev-01`
    1. In 3 nodes,
        1. Make a password for `root` account
        2. Edit `/etc/ssh/sshd_config` file with vim, `PermitRootLogin` to `yes`
        3. Restart ssh server `sudo systemctl restart sshd`
    2. Run `ssh-keygen`, and the 2 files will be in `/home/pal/.ssh/`
    3. copy the `id_rsa.pub` and append the data to `/root/.ssh/authorized_keys` of 3 nodes
12. Reboot all VMs

## 2. Prepare kubespray

1. Clone the kubespray repo from GitHub <https://github.com/kubernetes-sigs/kubespray>
2. And get into the directory
3. Install python3, python3-pip
4. Run `pip install -U -r requirements.txt`
5. (Follow this guide <https://kubespray.io/#/docs/getting-started>)
    1. copy `inventory/sample` directory to `inventory/mycluster`

    2. Run below

         ```bash
         declare -a IPS=(172.20.0.10 172.20.0.11 172.10.0.12)
         ```

    4. Run below

         ```bash
         CONFIG_FILE=inventory/mycluster/hosts.yml python3 contrib/inventory_builder/inventory.py ${IPS[@]}
         ```
  
          1. This makes `inventory/mycluster/hosts.yml` file
    6. Edit `inventory/mycluster/hosts.yml` properly
    7. Edit `inventory/mycluster/group_vars/k8s_cluster/k8s-cluster.yml` file
        1. Check version `kube_version`, maybe don't touch it to get latest version
        2. Set CNI `kube_network_plugin`, I recommend `flannel`
        3. Set CRI, `container_manager`, the `crio` is common nowadays

6. Deploy the cluster! and kubespray will do the rest for you. But you should read the LFD459 book I gave you to know what kubespray do for you.

    ```bash
    ansible-playbook -i inventory/mycluster/hosts.yaml -u root --become --become-user=root cluster.yml
    ```

## 3. Set `kubectl` in `dev-01`

1. Install only `kubectl`
    1. [In this guide](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#k8s-install-0), Start from the "Update the apt package index and install packages needed to use the Kubernetes apt repository"
    2. You don't need to install `kubelet` and `kubeadm`
    3. Don't forget to `sudo apt-mark hold kubectl`
2. Copy config file from CP node to `dev-01`
    1. In `dev-01`, run below

        ```bash
        scp root@172.20.0.10:/etc/kubernetes/admin.conf /home/pal/.kube/config
        sudo chmod $(id -u):$(id -g) /home/pal/.kube/config
        ```

3. Test below and see all 3 nodes are displayed

    ```bash
    kubectl get nodes -o wide
    ```
