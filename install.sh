set -xeu

(cd modules/01_vagrant_vms && vagrant up --color --provider virtualbox)
if source .venv/bin/activate; then
    python3 -m pip install -r requirements.txt
else
    python3 -m venv .venv
    source .venv/bin/activate
    python3 -m pip install -r requirements.txt
fi

if ! ssh registry bash -c "exit"; then
ssh_config_registry=$(cat <<EOF
Host registry
  HostName 192.168.60.9
  User vagrant
  UserKnownHostsFile /dev/null
  StrictHostKeyChecking no
  PasswordAuthentication no
  IdentityFile $(pwd)/modules/01_vagrant_vms/.vagrant/machines/registry/virtualbox/private_key
  IdentitiesOnly yes
  LogLevel FATAL
EOF
)
echo -e "$ssh_config_registry" >> ~/.ssh/config
fi

if ! ssh main03 bash -c "exit"; then
for i in {1..3}; do 
ssh_config_main=$(cat <<EOF
Host main0$i
  HostName 192.168.60.1$i
  User vagrant
  UserKnownHostsFile /dev/null
  StrictHostKeyChecking no
  PasswordAuthentication no
  IdentityFile $(pwd)/modules/01_vagrant_vms/.vagrant/machines/main0$i/virtualbox/private_key
  IdentitiesOnly yes
  LogLevel FATAL
EOF
)
echo -e "$ssh_config_main" >> ~/.ssh/config
done
fi

if ! ssh worker03 bash -c "exit"; then
for i in {1..3}; do 
ssh_config_worker=$(cat <<EOF
Host worker0$i
  HostName 192.168.60.2$i
  User vagrant
  UserKnownHostsFile /dev/null
  StrictHostKeyChecking no
  PasswordAuthentication no
  IdentityFile $(pwd)/modules/01_vagrant_vms/.vagrant/machines/worker0$i/virtualbox/private_key
  IdentitiesOnly yes
  LogLevel FATAL
EOF
)
echo -e "$ssh_config_worker" >> ~/.ssh/config
done
fi

ansible-playbook -i hosts.yml modules/02_networking/converge.yml
ansible-playbook -i hosts.yml modules/03_certs/converge.yml
# copy the created certs folder in  modules/03_certs to modules/04_registry, modules/05_containerd and modules/06_kubernetes
cp -r modules/03_certs/certs modules/04_registry/
cp -r modules/03_certs/certs modules/05_containerd/
cp -r modules/03_certs/certs modules/06_kubernetes/
ansible-playbook -i hosts.yml modules/04_registry/converge.yml
ansible-playbook -i hosts.yml modules/05_containerd/converge.yml
ansible-playbook -i hosts.yml modules/06_kubernetes/converge.yml
ansible-playbook -i hosts.yml modules/07_clusterinit/converge.yml
## fetch `admin.conf` and certificates from `main01` and pushs it to the `adminclient`.
ansible-playbook -i hosts.yml modules/08_post_init.yml

