# FAQ

## Why does the registry has to be a router and eth0 is disabled?

Kubeadm tries to automatically determine the ip address to use for its service,
which is by default the first found ip address.
This can cause some trouble with kubernetes.
You might able to make this work with [this](https://stackoverflow.com/questions/54722289/kubernetes-internet-access-with-two-network-interfaces) stackoverflow question.
But I wouldn't bother any further and just disabled it.

Also see [vagrant.md](vagrant.md)


## Why using containerd

As container runtime engine I choosed `containerd` in favor of docker,
because docker isn't supported anymore by kubernetes see [Dockershim Deprecation FAQ](https://kubernetes.io/blog/2020/12/02/dockershim-faq/).
So why containerd and not crio or other: There is no real reason for this.
Just picked up the first in [this](https://kubernetes.io/blog/2020/12/02/dockershim-faq/#are-there-examples-of-folks-using-other-runtimes-in-production-today) list.

## Why using your own registry

I've wanted to be more or less independent from docker hub.
The project also sets up a private registry and pulls all necessery image to it.
Kubernetes gets configured in a way so it is using this private registry.

## Why haproxy and keepalived

See 
* [kubernetes.io/docs/setup/production-environment/tools/kubeadm/high-availability/](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/high-availability/) and 
* [github.com/kubernetes/kubeadm/blob/main/docs/ha-considerations.md#options-for-software-load-balancing](https://github.com/kubernetes/kubeadm/blob/main/docs/ha-considerations.md#options-for-software-load-balancing)
