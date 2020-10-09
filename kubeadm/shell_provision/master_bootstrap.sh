#!/usr/bin/env bash

# ip of this box
IP_ADDR=$(ip addr show eth1 | grep -i 'inet.*eth1' | cut -d ' ' -f 6 | cut -d '/' -f 1)

echo "#### Initializing k8s cluster in $IP_ADDR - Calico Network####"
# Initializing cluster and saving join command
sudo kubeadm init --apiserver-advertise-address=$IP_ADDR --apiserver-cert-extra-sans=$IP_ADDR --pod-network-cidr=192.168.0.0/16

#copying credentials to regular user - vagrant. Required to specify vagrant user as the provision is executed by sudo
sudo --user=vagrant mkdir -p /home/vagrant/.kube
cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
chown $(id -u vagrant):$(id -g vagrant) /home/vagrant/.kube/config

export KUBECONFIG=/etc/kubernetes/admin.conf

kubeadm token create --print-join-command >> /etc/kubeadm_join_cmd.sh
chmod +x /etc/kubeadm_join_cmd.sh

# required for setting up password less ssh between guest VMs
sudo sed -i "/^[^#]*PasswordAuthentication[[:space:]]no/c\PasswordAuthentication yes" /etc/ssh/sshd_config
sudo service sshd restart

# install Calico
sudo wget -P /home/vagrant/manifest https://docs.projectcalico.org/manifests/calico.yaml

cd /home/vagrant/manifest
kubectl apply -f calico.yaml