#!/bin/bash

# Using default pod CIDR: 10.244.0.0/16
# kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml

# Use local yaml
kubectl apply -f ./kube-flannel.yml
