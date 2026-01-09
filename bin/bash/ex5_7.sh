# 5.7 knative - make pingpong app (and log_output, and greeter) serverless
# https://courses.mooc.fi/org/uh-cs/courses/devops-with-kubernetes/chapter-6/beyond-kubernetes

k3d cluster create --port 8082:30080@agent:0 -p 8081:80@loadbalancer --agents 2 --k3s-arg "--disable=traefik@server:0"
# install knative serving components
kubectl apply -f https://github.com/knative/serving/releases/download/knative-v1.18.2/serving-crds.yaml
kubectl apply -f https://github.com/knative/serving/releases/download/knative-v1.18.2/serving-core.yaml
# install networking layer (Knative Kourier)
kubectl apply -f https://github.com/knative/net-kourier/releases/download/knative-v1.18.0/kourier.yaml
kubectl patch configmap/config-network \
  --namespace knative-serving \
  --type merge \
  --patch '{"data":{"ingress-class":"kourier.ingress.networking.knative.dev"}}'
# confirm external IP allocated
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
kubectl apply -f ./pingpong/postgres/manifests/statefulset.yaml
kubectl apply -f ./pingpong/manifests/serverless.yaml
kubectl apply -f ./greeter/manifests/serverless.yaml

kubectl get ksvc
curl -H "Host: log-output.exercises.172.18.0.3.sslip.io " http://localhost:8081
curl -H "Host: pingpong.exercises.172.18.0.3.sslip.io " http://localhost:8081/pingpong

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

k3d cluster delete