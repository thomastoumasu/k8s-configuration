Configuration repo for the_project
Application has been moved to repo k8s-application for the last part (Ex 4. 10) of
https://courses.mooc.fi/org/uh-cs/courses/devops-with-kubernetes/

# uses different repositories for the code (k8s-application) and configurations (this repo).

# A push in code repo triggers a github action there that builds the images and updates the configuration files here with the image names.

# Argo is linked with this repo and syncs the cluster accordingly.

# https://courses.mooc.fi/org/uh-cs/courses/devops-with-kubernetes/chapter-5/gitops

# See ex4_10.sh to setup the cluster and ArgoCD
