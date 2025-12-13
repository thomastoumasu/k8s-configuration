# # gateway api for gke, to access cluster from outside sh bin/bash/ex3_3.sh
# https://courses.mooc.fi/org/uh-cs/courses/devops-with-kubernetes/chapter-4/introduction-to-google-kubernetes-engine

# # # test project on local cluster
# sh delete_k3scl.sh
# sh docker_clean.sh
# sh create_k3scl.sh
# sh bin/bash/ex2_8.sh

# test project on gke
sh delete_k3scl.sh
sh delete_k3gke.sh
sh docker_clean.sh
sh create_gkecl.sh
kubectl delete all --all -n project
kubens project
# deploy 
# create a path in one cluster node for the storage
docker exec k3d-k3s-default-agent-0 mkdir -p /tmp/kube

# create deployment and service for image-finder and frontend in one pod, backend in another, and for common ingress
kubectl apply -f ./the_project/manifests/persistentvolume.yaml
kubectl apply -f ./the_project/manifests/persistentvolumeclaim.yaml
kubectl apply -f ./the_project/mongo/manifests/config-map.yaml
kubectl apply -f ./the_project/mongo/manifests/statefulset.yaml
kubectl apply -f ./the_project/frontend/manifests/deployment.yaml
kubectl apply -f ./the_project/image-finder/manifests/deployment.yaml
# POD=$(kubectl get pods -o=name | grep mongo)
# kubectl wait --for=condition=Ready $POD
kubectl apply -f ./the_project/backend/manifests/deployment.yaml
kubectl apply -f ./the_project/manifests/ingress.yaml
kubectl apply -f manifests/curl.yaml 
kubectl apply -f manifests/busybox.yaml 

# check the-project is accessible on host port
kubectl rollout status deployment frontend-dep
POD=$(kubectl get pods -o=name | grep backend)
kubectl wait --for=condition=Ready $POD
kubectl get svc,ing # should see the svc on 1234 and 2345 as well as the ingress on 80
sleep 10
curl localhost:8081

# kubectl get ing --watch
# kubectl get all -n exercises

# debug: kubectl describe pod/... check Events:
# debug: kubectl logs -f pod/...
# kubectl delete pod alpine-curl --grace-period=0 --force

# curl ADDRESS of twoapps-ingress

# sh delete_gkecl.sh
