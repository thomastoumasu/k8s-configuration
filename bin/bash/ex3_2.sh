# # ingress for gke, to access cluster from outside sh bin/bash/ex3_2.sh

# sh delete_k3scl.sh
# sh docker_clean.sh

# # test pingpong on local cluster
# sh create_k3scl.sh
# kubens exercises
# # deploy 
# kubectl apply -f ./pingpong/postgres/manifests/config-map.yaml
# kubectl apply -f ./pingpong/postgres/manifests/statefulset.yaml
# kubectl apply -f ./pingpong/manifests/deployment.yaml
# kubectl apply -f ./pingpong/manifests/service.yaml

# kubectl apply -f ./log_output/manifests/config-map.yaml
# kubectl apply -f ./log_output/manifests/deployment.yaml
# kubectl apply -f ./log_output/manifests/service.yaml

# kubectl apply -f manifests/ingress.yaml

# kubectl apply -f manifests/curl.yaml 
# kubectl apply -f manifests/busybox.yaml 
# kubectl rollout status deployment pingpong-dep
# POD=$(kubectl get pods -o=name | grep output)
# kubectl wait --for=condition=Ready $POD

# curl two:8081/pingpong

# # # debug 
# # kubectl exec -it alpine-curl -- curl http://pingpong-svc:1234/pingpong 
# # # kubectl describe $POD
# # # # curl this ID, with internal port (3002)
# # # kubectl exec -it alpine-curl -- curl http://10.42.2.3:3002/pingpong 

# # test pingpong on gke
# sh delete_k3scl.sh
# sh docker_clean.sh
# kubectl delete all --all -n exercises
# sh create_gkecl.sh
# kubens exercises
# # deploy 
kubectl apply -f ./pingpong/postgres/manifests/config-map.yaml
kubectl apply -f ./pingpong/postgres/manifests/statefulset_gke.yaml
kubectl apply -f ./pingpong/manifests/deployment_gke.yaml
kubectl apply -f ./pingpong/manifests/service_gke.yaml

kubectl apply -f ./log_output/manifests/config-map.yaml
kubectl apply -f ./log_output/manifests/deployment_gke.yaml
kubectl apply -f ./log_output/manifests/service_gke.yaml

kubectl apply -f manifests/ingress_gke.yaml

kubectl get ing --watch
kubectl get all -n exercises

# debug: kubectl describe pod/... check Events:
# debug: kubectl logs -f pod/...
# kubectl delete pod alpine-curl --grace-period=0 --force

# curl ADDRESS of twoapps-ingress

# sh delete_gkecl.sh
