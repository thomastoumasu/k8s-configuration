# networking between pods sh bin/bash/ex2_1.sh
sh clear.sh  
# create cluster
k3d cluster create -p 8081:80@loadbalancer --agents 2

# kubectl delete deployments,svc,pods --all

# # create images
# cd log_output
# docker build -t 2.1 .   
# # sanity check
# # docker run --rm -p 3000:3000 --name 2.1 2.1 && curl localhost:3000
# docker tag 2.1 thomastoumasu/k8s-log-output:2.1
# docker push thomastoumasu/k8s-log-output:2.1
# cd ..
# cd pingpong
# docker build -t 2.1 .   
# # sanity check
# docker run --rm -p 3002:3002 --name 2.1 2.1 && curl localhost:3002/pingpong && curl localhost:3002/counter
# docker tag 2.1 thomastoumasu/k8s-pingpong:2.1
# docker push thomastoumasu/k8s-pingpong:2.1

# kubectl delete -f ./log_output/manifests/deployment.yaml
# kubectl delete -f ./log_output/manifests/service.yaml
# kubectl delete -f ./pingpong/manifests/deployment.yaml
# kubectl delete -f ./pingpong/manifests/service.yaml
# kubectl delete -f manifests/ingress.yaml
# kubectl delete -f manifests/debug-pod.yaml 

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
curl localhost:8081
curl localhost:8081/pingpong
curl localhost:8081

# debug: with service IP
# kubectl exec -it my-busybox -- wget -qO - http://pingpong-svc:1234/counter
kubectl exec -it alpine-curl -- curl http://pingpong-svc:1234/counter
kubectl exec -it alpine-curl -- curl http://log-output-svc:2345
# with service IP
SVCIP=$(kubectl get service/pingpong-svc -o jsonpath='{.spec.clusterIP}')
kubectl exec -it alpine-curl -- curl ${SVCIP}:1234/counter
# with pod IP
POD=$(kubectl get pods -o=name | grep pingpong)
kubectl describe $POD
# curl this ID, with internal port (3002)

# docker ps
# k3d kubeconfig get k3s-default
# kubectl cluster-info
# kubectl explain pod deployment svc
# kubectl get pod,deployment,svc, nodes
# kubectl describe nodes/...
# kubectl logs -f $POD --prefix --all-containers

# kubectl patch pvc image-claim -p '{"metadata":{"finalizers": []}}' --type=merge
