echo "Cleaning up the AWS Immersion Day labs" 

if [ ! -f ~/usr/local/bin/eksctl ]; then
	curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
	sudo mv /tmp/eksctl /usr/local/bin
fi

if [ ! -f ~/usr/local/bin/kubectl ]; then
	curl --silent -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
	chmod +x kubectl
	mkdir -p ~/.local/bin
	mv ./kubectl ~/usr/local/bin/
	export PATH=$PATH:~/usr/local/bin/
fi

echo "Deleting the destination cluster"
eksctl utils write-kubeconfig --cluster px-dataprotection-destination 
kubectl delete -f k8s-logo.yaml -n demo
sleep 30
kubectl delete -f postgres.yaml -n demo 
sleep 15
kubectl delete deploy stork -n kube-system 
sleep 15 
eksctl delete cluster -f eks-destination-cluster.yaml
 
eksctl utils write-kubeconfig --cluster px-dataprotection-source
kubectl delete -f k8s-logo.yaml -n demo
sleep 30
kubectl delete -f postgres.yaml -n demo 
sleep 15
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

eksctl delete cluster -f eks-source-cluster.yaml

echo "Deleting Backup buckets"

REGL_BUCKET="aws-12398-bucket"
OBJL_BUCKET="aws-12398-objl-bucket"

aws s3api delete-bucket --bucket $REGL_BUCKET --region us-east-1
aws s3api delete-bucket --bucket $OBJL_BUCKET --region us-east-1
