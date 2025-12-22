# 3.10 save to Google Global Storage
# template for storing local file testfile.txt to a public bucket: gcloud storage cp kube.png gs://thomastoumasu_k8s-bucket

# here the difficulty is to run gcloud from a pod inside the cluster. Needs authorization.
# Instead of mounting service file key.json as a volume into the pod, we use the Workload Identity Federation, see https://docs.cloud.google.com/kubernetes-engine/docs/how-to/workload-identity

CLUSTER_NAME=dwk-cluster
LOCATION=europe-north1-b
CONTROL_PLANE_LOCATION=europe-north1-b
PROJECT_ID=dwk-gke-480809
PROJECT_NUMBER=267537331918
KSA_NAME=gcs-api-service-account
BUCKET=thomastoumasu_k8s-bucket

# create cluster
gcloud -v
gcloud auth login
gcloud config set project $PROJECT_ID
gcloud services enable container.googleapis.com
gcloud container clusters create $CLUSTER_NAME --zone=$LOCATION \
  --cluster-version=1.32 --disk-size=32 --num-nodes=3 --machine-type=e2-small \
  --workload-pool=${PROJECT_ID}.svc.id.goog --workload-metadata=GKE_METADATA \
  --gateway-api=standard
kubectl cluster-info
kubectl create namespace project

# update if cluster had been created earlier
gcloud container clusters update $CLUSTER_NAME --location=$LOCATION --workload-pool=${PROJECT_ID}.svc.id.goog

# sanity check: make sure Workload Identity Federation was indeed activated on the nodes used, see https://www.trendmicro.com/cloudoneconformity/knowledge-base/gcp/GKE/enable-metadata-server.html
# first get the node-pool name
gcloud container node-pools list --cluster=$CLUSTER_NAME --zone=$LOCATION --format="(NAME)"
# if it is "default-pool", then do (or else replace the name)
gcloud container node-pools describe default-pool --cluster=$CLUSTER_NAME --zone=$LOCATION --format="value(config.workloadMetadataConfig)"
# if output is mode=GKE_METADATA, then all good. Otherwise need to manually update the existing node-pool:
gcloud container node-pools update default-pool --cluster=$CLUSTER_NAME --location=$LOCATION --workload-metadata=GKE_METADATA

# now install gateway API
gcloud container clusters update dwk-cluster --location=europe-north1-b --gateway-api=standard

# set kube-config to point at the cluster
# gcloud container clusters get-credentials $CLUSTER_NAME --zone=$LOCATION
gcloud container clusters get-credentials $CLUSTER_NAME --location=$CONTROL_PLANE_LOCATION

# Create account for authentification and set appropriate permissions
# for cp, needs storage.object.get, create, list, delete and storage.buckets.get, see https://docs.cloud.google.com/storage/docs/access-control/iam-gcloud
# so roles/storage.legacyBucketReader and roles/storage.legacyBucketWriter should be ok, see https://docs.cloud.google.com/storage/docs/access-control/iam-roles
kubectl create serviceaccount $KSA_NAME --namespace project

gcloud projects add-iam-policy-binding projects/${PROJECT_ID} \
    --role=roles/container.clusterViewer \
    --member=principal://iam.googleapis.com/projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/${PROJECT_ID}.svc.id.goog/subject/ns/project/sa/${KSA_NAME} \
    --condition=None

gcloud storage buckets add-iam-policy-binding gs://${BUCKET} \
    --role=roles/storage.legacyBucketReader \
    --member=principal://iam.googleapis.com/projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/${PROJECT_ID}.svc.id.goog/subject/ns/project/sa/${KSA_NAME} \
    --condition=None

gcloud storage buckets add-iam-policy-binding gs://${BUCKET} \
    --role=roles/storage.legacyBucketWriter \
    --member=principal://iam.googleapis.com/projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/${PROJECT_ID}.svc.id.goog/subject/ns/project/sa/${KSA_NAME} \
    --condition=None

# If not yet done, build dumper image, containing mongo for running mongodump and gcloud for saving to Google Cloud Storage
cd the_project/mongo/dumper
docker build --platform linux/amd64 -t 3.10 . 
docker tag 3.10 thomastoumasu/k8s-mongo-dumper:3.10-amd && docker push thomastoumasu/k8s-mongo-dumper:3.10-amd

# push on main to deploy project on namespace project (see .github/workflows/deploy_the-project.yaml)

# confirm backend is connected to the database: "--backend connected to MongoDB"
kubens project
BACKENDPOD=$(kubectl get pods -o=name | grep backend)
kubectl logs $BACKENDPOD

# then start job that once an hour deploys a pod that dumps mongodb to Google Cloud Storage
kubectl apply -f ./the_project/mongo/manifests/dumper.yaml

# # debug
# kubectl delete -f ./the_project/mongo/manifests/dumper.yaml
# kubectl describe pod/dumper 
# kubectl logs -f pod/dumper 
# kubectl exec -it dumper -- sh 
#   BUCKET="thomastoumasu_k8s-bucket"
#   URI="mongodb://the_username:the_password@mongo-svc.project:27017/the_database"
#   mongodump --uri=$MONGO_URI --out /usr/src/app/dump/
#   NOW=$(date +'%Y-%m-%dT%H-%M-%S')
#   FILENAME="/usr/src/app/dump/the_database/todos-${NOW}.bson"
#   mv /usr/src/app/dump/the_database/todos.bson $FILENAME
#   curl -X GET -H "Authorization: Bearer $(gcloud auth print-access-token)" "https://storage.googleapis.com/storage/v1/b/${BUCKET}/o"
#   gcloud storage cp $FILENAME gs://${BUCKET}


# # debug: additional permissions
# gcloud storage buckets add-iam-policy-binding gs://${BUCKET} \
#     --role=roles/storage.objectViewer \
#     --member=principal://iam.googleapis.com/projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/${PROJECT_ID}.svc.id.goog/subject/ns/project/sa/${KSA_NAME} \
#     --condition=None

# gcloud storage buckets add-iam-policy-binding gs://${BUCKET} \
#     --role=roles/storage.objectCreator \
#     --member=principal://iam.googleapis.com/projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/${PROJECT_ID}.svc.id.goog/subject/ns/project/sa/${KSA_NAME} \
#     --condition=None

# gcloud storage buckets add-iam-policy-binding gs://${BUCKET} \
#     --role=roles/storage.admin \
#     --member=principal://iam.googleapis.com/projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/${PROJECT_ID}.svc.id.goog/subject/ns/project/sa/${KSA_NAME} \
#     --condition=None

# gcloud storage buckets add-iam-policy-binding gs://${BUCKET} \
#     --role=roles/storage.objectAdmin \
#     --member=principal://iam.googleapis.com/projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/${PROJECT_ID}.svc.id.goog/subject/ns/project/sa/${KSA_NAME} \
#     --condition=None


# # debug: other way
###
# gcloud iam service-accounts create access-gcs \
#     --project=${PROJECT_ID}

# gcloud projects add-iam-policy-binding $PROJECT_ID \
#     --member "serviceAccount:access-gcs@${PROJECT_ID}.iam.gserviceaccount.com" \
#     --role "roles/storage.admin"

# gcloud container clusters get-credentials $CLUSTER_NAME --zone $LOCATION --project $PROJECT_ID

# kubectl create serviceaccount gcs-access-ksa \
#     --namespace project

# gcloud iam service-accounts add-iam-policy-binding access-gcs@${PROJECT_ID}.iam.gserviceaccount.com \
#     --role roles/iam.workloadIdentityUser \
#     --member "serviceAccount:${PROJECT_ID}.svc.id.goog[project/gcs-access-ksa]"

# kubectl annotate serviceaccount gcs-access-ksa \
#     --namespace project \
#     iam.gke.io/gcp-service-account=access-gcs@${PROJECT_ID}.iam.gserviceaccount.com