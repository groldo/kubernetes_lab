# vagrant_vms

Builds VMs with vagrant for lab deployment

## Requirements

### Hardware 

* 12 GB of RAM = 2 GB per machine(3 kubernetes master, 2 worker, 1 container registry)

### Software

* vagrant
* virtualbox

## ssh config

```bash
vagrant ssh-config 2>/dev/null >> ~/.ssh/config
ansible -m ping -i inventory/hosts.yml kubernetes
```
