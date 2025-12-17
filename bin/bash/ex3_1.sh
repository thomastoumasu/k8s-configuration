# # setup gke sh bin/bash/ex3_1.sh
# https://courses.mooc.fi/org/uh-cs/courses/devops-with-kubernetes/chapter-4/introduction-to-google-kubernetes-engine

# sh delete_k3scl.sh
# sh docker_clean.sh

# # test pingpong on local cluster
# sh create_k3scl.sh
# kubens exercises
# # deploy 
# kubectl apply -f ./pingpong/postgres/manifests/config-map.yaml
# kubectl apply -f ./pingpong/postgres/manifests/statefulset.yaml
# kubectl apply -f ./pingpong/manifests/deployment.yaml
# kubectl apply -f ./pingpong/manifests/service.yaml
# kubectl apply -f manifests/curl.yaml 
# kubectl apply -f manifests/busybox.yaml 
# kubectl rollout status deployment pingpong-dep
# POD=$(kubectl get pods -o=name | grep pingpong)
# kubectl wait --for=condition=Ready $POD
# # debug 
# kubectl exec -it alpine-curl -- curl http://pingpong-svc:1234/pingpong 
# # kubectl describe $POD
# # # curl this ID, with internal port (3002)
# # kubectl exec -it alpine-curl -- curl http://10.42.2.3:3002/pingpong 

# test pingpong on gke
sh delete_k3scl.sh
sh docker_clean.sh
kubectl delete all --all -n exercises
kubectl get all -n exercises
sh create_gkecl.sh
kubens exercises
# deploy 
kubectl apply -f ./pingpong/postgres/manifests/config-map.yaml
kubectl apply -f ./pingpong/postgres/manifests/statefulset_gke.yaml
kubectl apply -f ./pingpong/manifests/deployment_gke.yaml
kubectl apply -f ./pingpong/manifests/lb_gke.yaml
kubectl get svc --watch
kubectl get all -n exercises

# curl EXTERNAL-IP/pingpong of pingpong-svc

# sh delete_gkecl.sh

# logs:
# (base) thomas@thomass-MacBook-Air k8s-submission % kubectl get pods
# NAME                           READY   STATUS    RESTARTS   AGE
# pingpong-dep-6589dc87b-wxlqq   1/1     Running   0          2m50s
# postgres-ss-0                  1/1     Running   0          3m22s
# (base) thomas@thomass-MacBook-Air k8s-submission % kubectl describe pod/pingpong-dep-6589dc87b-wxlqq
# Name:             pingpong-dep-6589dc87b-wxlqq
# Namespace:        default
# Priority:         0
# Service Account:  default
# Node:             gke-dwk-cluster-default-pool-9e58cdfd-cs37/10.166.0.12
# Start Time:       Thu, 11 Dec 2025 13:44:26 +0100
# Labels:           app=pingpong
#                   pod-template-hash=6589dc87b
# Annotations:      <none>
# Status:           Running
# IP:               10.32.1.9
# IPs:
#   IP:           10.32.1.9
# Controlled By:  ReplicaSet/pingpong-dep-6589dc87b
# Containers:
#   pingpong:
#     Container ID:   containerd://74af14350def9bf270d734758e28333d6d7698d183ec2b9f1943454c87400f82
#     Image:          thomastoumasu/k8s-pingpong:2.7-amd
#     Image ID:       docker.io/thomastoumasu/k8s-pingpong@sha256:a257c4b8fa39ed29d87aaaa031745b6a86e9178a4c5919b9adeb4930a50de030
#     Port:           <none>
#     Host Port:      <none>
#     State:          Running
#       Started:      Thu, 11 Dec 2025 13:44:38 +0100
#     Ready:          True
#     Restart Count:  0
#     Environment:
#       PORT:          3002
#       DATABASE_URL:  postgres://postgres:mysecretpassword@postgres-svc:5432/postgres
#     Mounts:
#       /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-2xgqm (ro)
# Conditions:
#   Type                        Status
#   PodReadyToStartContainers   True 
#   Initialized                 True 
#   Ready                       True 
#   ContainersReady             True 
#   PodScheduled                True 
# Volumes:
#   kube-api-access-2xgqm:
#     Type:                    Projected (a volume that contains injected data from multiple sources)
#     TokenExpirationSeconds:  3607
#     ConfigMapName:           kube-root-ca.crt
#     Optional:                false
#     DownwardAPI:             true
# QoS Class:                   BestEffort
# Node-Selectors:              <none>
# Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
#                              node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
# Events:
#   Type    Reason     Age    From               Message
#   ----    ------     ----   ----               -------
#   Normal  Scheduled  2m59s  default-scheduler  Successfully assigned default/pingpong-dep-6589dc87b-wxlqq to gke-dwk-cluster-default-pool-9e58cdfd-cs37
#   Normal  Pulling    2m58s  kubelet            Pulling image "thomastoumasu/k8s-pingpong:2.7-amd"
#   Normal  Pulled     2m48s  kubelet            Successfully pulled image "thomastoumasu/k8s-pingpong:2.7-amd" in 9.453s (9.468s including waiting). Image size: 69041751 bytes.
#   Normal  Created    2m48s  kubelet            Created container: pingpong
#   Normal  Started    2m47s  kubelet            Started container pingpong
# (base) thomas@thomass-MacBook-Air k8s-submission % kubectl get pods
# NAME                           READY   STATUS    RESTARTS   AGE
# pingpong-dep-6589dc87b-wxlqq   1/1     Running   0          3m7s
# postgres-ss-0                  1/1     Running   0          3m39s
# (base) thomas@thomass-MacBook-Air k8s-submission % kubectl describe pod/postgres-ss-0
# Name:             postgres-ss-0
# Namespace:        default
# Priority:         0
# Service Account:  default
# Node:             gke-dwk-cluster-default-pool-9e58cdfd-2qz0/10.166.0.13
# Start Time:       Thu, 11 Dec 2025 13:43:58 +0100
# Labels:           app=postgres
#                   apps.kubernetes.io/pod-index=0
#                   controller-revision-hash=postgres-ss-7b9f66bc47
#                   statefulset.kubernetes.io/pod-name=postgres-ss-0
# Annotations:      <none>
# Status:           Running
# IP:               10.32.2.8
# IPs:
#   IP:           10.32.2.8
# Controlled By:  StatefulSet/postgres-ss
# Containers:
#   postgres:
#     Container ID:   containerd://f761156c93bb7aa0acbceeb385882fd99c0dd49fd45c6586fead229ffd551c6d
#     Image:          postgres
#     Image ID:       docker.io/library/postgres@sha256:38d5c9d522037d8bf0864c9068e4df2f8a60127c6489ab06f98fdeda535560f9
#     Port:           5432/TCP (web)
#     Host Port:      0/TCP (web)
#     State:          Running
#       Started:      Thu, 11 Dec 2025 13:44:22 +0100
#     Ready:          True
#     Restart Count:  0
#     Environment:
#       POSTGRES_PASSWORD:  <set to the key 'POSTGRES_PASSWORD' of config map 'postgres-cfgmp'>  Optional: false
#     Mounts:
#       /docker-entrypoint-initdb.d/ from config (ro)
#       /var/lib/postgresql from data (rw)
#       /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-zgbzr (ro)
# Conditions:
#   Type                        Status
#   PodReadyToStartContainers   True 
#   Initialized                 True 
#   Ready                       True 
#   ContainersReady             True 
#   PodScheduled                True 
# Volumes:
#   config:
#     Type:      ConfigMap (a volume populated by a ConfigMap)
#     Name:      postgres-cfgmp
#     Optional:  false
#   data:
#     Type:       PersistentVolumeClaim (a reference to a PersistentVolumeClaim in the same namespace)
#     ClaimName:  pvc-postgres
#     ReadOnly:   false
#   kube-api-access-zgbzr:
#     Type:                    Projected (a volume that contains injected data from multiple sources)
#     TokenExpirationSeconds:  3607
#     ConfigMapName:           kube-root-ca.crt
#     Optional:                false
#     DownwardAPI:             true
# QoS Class:                   BestEffort
# Node-Selectors:              <none>
# Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
#                              node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
# Events:
#   Type    Reason                  Age    From                     Message
#   ----    ------                  ----   ----                     -------
#   Normal  Scheduled               3m40s  default-scheduler        Successfully assigned default/postgres-ss-0 to gke-dwk-cluster-default-pool-9e58cdfd-2qz0
#   Normal  SuccessfulAttachVolume  3m33s  attachdetach-controller  AttachVolume.Attach succeeded for volume "pvc-e7d64fa7-9fa1-46f3-bfab-d88e72b3274f"
#   Normal  Pulling                 3m30s  kubelet                  Pulling image "postgres"
#   Normal  Pulled                  3m17s  kubelet                  Successfully pulled image "postgres" in 13.644s (13.656s including waiting). Image size: 162228059 bytes.
#   Normal  Created                 3m16s  kubelet                  Created container: postgres
#   Normal  Started                 3m16s  kubelet                  Started container postgres
# (base) thomas@thomass-MacBook-Air k8s-submission % kubectl get svc
# NAME           TYPE           CLUSTER-IP       EXTERNAL-IP    PORT(S)        AGE
# kubernetes     ClusterIP      34.118.224.1     <none>         443/TCP        25m
# pingpong-svc   LoadBalancer   34.118.238.123   34.88.57.178   80:32038/TCP   3m4s
# postgres-svc   ClusterIP      None             <none>         5432/TCP       3m56s
# (base) thomas@thomass-MacBook-Air k8s-submission % kubectl describe svc/pingpong-svc
# Name:                     pingpong-svc
# Namespace:                default
# Labels:                   <none>
# Annotations:              cloud.google.com/neg: {"ingress":true}
# Selector:                 app=pingpong
# Type:                     LoadBalancer
# IP Family Policy:         SingleStack
# IP Families:              IPv4
# IP:                       34.118.238.123
# IPs:                      34.118.238.123
# LoadBalancer Ingress:     34.88.57.178 (VIP)
# Port:                     <unset>  80/TCP
# TargetPort:               3002/TCP
# NodePort:                 <unset>  32038/TCP
# Endpoints:                10.32.1.9:3002
# Session Affinity:         None
# External Traffic Policy:  Cluster
# Internal Traffic Policy:  Cluster
# Events:
#   Type    Reason                Age    From                Message
#   ----    ------                ----   ----                -------
#   Normal  EnsuringLoadBalancer  3m16s  service-controller  Ensuring load balancer
#   Normal  EnsuredLoadBalancer   2m38s  service-controller  Ensured load balancer
# (base) thomas@thomass-MacBook-Air k8s-submission % 


