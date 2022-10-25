#!/bin/bash

# Using default pod CIDR: 10.244.0.0/16
# kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml

# Use local yaml, maybe custom
kubectl apply -f ./kube-flannel-0.20.0.yml
