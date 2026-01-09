# eventually delete previous image
docker images
# create images
cd wiki-server
docker build -t 5.4 .   
docker run --rm 5.4
# docker build --platform linux/amd64 -t 5.3 . 
# sanity check
# docker run --rm -p 3000:3000 --name 2.10 2.10 && curl localhost:8082 
docker tag 5.4 thomastoumasu/k8s-updater:5.4 && docker push thomastoumasu/k8s-updater:5.4
 && cd ../../../

cd the_project/frontend
IMAGE_TAG="thomastoumasu/k8s-frontend:3.4-amd"
docker build --platform linux/amd64 --tag $IMAGE_TAG . && docker push $IMAGE_TAG
docker rmi -f 
