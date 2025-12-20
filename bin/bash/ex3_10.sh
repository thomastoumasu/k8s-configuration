# 3.10 save to Google GLobal Storage
# set up backup_dl.yaml as cron job github action (needs cluster up and working, for example with sh create_gkecl_big_gat.sh)

# template for storing local file testfile.txt to a public bucket:
# gcloud storage cp testfile.txt gs://thomastoumasu_k8s-bucket

# build dumper image
cd the_project/mongo/dumper
docker build --platform linux/amd64 -t 3.10 . 
docker tag 3.10 thomastoumasu/k8s-mongo-dumper:3.10c-amd && docker push thomastoumasu/k8s-mongo-dumper:3.10c-amd
kubectl apply -f ./the_project/mongo/manifests/dumper.yaml


# kubectl run dumper --image=3.10 --env="KEY=private-key.json"


kubectl describe pod/dumper 
kubectl logs -f dumper 
