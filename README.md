# RKE based setup of kubernetes on bare metal

below are notes on how to setup a kubernetes cluster on bare metal using the rancher/rke installer.

Subfolders explain how to set up [metallb load balancer](./metallb/) and [Rook persistent storage](./rook/)


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

install the nfs client
```
sudo apt install -y nfs-common
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


## note on docker version and NVidia GPU support

Docker version 17.12.1 introduced a bug (see https://github.com/rancher/rancher/issues/11897) which blocks from installing kubernetes with RKE (and others).

nvidia-container-runtime requires by default that docker version at the time of writing this note (or 18.03). The docker-ce version has to be downgraded manually, but because nvidia docker runtime defines a dependency on it, the complete installation has to be done manually one by one.

Remove the all versions of docker and make sure to install 17.03 (as supported by kubernetes and rancher) as explained previously.

### install the CUDA libraries

find the right version available in this folder
https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64/

here's an example for version `9.1.85-1`
```
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64/cuda-repo-ubuntu1604_9.1.85-1_amd64.deb
```

it should spill out the next command to add the repository key.
for example
```
sudo apt-key adv --fetch-keys http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64/7fa2af80.pub
```

install cuda
```
sudo apt-get update
sudo apt-get install -y --no-install-recommends cuda
```

then add the respective repositories from nvidia docker related things.

### nvidia-container-runtime repository

```
curl -s -L https://nvidia.github.io/nvidia-container-runtime/gpgkey | \
  sudo apt-key add -
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-container-runtime/$distribution/nvidia-container-runtime.list | \
  sudo tee /etc/apt/sources.list.d/nvidia-container-runtime.list
sudo apt-get update
```

### nvidia-docker repository

```
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | \
  sudo apt-key add -
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | \
  sudo tee /etc/apt/sources.list.d/nvidia-docker.list
sudo apt-get update
```

then install the specific version of `nvidia-container-runtime` and `nvidia-docker2`
```
sudo apt install -y nvidia-container-runtime=2.0.0+docker17.03.2-1 
sudo apt install -y nvidia-docker2=2.0.3+docker17.03.2-1
```

### set nvidia-container-runtime as default

register the nvidia runtime by making the nvidia-container-runtime the default by putting in the `/etc/docker/daemon.json` file the following
```
{
    "default-runtime": "nvidia",
    "runtimes": {
        "nvidia": {
            "path": "/usr/bin/nvidia-container-runtime",
            "runtimeArgs": []
        }
    }
}
```

on some system, you may need to do it this way, by configuring systemd instead

```
sudo mkdir -p /etc/systemd/system/docker.service.d
sudo tee /etc/systemd/system/docker.service.d/override.conf <<EOF
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd --host=fd:// --add-runtime=nvidia=/usr/bin/nvidia-container-runtime
EOF
sudo systemctl daemon-reload
sudo systemctl restart docker
```

### configure nvidia-container-runtime

additional configuration can be done via Enviroment Variable of the container images. (ex:select which GPUs will be made available). The official NVidia CUDA image already defines all those variables.

see
https://github.com/nvidia/nvidia-container-runtime#environment-variables-oci-spec


A useful setup is to automatically add the path to the nvidia driver libraries in the LD_LIBRARY_PATH used by the nvidia-container-runtime. That will allow the users to not have to worry about mounting the right path/files in their kubernetes manifests.

edit `/etc/nvidia-container-runtime/config.toml` to set LD_LIBRARY_PATH in the environment variable.
For example, for the `nvidia-390` drivers.

```
$ cat /etc/nvidia-container-runtime/config.toml
disable-require = false
#swarm-resource = "DOCKER_RESOURCE_GPU"

[nvidia-container-cli]
#root = "/run/nvidia/driver"
#path = "/usr/bin/nvidia-container-cli"
environment = ["LD_LIBRARY_PATH=/usr/lib/nvidia-390"]
#debug = "/var/log/nvidia-container-runtime-hook.log"
#ldcache = "/etc/ld.so.cache"
load-kmods = true
ldconfig = "@/sbin/ldconfig.real"
```

### restart docker

restart the docker daemon
```
sudo systemctl daemon-reload
sudo systemctl restart docker
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

see the one actually used for our setup. [cluster.yml](./cluster.yml)

## installation of kubernetes

once the cluster.yml is configured, start the installation
```
bin/rke up --config ./cluster.yml
```

wait a few minutes for it to complete.

use the generated kube config file in the same folder as the cluster.yml file, to connect to the cluster with kubectl.

## finalize GPU support

the NVidia device plugin has to be installed in the cluster
```
# For Kubernetes v1.10
kubectl create -f https://raw.githubusercontent.com/NVIDIA/k8s-device-plugin/v1.10/nvidia-device-plugin.yml
```

check the node is reporting gpus
```
kubectl describe node kouda.os | grep gpu
```


