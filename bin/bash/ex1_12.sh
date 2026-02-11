# persistent storage
sh clear.sh  

# # create images
# cd the_project/frontend
# docker build -t 1.12 .   
# # sanity check
# docker run --rm -p 8081:80 --name 1.12 1.12 && curl localhost:8081 // should see default image
# docker tag 1.12 thomastoumasu/k8s-frontend:1.12
# docker push thomastoumasu/k8s-frontend:1.12
# cd ../image-finder
# docker build -t 1.12 .   
# # sanity check
# docker run --rm -p 8081:80 --name 1.12 1.12 && docker exec -it 1.12 sh // ls -la /shared // should see hourlyImage.jpg change
# docker tag 1.12 thomastoumasu/k8s-image-finder:1.12
# docker push thomastoumasu/k8s-image-finder:1.12

# create cluster
k3d cluster create -p 8081:80@loadbalancer --agents 2
# create a path in one cluster node for the storage
docker exec k3d-k3s-default-agent-0 mkdir -p /tmp/kube

# create deployment and service for image-finder and frontend apps, and for common ingress
kubectl apply -f ./the_project/manifests/persistentvolume.yaml
kubectl apply -f ./the_project/manifests/persistentvolumeclaim.yaml
kubectl apply -f ./the_project/manifests/deployment-persistent.yaml
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

# # delete the deployment and start again to check that the storage was not deleted
# kubectl delete -f ./the_project/manifests/deployment-persistent.yaml
# kubectl apply -f ./the_project/manifests/deployment-persistent.yaml
# curl localhost:8081

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