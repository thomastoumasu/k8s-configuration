gcloud -v
gcloud auth login
gcloud config set project dwk-gke-480809
gcloud services enable container.googleapis.com
gcloud container clusters create dwk-cluster --zone=europe-north1-b --cluster-version=1.32 --disk-size=32 --num-nodes=3 --machine-type=e2-small
gcloud container clusters get-credentials dwk-cluster --zone=europe-north1-b
kubectl cluster-info
# to set kube-config to point at the new cluster: gcloud container clusters get-credentials dwk-cluster --zone=europe-north1-b

gcloud container clusters update dwk-cluster --location=europe-north1-b --gateway-api=standard

kubectl create namespace project