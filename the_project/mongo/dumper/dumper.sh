#!/usr/bin/env bash
set -e

# if passed as arguments instead of env
# MONGO_URI=$1
# BUCKET=$2

if [[ -z $MONGO_URI ]]; then
  echo 'Cannot proceed without database information. Please provide the MONGO_URI as an environment variable called MONGO_URI in the manifest. Example: MONGO_URI="mongodb://the_username:the_password@mongo-svc.project:27017/the_database"' 
else
  mongodump --uri=$MONGO_URI --out /usr/src/app/dump/
  NOW=$(date +'%Y-%m-%dT%H-%M-%S')
  FILENAME="/usr/src/app/dump/the_database/todos-${NOW}.bson"
  mv /usr/src/app/dump/the_database/todos.bson $FILENAME
  if [[ -z $BUCKET ]]; then
    echo 'Cannot proceed without bucket information. Please provide the destination bucket as an environment variable called BUCKET in the manifest. Example: BUCKET="thomastoumasu_k8s-bucket"'
  else 
    gcloud storage cp $FILENAME gs://${BUCKET}
  fi
fi

# stay around for a little while to allow debugging
sleep 3600
# # debug authorization (should be authentified with service account, check dumper manifest and ex3_10.sh)
# curl -X GET -H "Authorization: Bearer $(gcloud auth print-access-token)" "https://storage.googleapis.com/storage/v1/b/thomastoumasu_k8s-bucket/o"
# # debug cp
# touch text.txt
# gcloud storage cp text.txt gs://thomastoumasu_k8s-bucket
