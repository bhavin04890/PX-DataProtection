if [ ! -f ~/usr/local/bin/eksctl ]; then
	echo "Step 1: Installing eksctl to deploy Amazon EKS clusters"
	curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
	sudo mv /tmp/eksctl /usr/local/bin
	echo "eksctl successfully installed with version:" 
	eksctl version
fi

if [ ! -f ~/usr/local/bin/kubectl ]; then
	echo " Step 2: Installing kubectl"
	curl --silent -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
	chmod +x kubectl
	mkdir -p ~/.local/bin
	mv ./kubectl ~/usr/local/bin/
	export PATH=$PATH:~/usr/local/bin/
	echo "kubectl installed successfully with version:"
	kubectl version --client
fi

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

echo "------- Lab Ready to use -------"