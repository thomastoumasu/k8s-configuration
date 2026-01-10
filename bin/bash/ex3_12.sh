# 3.12 enable gke monitoring
# https://docs.cloud.google.com/kubernetes-engine/docs/concepts/observability

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
  --logging=SYSTEM,WORKLOAD,API_SERVER

# # or just update existing cluster: 
# gcloud container clusters update $CLUSTER_NAME --zone=$LOCATION --logging=SYSTEM,WORKLOAD,API_SERVER

kubectl cluster-info
kubectl create namespace project

# set kube-config to point at the cluster
# gcloud container clusters get-credentials $CLUSTER_NAME --zone=$LOCATION
gcloud container clusters get-credentials $CLUSTER_NAME --location=$CONTROL_PLANE_LOCATION

# # check: Each node has a maximum capacity for each of the resource types: the amount of CPU and memory it can provide for Pods. 
# kubectl describe nodes > nodesStart.txt

# push on main to deploy project on namespace project (see .github/workflows/deploy_the-project.yaml)

# eventually connect the domain with the Gateway IP (in cloudflare)
kubectl get gateway shared-gateway -n infra

# confirm backend is connected to the database: "--backend connected to MongoDB"
kubens project
BACKENDPOD=$(kubectl get pods -o=name | grep backend)
kubectl logs $BACKENDPOD

# how much resources do the apps use
kubectl top pod -l app=backend && kubectl top pod -l app=frontend && kubectl top pod -l app=mongo && kubectl top pod -l app=image-finder
kubectl describe nodes > nodesEnd.txt

# debug: get pods status
POD=$BACKENDPOD
kubectl get $POD --no-headers -o custom-columns=":status"
kubectl get $POD --output=yaml
kubectl describe $POD
