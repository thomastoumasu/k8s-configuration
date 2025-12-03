# new namespace for exercises sh bin/bash/ex2_3.sh
# sh reset_cluster.sh
# kubectl get all --all-namespaces

kubectl delete all --all -n exercises
kubens exercises

# create deployment and service for both apps and common ingress
kubectl apply -f ./log_output/manifests/deployment.yaml
kubectl apply -f ./log_output/manifests/service.yaml
kubectl apply -f ./pingpong/manifests/deployment.yaml
kubectl apply -f ./pingpong/manifests/service.yaml
kubectl apply -f manifests/ingress.yaml
kubectl apply -f manifests/debug-pod.yaml 

# wait for deployment
kubectl rollout status deployment log-output-dep
kubectl get svc,ing # should see the svcs on 1234 and 2345 as well as the ingress on 80
# POD=$(kubectl get pods -o=name | grep output)
# kubectl logs -f $POD --prefix --all-containers 
sleep 10
curl two:8081
curl two:8081/pingpong
curl two:8081

# debug: with service IP
# kubectl exec -it my-busybox -- wget -qO - http://pingpong-svc:1234/counter
kubectl exec -it alpine-curl -- curl http://pingpong-svc.exercises:1234/counter
kubectl exec -it alpine-curl -- curl http://log-output-svc.exercises:2345
# with service IP
SVCIP=$(kubectl get service/pingpong-svc -o jsonpath='{.spec.clusterIP}')
kubectl exec -it alpine-curl -- curl ${SVCIP}:1234/counter
# # with pod IP
# POD=$(kubectl get pods -o=name | grep pingpong)
# kubectl describe $POD
# curl this ID, with internal port (3002)

