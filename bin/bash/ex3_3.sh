# # the_project with the gateway for gke, to access cluster from outside sh bin/bash/ex3_3.sh
# https://courses.mooc.fi/org/uh-cs/courses/devops-with-kubernetes/chapter-4/introduction-to-google-kubernetes-engine

# need first to get IP with the ingress, then write this IP in ENV VITE_BACKEND_URL in frontend Dockerfile, 
# and build this into the frontend image applied with the_project/frontend/manifests/deployment_gke.yaml

# # test project on local cluster
# kubectl delete all --all -n project
# sh delete_gkecl.sh
# sh delete_k3scl.sh
# sh docker_clean.sh
# sh create_k3scl.sh
# sh bin/bash/ex2_8.sh

# test project on gke, for mongo need --machine-type=e2-small
sh delete_k3scl.sh
sh docker_clean.sh
kubectl delete all --all -n project
sh create_gkecl.sh
kubens project
# deploy 
gcloud container clusters update dwk-cluster --location=europe-north1-b --gateway-api=standard
kubectl apply -f ./the_project/manifests/gateway.yaml 

kubectl apply -f ./the_project/mongo/manifests/config-map.yaml
kubectl apply -f ./the_project/mongo/manifests/statefulset_gke.yaml
MONGOPOD=$(kubectl get pods -o=name | grep mongo)
kubectl wait --for=condition=Ready $MONGOPOD
# sanity check: mongo-init.js should be called in  kubectl logs $MONGOPOD > tempMongo.txt
kubectl apply -f ./the_project/backend/manifests/deployment_gke_gat.yaml
kubectl apply -f ./the_project/backend/manifests/route_gke.yaml
BACKENDPOD=$(kubectl get pods -o=name | grep backend)
kubectl wait --for=condition=Ready $BACKENDPOD
# sanity check: backend should connect to mongo  kubectl logs $BACKENDPOD
kubectl apply -f ./the_project/manifests/persistentvolumeclaim_gke.yaml
kubectl apply -f ./the_project/image-finder/manifests/deployment_gke.yaml
kubectl apply -f ./the_project/frontend/manifests/deployment_gke_gat.yaml
FRONTENDPOD=$(kubectl get pods -o=name | grep frontend)
kubectl wait --for=condition=Ready $FRONTENDPOD
kubectl apply -f ./the_project/frontend/manifests/route_gke.yaml

kubectl describe gateway my-gateway
gcloud compute url-maps list
# check the-project is accessible
kubectl get gateway my-gateway
kubectl get httproutes
kubectl describe httproutes ...
# curl ADDRESS of my-gateway

# debug: kubectl describe pod/... check Events:
# debug: kubectl logs -f pod/...
kubectl get all -n project
kubectl get events -n project  --sort-by='.lastTimestamp'
kubectl get events --all-namespaces --sort-by='.lastTimestamp'
kubectl logs --since=1h $MONGOPOD > logsMongoPodSmall.txt
kubectl logs --previous $MONGOPOD > logsMongoPodSmallFirst.txt
kubectl apply -f manifests/busybox.yaml 
kubectl apply -f manifests/curl.yaml 
kubectl exec -it alpine-curl -n default -- curl http://backend-svc:2345/
# kubectl delete pod alpine-curl --grace-period=0 --force

# sh delete_gkecl.sh
