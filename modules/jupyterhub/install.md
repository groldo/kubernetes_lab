# jupyterhub

## make master nodes take worker load

```bash
kubectl taint nodes --all node-role.kubernetes.io/control-plane-
kubectl taint nodes --all node-role.kubernetes.io/master:NoSchedule-
```

## install helm

```bash
wget https://get.helm.sh/helm-v3.10.2-linux-amd64.tar.gz
tar xf helm-v3.10.2-linux-amd64.tar.gz
sudo mv linux-amd64/helm /usr/local/bin/
rm -rf helm-v3.10.2-linux-amd64.tar.gz linux-amd64/
```

## setup rook

```bash
git clone --single-branch --branch v1.10.6 https://github.com/rook/rook.git
cd rook/deploy/examples
vim cluster.yaml 
kubectl create -f crds.yaml -f common.yaml -f operator.yaml
vim cluster.yaml 
kubectl create -f cluster.yaml
```

## ceph command line tools

```bash
kubectl create -f toolbox.yaml
kubectl -n rook-ceph exec -it deploy/rook-ceph-tools -- bash
ceph -s
```

## status of cephcluster ressource in kubernetes

```bash
kubectl -n rook-ceph get CephCluster -o yaml
```

## rook-ceph dashboard

```bash
kubectl -n rook-ceph get service
kubectl -n rook-ceph get secret rook-ceph-dashboard-password -o jsonpath="{['data']['password']}" | base64 --decode && echo
ssh -L 8001:localhost:8001 main01
kubectl proxy
# http://localhost:8002/api/v1/namespaces/rook-ceph/services/https:rook-ceph-mgr-dashboard:8443/proxy/#/login?returnUrl=%2Fdashboard
```

To make ceph accessible
see [https://www.adaltas.com/en/2020/04/16/expose-ceph-from-rook-kubernetes/](https://www.adaltas.com/en/2020/04/16/expose-ceph-from-rook-kubernetes/)

## install jupyter

helm repo add jupyterhub https://jupyterhub.github.io/helm-chart/
helm repo update
vim jupyterhub.yaml
helm upgrade --cleanup-on-fail   --install jupyterhub jupyterhub/jupyterhub   --namespace jupyterhub   --create-namespace   --version=2.0.0   --values jupyterhub.yaml 

### access hub from outside kubernetes

```bash
vagrant@main01:~$ kubectl get service -n jupyterhub  
NAME           TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
hub            ClusterIP      10.101.122.32    <none>        8081/TCP       29h
proxy-api      ClusterIP      10.103.185.145   <none>        8001/TCP       29h
proxy-public   LoadBalancer   10.102.4.163     <pending>     80:32226/TCP   29h
```

browse to `http://<cluster-vip:jupyter-port` for example [http://192.168.60.253:32226](http://192.168.60.253:32226)
