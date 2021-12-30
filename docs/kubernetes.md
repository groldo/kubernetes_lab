# kubernetes

## kubernetes and multiple interfaces

```bash
sudo kubeadm init --config /etc/kubernetes/init-config.yaml
sudo tar vcf kubestrap.tar /etc/kubernetes/admin.conf /etc/kubernetes/pki/ca.* /etc/kubernetes/pki/etcd/ca.* /etc/kubernetes/pki/front-proxy-ca.* /etc/kubernetes/pki/sa.*
scp  -i ~/.ssh/staging-k8s-master-01_id_rsa ansible@10.10.97.170:~/kubestrap.tar .
scp  -i ~/.ssh/staging-k8s-master-02_id_rsa kubestrap.tar  ansible@10.10.97.171:~/kubestrap.tar
scp  -i ~/.ssh/staging-k8s-master-03_id_rsa kubestrap.tar  ansible@10.10.97.172:~/kubestrap.tar
sudo tar xfv kubestrap.tar -C /
sudo kubeadm init phase control-plane apiserver --config /etc/kubernetes/init-config.yaml
```

## images

For a list of image kubernetes will use:

```bash
# get the default kubernetes images
sudo kubeadm config images list
# or
sudo kubeadm config images list --config /etc/kubernetes/init-config.yaml
sudo kubeadm config images pull --config /etc/kubernetes/init-config.yaml
```

## resolvd

```bash
Dez 16 08:51:46 masternode kubelet[2257]: E1216 08:51:46.547725    2257 kuberuntime_sandbox.go:43] "Failed to generate sandbox config for pod" err="open /run/systemd/resolve/resolv.conf: no such file or directory" pod="kube-system/kube-apiserver-masternode"
Dez 16 08:51:46 masternode kubelet[2257]: E1216 08:51:46.547911    2257 kuberuntime_manager.go:832] "CreatePodSandbox for pod failed" err="open /run/systemd/resolve/resolv.conf: no such file or directory" pod="kube-system/kube-apiserver-masternode"
Dez 16 08:51:46 masternode kubelet[2257]: E1216 08:51:46.548044    2257 pod_workers.go:918] "Error syncing pod, skipping" err="failed to \"CreatePodSandbox\" for \"kube-apiserver-masternode_kube-system(ef62485ff2e1fda9cd0b93e7536f3019)\" with CreatePodSandboxError: \"Failed to generate sandbox config for pod \\\"kube-apiserver-masternode_kube-system(ef62485ff2e1fda9cd0b93e7536f3019)\\\": open /run/systemd/resolve/resolv.conf: no such file or directory\"" pod="kube-system/kube-apiserver-masternode" podUID=ef62485ff2e1fda9cd0b93e7536f3019
```
