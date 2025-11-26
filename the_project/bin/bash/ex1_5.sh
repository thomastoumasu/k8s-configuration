sh ../clear.sh  

# create cluster
k3d cluster create -a 2

# create image
sh ../builder.sh the_project 1.5

# create deployment 
kubectl apply -f manifests/deployment.yaml
# kubectl delete -f manifests/deployment.yaml

# wait for pod to be ready
POD=$(kubectl get pods -o=name | grep the-project)
kubectl wait --for=condition=Ready $POD

# forward port to host to be able debug in localhost (blocks so run in the background)
kubectl port-forward $POD 3006:5000 & sleep 1 && curl localhost:3006

