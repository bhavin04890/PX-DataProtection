#!/bin/bash

curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo cp /tmp/eksctl /usr/local/bin
echo "eksctl successfully installed with version:" 
eksctl version

eksctl utils write-kubeconfig --cluster px-dataprotection-destination -r us-west-2