# # monitoring sh bin/bash/ex2_10.sh
# sh reset_cluster.sh
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add stable https://charts.helm.sh/stable
helm repo update
kubectl create namespace prometheus
helm install prometheus-community/kube-prometheus-stack --generate-name --namespace prometheus
kubectl get po -n prometheus
GRAFANA_POD=$(kubectl get pods -n prometheus --no-headers -o custom-columns=":metadata.name" | grep grafana)
kubectl -n prometheus port-forward $GRAFANA_POD 3000
# go to localhost:3000, login to grafana with: admin prom-operator

helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
kubectl create namespace loki-stack
helm upgrade --install loki --namespace=loki-stack grafana/loki-stack --set loki.image.tag=2.9.3
kubectl get all -n loki-stack

kubectl apply -f ./manifests/redis.yaml
# In grafana: add new data source, Loki, http://loki.loki-stack:3100; then Explore -> loki -> app redisapp -> live


sh bin/bash/ex2_8.sh
# Explore -> loki -> app backend -> live