# create cluster
k3d cluster create -p 8081:80@loadbalancer --agents 2

# create namespaces
kubectl create namespace exercises
kubectl create namespace project
