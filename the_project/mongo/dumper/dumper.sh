#!/usr/bin/env bash
set -e

URI=$1
BUCKET=$2
mongodump --uri=$URI --out /usr/src/app/dump/

# gcloud auth activate-service-account github-actions@dwk-gke-480809.iam.gserviceaccount.com --key-file=/usr/src/app/private-key.json --project=dwk-gke-480809
gcloud auth activate-service-account github-actions@dwk-gke-480809.iam.gserviceaccount.com --key-file=/usr/src/app/$KEY --project=dwk-gke-480809

NOW=$(date +'%Y-%m-%dT%H-%M-%S')
FILENAME="/usr/src/app/dump/the_database/todos-${NOW}.bson"
mv /usr/src/app/dump/the_database/todos.bson $FILENAME

gcloud storage cp $FILENAME gs://${BUCKET}
# echo "Not sending the dump actually anywhere"
# curl -F ‘data=@/usr/src/app/dump/the_database/todos.bson’ https://somewhere

sleep 3600
# mongodump --uri='mongodb://the_username:the_password@mongo-svc.project:27017/the_database' --out $(pwd)