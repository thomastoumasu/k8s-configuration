k3d cluster delete

# kubectl delete all --all

docker rm -vf $(docker ps -aq) 
docker rmi -f $(docker images -aq)
# docker container prune -f
# docker image prune -f
docker volume prune -f
docker system prune -f
docker builder prune -f  
docker buildx history rm $(docker buildx history ls)
docker network prune -f  

# docker container inspect dfc59a5fe293 | grep -A 5 Mounts

# create cluster
k3d cluster create -p 8081:80@loadbalancer --agents 2
# create namespaces
kubectl create namespace exercises
kubectl create namespace project