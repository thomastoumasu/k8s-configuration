# k3d cluster create -a 2

sh ../builder.sh the_project 1.5

kubectl apply -f manifests/deployment.yaml

POD=$(kubectl get pods -o=name | grep the_project)

kubectl wait --for=condition=Ready $POD

kubectl port-forward $POD 3006:3000