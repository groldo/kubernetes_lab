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
cd modules/01_vagrant_vms
vagrant up --color --provision --provider virtualbox
```

### setup ssh for ansible

```bash
python3 -m venv .venv
source .venv/bin/activate
python3 -m pip install -r requirements.txt
cat files/ssh-config >> ~/.ssh/config
# adjust ssh config to your needs, especially IdentityFile might be diverging
# also see vagrant ssh-config for help
ansible -m ping -i inventory/kubernetes_hosts.yml kubernetes
```

```bash
ansible-playbook -i inventory/kubernetes_hosts.yml modules/02_networking/converge.yml
ansible-playbook -i inventory/kubernetes_hosts.yml modules/03_certs/converge.yml
# copy the created certs folder in  modules/03_certs to modules/04_registry, modules/05_containerd and modules/06_kubernetes
ansible-playbook -i inventory/kubernetes_hosts.yml modules/04_registry/converge.yml
ansible-playbook -i inventory/kubernetes_hosts.yml modules/05_containerd/converge.yml
ansible-playbook -i inventory/kubernetes_hosts.yml modules/06_kubernetes/converge.yml
ansible-playbook -i inventory/kubernetes_hosts.yml modules/07_clusterinit/converge.yml
# fetch `admin.conf` and certificates from `main01` and pushs it to the `adminclient`.
ansible-playbook -i inventory/kubernetes_hosts.yml post_init.yml
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
