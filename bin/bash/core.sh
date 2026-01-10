# Deploy the core functions of the pingpong/log_output/greeter app incl. db on GKE or locally with k3s
# Keeping as much common as possible:
# Using multi-arch images in the deployments: https://www.docker.com/blog/how-to-rapidly-build-multi-architecture-images-with-buildx/
# (since GKE uses amd and local k3s uses arm: arm workflows would be too expensive on GKE)
# But: 
# - Networking is either a Gateway (+ httproutes and lb HealthCheck policies) on GKE or an ingress on k3s.
# - pingpong app needs separate versions, since k3s ingress in this form does not allow path rewrite as is done on GKE (ToDo: replace with nginx ingress)
# - Volume provisioning for db is done slightly differently so different files for statefulset deployment of postgres db.

# GKE: set up GKE cluster -- from Template in gkecl.sh, here without Workload Identity nor Google Logging/Monitoring
CLUSTER_NAME=dwk-cluster
LOCATION=europe-north1-b
CONTROL_PLANE_LOCATION=europe-north1-b
PROJECT_ID=dwk-gke-480809
PROJECT_NUMBER=267537331918
gcloud -v
gcloud auth login
gcloud config set project $PROJECT_ID
gcloud services enable container.googleapis.com
gcloud container clusters create $CLUSTER_NAME --zone=$LOCATION \
  --cluster-version=1.32 --disk-size=32 --num-nodes=3 --machine-type=e2-small \
  --gateway-api=standard
kubectl cluster-info
gcloud container clusters get-credentials $CLUSTER_NAME --location=$CONTROL_PLANE_LOCATION 

# k3s: set up local cluster with k3d
k3d cluster create --port 8082:30080@agent:0 -p 8081:80@loadbalancer --agents 2

# Deploy the two common apps (Same form for both GKE and k3s). See kustomization.yaml.
kubectl create namespace exercises || true
kubens exercises
kubectl apply -k .

# Set up networking layer, pingpong deployment and postgres statefulset
# GKE: 
kubectl apply -f ./manifests/gateway_gke.yaml
kubectl apply -f ./pingpong/manifests/route_gke.yaml
kubectl apply -f ./pingpong/manifests/lb-healthcheckpolicy.yaml
kubectl apply -f ./log_output/manifests/route_gke.yaml
kubectl apply -f ./log_output/manifests/lb-healthcheckpolicy.yaml
kubectl apply -f ./pingpong/manifests/deployment.yaml
kubectl apply -f ./pingpong/postgres/manifests/statefulset_gke.yaml

# k3s:
kubectl apply -f manifests/ingress.yaml
kubectl apply -f ./pingpong/manifests/deployment_old.yaml
kubectl apply -f ./pingpong/postgres/manifests/statefulset.yaml

# sanity checks app
# multi-arch images sometimes lead to a "net/http: TLS handshake timeout" error from docker hub, in that case be patient and retry.
kubectl get po
kubectl rollout status deployment log-output-dep
POD=$(kubectl get pods -o=name | grep postgres) && kubectl wait --for=condition=Ready $POD
POD=$(kubectl get pods -o=name | grep pingpong)
# expect "Connection to postgres has been established successfully." after initContainer has completed
kubectl logs $POD -c init-postgres
kubectl logs $POD

# sanity checks GKE
# lb health checks
kubectl get HealthCheckPolicy
kubectl describe HealthCheckPolicy lb-healthcheck-log-output
kubectl describe HealthCheckPolicy lb-healthcheck-pingpong
# check cluster is accessible from outside via the gateway -- e.g. wait until PROGRAMMED True and ADDRESS has an IP, this can take time
kubectl get gateway pingpong-gateway
kubectl get httproutes
# expect SYNC, then wait 120 s
kubectl describe httproutes log-output-route
kubectl describe httproutes pingpong-route 
# curl ADDRESS of pingpong-gateway
curl 34.8.139.112/pingpong
curl 34.8.139.112

# sanity checks k3s  
# should see the svcs on 1234, 2345, 3456, 5432 as well as the ingress on 80
kubectl get svc,ing 
curl two:8081
curl two:8081/pingpong
curl two:8081

# expected output for GKE or k3s
# 2026-01-10T11:36:16.456Z: 0.nsye8l5xe8q 
# Ping / Pongs: 1
# env variable: MESSAGE=hello world
# file contents: this text is from files
# greetings: Hello from version 1.1

# delete cluster
# GKE
gcloud container clusters delete dwk-cluster --zone=europe-north1-b
# k3s
k3d cluster delete