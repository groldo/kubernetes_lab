# Kubernetes

This project sets up a kubernetes cluster with vagrant on virtualbox machines.
For more information regarding troubleshooting, learnings and so on see

* [containerd](docs/containerd.md)
* [kubernetes](docs/kubernetes.md)
* [kubeadm-phases](docs/kubeadm_phases.md)
* [vagrant](docs/vagrant.md)

## Usage

### setup local machine

```bash
python3 -m venv .venv
source .venv/bin/activate
python3 -m pip install -r requirements.txt
cat files/ssh-config >> ~/.ssh/config
# adjust ssh config to your needs, especially IdentityFile might be diverging
# also see vagrant ssh-config for help
ansible -m ping -i inventory/kubernetes_hosts.yml kubernetes
```

### install kubernetes

```bash
./install.sh
```

### join further master nodes

Have a look at [join_master_nodes](docs/join_master_nodes.md)

### finalize cluster with network

```bash
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.24.5/manifests/canal.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.6.1/aio/deploy/recommended.yaml
kubectl get pods -n kube-system -w
# watch pods as they go up
```

### cleanup

```bash
./destroy.sh
```
