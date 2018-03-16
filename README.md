# RKE based setup of kubernetes on bare metal

notes on how to setup a kubernetes cluster on bare metal using the rancher/rke installer.


# prepare the servers

## installation of ubuntu 16.04

at the time of writing, the method is to pxe boot the server in [grml](../grml/) and rsync the filesystem of a vanilla ubuntu 16.04 

you can follow the procedure detailed [here](../grml)

once ubuntu is installed

log in as the `platform` user
```
ssh -lplatform 172.30.1.xxx

```

update everything
```
sudo apt update
sudo apt upgrade -y
```

configure the hostname
```
sudo hostname THE_HOSTNAME
sudo echo THE_HOSTNAME > /etc/hostname
```


## installation of docker (specific version 17.03)

install docker version 17.03.2 (supported version by rancher and kubernetes at this time).

using another version typiclaly works though but may require additional configuration in RKE.

the following steps are based on the documentation at https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-16-04


```
#GPG key of docker repository
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

#add the repository
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

#update
sudo apt update

#list the versions available
sudo apt-cache policy docker-ce

sudo apt install -y docker-ce=17.03.2~ce-0~ubuntu-xenial

```

if docker is already installed somehow, use the following to clean up and reinstall
```
sudo systemctl stop docker
sudo apt-get autoremove -y docker-ce
sudo apt-get purge docker-ce -y
sudo rm -rf /etc/docker/
sudo rm -f /etc/systemd/system/multi-user.target.wants/docker.service
sudo rm -rf /var/lib/docker
sudo systemctl daemon-reload

sudo apt install -y docker-ce=17.03.2~ce-0~ubuntu-xenial

```

add the platform user to the docker group
```
sudo usermod -aG docker ${USER}
```


## installation of Rancher RKE

on one of the servers (ex: one of the master nodes), clone the github repository of RKE and compile it.
the `make` package is required.


```
cd ~
git clone https://github.com/rancher/rke.git
cd rke
sudo apt install make
make
```

### ssh configuration

the node that will run the RKE installer needs to be able to ssh to all the nodes part of the cluster.

generate an ssh key on the RKE node and copy the public key to all the nodes `~/.ssh/authorized_keys`

```
ssh-keygen -t rsa -b 4096 -q -P '' -f $HOME/.ssh/id_rsa
```


### configuration of RKE

the main configuration file of RKE is `cluster.yml`

the version of kubernetes, the parameters of the kubelet and the list of additional addons to installed can be specified in this file, as well as the role of the different servers in the cluster. Nodes can be part of the control plane, the etcd database and the workers. 





