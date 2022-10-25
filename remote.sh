#!/bin/bash
printf "\nOYS k8s-test shell script\n\n"

declare -A NODES
NODES[cp]="172.30.0.10"
NODES[worker01]="172.30.0.11"
NODES[worker02]="172.30.0.12"

declare -a targetNodes

commandIdx=1

function isTargetNode() {
    if [[ ${#targetNodes[@]} > 0 ]]; then
        for anEle in "${targetNodes[@]}"; do
            if [ ${anEle} = ${@} ]; then
                return 0
            fi
        done
    fi
    return 1
}

while [[ ${!commandIdx} == -* ]]; do
    {
        if [ ${!commandIdx:1} = "cp" ]; then
            if ! isTargetNode "${NODES[cp]}"; then
                targetNodes+=("${NODES[cp]}")
            fi
        elif [ ${!commandIdx:1} = "worker01" ] || [ ${!commandIdx:1} = "w01" ]; then
            if ! isTargetNode "${NODES[worker01]}"; then
                targetNodes+=("${NODES[worker01]}")
            fi
        elif [ ${!commandIdx:1} = "worker02" ] || [ ${!commandIdx:1} = "w02" ]; then
            if ! isTargetNode "${NODES[worker02]}"; then
                targetNodes+=("${NODES[worker02]}")
            fi
        else
            printf "Not a node name!\n"
            exit 0
        fi
        ((commandIdx = commandIdx + 1))
    }
done

if [[ ${#targetNodes[@]} = 0 ]]; then
    targetNodes=("${NODES[cp]}" "${NODES[worker01]}" "${NODES[worker02]}")
fi

if [ -n "${!commandIdx}" ]; then
    if [ "${!commandIdx}" = "ssh" ]; then
        for i in "${!targetNodes[@]}"; do
            ssh "root@${targetNodes[i]}" "${@:((commandIdx + 1))}"
            printf "\n[ssh] [${targetNodes[i]}]\tDone\n\n"
        done

    elif [ "${!commandIdx}" = "async-ssh" ]; then
        for i in "${!targetNodes[@]}"; do
            {
                ssh "root@${targetNodes[i]}" "${@:((commandIdx + 1))}"
                # printf "[async-ssh] [${targetNodes[i]}]\tDone\n\n"
            } &
        done
        wait
        printf "\n[async-ssh] [All]\tDone\n\n"
    elif [ "${!commandIdx}" = "deploy-scripts" ]; then
        for i in "${!targetNodes[@]}"; do
            {
                rsync -rltvuA --delete "/home/oys/k8s-test/node-scripts" "root@${targetNodes[i]}:/root"
            }
            # printf "[deploy-scripts] [ALL]\tDone\n\n"
        done
        printf "\n[deploy-scripts] [ALL]\tDone\n\n"
    elif [ "${!commandIdx}" = "get-inotis" ]; then
        for i in "${!targetNodes[@]}"; do
            {
                scp -r "root@${targetNodes[i]}:/home/oys/bash-scripts/inoti.csv" "inotis/${targetNodes[i]}.csv"
                # scp -r "bash-scripts" "root@${targetNodes[i]}:/home/oys/" | sed "s/^/[${targetNodes[i]}] /"
                # ssh "root@${targetNodes[i]}" "chmod ugo+rwx /home/oys/bash-scripts/*" | sed "s/^/[${targetNodes[i]}] /"
            } &
        done
        wait
        chmod ugo+rwx /home/oys/inotis/*
        printf "[DONE]\tget-inotis\n\n"
    elif [ "${!commandIdx}" = "init-rsnap" ]; then
        for i in "${!targetNodes[@]}"; do
            {
                ssh "root@${targetNodes[i]}" "apt-get install rsnapshot -y"
                scp -r "rsnap-k8s" "root@${targetNodes[i]}:/home/oys/"
                ssh "root@${targetNodes[i]}" "touch /home/oys/rsnap-k8s/rsnap-k8s.log && chmod ugo+rwx /home/oys/rsnap-k8s/*"
            } &
        done
        wait
        printf "[DONE]\tinit-rsnap\n\n"
    elif [ "${!commandIdx}" = "backup" ]; then
        for i in "${!targetNodes[@]}"; do
            {
                ssh "root@${targetNodes[i]}" "rsnapshot -c /home/oys/rsnap-k8s/rsnap-conf-${targetNodes[i]}.conf alpha"
                printf "[DONE]\trsnapshot alpha\n\n"
                ssh "root@${targetNodes[i]}" "tar -C /home/oys/rsnap-k8s/alpha.0/localhost/ -cpf /home/oys/rsnap-k8s/alpha.tar ./"
                scp "root@${targetNodes[i]}:/home/oys/rsnap-k8s/alpha.tar" "/home/oys/k8s-06/${targetNodes[i]}-alpha.tar"
                scp "root@${targetNodes[i]}:/home/oys/rsnap-k8s/rsnap-k8s.log" "/home/oys/k8s-06/${targetNodes[i]}-rsnap.log"
            } &
        done
        wait
        printf "[DONE]\tbackup\n\n"
    elif [ "${!commandIdx}" = "rsnap" ]; then
        for i in "${!targetNodes[@]}"; do
            {
                ssh "root@${targetNodes[i]}" "rsnapshot -c /home/oys/rsnap-k8s/rsnap-conf-${targetNodes[i]}.conf alpha"
            } &
        done
        wait
        printf "[DONE]\trsnap\n\n"
    elif [ "${!commandIdx}" = "revert" ]; then
        for i in "${!targetNodes[@]}"; do
            {
                ssh root@${targetNodes[i]} 'sudo modprobe overlay'
                ssh root@${targetNodes[i]} 'sudo modprobe br_netfilter'

                ssh root@${targetNodes[i]} 'echo "net.bridge.bridge-nf-call-iptables = 1" | sudo tee -a /etc/sysctl.d/99-kubernetes-cri.conf'
                ssh root@${targetNodes[i]} 'echo "net.ipv4.ip_forward = 1" | sudo tee -a /etc/sysctl.d/99-kubernetes-cri.conf'
                ssh root@${targetNodes[i]} 'echo "net.bridge.bridge-nf-call-ip6tables = 1" | sudo tee -a /etc/sysctl.d/99-kubernetes-cri.conf'

                ssh root@${targetNodes[i]} 'sudo sysctl --system'

                printf "\n[INFO]\t[${targetNodes[i]}]\tkernel setup done\n"
            } &
        done
        wait

        # for i in "${!targetNodes[@]}"; do
        #     {
        #         ssh root@${targetNodes[i]} "systemctl stop kubelet"
        #         printf "\n[INFO]\t[${targetNodes[i]}]\tstop kubelet done\n"
        #     } &
        # done
        # wait

        for i in "${!targetNodes[@]}"; do
            {
                # ssh root@${targetNodes[i]} 'crictl stopp $(crictl pods | awk "/kube-system/ {print \$1}")'
                # printf "\n[INFO]\t[${targetNodes[i]}]\tstop pods done\n"
                # ssh "root@${targetNodes[i]}" "systemctl stop crio"
                # printf "\n[INFO]\t[${targetNodes[i]}]\tstop cri-o done\n"
                scp "/home/oys/k8s-06/${targetNodes[i]}-alpha.tar" "root@${targetNodes[i]}:/home/oys/rsnap-k8s/${targetNodes[i]}-alpha.tar"
                printf "\n[INFO]\t[${targetNodes[i]}]\tscp tar done\n"
                ssh "root@${targetNodes[i]}" "tar -xf /home/oys/rsnap-k8s/${targetNodes[i]}-alpha.tar -C / --overwrite"
                printf "\n[INFO]\t[${targetNodes[i]}]\ttar extract overwrite done\n"
            } &
        done
        wait

        for i in "${!targetNodes[@]}"; do
            {
                ssh root@${targetNodes[i]} 'systemctl daemon-reload'
                printf "\n[INFO]\t[${targetNodes[i]}]\tsystemctl daemon-reload done\n"
                ssh root@${targetNodes[i]} 'systemctl enable crio.service'
                printf "\n[INFO]\t[${targetNodes[i]}]\tsystemctl enable crio.service done\n"
                ssh root@${targetNodes[i]} 'systemctl enable kubelet.service'
                printf "\n[INFO]\t[${targetNodes[i]}]\tsystemctl enable kubelet.service done\n"
            } &
        done
        wait

        for ((i = ${#targetNodes[@]} - 1; i >= 0; i--)); do
            # ssh "root@${targetNodes[i]}" "crictl start $(crictl ps -a | awk '/kube-|etcd|coredns/ { res=sprintf("%s %s",res,$1) } END { print res }')"
            # printf "[INFO]\t[${targetNodes[i]}]\tstarted kube-system containers, wait 10secs for stablize"
            # wait 10s
            ssh "root@${targetNodes[i]}" "systemctl restart crio"
            printf "[INFO]\t[${targetNodes[i]}]\trestarted cri-o, wait 5secs for stablize\n"
            sleep 5s
            ssh "root@${targetNodes[i]}" "systemctl restart kubelet"
            printf "[INFO]\t[${targetNodes[i]}]\trestarted kubelet\n"
        done

        ssh "root@172.30.0.10" 'echo "export KUBECONFIG=/etc/kubernetes/admin.conf" | sudo tee -a /root/.bashrc'

        printf "[DONE]\trevert\n\n"
    else
        printf "Need help...?\n\n"
    fi

else
    printf "Empty command!\n\n"
fi
# wait
