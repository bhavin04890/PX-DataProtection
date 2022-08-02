#!/bin/bash

REGL_BUCKET="pxbackup-demo"
#OBJL_BUCKET="aws-12398-objl-bucket"

if [ ! -f ~/usr/local/bin/eksctl ]; then
	echo "Step 1: Installing eksctl to deploy Amazon EKS clusters"
	curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
	sudo cp /tmp/eksctl /usr/local/bin
	echo "eksctl successfully installed with version:" 
	eksctl version
fi

if [ ! -f ~/usr/local/bin/kubectl ]; then
	echo " Step 2: Installing kubectl"
        curl --silent -LO https://dl.k8s.io/release/v1.21.0/bin/linux/amd64/kubectl
        chmod +x kubectl
	sudo cp ./kubectl /usr/local/bin/
	export PATH=$PATH:/usr/local/bin/
	echo "kubectl installed successfully with version:"
	kubectl version --client
fi

echo "Creating S3 buckets as backup targets"

#aws s3api create-bucket --bucket $REGL_BUCKET --region us-west-2
aws s3 mb s3://$REGL_BUCKET --region us-west-2

#aws s3api create-bucket --bucket $OBJL_BUCKET --region us-west-2 --object-lock-enabled-for-bucket 
#aws s3api put-object-lock-configuration --bucket $OBJL_BUCKET --object-lock-configuration '{ "ObjectLockEnabled": "Enabled", "Rule": { "DefaultRetention": { "Mode": "COMPLIANCE", "Days": 1 }}}'


echo "Step 3: Installing destination EKS cluster. This might take close to 20 minutes"
eksctl create cluster -f eks-destination-cluster.yaml

kubectl get nodes 
kubectl create ns demo
echo "Step 4: Installing Stork on destination EKS cluster"
curl -fsL -o stork-spec.yaml "https://install.portworx.com/pxbackup?comp=stork&storkNonPx=true"
kubectl apply -f stork-spec.yaml

echo "Step 5: Deploying source EKS cluster. This might take close to 20 minutes!"
eksctl create cluster -f eks-source-cluster.yaml
kubectl get nodes 
echo "Step 6: Installing Stork on EKS cluster!"
curl -fsL -o stork-spec.yaml "https://install.portworx.com/pxbackup?comp=stork&storkNonPx=true"
kubectl apply -f stork-spec.yaml
echo "Step 7: Deploying Demo Applicatons"
kubectl create ns demo
sleep 5s
kubectl apply -f postgres.yaml -n demo
sleep 10s 
kubectl apply -f k8s-logo.yaml -n demo
sleep 30s 
kubectl get all -n demo
sleep 10s
kubectl get pvc -n demo

kubectl create ns pacman
sleep 5s
kubectl apply -f mongo-deployment.yaml -n pacman
sleep 5 
kubectl apply -f pacman-deployment.yaml -n pacman
sleep 5 
kubectl apply -f mongo-pvc.yaml -n pacman
sleep 5
kubectl apply -f mongo-service.yaml -n pacman
sleep 5 
kubectl apply -f pacman-service.yaml -n pacman 
sleep 5 

echo "Demo Applications deployed successfully!"

echo "Application endpoints:"
echo "Logo App:"
kubectl get svc -n demo 

echo "Pacman App:"
kubectl get svc -n pacman -l name=pacman 


echo "------- Lab Ready to use -------"
