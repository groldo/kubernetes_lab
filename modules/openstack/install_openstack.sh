sudo apt-get install python3-dev git curl make build-essential libssl-dev libffi-dev jq
# install helm
wget https://get.helm.sh/helm-v3.10.2-linux-amd64.tar.gz
tar xf helm-v3.10.2-linux-amd64.tar.gz
sudo mv linux-amd64/helm /usr/local/bin/
# clone repos
git clone https://opendev.org/openstack/openstack-helm-infra.git
git clone https://opendev.org/openstack/openstack-helm.git

scp modules/openstack/ceph-lo.sh main01:
scp modules/openstack/ceph-lo.sh main02:
scp modules/openstack/ceph-lo.sh main03:

scp modules/openstack/ceph-lo.sh worker01:
scp modules/openstack/ceph-lo.sh worker02:
scp modules/openstack/ceph-lo.sh worker03:
ssh worker01
chmod +x ceph-lo.sh
./ceph-lo.sh --ceph-osd-data /dev/loop8 --ceph-osd-dbwal /dev/loop9