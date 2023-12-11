#!/bin/bash

echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p

mkdir -p /home/oys/grad-exp/inoti/
touch "/home/oys/grad-exp/inoti/inoti.csv"
rm "/home/oys/grad-exp/inoti/inoti.csv"
touch "/home/oys/grad-exp/inoti/inoti.csv"
chmod ugo+rw "/home/oys/grad-exp/inoti"

cp -r ./ /home/oys/grad-exp/inoti/
