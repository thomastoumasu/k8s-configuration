# k3d cluster create -a 2
kubectl apply -f manifests/deployment.yaml

# kubectl get pods -o=name
# kubectl logs -f $POD

# kubectl delete -f manifests/deployment.yaml

# kubectl get deployments