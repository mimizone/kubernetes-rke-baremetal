
setup of a [rook](https://rook.io/docs/rook/master/) based persistent storage solution on kubernetes.

Rook is made of 2 components:
- Operator: managing and monitoring the cluster
- Cluster: keeping the data (the Ceph MONs and OSDs)

Rook uses ceph under the hood. Ceph is using block devices (or folder) to store the data. In our setup, we will assign specific drives to rook on each node where the cluster runs.

Rook also uses a local folder on each node to persist its configuration (defaulting to `/var/lib/rook`).

# Operator installation

there is an example of configuration [here](https://github.com/mimizone/rook/blob/master/cluster/examples/kubernetes/rook-operator.yaml)

We use the same config (see [rook-operator.yml](./rook-operator.yml))

```
$ kubectl create -f rook-operator.yml
namespace "rook-system" created
clusterrole "rook-operator" created
serviceaccount "rook-operator" created
clusterrolebinding "rook-operator" created
deployment "rook-operator" created
```

# Cluster
in our setup, we need to deploy the cluster only on specific nodes. Also, only specific block devices should be allocated to rook.

For this we can use labels on the nodes, or the affinity/toleration feature of k8s.
In our case, we only use so far an explicit list of nodes in the configuration of the cluster, each with a list of devices that should be used.

```
kubectl create -f rook-cluster.yml
```

# tools

use the rook tools to manage rook.

```
kubectl create -f rook-tools.yml
```

connect to the instance
```
kubectl -n rook exec -it rook-tools bash
```

# Usage example

You first need to create Storage Classes that can be used by Kubernetes pods.

See the example included [here](./rook-storageclass.yml)

```
kubectl create -f rook-storageclass.yml
```

instantiate a simple nginx server using the included configuration [example.yml](./example.yml)
```
kubectl create -f example.yml
```

the following assumes a Load Balancing service is in place in the cluster.
```
kubectl get svc -n 
```

