# ingress service - to access multiple apps (here two: log_output and pingpong) from outside
sh clear.sh  

# # create images
# cd write
# docker build -t 1.10 .   
# # sanity check
# docker run --rm -p 3000:3000 --name 1.10 1.10 && curl localhost:3000
# docker tag 1.10 thomastoumasu/k8s-write:1.10
# docker push thomastoumasu/k8s-write:1.10
# cd ..

# create cluster
k3d cluster create -p 8081:80@loadbalancer --agents 2

# create deployment and service for both apps and common ingress
kubectl apply -f ./log_output/manifests/deployment.yaml
kubectl apply -f ./log_output/manifests/service.yaml
kubectl apply -f ./log_output/manifests/ingress.yaml

# check apps is accessible on host port
kubectl rollout status deployment log-output-dep
POD=$(kubectl get pods -o=name | grep log-output)
kubectl wait --for=condition=Ready $POD
kubectl get svc,ing # should see the svc on 2345 as well as the ingress on 80
# kubectl logs -f $POD --prefix --all-containers 
sleep 10
curl localhost:8081

# delete the deployment and start again to check that the storage was deleted
kubectl delete -f ./log_output/manifests/deployment.yaml
kubectl apply -f ./log_output/manifests/deployment.yaml
POD=$(kubectl get pods -o=name | grep log-output)
kubectl wait --for=condition=Ready $POD
sleep 10
curl localhost:8081

# docker ps
# k3d kubeconfig get k3s-default
# kubectl cluster-info
# kubectl explain pod deployment svc
# kubectl get pod,deployment,svc, nodes
# kubectl describe nodes/...
# kubectl logs -f $POD --prefix --all-containers
