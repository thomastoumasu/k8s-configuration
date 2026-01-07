# 5.2 Service mesh - istio
# https://courses.mooc.fi/org/uh-cs/courses/devops-with-kubernetes/chapter-6/service-mesh

# install istio https://istio.io/latest/docs/ambient/getting-started/ 
# curl -L https://istio.io/downloadIstio | sh -   , and add /bin to path
k3d cluster create --api-port 6550 -p '9080:80@loadbalancer' -p '9443:443@loadbalancer' --agents 2 --k3s-arg '--disable=traefik@server:*'
# check client version is shown
istioctl version
istioctl install --set profile=ambient --set values.global.platform=k3d

# install gateway
kubectl get crd gateways.gateway.networking.k8s.io &> /dev/null || \
  kubectl apply --server-side -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.4.0/experimental-install.yaml
# Do not do !! kubectl label namespace default istio-injection=enabled

# install example app https://istio.io/latest/docs/ambient/getting-started/deploy-sample-app/
kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml
kubectl apply -f samples/bookinfo/platform/kube/bookinfo-versions.yaml
# check all pods are running
kubectl get pods
kubectl apply -f samples/bookinfo/gateway-api/bookinfo-gateway.yaml
kubectl annotate gateway bookinfo-gateway networking.istio.io/service-type=ClusterIP --namespace=default
# check gateway is programmed
kubectl get gateway
kubectl port-forward svc/bookinfo-gateway-istio 8080:80

# add app to the mesh
kubectl label namespace default istio.io/dataplane-mode=ambient

# visualize the metrics
kubectl apply -f samples/addons/prometheus.yaml
kubectl apply -f samples/addons/kiali.yaml
istioctl dashboard kiali
# send some traffic
for i in $(seq 1 100); do curl -sSI -o /dev/null http://localhost:8080/productpage; done

# enforce layer 4 authorization policies 
# apply ztunnel authorization
kubectl apply -f - <<EOF
apiVersion: security.istio.io/v1
kind: AuthorizationPolicy
metadata:
  name: productpage-ztunnel
  namespace: default
spec:
  selector:
    matchLabels:
      app: productpage
  action: ALLOW
  rules:
  - from:
    - source:
        principals:
        - cluster.local/ns/default/sa/bookinfo-gateway-istio
EOF
kubectl apply -f samples/curl/curl.yaml
# access denied if accessed from another client (curl pod is using a different service account)
kubectl exec deploy/curl -- curl -s "http://productpage:9080/productpage"

# enforce layer 7 authorization policies 
istioctl waypoint apply --enroll-namespace --wait
# namespace default should be now labeled
kubectl get gtw waypoint
# should be programmed
# apply zpoint authorization
kubectl apply -f - <<EOF
apiVersion: security.istio.io/v1
kind: AuthorizationPolicy
metadata:
  name: productpage-waypoint
  namespace: default
spec:
  targetRefs:
  - kind: Service
    group: ""
    name: productpage
  action: ALLOW
  rules:
  - from:
    - source:
        principals:
        - cluster.local/ns/default/sa/curl
    to:
    - operation:
        methods: ["GET"]
EOF
# update ztunnel authorization
kubectl apply -f - <<EOF
apiVersion: security.istio.io/v1
kind: AuthorizationPolicy
metadata:
  name: productpage-ztunnel
  namespace: default
spec:
  selector:
    matchLabels:
      app: productpage
  action: ALLOW
  rules:
  - from:
    - source:
        principals:
        - cluster.local/ns/default/sa/bookinfo-gateway-istio
        - cluster.local/ns/default/sa/waypoint
EOF
# This fails with an RBAC error because you're not using a GET operation
kubectl exec deploy/curl -- curl -s "http://productpage:9080/productpage" -X DELETE
# This fails with an RBAC error because the identity of the reviews-v1 service is not allowed
kubectl exec deploy/reviews-v1 -- curl -s http://productpage:9080/productpage
# This works as you're explicitly allowing GET requests from the curl pod
kubectl exec deploy/curl -- curl http://productpage:9080/productpage

# Split traffic between services
kubectl apply -f - <<EOF
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: reviews
spec:
  parentRefs:
  - group: ""
    kind: Service
    name: reviews
    port: 9080
  rules:
  - backendRefs:
    - name: reviews-v1
      port: 9080
      weight: 90
    - name: reviews-v2
      port: 9080
      weight: 10
EOF

# confirm that roughly 10% of the traffic from 100 requests goes to reviews-v2
kubectl exec deploy/curl -- sh -c "for i in \$(seq 1 100); do curl -s http://productpage:9080/productpage | grep reviews-v.-; done"

# clean up istio
kubectl label namespace default istio.io/use-waypoint-
istioctl waypoint delete --all
kubectl label namespace default istio.io/dataplane-mode-
kubectl delete httproute reviews
kubectl delete authorizationpolicy productpage-viewer
kubectl delete -f samples/curl/curl.yaml
kubectl delete -f samples/bookinfo/platform/kube/bookinfo.yaml
kubectl delete -f samples/bookinfo/platform/kube/bookinfo-versions.yaml
kubectl delete -f samples/bookinfo/gateway-api/bookinfo-gateway.yaml
istioctl uninstall -y --purge
kubectl delete namespace istio-system
kubectl delete -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.4.0/experimental-install.yaml
cd
rm -rf istio-1.28.2
k3d cluster delete



