# eventually delete previous image
docker images
# create images
cd pingpong
# docker build -t 3.2 .   
docker build --platform linux/amd64 -t 4.1 . 
# sanity check
# docker run --rm -p 3000:3000 --name 2.10 2.10 && curl localhost:8082 
docker tag 4.1 thomastoumasu/k8s-pingpong:4.1d-amd && docker push thomastoumasu/k8s-pingpong:4.1d-amd
 && cd ../../../

cd the_project/frontend
IMAGE_TAG="thomastoumasu/k8s-frontend:3.4-amd"
docker build --platform linux/amd64 --tag $IMAGE_TAG . && docker push $IMAGE_TAG
docker rmi -f 
