# nodeport service - to access app from outside
sh ../clear.sh  

# create cluster
k3d cluster create --port 8082:30080@agent:0 -p 8081:80@loadbalancer --agents 2

# create deployment and nodeport service
kubectl apply -f manifests/deployment.yaml
kubectl apply -f manifests/nodeport_service.yaml
# kubectl delete -f manifests/deployment.yaml

# check that app is accessible on host port
kubectl rollout status deployment the-project
# POD=$(kubectl get pods -o=name | grep the-project)
# kubectl wait --for=condition=Ready $POD

sleep 1 && curl localhost:8082