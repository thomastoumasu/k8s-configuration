# persistent storage
sh clear.sh  

# # create images
# cd log-output
# docker build -t 1.11 .   
# # sanity check
# docker run --rm -p 3000:3000 --name 1.11 1.11 && curl localhost:3000
# docker tag 1.11 thomastoumasu/k8s-log-output:1.11
# docker push thomastoumasu/k8s-log-output:1.11
# cd ..

# create cluster
k3d cluster create -p 8081:80@loadbalancer --agents 2

docker exec k3d-k3s-default-agent-0 mkdir -p /tmp/kube

# create deployment and service for both apps and common ingress
kubectl apply -f manifests/persistentvolume.yaml
kubectl apply -f manifests/persistentvolumeclaim.yaml
kubectl apply -f manifests/deployment-persistent.yaml
kubectl apply -f manifests/service.yaml
kubectl apply -f manifests/ingress.yaml

# check apps are accessible on host port
kubectl rollout status deployment apps-dep
POD=$(kubectl get pods -o=name | grep apps)
kubectl wait --for=condition=Ready $POD
kubectl get svc,ing # should see the svcs on 1234 and 2345 as well as the ingress on 80
# kubectl logs -f $POD --prefix --all-containers 
sleep 3
curl localhost:8081

# # delete the deployment and start again to check that the storage was not deleted
# kubectl delete -f manifests/deployment-persistent.yaml
# kubectl apply -f manifests/deployment-persistent.yaml
# POD=$(kubectl get pods -o=name | grep apps)
# kubectl wait --for=condition=Ready $POD
# sleep 10
# curl localhost:8081

# docker ps
# k3d kubeconfig get k3s-default
# kubectl cluster-info
# kubectl explain pod deployment svc
# kubectl get pod,deployment,svc, nodes
# kubectl describe nodes/...
# kubectl logs -f $POD --prefix --all-containers

# kubectl patch pvc image-claim -p '{"metadata":{"finalizers": []}}' --type=merge
