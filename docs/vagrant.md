# vagrant

## private network

Vagrant can not disable the default nat interface.
When an additional interface created, eg. to use for a private network,
there are actually two interfaces

* the default nat interface
* the network interface for the private network

This is by design for vagrant to have an interface to connect to.

also see [this question from stackoverflow](https://stackoverflow.com/questions/35208188/how-can-i-define-network-settings-with-vagrant/35211086#35211086)

## `virtualbox__intnet`

When playing around with vagrant I came across `virtualbox__intnet`.
(also see [vagrant/virtualbox-internal-network](https://www.vagrantup.com/docs/providers/virtualbox/networking#virtualbox-internal-network)).

```ruby
if (host_config.has_key? "intnet")
    machine.vm.network "private_network", ip: host_config['intnet']['ip'], virtualbox__intnet: true
    machine.vm.network "private_network", ip: host_config['intnet']['ip']
end
```

Turns out without `virtualbox__intnet: true` vagrant and virtualbox does not create an ip route for the private network:

    192.168.1.0/24 dev vboxnet0 proto kernel scope link src 192.168.1.1 

also witness that there is a new interface:

    4: vboxnet0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP mode DEFAULT group default qlen 1000
        link/ether 0a:00:27:00:00:00 brd ff:ff:ff:ff:ff:ff

## disconnect network interfaces with `VBoxManage`

```bash
VBoxManage list vms
cd vagrant-ansiblified
vagrant halt
VBoxManage modifyvm masternode --cableconnected1 off
VBoxManage modifyvm masternode --cableconnected2 on
VBoxManage modifyvm workerone --cableconnected1 off
VBoxManage modifyvm workerone --cableconnected2 on
VBoxManage modifyvm registry --cableconnected1 on
VBoxManage modifyvm registry --cableconnected2 on
```