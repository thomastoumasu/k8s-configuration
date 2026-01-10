# Templates to create and delete gke cluster

# Delete existing gke cluster (see EOF to additionaly delete images in google images repo)
gcloud container clusters delete dwk-cluster --zone=europe-north1-b

# Create new gke cluster
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
# if Workload Identity needed (to run gcloud command from a pod inside the cluster, see 4.9)
  --workload-pool=${PROJECT_ID}.svc.id.goog --workload-metadata=GKE_METADATA \
# if wants to use Google Logging (instead of say Prometheus), see 3.11
  --logging=SYSTEM,WORKLOAD,API_SERVER
# if uses gateway api instead of ingress
  --gateway-api=standard
kubectl cluster-info
# set kube-config to point at the cluster
gcloud container clusters get-credentials $CLUSTER_NAME --location=$CONTROL_PLANE_LOCATION 
# or --zone=$LOCATION

#########################################OPTIONAL#############################
# if using Argo and github actions, see 4.9
kubectl create namespace infra || true
kubectl create namespace production || true
kubectl label namespaces production shared-gateway-access=true --overwrite=true
kubectl create namespace staging || true
kubectl label namespaces staging shared-gateway-access=true --overwrite=true

# Example setting authorizations for Workload Identity, see 4.9
KSA_NAME=gcs-api-service-account
BUCKET=thomastoumasu_k8s-bucket
kubectl create serviceaccount $KSA_NAME --namespace production
gcloud projects add-iam-policy-binding projects/${PROJECT_ID} \
    --role=roles/container.clusterViewer \
    --member=principal://iam.googleapis.com/projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/${PROJECT_ID}.svc.id.goog/subject/ns/production/sa/${KSA_NAME} \
    --condition=None

gcloud storage buckets add-iam-policy-binding gs://${BUCKET} \
    --role=roles/storage.legacyBucketReader \
    --member=principal://iam.googleapis.com/projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/${PROJECT_ID}.svc.id.goog/subject/ns/production/sa/${KSA_NAME} \
    --condition=None

gcloud storage buckets add-iam-policy-binding gs://${BUCKET} \
    --role=roles/storage.legacyBucketWriter \
    --member=principal://iam.googleapis.com/projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/${PROJECT_ID}.svc.id.goog/subject/ns/production/sa/${KSA_NAME} \
    --condition=None

# delete images in google images repo
gcloud container images delete

# With cleanup policy, see delete.yaml in .github/workflows
# https://docs.cloud.google.com/artifact-registry/docs/repositories/cleanup-policy#json
gcloud artifacts repositories set-cleanup-policies my-repository --project='dwk-gke-480809' --location='europe-north1' --policy='delete-policy.json' --no-dry-run

# if dry run, see the result
gcloud logging read 'protoPayload.serviceName="artifactregistry.googleapis.com" AND protoPayload.request.parent="projects/dwk-gke-480809/locations/europe-north1/repositories/my-repository/packages/-" AND protoPayload.request.validateOnly=true' --resource-names="projects/dwk-gke-480809" --project=dwk-gke-480809

# check after one day
gcloud artifacts docker images list europe-north1-docker.pkg.dev/dwk-gke-480809/my-repository/backend --include-tags > after.txt

# delete-policy.json
[
  {
    "name": "delete-branch-images",
    "action": { "type": "Delete" },
    "condition": {
      "tagState": "tagged",
      "tagPrefixes": ["test-sharedgta"]
    }
  }
]

