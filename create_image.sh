# eventually delete previous image
docker images
# create images
cd the_project/frontend
# docker build -t 3.2 .   
docker build --platform linux/amd64 -t 3.4 . 
# sanity check
# docker run --rm -p 3000:3000 --name 2.10 2.10 && curl localhost:8082 
docker tag 3.4 thomastoumasu/k8s-pingpong:3.4-amd && docker push thomastoumasu/k8s-pingpong:3.4-amd
 && cd ../../../
