# eventually delete previous image
docker images
# create images
cd the_project/frontend
# docker build -t 3.2 .   
docker build --platform linux/amd64 -t 3.3b . 
# sanity check
# docker run --rm -p 3000:3000 --name 2.10 2.10 && curl localhost:8082 
docker tag 3.3b thomastoumasu/k8s-frontend:3.3b-amd && docker push thomastoumasu/k8s-frontend:3.3b-amd
 && cd ../../../
