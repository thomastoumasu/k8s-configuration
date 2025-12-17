docker rm -vf $(docker ps -aq) 
docker rmi -f $(docker images -aq)
# docker container prune -f
# docker image prune -f
docker volume prune -f
docker system prune -f
docker builder prune -f  
docker buildx history rm $(docker buildx history ls)
docker network prune -f  