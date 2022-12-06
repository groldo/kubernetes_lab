set -xeu

(cd modules/01_vagrant_vms && vagrant up --color --provider virtualbox)
if source .venv/bin/activate; then
    python3 -m pip install -r requirements.txt
else
    python3 -m venv .venv
    source .venv/bin/activate
    python3 -m pip install -r requirements.txt
fi
ansible-playbook -i inventory/kubernetes_hosts.yml modules/02_networking/converge.yml
ansible-playbook -i inventory/kubernetes_hosts.yml modules/03_certs/converge.yml
# copy the created certs folder in  modules/03_certs to modules/04_registry, modules/05_containerd and modules/06_kubernetes
cp -r modules/03_certs/certs modules/04_registry/
cp -r modules/03_certs/certs modules/05_containerd/
cp -r modules/03_certs/certs modules/06_kubernetes/
ansible-playbook -i inventory/kubernetes_hosts.yml modules/04_registry/converge.yml
ansible-playbook -i inventory/kubernetes_hosts.yml modules/05_containerd/converge.yml
ansible-playbook -i inventory/kubernetes_hosts.yml modules/06_kubernetes/converge.yml
ansible-playbook -i inventory/kubernetes_hosts.yml modules/07_clusterinit/converge.yml
# fetch `admin.conf` and certificates from `main01` and pushs it to the `adminclient`.
ansible-playbook -i inventory/kubernetes_hosts.yml post_init.yml
