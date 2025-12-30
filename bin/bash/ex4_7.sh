# 4.7 deploy log_output/pingpong app (aka exercises) with argo
# https://courses.mooc.fi/org/uh-cs/courses/devops-with-kubernetes/chapter-5/gitops

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
gcloud container clusters get-credentials $CLUSTER_NAME --location=$CONTROL_PLANE_LOCATION

# # kustomize sanity check
# kubectl kustomize .
# deploy using kustomize
kubens exercises
kubectl apply -k .
# now link kustomization.yaml to argo so that argo will sync the cluster with repo changes
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
# check external IP of argocd-server
kubectl get svc -n argocd --watch
# get initial password for admin (needs base64 decoding)
kubectl get -n argocd secrets argocd-initial-admin-secret -o yaml | grep -o 'password: .*' | cut -f2- -d: | base64 --decode
# log into argo in browser at external IP using admin and this password
# then sync the cluster (use repo https://github.com/thomastoumasu/k8s-submission and path . to sync with the kustomization.yaml of exercises), and get gateway IP in argo

# # debug
# kubectl get gateway pingpong-gateway --watch
# kubectl describe gateway pingpong-gateway
# kubectl get httproutes
# kubectl describe httproutes log-output-route

