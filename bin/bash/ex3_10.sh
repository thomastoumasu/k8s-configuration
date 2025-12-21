# 3.10 save to Google GLobal Storage
# set up backup_dl.yaml as cron job github action (needs cluster up and working, for example with sh create_gkecl_big_gat.sh)

# template for storing local file testfile.txt to a public bucket:
# gcloud storage cp testfile.txt gs://thomastoumasu_k8s-bucket
# here the difficulty is to run gcloud from a pod inside the cluster.

# create cluster
sh create_gkecl_big_gat.sh

# Create account for authentification, see https://docs.cloud.google.com/kubernetes-engine/docs/how-to/workload-identity
CLUSTER_NAME=dwk-cluster
LOCATION=europe-north1-b
PROJECT_ID=dwk-gke-480809
CONTROL_PLANE_LOCATION=europe-north1-b
KSA_NAME=gcs-api-sa
PROJECT_NUMBER=267537331918
BUCKET=thomastoumasu_k8s-bucket

gcloud container clusters update $CLUSTER_NAME \
    --location=$LOCATION \
    --workload-pool=${PROJECT_ID}.svc.id.goog

gcloud container clusters get-credentials $CLUSTER_NAME \
    --location=$CONTROL_PLANE_LOCATION

kubectl create serviceaccount $KSA_NAME \
    --namespace project

gcloud projects add-iam-policy-binding projects/${PROJECT_ID} \
    --role=roles/container.clusterViewer \
    --member=principal://iam.googleapis.com/projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/${PROJECT_ID}.svc.id.goog/subject/ns/project/sa/${KSA_NAME} \
    --condition=None

gcloud storage buckets add-iam-policy-binding gs://${BUCKET} \
    --role=roles/storage.objectCreator \
    --member=principal://iam.googleapis.com/projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/${PROJECT_ID}.svc.id.goog/subject/ns/project/sa/${KSA_NAME} \
    --condition=None

# build dumper image, containing mongo for running mongodump and gcloud for saving to Google Cloud Storage
cd the_project/mongo/dumper
docker build --platform linux/amd64 -t 3.10 . 
docker tag 3.10 thomastoumasu/k8s-mongo-dumper:3.10-amd && docker push thomastoumasu/k8s-mongo-dumper:3.10-amd

# push on main to deploy project on namespace project (see .github/workflows/deploy_the-project.yaml)

# then deploy pod that dumps mongodb to Google Cloud Storage
kubectl apply -f ./the_project/mongo/manifests/dumper.yaml

# debug
kubectl describe pod/dumper 
kubectl logs -f dumper 
