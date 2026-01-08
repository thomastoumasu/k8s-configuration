# 5.3 Service mesh - istio
# use L7 processing to split traffic between two app versions
# https://courses.mooc.fi/org/uh-cs/courses/devops-with-kubernetes/chapter-6/service-mesh

# install istio https://istio.io/latest/docs/ambient/getting-started/ 
# curl -L https://istio.io/downloadIstio | sh -   , and add to path

# set up cluster and get traffic inside with a gateway
k3d cluster create --api-port 6550 -p '9080:80@loadbalancer' -p '9443:443@loadbalancer' --agents 2 --k3s-arg '--disable=traefik@server:*'
istioctl install --set profile=ambient --set values.global.platform=k3d
kubectl get crd gateways.gateway.networking.k8s.io &> /dev/null || \
  kubectl apply --server-side -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.4.0/experimental-install.yaml
kubectl create namespace exercises || true
kubens exercises
kubectl apply -f manifests/gateway.yaml
kubectl apply -f manifests/routes.yaml

# alternative setup to debug gateway problems (will work for basic version with deployment, not with the L7 / traffic split version): use an ingress
# k3d cluster create --port 8082:30080@agent:0 -p 8081:80@loadbalancer --agents 2
# kubectl create namespace exercises || true
# kubens exercises
# kubectl apply -f manifests/ingress.yaml

# create deployment and service for the three apps (log_output, pingpong and greeter)
kubectl apply -f ./log_output/manifests/config-map.yaml
kubectl apply -f ./log_output/manifests/deployment.yaml
# 2345->3000
kubectl apply -f ./log_output/manifests/service.yaml
kubectl apply -f ./pingpong/postgres/manifests/config-map.yaml
kubectl apply -f ./pingpong/postgres/manifests/statefulset.yaml
kubectl apply -f ./pingpong/manifests/deployment.yaml
# 1234->3002
kubectl apply -f ./pingpong/manifests/service.yaml
kubectl apply -f ./greeter/manifests/deployment.yaml
# 3456->3004
kubectl apply -f ./greeter/manifests/service.yaml

# sanity checks
kubectl rollout status deployment log-output-dep
POD=$(kubectl get pods -o=name | grep postgres)
kubectl wait --for=condition=Ready $POD
POD=$(kubectl get pods -o=name | grep pingpong)
# expect "Connection to postgres has been established successfully." If not, wait a bit and retry.
kubectl logs $POD

# if gateway
kubectl annotate gateway log-output-gateway networking.istio.io/service-type=ClusterIP --namespace=exercises
# check gateway is programmed
kubectl get gateway
kubectl port-forward svc/log-output-gateway-istio 8080:80
curl localhost:8080/pingpong
# if connection breaks, redo port-forward above
curl localhost:8080

# # if ingress (to debug gateway problems)
# # should see the svcs on 1234, 2345, 3456, 5432 as well as the ingress on 80
# kubectl get svc,ing 
# curl two:8081
# curl two:8081/pingpong
# curl two:8081

# add app to the mesh
kubectl label namespace exercises istio.io/dataplane-mode=ambient
# visualize the metrics
kubectl apply -f greeter/manifests/prometheus.yaml
kubectl apply -f greeter/manifests/kiali.yaml
kubectl apply -f greeter/manifests/grafana.yaml
POD=$(kubectl get pods -n istio-system -o=name | grep kiali)
kubectl wait --for=condition=Ready $POD -n istio-system
istioctl dashboard kiali
# send some traffic, watch in kali (do not forget to set the namespace above the display)
for i in $(seq 1 100); do curl -sSI -o /dev/null http://localhost:8080; curl -sSI -o /dev/null http://localhost:8080/pingpong; done

# from here: only gateway. Replace greeter deployment with deployment of two versions
# original service can be kept, add a http route that refers it as parent and the two new versions as backendRefs, with respective weight:
kubectl apply -f ./greeter/manifests/deployment_twoversions.yaml
# activate L7 processing (waypoint proxy) - this will deploy a istio-waypoint gateway that can process traffic for services. https://istio.io/latest/docs/ambient/usage/waypoint/
istioctl waypoint apply --enroll-namespace --wait
# sanity check: no error in route
kubectl describe httproute greeters-route
# wait a bit and send some traffic (should see version 2 and 1 in proportion to the weights defined in deployment_twoversions.yaml)
for i in $(seq 1 100); do curl -sS http://localhost:8080 | grep greetings; done
# watch in kali (if not everything displayed, wait a bit a resend traffic)

kubectl get gateway
# NAME                 CLASS            ADDRESS                                                PROGRAMMED   AGE
# log-output-gateway   istio            log-output-gateway-istio.exercises.svc.cluster.local   True         7m32s
# waypoint             istio-waypoint   10.43.207.89                                           True         22s

k3d cluster delete



