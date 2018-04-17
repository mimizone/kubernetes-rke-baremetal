
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

then use the ceph client for managing ceph
```
root@rook-tools:/# ceph status
  cluster:
    id:     43d42860-5783-4bfd-aa5e-463b4ab4d866
    health: HEALTH_OK

  services:
    mon: 3 daemons, quorum rook-ceph-mon1,rook-ceph-mon2,rook-ceph-mon0
    mgr: rook-ceph-mgr0(active)
    osd: 40 osds: 40 up, 40 in

  data:
    pools:   0 pools, 0 pgs
    objects: 0 objects, 0 bytes
    usage:   840 GB used, 35558 GB / 36399 GB avail
    pgs:

```

```
root@rook-tools:/# ceph osd status
+----+-----------------------------------+-------+-------+--------+---------+--------+---------+-----------+
| id |                host               |  used | avail | wr ops | wr data | rd ops | rd data |   state   |
+----+-----------------------------------+-------+-------+--------+---------+--------+---------+-----------+
| 0  | rook-ceph-osd-osv7smi14a.os-hwxzm | 21.0G |  909G |    0   |     0   |    0   |     0   | exists,up |
| 1  | rook-ceph-osd-osv7smi14a.os-hwxzm | 21.0G |  909G |    0   |     0   |    0   |     0   | exists,up |
| 2  | rook-ceph-osd-osv7smi14a.os-hwxzm | 21.0G |  909G |    0   |     0   |    0   |     0   | exists,up |
| 3  | rook-ceph-osd-osv7smi14a.os-hwxzm | 21.0G |  909G |    0   |     0   |    0   |     0   | exists,up |
| 4  | rook-ceph-osd-osv7smi14a.os-hwxzm | 21.0G |  909G |    0   |     0   |    0   |     0   | exists,up |
| 5  | rook-ceph-osd-osv7smi14b.os-nfkmw | 21.0G |  909G |    0   |     0   |    0   |     0   | exists,up |
| 6  | rook-ceph-osd-osv7smi14b.os-nfkmw | 21.0G |  909G |    0   |     0   |    0   |     0   | exists,up |
| 7  | rook-ceph-osd-osv7smi14b.os-nfkmw | 21.0G |  909G |    0   |     0   |    0   |     0   | exists,up |
| 8  | rook-ceph-osd-osv7smi14b.os-nfkmw | 21.0G |  909G |    0   |     0   |    0   |     0   | exists,up |
| 9  | rook-ceph-osd-osv7smi14b.os-nfkmw | 21.0G |  909G |    0   |     0   |    0   |     0   | exists,up |
| 10 | rook-ceph-osd-osv7smi14c.os-2b2zb | 21.0G |  909G |    0   |     0   |    0   |     0   | exists,up |
| 11 | rook-ceph-osd-osv7smi14c.os-2b2zb | 21.0G |  909G |    0   |     0   |    0   |     0   | exists,up |
| 12 | rook-ceph-osd-osv7smi14c.os-2b2zb | 21.0G |  909G |    0   |     0   |    0   |     0   | exists,up |
| 13 | rook-ceph-osd-osv7smi14c.os-2b2zb | 21.0G |  909G |    0   |     0   |    0   |     0   | exists,up |
| 14 | rook-ceph-osd-osv7smi14c.os-2b2zb | 21.0G |  909G |    0   |     0   |    0   |     0   | exists,up |
| 15 | rook-ceph-osd-osv7smi14d.os-bwwgl | 21.0G |  909G |    0   |     0   |    0   |     0   | exists,up |
| 16 | rook-ceph-osd-osv7smi14d.os-bwwgl | 21.0G |  909G |    0   |     0   |    0   |     0   | exists,up |
| 17 | rook-ceph-osd-osv7smi14d.os-bwwgl | 21.0G |  909G |    0   |     0   |    0   |     0   | exists,up |
| 18 | rook-ceph-osd-osv7smi14d.os-bwwgl | 21.0G |  909G |    0   |     0   |    0   |     0   | exists,up |
| 19 | rook-ceph-osd-osv7smi14d.os-bwwgl | 21.0G |  909G |    0   |     0   |    0   |     0   | exists,up |
| 20 | rook-ceph-osd-osv7smi16a.os-2b2x6 | 21.0G |  909G |    0   |     0   |    0   |     0   | exists,up |
| 21 | rook-ceph-osd-osv7smi16a.os-2b2x6 | 21.0G |  909G |    0   |     0   |    0   |     0   | exists,up |
| 22 | rook-ceph-osd-osv7smi16a.os-2b2x6 | 21.0G |  909G |    0   |     0   |    0   |     0   | exists,up |
| 23 | rook-ceph-osd-osv7smi16a.os-2b2x6 | 21.0G |  909G |    0   |     0   |    0   |     0   | exists,up |
| 24 | rook-ceph-osd-osv7smi16a.os-2b2x6 | 21.0G |  909G |    0   |     0   |    0   |     0   | exists,up |
| 25 | rook-ceph-osd-osv7smi16c.os-zkclk | 21.0G | 71.5G |    0   |     0   |    0   |     0   | exists,up |
| 26 | rook-ceph-osd-osv7smi16c.os-zkclk | 21.0G |  909G |    0   |     0   |    0   |     0   | exists,up |
| 27 | rook-ceph-osd-osv7smi16c.os-zkclk | 21.0G |  909G |    0   |     0   |    0   |     0   | exists,up |
| 28 | rook-ceph-osd-osv7smi16c.os-zkclk | 21.0G |  909G |    0   |     0   |    0   |     0   | exists,up |
| 29 | rook-ceph-osd-osv7smi16c.os-zkclk | 21.0G |  909G |    0   |     0   |    0   |     0   | exists,up |
| 30 | rook-ceph-osd-osv7smi18c.os-zr8kg | 21.0G |  909G |    0   |     0   |    0   |     0   | exists,up |
| 31 | rook-ceph-osd-osv7smi18c.os-zr8kg | 21.0G |  909G |    0   |     0   |    0   |     0   | exists,up |
| 32 | rook-ceph-osd-osv7smi18c.os-zr8kg | 21.0G |  909G |    0   |     0   |    0   |     0   | exists,up |
| 33 | rook-ceph-osd-osv7smi18c.os-zr8kg | 21.0G |  909G |    0   |     0   |    0   |     0   | exists,up |
| 34 | rook-ceph-osd-osv7smi18c.os-zr8kg | 21.0G |  909G |    0   |     0   |    0   |     0   | exists,up |
| 35 | rook-ceph-osd-osv7smi20c.os-qf7wz | 21.0G |  909G |    0   |     0   |    0   |     0   | exists,up |
| 36 | rook-ceph-osd-osv7smi20c.os-qf7wz | 21.0G |  909G |    0   |     0   |    0   |     0   | exists,up |
| 37 | rook-ceph-osd-osv7smi20c.os-qf7wz | 21.0G |  909G |    0   |     0   |    0   |     0   | exists,up |
| 38 | rook-ceph-osd-osv7smi20c.os-qf7wz | 21.0G |  909G |    0   |     0   |    0   |     0   | exists,up |
| 39 | rook-ceph-osd-osv7smi20c.os-qf7wz | 21.0G |  909G |    0   |     0   |    0   |     0   | exists,up |
+----+-----------------------------------+-------+-------+--------+---------+--------+---------+-----------+
```

watch events in the cpeh cluster as they go
```
root@rook-tools:/# ceph -w
  cluster:
    id:     43d42860-5783-4bfd-aa5e-463b4ab4d866
    health: HEALTH_WARN
            noscrub,nodeep-scrub flag(s) set

  services:
    mon: 3 daemons, quorum rook-ceph-mon1,rook-ceph-mon2,rook-ceph-mon0
    mgr: rook-ceph-mgr0(active)
    osd: 25 osds: 22 up, 22 in
         flags noscrub,nodeep-scrub

  data:
    pools:   0 pools, 0 pgs
    objects: 0 objects, 0 bytes
    usage:   462 GB used, 20018 GB / 20480 GB avail
    pgs:


2018-03-30 00:23:20.614628 mon.rook-ceph-mon1 [INF] osd.21 10.233.66.40:6804/606 boot
2018-03-30 00:23:34.808480 mon.rook-ceph-mon1 [INF] osd.22 10.233.66.40:6808/833 boot
2018-03-30 00:23:48.769462 mon.rook-ceph-mon1 [INF] osd.23 10.233.66.40:6812/1060 boot
```

state of distributed file system
```
root@rook-tools:/# ceph df
GLOBAL:
    SIZE       AVAIL      RAW USED     %RAW USED
    36399G     35558G         840G          2.31
POOLS:
    NAME     ID     USED     %USED     MAX AVAIL     OBJECTS
```

health of the cluster
```
root@rook-tools:/# ceph health
HEALTH_WARN noscrub,nodeep-scrub flag(s) set
```

distributed file system via Rados
```
root@rook-tools:/# rados df
POOL_NAME USED OBJECTS CLONES COPIES MISSING_ON_PRIMARY UNFOUND DEGRADED RD_OPS RD WR_OPS WR

total_objects    0
total_used       840G
total_avail      35558G
total_space      36399G
```

once you have created a pool via kubernetes storage classes for instance, you may need to change the number of Placement groups for performance optimization. Placement Group number can only be increase, never decreased. It is also a power of 2 number.

```
ceph osd pool set POOLNAME pg_num 1024
```
then once it is done (it may take a lot of time if the pool has data or it's instantaneous if empty), you need to change the Placement Group for Placement (PGP) to actually use those Placement groups.
```
ceph osd pool set POOLNAME pgp_num 1024
```

# Persistent storage example

You first need to create Storage Classes (done by an admin of the cluster) that can be used by Kubernetes pods.

See the example included [here](./rook-storageclass.yml)

```
kubectl create -f rook-storageclass.yml
```

## Deployment
instantiate a simple nginx server using the included configuration [example-deployment.yml](./example-deployment.yml)
```
kubectl create -f example-deployment.yml
```

the following assumes a Load Balancing service is in place in the cluster.
```
kubectl get svc -n 
```

## Statefulset
instantiate a statefulset that uses volumeclaims
[example-simplehttpset.yml](./example-simplehttpset.yml)
```
kubectl create -f example-simplehttpset.yml
```
