# 3.10 save to Google GLobal Storage

gcloud storage cp test-storage2.txt gs://thomastoumasu_k8s-bucket

docker run --rm -it --name frontend -p 5173:80 frontend bash