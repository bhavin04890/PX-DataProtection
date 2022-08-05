#/bin/sh

kubectl delete -f mongo-service.yaml -n pacman
sleep 30
kubectl delete -f pacman-service.yaml -n pacman
sleep 30
kubectl delete -f mongo-deployment.yaml -n pacman
sleep 10
kubectl delete -f mongo-pvc.yaml -n pacman
sleep 10
kubectl delete -f pacman-deployment.yaml -n pacman
sleep 10
kubectl delete ns pacman
sleep 30

echo "Pacman delete 'Accidently'"
