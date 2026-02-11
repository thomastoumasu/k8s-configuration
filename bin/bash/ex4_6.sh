# 4.6 nats - broadcaster

CLUSTER_NAME=dwk-cluster
LOCATION=europe-north1-b
CONTROL_PLANE_LOCATION=europe-north1-b
PROJECT_ID=dwk-gke-480809
PROJECT_NUMBER=267537331918

# create cluster
gcloud -v
gcloud auth login
gcloud config set project $PROJECT_ID
gcloud services enable container.googleapis.com
gcloud container clusters create $CLUSTER_NAME --zone=$LOCATION \
  --cluster-version=1.32 --disk-size=32 --num-nodes=3 --machine-type=e2-small \
  --gateway-api=standard
kubectl cluster-info
kubectl create namespace project

# set kube-config to point at the cluster
gcloud container clusters get-credentials $CLUSTER_NAME --location=$CONTROL_PLANE_LOCATION 
# or --zone=$LOCATION

# # install helm chart for nats
# helm repo add nats https://nats-io.github.io/k8s/helm/charts/
# helm repo update
# # should see nats                    https://nats-io.github.io/k8s/helm/charts/ 
# helm repo list
kubens project
helm install my-nats nats/nats

# push on main to deploy project on namespace project (see .github/workflows/deploy_the-project.yaml)

# eventually get the Gateway IP to connect the domain (in cloudflare)
kubectl get gateway shared-gateway -n infra

# check the logs of the broadcaster
POD=$(kubectl get pods -o=name | grep broadcaster)
kubectl describe $POD
kubectl wait --for=condition=Ready $POD
kubectl logs -f $POD

# monitor simply with nats
kubectl port-forward my-nats-0 8222:8222

# # debug
kubectl delete -f ./the_project/broadcaster/manifests/deployment.yaml
cd the_project/broadcaster
docker build --platform linux/amd64 -t broadcaster . 
docker tag broadcaster thomastoumasu/k8s-broadcaster:j && docker push thomastoumasu/k8s-broadcaster:j
cd ../../
kubectl apply -f ./the_project/broadcaster/manifests/deployment.yaml
