echo "Cleaning up the AWS Immersion Day labs" 

echo "Deleting the destination cluster"
eksctl utils write-kubeconfig --cluster=px-dataprotection-destination
kubectl delete -f k8s-logo.yaml -n demo
sleep 30
kubectl delete -f postgres.yaml -n demo 
sleep 15
kubectl delete deploy stork -n kube-system 
sleep 15 
eksctl delete cluster -f eks-destination-cluster.yaml


eksctl utils write-kubeconfig --cluster=px-dataprotection-source 
kubectl delete -f k8s-logo.yaml -n demo
sleep 30
kubectl delete -f postgres.yaml -n demo 
sleep 15
kubectl delete deploy stork -n kube-system 
sleep 15 
eksctl delete cluster -f eks-source-cluster.yaml