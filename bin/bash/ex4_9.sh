# 4.9 pull deployment pipeline of the_project with argo
# github action has changed: instead of deploying from action, action changes and checks in the kustomization file. 
# Argo is linked with this file and syncs the cluster accordingly.

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
# set kube-config to point at the cluster
gcloud container clusters get-credentials $CLUSTER_NAME --location=$CONTROL_PLANE_LOCATION 
# or --zone=$LOCATION
# sanity check: make sure Workload Identity Federation was indeed activated on the nodes used, output should be mode=GKE_METADATA, see ex3_10.sh
gcloud container node-pools describe default-pool --cluster=$CLUSTER_NAME --zone=$LOCATION --format="value(config.workloadMetadataConfig)"

kubectl create namespace infra || true
kubectl create namespace production || true
kubectl label namespaces production shared-gateway-access=true --overwrite=true
kubectl create namespace staging || true
kubectl label namespaces staging shared-gateway-access=true --overwrite=true

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

# link repo to argo so that argo will sync the cluster with repo changes
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
# check external IP of argocd-server to log in
kubectl get svc -n argocd --watch
# get initial password for admin (needs base64 decoding)
kubectl get -n argocd secrets argocd-initial-admin-secret -o yaml | grep -o 'password: .*' | cut -f2- -d: | base64 --decode
# log into argo in browser at external IP using admin and this password
# then sync the cluster 
# manually (use repo https://github.com/thomastoumasu/k8s-submission and path ./the_project/kustomize/overlays/main to sync with the kustomization.yaml of main)
# or declaratively
kubectl apply -n argocd -f ./the_project/kustomize/infra/application.yaml
kubectl apply -n argocd -f ./the_project/kustomize/overlays/staging/application.yaml
kubectl apply -n argocd -f ./the_project/kustomize/overlays/production/nats.yaml
kubectl apply -n argocd -f ./the_project/kustomize/overlays/production/application.yaml

# push on main will trigger deployment on staging namespace, release on main deployment on production namespace (see .github/workflows/pull-deploy_the-project.yaml)
# get gateway IP in argo, use it to connect the domain (in cloudflare)
kubectl get gateway shared-gateway -n infra --watch

# # debug
kubectl describe httproutes frontend-route -n staging
# dumper, see ex3_10.sh
kubectl describe cronjobs/periodic-dumper -n production
kubectl describe job/periodic-dumper-29440029 -n production
kubectl logs pod/periodic-dumper-29440029-ghq95 -n production # should see the dump: Copying file:///usr/src/app/dump/the_database/todos-2025-12-22T11-09-01.bson to gs://thomastoumasu_k8s-bucket/todos-2025-12-22T11-09-01.bson

