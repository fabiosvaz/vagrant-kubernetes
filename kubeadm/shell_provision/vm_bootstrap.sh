#!/usr/bin/env bash

#echo "#### Adding Docker repository ####"

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

echo "#### Adding k8s repository ####"

sudo apt-get update && apt-get install -y apt-transport-https curl

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
cat << EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

sudo apt-get update

echo "#### Installing docker, and latest kubelet, kudeadm and kubectl ####"

sudo apt-get install -y docker-ce kubelet kubeadm kubectl

echo "#### Setting docker group for vagrant user ####"

# run docker commands as vagrant user (sudo not required)
sudo usermod -aG docker vagrant

echo "#### Disabling auto update for Docker, Kubeadm, Kubelete and Kubectl ####"
# avoid updates
sudo apt-mark hold docker-ce kubelet kubeadm kubectl

echo "#### Disabling swap ####"
#kubeadm/kubelet requires swap off
sudo swapoff -a
# keep swap off after reboot
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

echo "#### Configuring Kubelet with VM ip ####"

# ip of this box
#Issue with kubectl commands such as logs. This happens in Vagrant if you're running a multi-box setup because the kubelet on the workers end up binding services to the wrong ethernet interface.

IP_ADDR=$(ip addr show eth1 | grep -i 'inet.*eth1' | cut -d ' ' -f 6 | cut -d '/' -f 1)
# set node-ip
echo "#### Congiguring kubelet with node-ip=$IP_ADDR ####"
touch /etc/default/kubelet
#sudo sed -i "/^[^#]*KUBELET_EXTRA_ARGS=/c\KUBELET_EXTRA_ARGS=--node-ip=$IP_ADDR" /etc/default/kubelet
echo "KUBELET_EXTRA_ARGS=--node-ip=$IP_ADDR" | sudo tee -a /etc/default/kubelet
echo `cat /etc/default/kubelet`

sudo systemctl daemon-reload
sudo systemctl restart kubelet