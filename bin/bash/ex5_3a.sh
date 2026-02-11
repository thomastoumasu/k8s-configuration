# 5.3a Service mesh - istio
# same as 5.3 but simpler (only uses main gateway to split traffic, not with a second gateway inside)

# install istio https://istio.io/latest/docs/ambient/getting-started/ 
# curl -L https://istio.io/downloadIstio | sh -   , and add to path

k3d cluster create --api-port 6550 -p '9080:80@loadbalancer' -p '9443:443@loadbalancer' --agents 2 --k3s-arg '--disable=traefik@server:*'
istioctl install --set profile=ambient --set values.global.platform=k3d
kubectl get crd gateways.gateway.networking.k8s.io &> /dev/null || \
  kubectl apply --server-side -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.4.0/experimental-install.yaml

# install hello world app in default namespace
kubectl apply -f greeter/manifests/hello.yaml
kubectl apply -f greeter/manifests/gateway.yaml
kubectl apply -f greeter/manifests/route.yaml
# check all pods are running
kubectl get pods
kubectl annotate gateway hello-gateway networking.istio.io/service-type=ClusterIP --namespace=default
# check gateway is programmed
kubectl get gateway
kubectl port-forward svc/hello-gateway-istio 8080:80
# add app to the mesh
kubectl label namespace default istio.io/dataplane-mode=ambient
# visualize the metrics
kubectl apply -f greeter/manifests/prometheus.yaml
kubectl apply -f greeter/manifests/kiali.yaml
POD=$(kubectl get pods -n istio-system -o=name | grep kiali)
kubectl wait --for=condition=Ready $POD -n istio-system
istioctl dashboard kiali
# send some traffic
for i in $(seq 1 100); do curl -sSI -o /dev/null http://localhost:8080; done
# nc -zv localhost 8080

# now change to two versions, splitting traffic in the gateway
kubectl apply -f greeter/manifests/hello_twoversions.yaml
kubectl apply -f greeter/manifests/route_twoversions.yaml
kubectl describe httproute hello
# send some traffic again, see the two differents outputs in the terminal, also see traffic distribution in kiali
for i in $(seq 1 100); do curl -s http://localhost:8080 | grep Hello; done

kubectl get gateway
# NAMESPACE   NAME            CLASS   ADDRESS                                         PROGRAMMED   AGE
# default     hello-gateway   istio   hello-gateway-istio.default.svc.cluster.local   True         14m

k3d cluster delete