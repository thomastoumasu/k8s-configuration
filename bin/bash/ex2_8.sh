# env variables sh bin/bash/ex2_8.sh
# sh reset_cluster.sh
# kubectl get all --all-namespaces

kubectl delete all --all -n project
kubens project

# create a path in one cluster node for the storage
docker exec k3d-k3s-default-agent-0 mkdir -p /tmp/kube

# create deployment and service for image-finder and frontend in one pod, backend in another, and for common ingress
kubectl apply -f ./the_project/manifests/persistentvolume.yaml
kubectl apply -f ./the_project/manifests/persistentvolumeclaim.yaml
kubectl apply -f ./the_project/mongo/manifests/config-map.yaml
kubectl apply -f ./the_project/mongo/manifests/statefulset.yaml
kubectl apply -f ./the_project/frontend/manifests/deployment.yaml
kubectl apply -f ./the_project/image-finder/manifests/deployment.yaml
kubectl apply -f ./the_project/backend/manifests/deployment.yaml
kubectl apply -f ./the_project/manifests/ingress.yaml
kubectl apply -f manifests/debug-pod.yaml 

# check the-project is accessible on host port
kubectl rollout status deployment frontend-dep
POD=$(kubectl get pods -o=name | grep backend)
kubectl wait --for=condition=Ready $POD
kubectl get svc,ing # should see the svc on 1234 and 2345 as well as the ingress on 80
sleep 10
curl localhost:8081

# # debug mongo
# POD=$(kubectl get pods -o=name | grep backend) && kubectl logs -f $POD  
# POD=$(kubectl get pods -o=name | grep mongo) && kubectl logs -f $POD  
# kubectl exec -it $POD -- sh 
# mongosh -u root -p example
# mongosh -u the_username -p the_password
# show dbs
# use the_database
# show collections
# db.todos.find({})

# # reset mongo
kubectl delete -f ./the_project/mongo/manifests/config-map.yaml # and change the file
kubectl delete -f ./the_project/mongo/manifests/statefulset.yaml
kubectl get pvc
kubectl delete pvc/data-mongo-ss-0  
kubectl apply -f ./the_project/mongo/manifests/config-map.yaml
kubectl apply -f ./the_project/mongo/manifests/statefulset.yaml

# # debug network: with service name
kubectl exec -it alpine-curl -- curl http://backend-svc.project:2345/api/todos 
kubectl exec -it alpine-curl -- curl http://frontend-svc.project:1234
# # with service IP
SVCIP=$(kubectl get service/backend-svc -o jsonpath='{.spec.clusterIP}')
kubectl exec -it alpine-curl -- curl ${SVCIP}:2345/api/todos
# # with pod IP
# POD=$(kubectl get pods -o=name | grep backend)
# kubectl describe $POD
# curl this ID, with internal port (5000)

