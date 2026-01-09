# 5.4 Init- and Sidecar controller: Wikipedia with init and sidecar
# https://courses.mooc.fi/org/uh-cs/courses/devops-with-kubernetes/chapter-6/service-mesh
# https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-initialization/#create-a-pod-that-has-an-init-container


k3d cluster create --port 8082:30080@agent:0 -p 8081:80@loadbalancer --agents 2
kubectl create namespace exercises || true
kubens exercises
kubectl apply -f wiki-server/manifests/nginx-configmap.yaml
kubectl apply -f wiki-server/manifests/deployment.yaml
# sanity check
kubectl get pods
POD=$(kubectl get pods -o=name | grep dep)
kubectl describe $POD
# should see curl of kubernetes wiki page
kubectl logs $POD -c install
# should see countdown then curl of random wiki pages
kubectl logs -f $POD -c update
# check also in browser/localhost
kubectl port-forward $POD 8080:80
curl localhost:8080

k3d cluster delete

# debug main container
kubectl logs $POD -c nginx
kubectl exec -it $POD -c nginx -- sh

# recreate image
docker images
docker rmi -f f8f17719b3af
cd wiki-server
docker build -t 5.4 . 
docker tag 5.4 thomastoumasu/k8s-countdown-curler:5.4 && docker push thomastoumasu/k8s-countdown-curler:5.4
cd ../
kubectl delete -f wiki-server/manifests/deployment.yaml


