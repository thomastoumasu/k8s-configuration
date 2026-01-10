
# Templates for image creation workflow

# multi-arch images
docker buildx create --name mybuilder --use --bootstrap
cd greeter
docker buildx build --push \
--platform linux/amd64,linux/arm64 \
--tag thomastoumasu/k8s-greeter:buildx-latest .


# manually set up architecture
# eventually delete previous image
docker images
docker rmi -f 73bb2e43916a

cd greeter
docker build -t 5.3 . 
# if GKE: --platform linux/amd64
docker build --platform linux/amd64 -t 5.3 . 
# sanity check
# docker run --rm -p 3000:3000 5.1
docker tag 5.3 thomastoumasu/k8s-greeter:5.3-amd && docker push thomastoumasu/k8s-greeter:5.3-amd
cd ../

cd the_project/frontend
IMAGE_TAG="thomastoumasu/k8s-frontend:3.4-amd"
docker build --platform linux/amd64 --tag $IMAGE_TAG . && docker push $IMAGE_TAG

