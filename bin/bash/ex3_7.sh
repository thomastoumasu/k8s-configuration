# 3.7 main deployment on namespace project and branch deployment on namespace branch

# # create a static IP - does not work with global gateway
# gcloud compute addresses create my-ip (--region=europe-north1 (--network-tier=STANDARD))
# gcloud compute addresses describe my-ip --region=europe-north1
# gcloud compute addresses create my-ip --global
# gcloud compute addresses describe my-ip --global  // 34.54.85.237
# # just wait for gateway to allocate an IP and add it to cloudfare DNS record
# 34.110.191.245
# use "www.thomastoumasu.dpdns.org" for main aka namespace project
# use "www.thomastoumasu.xx.kg" for branch aka namespace branch

# both deployment work and are accessible under different domains
# can still be improved:
# 1. Right now two gateways are created with two IPs
# it should be possible to share one gateway to reduce costs: https://gateway-api.sigs.k8s.io/guides/multiple-ns/
# 2. Two stateful sets and two pvc are created for mongo, one in each namespace. However the db is still shared. Debug, f.e. change one pvc name to avoid potential confusion.
# 3. Sometimes bind error on the volume shared between image-finder and frontend. Not sure why it works sometimes actually. Either use a ReadWriteMany, or put both appds in one pod.

# debug
# kubectl describe gateway my-gateway
# gcloud compute url-maps list
# kubectl get gateway my-gateway