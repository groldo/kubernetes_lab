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

To make ceph accessible from outside kubernetes 
see [https://www.adaltas.com/en/2020/04/16/expose-ceph-from-rook-kubernetes/](https://www.adaltas.com/en/2020/04/16/expose-ceph-from-rook-kubernetes/)
