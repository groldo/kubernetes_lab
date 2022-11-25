# join further nodes and adjusting bind-address

## join node

```bash
ssh main02
# prepare kubernetes with certs
sudo mv pki/* /etc/kubernetes/pki/
# get join command from first initiated cluster node and update command
sudo kubeadm join 192.168.60.253:6443 
    --token abcdef.0123456789abcdef         
    --discovery-token-ca-cert-hash sha256:1c39a88bd2df11fb639b8a8d42e4c47a03cb5b024b380f86814a8d230b26dede         
    --control-plane --ignore-preflight-errors=Port-6443
```

## Update bind-address of api-server

```bash
kubectl get cm -n kube-system kubeadm-config -o=jsonpath="{.data.ClusterConfiguration}" > node-config.yaml
```

adjust `bind-address: 192.168.60.11` to the ip address of the new master node e.g. `192.168.60.12`
copy `node-config.yaml` to the node and run

```bash
sudo kubeadm init phase control-plane apiserver --config /etc/kubernetes/node-config.yaml
```

### Whats the problem?

When joining further nodes to the kubernetes cluster the new node tries to bind itself to `192.168.60.11` which is the ip address of the first cluster.
This leads to an `CrashLoopBackOff`. 
You can see this when watching the `kube-system` pods

```bash
vagrant@main01:~$ kubectl get pods -n kube-system
NAME                             READY   STATUS             RESTARTS         AGE
coredns-8648f4c584-5sk79         0/1     Pending            0                112m
coredns-8648f4c584-jwczd         0/1     Pending            0                112m
etcd-main01                      1/1     Running            0                113m
etcd-main02                      1/1     Running            0                104m
kube-apiserver-main01            1/1     Running            0                113m
kube-apiserver-main02            0/1     CrashLoopBackOff   24 (3m44s ago)   104m
kube-controller-manager-main01   1/1     Running            1 (104m ago)     113m
kube-controller-manager-main02   1/1     Running            0                102m
kube-proxy-97b9m                 1/1     Running            0                104m
kube-proxy-wxfw2                 1/1     Running            0                112m
kube-scheduler-main01            1/1     Running            1 (104m ago)     113m
kube-scheduler-main02            1/1     Running            0                103m
```

And by watching the logs.

```bash
vagrant@main01:~$ kubectl logs -n kube-system kube-apiserver-main02
E1114 14:03:39.120000       1 reflector.go:140] vendor/k8s.io/client-go/informers/factory.go:134: Failed to watch *v1.LimitRange: failed to list *v1.LimitRange: Get "https://192.168.60.11:6443/api/v1/limitranges?limit=500&resourceVersion=0": x509: certificate signed by unknown authority
W1114 14:03:39.473953       1 reflector.go:424] vendor/k8s.io/client-go/informers/factory.go:134: failed to list *v1.Namespace: Get "https://192.168.60.11:6443/api/v1/namespaces?limit=500&resourceVersion=0": x509: certificate signed by unknown authority
E1114 14:03:39.475283       1 reflector.go:140] vendor/k8s.io/client-go/informers/factory.go:134: Failed to watch *v1.Namespace: failed to list *v1.Namespace: Get "https://192.168.60.11:6443/api/v1/namespaces?limit=500&resourceVersion=0": x509: certificate signed by unknown authority
```

To solve this the kube-apiserver config has to be adjusted.
