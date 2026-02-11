# 5.7 knative - make pingpong app (and log_output, and greeter) serverless
# work as well in GKE as in k3s. Deployments use multi-arch images so can be shared. Only postgres statefulset need to be applied separately.
# no ingress nor gateway needed for GKE, knative/kourier takes care of making apps reachable from outside the cluster.

# IF GKE: create cluster 
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
  --cluster-version=1.32 --disk-size=32 --num-nodes=3 --machine-type=e2-small 
kubectl cluster-info
gcloud container clusters get-credentials $CLUSTER_NAME --location=$CONTROL_PLANE_LOCATION 

# IF k3d: create cluster
k3d cluster create --port 8082:30080@agent:0 -p 8081:80@loadbalancer --agents 2 --k3s-arg "--disable=traefik@server:0"

# Form here, same for GKE and k3s, except statefulset, see below.
# install knative serving components
kubectl apply -f https://github.com/knative/serving/releases/download/knative-v1.18.2/serving-crds.yaml
kubectl apply -f https://github.com/knative/serving/releases/download/knative-v1.18.2/serving-core.yaml
# install networking layer (Knative Kourier)
kubectl apply -f https://github.com/knative/net-kourier/releases/download/knative-v1.18.0/kourier.yaml
kubectl patch configmap/config-network \
  --namespace knative-serving \
  --type merge \
  --patch '{"data":{"ingress-class":"kourier.ingress.networking.knative.dev"}}'
# confirm external IP allocated, can take time for GKE
kubectl --namespace kourier-system get service kourier
# verify installation
kubectl get pods -n knative-serving
# configure DNS
kubectl apply -f https://github.com/knative/serving/releases/download/knative-v1.18.2/serving-default-domain.yaml

kubectl create namespace exercises || true
kubens exercises
# deploy three serverless apps (log_output, pingpong and greeter) and one stateful database
kubectl apply -f ./log_output/manifests/config-map.yaml
kubectl apply -f ./log_output/manifests/serverless.yaml
kubectl apply -f ./pingpong/postgres/manifests/config-map.yaml

# IF GKE (Volume provisioning is done a little differently)
kubectl apply -f ./pingpong/postgres/manifests/statefulset_gke.yaml
# IF k3s
kubectl apply -f ./pingpong/postgres/manifests/statefulset.yaml

kubectl apply -f ./pingpong/manifests/serverless.yaml
kubectl apply -f ./greeter/manifests/serverless.yaml

kubectl get ksvc
# for GKE, just curl the IPs
curl $(kubectl get ksvc/pingpong -o=jsonpath='{.status.url}')
curl $(kubectl get ksvc/log-output -o=jsonpath='{.status.url}')
curl $(kubectl get ksvc/greeter -o=jsonpath='{.status.url}')
# for k3s:
curl -H "Host: log-output.exercises.172.18.0.3.sslip.io " http://localhost:8081
curl -H "Host: pingpong.exercises.172.18.0.3.sslip.io " http://localhost:8081

# observe autoscaling, replica go to 0, starts up again if curled
kubectl get pod -l serving.knative.dev/service=pingpong -w

# debug DNS
kubectl apply -f ./manifests/curl.yaml
kubectl exec -it alpine-curl -- sh
curl pingpong.exercises.svc.cluster.local/pingpong
curl greeter.exercises.svc.cluster.local
curl greeter.exercises.172.18.0.3.sslip.io 
curl pingpong.exercises.172.18.0.3.sslip.io/counter
# if problem with db, debug postgres
kubectl apply -f ./manifests/busybox.yaml
kubectl exec -it my-busybox -- nslookup postgres-svc

# delete cluster
# GKE
gcloud container clusters delete dwk-cluster --zone=europe-north1-b
# k3s
k3d cluster delete