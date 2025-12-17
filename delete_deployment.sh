kubectl delete -f ./pingpong/postgres/manifests/config-map.yaml
kubectl delete -f ./pingpong/postgres/manifests/statefulset.yaml
kubectl delete -f ./pingpong/manifests/deployment.yaml
kubectl delete -f ./pingpong/manifests/cloud_lb.yaml