# 4.8 pull deployment pipeline of the_project with argo
# github action has changed: instead of deploying from action, action changes and checks in the kustomization file. Argo is linked with this file and syncs the cluster accordingly.
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
# set kube-config to point at the cluster
gcloud container clusters get-credentials $CLUSTER_NAME --location=$CONTROL_PLANE_LOCATION 
# or --zone=$LOCATION

kubectl create namespace infra || true
kubectl create namespace production || true
kubectl label namespaces production shared-gateway-access=true --overwrite=true
kubectl create namespace staging || true
kubectl label namespaces staging shared-gateway-access=true --overwrite=true

# link repo to argo so that argo will sync the cluster with repo changes
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
# check external IP of argocd-server
kubectl get svc -n argocd --watch
# get initial password for admin (needs base64 decoding)
kubectl get -n argocd secrets argocd-initial-admin-secret -o yaml | grep -o 'password: .*' | cut -f2- -d: | base64 --decode
# log into argo in browser at external IP using admin and this password
# then sync the cluster 
# manually (use repo https://github.com/thomastoumasu/k8s-submission and path ./the_project/kustomize/overlays/main to sync with the kustomization.yaml of main)
# or declaratively
kubectl apply -n argocd -f ./the_project/kustomize/infra/application.yaml
kubectl apply -n argocd -f ./the_project/kustomize/overlays/production/application.yaml
# kubectl apply -n argocd -f ./the_project/kustomize/overlays/staging/application.yaml


# push on main to create cluster description in repo (namespace prod) (see .github/workflows/pull-deploy_the-project.yaml)
# and get gateway IP in argo, use it to connect the domain (in cloudflare)

# no GKE credentials


# # debug
kubectl get gateway shared-gateway -n infra

# need to patch cm, https://argo-cd.readthedocs.io/en/release-2.3/user-guide/kustomize/
kubectl patch cm argocd-cm -n argocd -p '{"data": {"kustomize.buildOptions": "--load-restrictor LoadRestrictionsNone"}}'
kubectl patch cm argocd-cm -n argocd -p '{"data": {"kustomize.buildOptions": "--enable-helm"}}'

