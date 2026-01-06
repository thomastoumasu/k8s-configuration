# 5.1 Custom Resource Definition and Controller: Dummy site 
# https://courses.mooc.fi/org/uh-cs/courses/devops-with-kubernetes/chapter-6/custom-resource-definitions

k3d cluster create --port 8082:30080@agent:0 -p 8081:80@loadbalancer --agents 2
kubectl apply -f ./dummy-site/controller/manifests/resourcedefinition.yaml
kubectl apply -f ./dummy-site/controller/manifests/serviceaccount.yaml
kubectl apply -f ./dummy-site/controller/manifests/clusterrole.yaml
kubectl apply -f ./dummy-site/controller/manifests/clusterrolebinding.yaml
# wait a bit to avoid error "Too many requests" from Watch.watch
kubectl apply -f ./dummy-site/controller/manifests/deployment.yaml
# sanity check: controller should watch (e.g. logs should be "starting dummysites watcher")
POD=$(kubectl get pods -o=name | grep dummysite-controller)
kubectl describe $POD 
kubectl logs -f $POD
# deploy two custom resources and check they are available
kubectl create namespace test && kubectl apply -f ./dummy-site/manifests/dummysite.yaml
POD=$(kubectl get pods -o=name | grep wiki)
kubectl port-forward $POD 3003:80
POD=$(kubectl get pods -n test -o=name | grep example)
kubectl port-forward $POD -n test 3004:80
# update one resource (e.g. change dummysite.yaml)
kubectl apply -f ./dummy-site/manifests/dummysite.yaml
POD=$(kubectl get pods -o=name | grep wiki)
kubectl port-forward $POD 3003:80
# stop and restart the controller - it should skip creating pvc and deployment for both resources 
kubectl delete -f ./dummy-site/controller/manifests/deployment.yaml
kubectl apply -f ./dummy-site/controller/manifests/deployment.yaml
POD=$(kubectl get pods -o=name | grep dummysite-controller)
kubectl logs -f $POD
# delete both resources
kubectl delete -f ./dummy-site/manifests/dummysite.yaml
kubectl get deployments,pvc --all-namespaces

kubectl delete all --all && k3d cluster delete



# debug controller in node
cd dummy-site/controller
npm install && npm run dev

# recreate controller image
docker images
docker rmi -f ee8eac1b2e56
cd dummy-site/controller
docker build -t 5.1 . 
# if GKE: --platform linux/amd64
docker tag 5.1 thomastoumasu/k8s-dummysite-controller:5.1d && docker push thomastoumasu/k8s-dummysite-controller:5.1d
cd ../../
# update image in ./dummy-site/controller/manifests/deployment.yaml
kubectl apply -f ./dummy-site/controller/manifests/deployment.yaml
POD=$(kubectl get pods -o=name | grep dummysite-controller)
kubectl describe $POD
kubectl logs $POD

# # deeper debug step one: test container alone
# cd dummy-site
# curl example.com > index.html
# # string=$(curl -I https://en.wikipedia.org/wiki/Special:Random | grep location) 
# # url=${string#"location: "}
# # url="${url//$'\r'/}"
# # curl $url > index.html
# docker build -t dummy . && docker run --rm --name dummy -p 80:80 dummy

# # deeper debug step two: test site-fetcher function (adapt the directory in index.js)
# cd site-fetcher
# npm install
# SITE=https://en.wikipedia.org/wiki/Special:Random npm start    

# # deeper debug test three: test manual deployment on k3s
# cd site-fetcher
# docker build -t 5.1 . 
# # sanity check
# docker run --rm -p 80:80 --name 5.1 5.1 && docker exec -it 5.1 bash
#     cat /shared/index.html
# docker tag 5.1 thomastoumasu/k8s-site-fetcher:5.1 && docker push thomastoumasu/k8s-site-fetcher:5.1
# k3d cluster create --port 8082:30080@agent:0 -p 8081:80@loadbalancer --agents 2
# kubectl create namespace exercises || true
# kubens exercises
# kubectl apply -f manifests/persistentvolumeclaim.yaml
# kubectl apply -f manifests/deployment.yaml
# POD=$(kubectl get pods -o=name | grep dep)
# kubectl port-forward $POD 3003:80
# curl localhost:3003
# # instead of port-forward use an ingress
# kubectl apply -f manifests/service.yaml
# kubectl apply -f manifests/ingress.yaml
# curl localhost:8081
# # debug
# kubectl logs $POD -c site-fetcher


