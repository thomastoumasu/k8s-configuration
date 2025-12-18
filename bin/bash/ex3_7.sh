# 3.7 main deployment on namespace project and branch deployment on namespace branch
# both deployments sharing one gateway to reduce costs
# (to have two gateways, just remove the infra namespace and create both gateways in the respective main and branch namespaces, you then get two different gateway IPs)

# # allocate a global IP for the gateway or just wait for gateway to allocate an IP and then add it to cloudfare DNS record
# 34.110.191.245
# use "www.thomastoumasu.dpdns.org" for main aka namespace project
# use "www.thomastoumasu.xx.kg" for branch aka namespace branch
# in frontend/route, backend/route and frontend Dockerfile

# both deployment work and are accessible under different domains
# can still be improved:
# 1. Right now two gateways are created with two IPs
# it should be possible to share one gateway to reduce costs: https://gateway-api.sigs.k8s.io/guides/multiple-ns/
# 2. Sometimes bind error on the volume shared between image-finder and frontend. Not sure why it works sometimes actually. Either use a ReadWriteMany, or put both appds in one pod.
# 3. delete images programmatically
# gcloud artifacts files list --project=dwk-gke-480809 --location=europe-north1 --repository=my-repository --package=backend --tag=1.0-dev
# gcloud artifacts docker images list europe-north1-docker.pkg.dev/dwk-gke-480809/my-repository/backend --include-tags
# gcloud artifacts docker images list europe-north1-docker.pkg.dev/dwk-gke-480809/my-repository/backend --include-tags | grep main
# 4. allocate global IP to avoid update in cloudflare
# gcloud compute addresses create my-ip (--region=europe-north1 (--network-tier=STANDARD))
# gcloud compute addresses describe my-ip --region=europe-north1
# gcloud compute addresses create my-ip --global
# gcloud compute addresses describe my-ip --global  // 34.54.85.237


# debug
# kubectl describe gateway my-gateway
# gcloud compute url-maps list
# kubectl get gateway my-gateway