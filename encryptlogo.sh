#/bin/sh

kubectl delete -f k8s-logo.yaml -n demo
sleep 20
kubectl delete -f postgres.yaml -n demo
sleep 10
echo "Your Amazon EKS cluster has been under attack! All your applications have been encrypted!"