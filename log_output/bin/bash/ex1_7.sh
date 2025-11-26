# ingress service - to access app from outside
sh ../clear.sh  

# build image
sh ../builder.sh log_output 1.7

# create cluster
k3d cluster create --port 8082:30080@agent:0 -p 8081:80@loadbalancer --agents 2

kubectl apply -f manifests/deployment.yaml
kubectl apply -f manifests/service.yaml
kubectl apply -f manifests/ingress.yaml

# check that app is accessible on host port
kubectl rollout status deployment log-output-dep

sleep 1 && curl localhost:8081
