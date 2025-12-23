# 4.1 readiness and liveliness probes
# added two load balancer Health Check Policies to replace the default health checks on / from the load balancer

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
kubectl create namespace exercises

# set kube-config to point at the cluster
# gcloud container clusters get-credentials $CLUSTER_NAME --zone=$LOCATION
gcloud container clusters get-credentials $CLUSTER_NAME --location=$CONTROL_PLANE_LOCATION

kubectl apply -f ./manifests/gateway.yaml 
# deploy postgres, pingpong and log-output in namespace exercises
kubectl apply -f ./pingpong/postgres/manifests/config-map.yaml
kubectl apply -f ./pingpong/postgres/manifests/statefulset_gke.yaml
kubectl apply -f ./pingpong/manifests/deployment_gke.yaml
kubectl apply -f ./pingpong/manifests/service_gke_gat.yaml
kubectl apply -f ./pingpong/manifests/route_gke.yaml
kubectl apply -f ./pingpong/manifests/lb-healthcheckpolicy.yaml 
kubectl apply -f ./log_output/manifests/config-map.yaml
kubectl apply -f ./log_output/manifests/deployment_gke.yaml
kubectl apply -f ./log_output/manifests/service_gke_gat.yaml
kubectl apply -f ./log_output/manifests/route_gke.yaml
kubectl apply -f ./log_output/manifests/lb-healthcheckpolicy.yaml 

# check the-project is accessible
kubectl get gateway pingpong-gateway
kubectl get httproutes
kubectl describe httproutes ...
# curl ADDRESS of pingpong-gateway

# debug lb health check
kubectl get HealthCheckPolicy
kubectl describe HealthCheckPolicy lb-healthcheck-log-output
kubectl describe HealthCheckPolicy lb-healthcheck-pingpong

# kubectl get pods should show all pods running
# now remove the db, pingpong should fail its probes and start being not READY
kubectl delete -f ./pingpong/postgres/manifests/statefulset_gke.yaml

# reapplying the db should fix it
kubectl apply -f ./pingpong/postgres/manifests/statefulset_gke.yaml
