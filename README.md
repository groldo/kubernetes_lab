# Kubernetes

This sets up a kubernetes cluster with vagrant on virtualbox machines.
It might run on other hypervisor as well, but was tested with:

* host: ubuntu 20.04 LTS (virtual machine)
* virtualbox:
    vboxmanage --version
    6.1.26_Ubuntur145957
* vagrant:
    vagrant --version
    Vagrant 2.2.6

for more information on troubleshooting, learnings and so on see

* [containerd](docs/containerd.md)
* [kubernetes](docs/kubernetes.md)
* [kubeadm-phases](docs/kubeadm_phases.md)
* [vagrant](docs/vagrant.md)

## Usage

### create virtual machines

```bash
cd vagrant-ansiblified
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

### run playbook

```bash
ansible-galaxy install -r roles/requirements.yml -p roles/
ansible-playbook playbook.yml
```

### initialize masterone

```bash
ssh masternode
sudo kubeadm config images pull --config /etc/kubernetes/init-config.yaml
sudo kubeadm init --config /etc/kubernetes/init-config.yaml --ignore-preflight-errors=Port-6443
exit
```

### join cluster with workerone

```bash
ssh workerone
sudo rm -rf /etc/kubernetes/pki
sudo kubeadm join 192.168.1.253:6443 --token abcdef.0123456789abcdef         --discovery-token-ca-cert-hash sha256:5d61d858b2b17a134ab91f74cb6fb46f9a9541b1ecb4e0447e2189f61924348d
```
