#!/bin/bash

# Install golang and setup its environment
echo "### Installing golang and setup its environment ###"
wget https://dl.google.com/go/go1.15.2.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.15.2.linux-amd64.tar.gz
echo "
export GOPATH=$HOME/go
export GOROOT=/usr/local/go
export PATH=$PATH:/usr/local/go/bin:/home/vagrant/go/bin
" >> $HOME/.profile

source $HOME/.profile

# Install kind
echo "### Installing Kind ###"
GO111MODULE="on" go get sigs.k8s.io/kind@v0.9.0

# Install kubectl
echo "### Installing Kubectl ###"
sudo apt-get update && sudo apt-get install -y curl apt-transport-https gnupg2
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl
kubectl version --client
