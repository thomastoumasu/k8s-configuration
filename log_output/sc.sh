# create docker image and push it to docker hub:
# 1. manually 
  # docker build -t 1.1 .
  # # image sanity check 
  # # docker run --rm --name 1.1 1.1

  # docker tag 1.1 thomastoumasu/k8s-log_output:1.1
  # docker push thomastoumasu/k8s-log_output:1.1

# 2. or with builder script
sh ../builder.sh log_output 1.1

# create cluster
k3d cluster create -a 2
# kubectl cluster-info
# k3d cluster stop start delete

# deploy image on cluster
kubectl create deployment log-output --image=thomastoumasu/k8s-log_output:1.1
sleep 10

# check logs
# kubectl get pods
# kubectl get deployments
kubectl logs -f $(kubectl get pods -o=name)