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

```bash
cd vagrant-ansiblifies
vagrant up --color --provision --provider virtualbox
vagrant ssh-config 2>/dev/null >> ~/.ssh/config
cat files/ssh-config >> ~/.ssh/config    
ansible -m ping -i inventory/hosts.yml kubernetes
ansible-galaxy install -r roles/requirements.yml -p roles/
ansible-playbook playbook
```

## kubernetes and multiple interfaces

https://stackoverflow.com/questions/35208188/how-can-i-define-network-settings-with-vagrant/35211086#35211086

kubernetes seems to have problems with multiple interfaces.

```bash
VBoxManage list vms
cd vagrant-ansiblified
vagrant halt
cd ../
VBoxManage modifyvm masternode --cableconnected1 off
VBoxManage modifyvm masternode --cableconnected2 on
VBoxManage modifyvm workerone --cableconnected1 off
VBoxManage modifyvm workerone --cableconnected2 on
VBoxManage modifyvm registry --cableconnected1 on
VBoxManage modifyvm registry --cableconnected2 on
```

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

## router

```bash
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -A FORWARD -i eth0 -o eth1 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i eth1 -o eth0 -j ACCEPT
```

## cluster administration

```bash
$ mkdir -p $HOME/.kube
$ sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
$ sudo chown $(id -u):$(id -g) $HOME/.kube/config
$ sudo kubectl get pods -n kube-system
$ kubectl get pods -n kube-system

sudo apt update && sudo apt install bash-completion
source <(kubectl completion bash)
kubectl <TAB>
```

## Certificates

There is a ca certificate generated which gets created in the `certs` directory

Kubernetes does not handle password encrypted keys.

## resolvd

```bash
Dez 16 08:51:46 masternode kubelet[2257]: E1216 08:51:46.547725    2257 kuberuntime_sandbox.go:43] "Failed to generate sandbox config for pod" err="open /run/systemd/resolve/resolv.conf: no such file or directory" pod="kube-system/kube-apiserver-masternode"
Dez 16 08:51:46 masternode kubelet[2257]: E1216 08:51:46.547911    2257 kuberuntime_manager.go:832] "CreatePodSandbox for pod failed" err="open /run/systemd/resolve/resolv.conf: no such file or directory" pod="kube-system/kube-apiserver-masternode"
Dez 16 08:51:46 masternode kubelet[2257]: E1216 08:51:46.548044    2257 pod_workers.go:918] "Error syncing pod, skipping" err="failed to \"CreatePodSandbox\" for \"kube-apiserver-masternode_kube-system(ef62485ff2e1fda9cd0b93e7536f3019)\" with CreatePodSandboxError: \"Failed to generate sandbox config for pod \\\"kube-apiserver-masternode_kube-system(ef62485ff2e1fda9cd0b93e7536f3019)\\\": open /run/systemd/resolve/resolv.conf: no such file or directory\"" pod="kube-system/kube-apiserver-masternode" podUID=ef62485ff2e1fda9cd0b93e7536f3019
```
