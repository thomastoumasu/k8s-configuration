# new namespace for project sh bin/bash/ex2_4.sh
sh reset_cluster.sh
# kubectl get all --all-namespaces

kubectl delete all --all -n project
kubens project

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
kubectl apply -f manifests/debug-pod.yaml 

# check the-project is accessible on host port
kubectl rollout status deployment the-project-dep
POD=$(kubectl get pods -o=name | grep the-project)
kubectl wait --for=condition=Ready $POD
kubectl get svc,ing # should see the svc on 1234 as well as the ingress on 80
sleep 10
curl localhost:8081

# # debug: with service name
kubectl exec -it alpine-curl -- curl http://backend-svc.project:2345/api/todos 
# kubectl exec -it alpine-curl -n default -- curl http://backend-svc.project:2345/api/todos 
kubectl exec -it alpine-curl -- curl http://the-project-svc.project:1234
# # with service IP
SVCIP=$(kubectl get service/backend-svc -o jsonpath='{.spec.clusterIP}')
kubectl exec -it alpine-curl -- curl ${SVCIP}:2345/api/todos
# # with pod IP
# POD=$(kubectl get pods -o=name | grep backend)
# kubectl describe $POD
# curl this ID, with internal port (5000)

