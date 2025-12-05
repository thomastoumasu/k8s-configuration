# eventually delete previous image
docker images
# create images
cd the_project/backend && docker build -t 2.8 .   
# sanity check
docker run --rm -p 8082:3000 --name 2.8 2.8 && curl localhost:8082 
docker tag 2.8 thomastoumasu/k8s-backend:2.8 && docker push thomastoumasu/k8s-backend:2.8 && cd ../../