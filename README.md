# Kubernetes

This project sets up a kubernetes cluster with vagrant on virtualbox machines.
For more information regarding troubleshooting, learnings and so on see

* [containerd](docs/containerd.md)
* [kubernetes](docs/kubernetes.md)
* [kubeadm-phases](docs/kubeadm_phases.md)
* [vagrant](docs/vagrant.md)

## Usage

### create virtual machines

```bash
git submodule init
git submodule update
python3 -m venv .venv
source .venv/bin/activate
python3 -m pip install -r requirements.txt
cd modules/01_vagrant_vms
vagrant up --color --provision --provider virtualbox
```

### setup ssh for ansible

```bash
cd ..
cat files/ssh-config >> ~/.ssh/config
# adjust ssh config to your needs, especially IdentityFile might be diverging
# also see vagrant ssh-config for help
ansible -m ping -i inventory/hosts.yml kubernetes
```

```bash
ansible-playbook -i inventory/kubernetes_hosts.yml modules/02_networking/converge.yml
ansible-playbook -i inventory/kubernetes_hosts.yml modules/03_certs/converge.yml
ansible-playbook -i inventory/kubernetes_hosts.yml modules/04_registry/converge.yml
ansible-playbook -i inventory/kubernetes_hosts.yml modules/05_containerd/converge.yml
ansible-playbook -i inventory/kubernetes_hosts.yml modules/06_kubernetes/converge.yml
```

### initialize kubernetes

```bash
ssh main01
sudo kubeadm config images pull --config /etc/kubernetes/init-config.yaml
sudo kubeadm init --config /etc/kubernetes/init-config.yaml --ignore-preflight-errors=Port-6443
exit
```

### join further master nodes

```bash
ansible-playbook -i inventory/kubernetes_hosts.yml post-init.yml
scp k8s_config.tgz main02:~/
scp k8s_config.tgz main03:~/
```

```
sudo kubeadm join 192.168.60.253:6443 
    --token abcdef.0123456789abcdef         
    --discovery-token-ca-cert-hash sha256:1c39a88bd2df11fb639b8a8d42e4c47a03cb5b024b380f86814a8d230b26dede         
    --control-plane --ignore-preflight-errors=Port-6443
```

```bash
kubectl get cm -n kube-system kubeadm-config -o=jsonpath="{.data.ClusterConfiguration}" 
```

```yaml
apiServer:
  certSANs:
  - cluster.local
  - api.k8s
  - localhost
  extraArgs:
    advertise-address: 192.168.60.253
    audit-log-path: '-'
    audit-policy-file: /etc/kubernetes/audit.yaml
    authorization-mode: Node,RBAC
    bind-address: 192.168.60.11
  extraVolumes:
  - hostPath: /etc/kubernetes/audit.yaml
    mountPath: /etc/kubernetes/audit.yaml
    name: audit
    pathType: File
    readOnly: true
  timeoutForControlPlane: 4m0s
apiVersion: kubeadm.k8s.io/v1beta3
certificatesDir: /etc/kubernetes/pki
clusterName: kubernetes
controlPlaneEndpoint: 192.168.60.253:6443
controllerManager: {}
dns: {}
etcd:
  local:
    dataDir: /var/lib/etcd
    imageRepository: registry.local
    imageTag: 3.5.4-0
imageRepository: registry.local
kind: ClusterConfiguration
kubernetesVersion: v1.25.3
networking:
  dnsDomain: cluster.local
  podSubnet: 10.244.0.0/16
  serviceSubnet: 10.96.0.0/12
scheduler: {}
```

### join cluster with workerone

```bash
ssh workerone
sudo kubeadm join 192.168.60.253:6443 \
    --token abcdef.0123456789abcdef \
    --discovery-token-ca-cert-hash sha256:1c39a88bd2df11fb639b8a8d42e4c47a03cb5b024b380f86814a8d230b26dede
# adjust to your join command
```

### finalize cluster with network

```bash
ansible-playbook post_init.yml
kubectl get pods -n kube-system
curl https://raw.githubusercontent.com/projectcalico/calico/v3.24.5/manifests/canal.yaml -O
kubectl apply -f ~/canal.yaml
watch kubectl get pods -n kube-system
# watch pods as they go up
```
