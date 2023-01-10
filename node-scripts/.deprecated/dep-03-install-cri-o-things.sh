#!/bin/bash
apt update
apt install cri-o cri-o-runc podman buildah -y

sleep 3

sudo systemctl daemon-reload
sudo systemctl enable crio
sudo systemctl start crio
