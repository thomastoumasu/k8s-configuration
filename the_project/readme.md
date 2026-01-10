# Configuration repo for the_project

Application itself has been moved to repo k8s-application for the last part (Ex 4. 10) of  
https://courses.mooc.fi/org/uh-cs/courses/devops-with-kubernetes/chapter-5/gitops

Goal: To use different repositories for the code (k8s-application) and configurations (this repo).  
A push in code repo triggers a github action there that builds the images and updates the configuration files here with the image names.  
Argo is linked with this repo here and syncs the cluster accordingly.  
See bin/bash/ex4_10.sh for the precise setup with ArgoCD.
