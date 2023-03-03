# openstack

try with openstack
up to now not functional

```bash
ansible-playbook -i hosts.yml modules/openstack/converge.yml
```

```bash
./label_nodes.sh
cd openstack-helm
./tools/deployment/multinode/010-setup-client.sh
OSH_DEPLOY_MULTINODE=True ./tools/deployment/component/common/ingress.sh
# ./tools/deployment/multinode/030-ceph.sh - uses loopback devices for real hdds use deploy-ceph.sh
./deploy-ceph.sh
./tools/deployment/multinode/040-ceph-ns-activate.sh
./tools/deployment/multinode/050-mariadb.sh
./tools/deployment/multinode/060-rabbitmq.sh
./tools/deployment/multinode/070-memcached.sh
./tools/deployment/multinode/080-keystone.sh
./tools/deployment/multinode/090-ceph-radosgateway.sh
./tools/deployment/multinode/100-glance.sh
./tools/deployment/multinode/110-cinder.sh
./tools/deployment/multinode/120-openvswitch.sh
./tools/deployment/multinode/130-libvirt.sh
./tools/deployment/multinode/140-compute-kit.sh
./tools/deployment/multinode/150-heat.sh
./tools/deployment/multinode/160-barbican.sh
```

fails when

```bash
./tools/deployment/multinode/100-glance.sh
```

## notes

the openstack-helm project automatically assigns all nodes which gets labeled with `ceph-enabled` as ceph nodes.
So you need to adjust which nodes shall have this label.
ceph will check if a node which should be `ceph-enabled` is not a working ceph node.
This will cause trouble when you you don't assign your master nodes to have worker load.

### troubleshooting ceph

```
kubectl exec -n ceph ceph-mon-default-37207810-7q6w4 -- ceph -s
kubectl exec -n ceph -it ceph-mon-default-37207810-7q6w4 -- ceph
```

