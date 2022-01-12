# Kubernetes

This project sets up a kubernetes cluster with vagrant on virtualbox machines.

The idea is to have a quick setup for kubernetes,
which is suppose to have a production type character.

Up to now there is only one masternode and one workernode,
but it should be pretty straight forward to just add more masternodes and workernodes.

As container runtime engine I choosed `containerd` in favor of docker,
because it isn't supported anymore, also see[Dockershim Deprecation FAQ](https://kubernetes.io/blog/2020/12/02/dockershim-faq/).

The project also sets up a private registry and pulls all necessery image to it.
Kubernetes gets configure in a way so it is using the private registry.

It might run on other hypervisor as well, but was tested with:

* host: windows bare metal host
    * hyperv and vagrant installed
    * make sure it does has some spare resources ;)
* guest: ubuntu 20.04 LTS (virtual machine) guest with virtualization extensions installed 
    * (also see [vagrant-ansiblified](https://github.com/groldo/vagrant-ansiblified) for a hyperv vagrant config)
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

If you're only interested in the ansible scripts to setup a kubernetes cluster,
you should focus on only the `converge.yml`.

Since the `prepare.yml` and the `submodule` is only for the "environment" setup in `virtualbox`.

The `post_init.yml` is supposed to setup a `adminclient`, which can be any client which have network access to the kubernetes cluster.

## Usage

### create virtual machines

```bash
git submodule init
git submodule update
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
ansible-playbook prepare.yml
ansible-playbook converge.yml
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
sudo kubeadm join 192.168.1.253:6443 --token abcdef.0123456789abcdef         --discovery-token-ca-cert-hash sha256:5d61d858b2b17a134ab91f74cb6fb46f9a9541b1ecb4e0447e2189f61924348d
# adjust to your join command
```

### finalize cluster with network

```bash
ansible-playbook post_init.yml
kubectl get pods -n kube-system
kubectl apply -f ~/canal.yaml
watch kubectl get pods -n kube-system
# watch pods as they go up
```
