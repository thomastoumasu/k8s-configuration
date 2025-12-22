# 3.11 requests and limits
# https://kubernetes.io/docs/tasks/configure-pod-container/assign-cpu-resource/
# By keeping a Pod's memory/CPU request low, you give the Pod a good chance of being scheduled. 
# By having a memory/CPU limit that is greater than the memory/CPU request, you accomplish two things:
# The Pod can have bursts of activity where it makes use of memory/CPU that happens to be available.
# The amount of memory/CPU a Pod can use during a burst is limited to some reasonable amount.
# Example:
#   resources:
#     requests: # kube-scheduler uses this information to decide which node to place the Pod on and reserves at least this amount specifically for that container to use
#         memory: "64Mi" # in bytes, i for power of 2
#         cpu: "250m" # 1 CPU unit is equivalent to 1 physical CPU core, or 1 virtual core, depending on whether the node is a physical host or a virtual machine running inside a physical machine.
#     limits: # kubelet enforces the limit so that the running container is not allowed to use more of that resource:
#       memory: "128Mi" # Above this, the kernel may terminate the container (OOMKilled, Out Of Memory) when it detects memory pressure. 
#       cpu: "500m" # Around this, the kernel will restrict access to the CPU (CPU throttling).
# for mongo request, check https://www.mongodb.com/docs/kubernetes/current/tutorial/plan-k8s-op-considerations/

# result:
# (base) thomas@thomass-Air k8s-submission % kubectl top pod -l app=backend
# kubectl top pod -l app=frontend
# kubectl top pod -l app=mongo
# kubectl top pod -l app=image-finder
# NAME                           CPU(cores)   MEMORY(bytes)   
# backend-dep-7c69995bc5-4bx8v   3m           50Mi            
# NAME                            CPU(cores)   MEMORY(bytes)   
# frontend-dep-546bbfc758-zlt9v   1m           3Mi             
# NAME         CPU(cores)   MEMORY(bytes)   
# mongo-ss-0   11m          176Mi           
# NAME                                CPU(cores)   MEMORY(bytes)   
# image-finder-dep-6494c756db-k6bt7   5m           38Mi  

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
# gcloud container clusters get-credentials $CLUSTER_NAME --zone=$LOCATION
gcloud container clusters get-credentials $CLUSTER_NAME --location=$CONTROL_PLANE_LOCATION

# check: Each node has a maximum capacity for each of the resource types: the amount of CPU and memory it can provide for Pods. 
kubectl describe nodes > nodesStart.txt

# push on main to deploy project on namespace project (see .github/workflows/deploy_the-project.yaml)

# eventually connect the domain with the Gateway IP (in cloudflare)
kubectl get gateway shared-gateway -n infra

# confirm backend is connected to the database: "--backend connected to MongoDB"
kubens project
BACKENDPOD=$(kubectl get pods -o=name | grep backend)
kubectl logs $BACKENDPOD

# get pods status
POD=$BACKENDPOD
kubectl get $POD --no-headers -o custom-columns=":status"
kubectl get $POD --output=yaml
kubectl describe $POD

# how much do the apps use
kubectl top pod -l app=backend
kubectl top pod -l app=frontend
kubectl top pod -l app=mongo
kubectl top pod -l app=image-finder
kubectl describe nodes > nodesEnd.txt
