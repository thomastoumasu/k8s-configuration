# networking between pods
sh clear.sh  

# # create images
# cd the_project/backend
# docker build -t 1.13 .   
# # sanity check
# docker run --rm -p 3000:3000 --name 1.13 1.13 && curl localhost:3000/api/todos 
# docker tag 1.13 thomastoumasu/k8s-backend:1.13
# docker push thomastoumasu/k8s-backend:1.13

# create cluster
k3d cluster create -p 8081:80@loadbalancer --agents 2
# create a path in one cluster node for the storage
docker exec k3d-k3s-default-agent-0 mkdir -p /tmp/kube

# create deployment and service for image-finder and frontend in one pod, backend in another, and for common ingress
kubectl apply -f ./the_project/manifests/persistentvolume.yaml
kubectl apply -f ./the_project/manifests/persistentvolumeclaim.yaml
kubectl apply -f ./the_project/manifests/deployment-persistent.yaml
kubectl apply -f ./the_project/backend/manifests/deployment.yaml
kubectl apply -f ./the_project/backend/manifests/service.yaml
kubectl apply -f ./the_project/manifests/service.yaml
kubectl apply -f ./the_project/manifests/ingress.yaml

# check the-project is accessible on host port
kubectl rollout status deployment the-project-dep
POD=$(kubectl get pods -o=name | grep the-project)
kubectl wait --for=condition=Ready $POD
kubectl get svc,ing # should see the svc on 1234 as well as the ingress on 80
sleep 10
curl localhost:8081
# kubectl logs -f $POD --prefix --all-containers 

# # play around
# POD=$(kubectl get pods -o=name | grep the-project)
# kubectl exec -it $POD -c frontend -- sh  // rm /usr/share/nginx/html/shared/hourlyImage.jpg // should see defaultImage now
# kubectl exec $POD -c image-finder -- /sbin/reboot
# kubectl exec -it $POD -c image-finder -- /bin/sh -c "kill 1"

# docker ps
# k3d kubeconfig get k3s-default
# kubectl cluster-info
# kubectl explain pod deployment svc
# kubectl get pod,deployment,svc, nodes
# kubectl describe nodes/...
# kubectl logs -f $POD --prefix --all-containers
# kubectl get pods $POD -o jsonpath='{.spec.containers[*].name}'
# kubectl exec -it $POD -c frontend -- sh