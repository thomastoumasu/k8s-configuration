set -e # exit immediately if a command exits with a non-zero status

# create cluster
k3d cluster create -a 2
# kubectl cluster-info
# k3d cluster stop start delete

# create docker image and push it to docker hub:
# 1. manually 
  # docker build -t 1.2 .
  # # image sanity check 
  # # docker run --rm --name 1.2 1.2

  # docker tag 1.2 thomastoumasu/k8s-the_project:1.2
  # docker push thomastoumasu/k8s-the_project:1.2

# 2. or with builder script
sh ../builder.sh the_project 1.2

# deploy image on cluster and wait for readyness
kubectl create deployment the-project --image=thomastoumasu/k8s-the_project:1.2
# kubectl get pods deployment
POD="$(kubectl get pods -o=name)"
kubectl wait --for=condition=Ready $POD

# check logs
kubectl logs -f $POD