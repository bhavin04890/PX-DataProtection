#!/bin/bash

REGL_BUCKET="aws-12398-bucket"
OBJL_BUCKET="aws-12398-objl-bucket"

if [ ! -f ~/usr/local/bin/eksctl ]; then
	echo "Step 1: Installing eksctl to deploy Amazon EKS clusters"
	echo -e "/n"
	curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
	sudo mv /tmp/eksctl /usr/local/bin
	echo "eksctl successfully installed with version:" 
	eksctl version
fi

echo -e "/n"

if [ ! -f ~/usr/local/bin/kubectl ]; then
	echo " Step 2: Installing kubectl"
	echo -e "/n"
	curl --silent -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
	chmod +x kubectl
	mkdir -p ~/.local/bin
	mv ./kubectl ~/usr/local/bin/
	export PATH=$PATH:~/usr/local/bin/
	echo "kubectl installed successfully with version:"
	kubectl version --client
fi

echo -e "/n"

echo "Step 3: Installing destination EKS cluster. This might take close to 20 minutes"
eksctl create cluster -f eks-destination-cluster.yaml

echo -e "/n/n"
kubectl get nodes 
kubectl create ns demo
echo -e "/n"
echo "Step 4: Installing Stork on destination EKS cluster"
curl -fsL -o stork-spec.yaml "https://install.portworx.com/pxbackup?comp=stork&storkNonPx=true"
kubectl apply -f stork-spec.yaml

echo -e "/n"
echo "Step 5: Deploying source EKS cluster. This might take close to 20 minutes!"
eksctl create cluster -f eks-source-cluster.yaml
echo -e "/n/n"
kubectl get nodes 
echo "Step 6: Installing Stork on EKS cluster!"
curl -fsL -o stork-spec.yaml "https://install.portworx.com/pxbackup?comp=stork&storkNonPx=true"
kubectl apply -f stork-spec.yaml
echo -e "/n"
echo "Step 7: Deploying Demo Applicaton"
kubectl create ns demo
sleep 5s
kubectl apply -f postgres.yaml -n demo
sleep 10s 
kubectl apply -f k8s-logo.yaml -n demo
sleep 30s 
kubectl get all -n demo
sleep 10s
kubectl get pvc -n demo
echo "Demo Application deployed successfully!"
echo -e "/n/n"
echo "Creating S3 buckets as backup targets"
echo -e "/n"

aws s3api create-bucket --bucket $REGL_BUCKET --region us-east-1

aws s3api create-bucket --bucket $OBJL_BUCKET --region us-east-1 --object-lock-enabled-for-bucket 
aws s3api put-object-lock-configuration --bucket $OBJL_BUCKET --object-lock-configuration '{ "ObjectLockEnabled": "Enabled", "Rule": { "DefaultRetention": { "Mode": "COMPLIANCE", "Days": 1 }}}'


echo -e "/n"
echo "------- Lab Ready to use -------"