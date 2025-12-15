# 3.5 kustomize
# # first play with static website example
# cd static-website
# build image
# docker build . -t colorcontent && docker run --rm -p 3000:80 colorcontent
# curl localhost:3000
# docker tag colorcontent thomastoumasu/k8s-colorcontent:arm
# docker push thomastoumasu/k8s-colorcontent:arm

# # deploy on k3s cluster
# sh ../sh delete_k3scl.sh
# sh ../docker_clean.sh
# k3d cluster create --port 8082:30080@agent:0 --agents 2
# kubectl create namespace exercises
# kubens exercises
# kubectl kustomize . # to check what kustomize is doing
# kubectl apply -k .
# kubectl rollout status deployment dwk-environments
# curl localhost:8082

# # same as 3.3 with kustomize
# # the_project with the gateway for gke, to access cluster from outside sh bin/bash/ex3_5.sh
# sh delete_k3scl.sh
# sh docker_clean.sh
# kubectl delete all --all -n project
# # for mongo need --machine-type=e2-small
# sh create_gkecl.sh
# kubens project
# # deploy 
# gcloud container clusters update dwk-cluster --location=europe-north1-b --gateway-api=standard
cd the_project
# sanity check for customize: 
kubectl kustomize .
kubectl apply -k .
# check the-project is accessible
kubectl describe gateway my-gateway
gcloud compute url-maps list
kubectl get gateway my-gateway