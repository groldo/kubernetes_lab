# containerd

## debugging containerd with crictl

crictl is installed with kubernetes and is helping to debug the container runtime engine.

To avoid having to explicit set the runtime everytime you can set `/etc/crictl.yaml`
also see https://github.com/kubernetes-sigs/cri-tools/blob/master/docs/crictl.md

```yaml
runtime-endpoint: unix:///run/containerd/containerd.sock
image-endpoint: unix:///run/containerd/containerd.sock
timeout: 2
debug: false
pull-image-on-create: false
```

## pitfalls

containerd registries:
configuration in `/etc/containerd/config.toml` is only read by crictl and therefore kubeadm.
so configured registries in /etc/containerd/certs.d/ can only be debugged with crictl (installed with kubernetes).
see https://github.com/containerd/containerd/blob/aa2733c202077e8f0b4ca23f09e0e806d7980234/docs/cri/config.md#L316

```bash
# this does not run
sudo ctr image pull registry:5000/node:v3.18.1
# this does run
sudo crictl -r "unix:///run/containerd/containerd.sock" pull 192.168.1.13:5000/node:v3.18.1
```

```bash
# mind the full path with library

vagrant@masternode:~$ sudo ctr image pull docker.io/library/hello-world:latest
docker.io/library/hello-world:latest: resolving      |--------------------------------------| 
docker.io/library/hello-world:latest:                                             resolved       |++++++++++++++++++++++++++++++++++++++| 
index-sha256:cc15c5b292d8525effc0f89cb299f1804f3a725c8d05e158653a563f15e4f685:    exists         |++++++++++++++++++++++++++++++++++++++| 
manifest-sha256:f54a58bc1aac5ea1a25d796ae155dc228b3f0e11d046ae276b39c4bf2f13d8c4: done           |++++++++++++++++++++++++++++++++++++++| 
layer-sha256:2db29710123e3e53a794f2694094b9b4338aa9ee5c40b930cb8063a1be392c54:    done           |++++++++++++++++++++++++++++++++++++++| 
config-sha256:feb5d9fea6a5e9606aa995e879d862b825965ba48de054caab5ef356dc6b3412:   done           |++++++++++++++++++++++++++++++++++++++| 
elapsed: 1.2 s                                                                    total:   0.0 B (0.0 B/s)                                         
unpacking linux/amd64 sha256:cc15c5b292d8525effc0f89cb299f1804f3a725c8d05e158653a563f15e4f685...
done: 14.891897ms
vagrant@masternode:~$ sudo ctr image pull docker.io/hello-world:latest
docker.io/hello-world:latest: resolving      |--------------------------------------| 
elapsed: 0.9 s                total:   0.0 B (0.0 B/s)                                         
INFO[0001] trying next host                              error="pull access denied, repository does not exist or may require authorization: server message: insufficient_scope: authorization failed" host=registry-1.docker.io
ctr: failed to resolve reference "docker.io/hello-world:latest": pull access denied, repository does not exist or may require authorization: server message: insufficient_scope: authorization failed
```

## Differences when using 

When coming from docker to containerd.
Then there was a configuration arg for the kubelet service: `pod-infra-container-image`

the full command from `systemctl status kubelet` might say:

```bash
/usr/bin/kubelet --bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf \
                    --kubeconfig=/etc/kubernetes/kubelet.conf \
                    --config=/var/lib/kubelet/config.yaml \
                    --cgroup-driver=systemd 
                    --container-runtime=remote 
                    --container-runtime-endpoint=unix:///run/containerd/containerd.sock
                    --pod-infra-container-image=<some_registry>/pause:3.6
```

this isn't needed for containerd.
Additionally it gets ignored from kubelet.
Which results in having the default value from containerd be downloaded.

which in turn is

    sandbox_image = "k8s.gcr.io/pause:3.5"

If you are working in a closed environment this will stop kublet from downloading the correct pause image for the kube system pods
