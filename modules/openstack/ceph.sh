#!/bin/bash
#NOTE: Deploy command
[ -s /tmp/ceph-fs-uuid.txt ] || uuidgen > /tmp/ceph-fs-uuid.txt
CEPH_PUBLIC_NETWORK="$(./tools/deployment/multinode/kube-node-subnet.sh)"
CEPH_CLUSTER_NETWORK="${CEPH_PUBLIC_NETWORK}"
CEPH_FS_ID="$(cat /tmp/ceph-fs-uuid.txt)"
#NOTE(portdirect): to use RBD devices with kernels < 4.5 this should be set to 'hammer'
LOWEST_CLUSTER_KERNEL_VERSION=$(kubectl get node  -o go-template='{{range .items}}{{.status.nodeInfo.kernelVersion}}{{"\n"}}{{ end }}' | sort -V | tail -1)
if [ "$(echo ${LOWEST_CLUSTER_KERNEL_VERSION} | awk -F "." '{ print $1 }')" -lt "4" ] || [ "$(echo ${LOWEST_CLUSTER_KERNEL_VERSION} | awk -F "." '{ print $2 }')" -lt "15" ]; then
  echo "Using hammer crush tunables"
  CRUSH_TUNABLES=hammer
else
  CRUSH_TUNABLES=null
fi
NUMBER_OF_OSDS="$(kubectl get nodes -l ceph-osd=enabled --no-headers | wc -l)"
tee /tmp/ceph.yaml << EOF
endpoints:
  ceph_mon:
    namespace: ceph
network:
  public: ${CEPH_PUBLIC_NETWORK}
  cluster: ${CEPH_CLUSTER_NETWORK}
deployment:
  storage_secrets: true
  ceph: true
  rbd_provisioner: true
  csi_rbd_provisioner: true
  cephfs_provisioner: false
  client_secrets: false
bootstrap:
  enabled: true
conf:
  ceph:
    global:
      fsid: ${CEPH_FS_ID}
  pool:
    crush:
      tunables: ${CRUSH_TUNABLES}
    target:
      osd: ${NUMBER_OF_OSDS}
      pg_per_osd: 100
  storage:
    osd:
      - data:
          type: bluestore
          location: /dev/loop8
        block_db:
          location: /dev/loop9
          size: "5GB"
        block_wal:
          location: /dev/loop9
          size: "2GB"
storageclass:
  cephfs:
    provision_storage_class: false
manifests:
  deployment_cephfs_provisioner: false
  job_cephfs_client_key: false
EOF

: ${OSH_INFRA_PATH:="../openstack-helm-infra"}
for CHART in ceph-mon ceph-osd ceph-client ceph-provisioners; do
  make -C ${OSH_INFRA_PATH} ${CHART}
  echo "helm upgrade --install ${CHART} ${OSH_INFRA_PATH}/${CHART} \
    --namespace=ceph \
    --values=/tmp/ceph.yaml \
    ${OSH_EXTRA_HELM_ARGS} \
    ${OSH_EXTRA_HELM_ARGS_CEPH_DEPLOY}"
  #helm uninstall ${CHART} --namespace=ceph
  helm upgrade --install ${CHART} ${OSH_INFRA_PATH}/${CHART} \
    --namespace=ceph \
    --values=/tmp/ceph.yaml \
    ${OSH_EXTRA_HELM_ARGS} \
    ${OSH_EXTRA_HELM_ARGS_CEPH_DEPLOY}

  #NOTE: Wait for deploy
  ./tools/deployment/common/wait-for-pods.sh ceph 1200

  #NOTE: Validate deploy
  MON_POD=$(kubectl get pods \
    --namespace=ceph \
    --selector="application=ceph" \
    --selector="component=mon" \
    --no-headers | awk '{ print $1; exit }')
  kubectl exec -n ceph ${MON_POD} -- ceph -s
done
