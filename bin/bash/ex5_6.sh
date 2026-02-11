# 5.6 serverless

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

# deploy
kubectl apply -f knative/manifests/hello.yaml
kubectl get ksvc
curl -H "Host: hello.default.172.18.0.3.sslip.io" http://localhost:8081

# observe autoscaling, replica go to 0, starts up again if curled
kubectl get pod -l serving.knative.dev/service=hello -w

# traffic splitting
# create a new version: change the ENV TARGET from World to Knative in hello.yaml and reapply
kubectl apply -f knative/manifests/hello.yaml
kubectl get revisions
# same + see traffic split, default is 100% to new revision
kn revisions list
# uncomment the traffic part of hello.yaml and reapply
kubectl apply -f knative/manifests/hello.yaml
kn revisions list

# # do similar thing with own app
kubectl apply -f knative/manifests/greeter.yaml
kubectl get ksvc
curl -H "Host: greeter.default.172.18.0.3.sslip.io" http://localhost:8081
kubectl apply -f ./manifests/curl.yaml
kubectl exec -it alpine-curl -- sh
curl greeter.default.172.18.0.3.sslip.io
kubectl get pod -l serving.knative.dev/service=greeter -w
# change version and reapply
kubectl apply -f knative/manifests/greeter.yaml
kn revisions list 

k3d cluster delete