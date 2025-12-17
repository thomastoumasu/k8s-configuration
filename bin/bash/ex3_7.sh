# 3.7 main deployment on namespace project and branch deployment on namespace branch

# # create a static IP - does not work with global gateway
# gcloud compute addresses create my-ip --region=europe-north1 --network-tier=STANDARD
# gcloud compute addresses create my-ip --region=europe-north1
# gcloud compute addresses describe my-ip --region=europe-north1
# # just wait for gateway to allocate an IP and add it to cloudfare DNS record
# 34.54.85.237
# use "www.thomastoumasu.dpdns.org" for main aka namespace project
# use "www.thomastoumasu.xx.kg" for branch aka namespace branch

# debug
# kubectl describe gateway my-gateway
# gcloud compute url-maps list
# kubectl get gateway my-gateway