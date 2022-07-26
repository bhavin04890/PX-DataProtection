#!/bin/bash

echo "Cleaning up the AWS Immersion Day labs" 

if [ ! -f ~/usr/local/bin/eksctl ]; then
	curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
	sudo cp /tmp/eksctl /usr/local/bin
fi

if [ ! -f ~/usr/local/bin/kubectl ]; then
	curl --silent -LO https://dl.k8s.io/release/v1.21.0/bin/linux/amd64/kubectl
	chmod +x kubectl
	sudo cp ./kubectl /usr/local/bin/
	export PATH=$PATH:/usr/local/bin/
fi

echo "Deleting the destination cluster"
eksctl utils write-kubeconfig --cluster px-dataprotection-destination -r us-west-2
kubectl delete -f k8s-logo.yaml -n demo
sleep 30
kubectl delete -f postgres.yaml -n demo 
sleep 15
kubectl delete ns demo
kubectl delete deploy stork -n kube-system 
sleep 15 
eksctl delete cluster -f eks-destination-cluster.yaml

 
eksctl utils write-kubeconfig --cluster px-dataprotection-source -r us-west-2
#kubectl delete -f k8s-logo.yaml -n demo
#sleep 30
#kubectl delete -f postgres.yaml -n demo 
#sleep 15
kubectl delete ns demo
sleep 5
kubectl delete deploy stork -n kube-system 
sleep 15 
kubectl delete -f mongo-service.yaml -n pacman
sleep 15 
kubectl delete -f pacman-service.yaml -n pacman 
sleep 15
kubectl delete -f mongo-deployment.yaml -n pacman
sleep 15 
kubectl delete -f pacman-deployment.yaml -n pacman
sleep 15 
kubectl delete -f mongo-pvc.yaml -n pacman
sleep 15
kubectl delete ns pacman
eksctl delete cluster -f eks-source-cluster.yaml

echo "Deleting Backup buckets"

REGL_BUCKET="pxbackup-demo"
aws s3 rm s3://$REGL_BUCKET --r us-west-2 --recursive
aws s3 rb s3://$REGL_BUCKET --r us-west-2

