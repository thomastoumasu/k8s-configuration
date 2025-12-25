# 4.2 readiness and liveliness probes
# added one load balancer Health Check Policy to replace the default health check on / from the load balancer
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
kubectl cluster-info
kubectl create namespace project

# set kube-config to point at the cluster
gcloud container clusters get-credentials $CLUSTER_NAME --location=$CONTROL_PLANE_LOCATION # or --zone=$LOCATION

# push on main to deploy project on namespace project (see .github/workflows/deploy_the-project.yaml)

# eventually get the Gateway IP to connect the domain (in cloudflare)
kubectl get gateway shared-gateway -n infra

# debug lb health check
kubens project
kubectl get HealthCheckPolicy
kubectl describe HealthCheckPolicy lb-healthcheck-backend

# kubectl get pods should show all pods running
# now remove the db, the backend should fail its probes and start being not READY
kubectl delete -f ./the_project/mongo/manifests/statefulset_gke.yaml

# reapplying the db should fix it
kubectl apply -f ./the_project/mongo/manifests/statefulset_gke.yaml

# debug confirm backend is connected to the database: "--backend connected to MongoDB"
POD=$(kubectl get pods -o=name | grep backend)
kubectl logs $POD
# debug: get pods status
kubectl get $POD --no-headers -o custom-columns=":status"
kubectl get $POD --output=yaml
kubectl describe $POD
