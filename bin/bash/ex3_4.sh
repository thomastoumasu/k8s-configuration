# # pingpong with the gateway for gke, to access cluster from outside sh bin/bash/ex3_4.sh
# https://courses.mooc.fi/org/uh-cs/courses/devops-with-kubernetes/chapter-4/introduction-to-google-kubernetes-engine
# from ingress to cluster: delete ingress and services, then 
# update cluster with gateway-api, apply gateway, new services (with ClusterIP instead of NodePort) and routes.

# sh delete_k3scl.sh
# sh docker_clean.sh
# kubectl delete all --all -n exercises
# sh create_gkecl.sh
# kubens exercises
# # deploy 
gcloud container clusters update dwk-cluster --location=europe-north1-b --gateway-api=standard
kubectl apply -f ./manifests/gateway.yaml 

kubectl apply -f ./pingpong/postgres/manifests/config-map.yaml
kubectl apply -f ./pingpong/postgres/manifests/statefulset_gke.yaml
# sanity check: PostgreSQL init process complete; ready for start up. in  
POSTGRESPOD=$(kubectl get pods -o=name | grep postgres)
kubectl wait --for=condition=Ready $POSTGRESPOD
kubectl logs $POSTGRESPOD 
kubectl apply -f ./pingpong/manifests/deployment_gke.yaml
kubectl apply -f ./pingpong/manifests/service_gke_gat.yaml
kubectl apply -f ./pingpong/manifests/route_gke.yaml
# sanity check: pingpong should connect to postgres
BACKENDPOD=$(kubectl get pods -o=name | grep pingpong)
kubectl wait --for=condition=Ready $BACKENDPOD
kubectl logs $BACKENDPOD

kubectl apply -f ./log_output/manifests/config-map.yaml
kubectl apply -f ./log_output/manifests/deployment_gke.yaml
LOGPOD=$(kubectl get pods -o=name | grep log-output)
kubectl wait --for=condition=Ready $LOGPOD
kubectl logs $LOGPOD
kubectl apply -f ./log_output/manifests/service_gke_gat.yaml
kubectl apply -f ./log_output/manifests/route_gke.yaml

kubectl describe gateway pingpong-gateway
gcloud compute url-maps list
# check the-project is accessible
kubectl get gateway pingpong-gateway
kubectl get httproutes
kubectl describe httproutes ...
# curl ADDRESS of pingpong-gateway

# debug: kubectl describe pod/... check Events:
# debug: kubectl logs -f pod/...
# kubectl get all -n exercises
# kubectl get events -n exercises  --sort-by='.lastTimestamp'
# kubectl get events --all-namespaces --sort-by='.lastTimestamp'
# kubectl logs --since=1h $MONGOPOD > logsMongoPodSmall.txt
# kubectl logs --previous $MONGOPOD > logsMongoPodSmallFirst.txt
# kubectl apply -f manifests/busybox.yaml 
# kubectl apply -f manifests/curl.yaml 
# kubectl exec -it alpine-curl -n default -- curl http://backend-svc:2345/
# kubectl delete pod alpine-curl --grace-period=0 --force



# sh delete_gkecl.sh
