# prepare master nodes for workload
# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#control-plane-node-isolation
kubectl taint nodes --all node-role.kubernetes.io/control-plane-
# https://stackoverflow.com/questions/43147941/allow-scheduling-of-pods-on-kubernetes-master
kubectl taint nodes --all node-role.kubernetes.io/master:NoSchedule-
sudo apt-get install python3-dev git curl make build-essential libssl-dev libffi-dev jq

# install helm
wget https://get.helm.sh/helm-v3.10.2-linux-amd64.tar.gz
tar xf helm-v3.10.2-linux-amd64.tar.gz
sudo mv linux-amd64/helm /usr/local/bin/
rm -rf helm-v3.10.2-linux-amd64.tar.gz linux-amd64/
# clone repos
git clone https://opendev.org/openstack/openstack-helm-infra.git
git clone https://opendev.org/openstack/openstack-helm.git


# setup openstack
#192.168.60.253 keystone.openstack.svc.cluster.local
#192.168.60.253 glance.openstack.svc.cluster.local
#192.168.60.253 cinder.openstack.svc.cluster.local

cd openstack-helm
./label_nodes.sh
./tools/deployment/multinode/010-setup-client.sh
OSH_DEPLOY_MULTINODE=True ./tools/deployment/component/common/ingress.sh
# ./tools/deployment/multinode/030-ceph.sh
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



scp modules/openstack/ceph-lo.sh main01:
scp modules/openstack/ceph-lo.sh main02:
scp modules/openstack/ceph-lo.sh main03:

scp modules/openstack/ceph-lo.sh worker01:
scp modules/openstack/ceph-lo.sh worker02:
scp modules/openstack/ceph-lo.sh worker03:
ssh worker01
chmod +x ceph-lo.sh
./ceph-lo.sh --ceph-osd-data /dev/loop8 --ceph-osd-dbwal /dev/loop9

kubectl exec -n ceph ceph-mon-default-37207810-7q6w4 -- ceph -s
