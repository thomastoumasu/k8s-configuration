# 3.10 save to Google GLobal Storage
# set up backup_dl.yaml as cron job github action (needs cluster up and working, for example with sh create_gkecl_big_gat.sh)

# template for storing local file testfile.txt to a public bucket:
# gcloud storage cp testfile.txt gs://thomastoumasu_k8s-bucket
