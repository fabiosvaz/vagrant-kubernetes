#!/usr/bin/env bash

sudo apt-get install -y sshpass
sudo sshpass -p "vagrant" scp -o StrictHostKeyChecking=no vagrant@172.168.50.10:/etc/kubeadm_join_cmd.sh .

echo "#### Joining cluster ####"
sudo sh ./kubeadm_join_cmd.sh