# 3.10 save to Google GLobal Storage
# set up backup_dl.yaml as cron job github action (needs cluster up and working, for example with sh create_gkecl_big_gat.sh)

# template for storing local file testfile.txt to a public bucket:
# gcloud storage cp kube.png gs://thomastoumasu_k8s-bucket
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
    --role=roles/storage.objectViewer \
    --member=principal://iam.googleapis.com/projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/${PROJECT_ID}.svc.id.goog/subject/ns/project/sa/${KSA_NAME} \
    --condition=None

gcloud storage buckets add-iam-policy-binding gs://${BUCKET} \
    --role=roles/storage.objectCreator \
    --member=principal://iam.googleapis.com/projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/${PROJECT_ID}.svc.id.goog/subject/ns/project/sa/${KSA_NAME} \
    --condition=None

gcloud storage buckets add-iam-policy-binding gs://${BUCKET} \
    --role=roles/storage.legacyBucketWriter \
    --member=principal://iam.googleapis.com/projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/${PROJECT_ID}.svc.id.goog/subject/ns/project/sa/${KSA_NAME} \
    --condition=None

gcloud storage buckets add-iam-policy-binding gs://${BUCKET} \
    --role=roles/storage.admin \
    --member=principal://iam.googleapis.com/projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/${PROJECT_ID}.svc.id.goog/subject/ns/project/sa/${KSA_NAME} \
    --condition=None

gcloud storage buckets add-iam-policy-binding gs://${BUCKET} \
    --role=roles/storage.objectAdmin \
    --member=principal://iam.googleapis.com/projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/${PROJECT_ID}.svc.id.goog/subject/ns/project/sa/${KSA_NAME} \
    --condition=None

###
gcloud iam service-accounts create access-gcs \
    --project=${PROJECT_ID}

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member "serviceAccount:access-gcs@${PROJECT_ID}.iam.gserviceaccount.com" \
    --role "roles/storage.admin"

gcloud container clusters get-credentials $CLUSTER_NAME --zone $LOCATION --project $PROJECT_ID

kubectl create serviceaccount gcs-access-ksa \
    --namespace project

gcloud iam service-accounts add-iam-policy-binding access-gcs@${PROJECT_ID}.iam.gserviceaccount.com \
    --role roles/iam.workloadIdentityUser \
    --member "serviceAccount:${PROJECT_ID}.svc.id.goog[project/gcs-access-ksa]"

kubectl annotate serviceaccount gcs-access-ksa \
    --namespace project \
    iam.gke.io/gcp-service-account=access-gcs@${PROJECT_ID}.iam.gserviceaccount.com

gcloud container node-pools list \
	--cluster=$CLUSTER_NAME \
	--zone=$LOCATION \
	--format="(NAME)"

gcloud container node-pools describe default-pool \
	--cluster=$CLUSTER_NAME \
	--zone=$LOCATION \
	--format="value(config.workloadMetadataConfig)"

gcloud container node-pools update default-pool \
    --cluster=$CLUSTER_NAME \
    --location=$LOCATION \
    --workload-metadata=GKE_METADATA
    

# build dumper image, containing mongo for running mongodump and gcloud for saving to Google Cloud Storage
cd the_project/mongo/dumper
docker build --platform linux/amd64 -t 3.10 . 
docker tag 3.10 thomastoumasu/k8s-mongo-dumper:3.10a-amd && docker push thomastoumasu/k8s-mongo-dumper:3.10a-amd

# push on main to deploy project on namespace project (see .github/workflows/deploy_the-project.yaml)

# confirm backend is connected to the database: "--backend connected to MongoDB"
kubens project
BACKENDPOD=$(kubectl get pods -o=name | grep backend)
kubectl logs $BACKENDPOD

# then deploy pod that dumps mongodb to Google Cloud Storage
kubectl apply -f ./the_project/mongo/manifests/dumper.yaml
kubectl delete -f ./the_project/mongo/manifests/dumper.yaml

# debug
kubectl describe pod/dumper 
kubectl logs -f pod/dumper 
kubectl exec -it dumper -- sh 
BUCKET="thomastoumasu_k8s-bucket"
URI="mongodb://the_username:the_password@mongo-svc.project:27017/the_database"
