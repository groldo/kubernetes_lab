# cluster administration

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
