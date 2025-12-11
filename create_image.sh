# eventually delete previous image
docker images
# create images
cd the_project/backend/generator 
docker build -t 3.2 .   
docker build --platform linux/amd64 -t 3.2 . 
# sanity check
docker run --rm -p 3000:3000 --name 2.10 2.10 && curl localhost:8082 
docker tag 3.2 thomastoumasu/k8s-log-output:3.2-amd && docker push thomastoumasu/k8s-log-output:3.2-amd && cd ../../../