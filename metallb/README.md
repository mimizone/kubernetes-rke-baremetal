Bare metal Kubernetes clusters don't come out of the box with the equivalent of a load balancing service as on the different cloud providers options.

The following is a setup to run [metallb](https://metallb.universe.tf) (in alpha stage at this time) to provide this service to our local cluster.


The configuration we selected uses ARP to advertise the IP of the load balancer on the network and make it reachable. A [dedicated IP range](https://docs.google.com/spreadsheets/d/1KEX9sll5avzTkKU9lfxZXBKZamJ9a6CsMqbMrPiWkAE/edit?usp=sharing) has been allocated to metallb. It is configured in the associated `ConfigMap`.


Because we use layer 2 ARP mechanism for advertisement, the metallb `speaker` nodes must be in the L2 network broadcast domain corresponding to the configuration in the ConfigMap. In our case, we make sure the speaker nodes are created only on the Kubernetes nodes with a specific label `vlan="50"`. Make sure the nodes are label accordingly in the cluster.
For this we added a nodeSelector in the definition of the speaker DaemonSet.
```
    spec:
      serviceAccountName: speaker
      terminationGracePeriodSeconds: 0
      hostNetwork: true
      nodeSelector:
        vlan: "50"
      containers:
      - name: speaker
        image: metallb/speaker:v0.4.6
```


# Installation of metallb

install all the necessary components (controller, speakers, roles etc...)
```
kubectl create -f metallb.yml
```

this puts everything in the namespace `metal-system`.

then you need to apply a configuration vi a `ConfigMap`.
```
kubectl apply -f configmap.yml
```

the [configmap](./configmap.yml) allocates a network slice and makes sure that the righ broadcast domain is used.

# Usage example

the included example [simplehttp.yml](./simplehttp.yml) creates a StatefulSet of nginx servers with a Load Balancer in front.
The nginx server returns a simple Hello message including the name of the container.

install the example
```
kubectl create -f simplehttp.yml
```

check the allocated IP
```
$ kubectl get svc nginx -n metal-test
NAME      TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
nginx     LoadBalancer   10.233.41.110   172.30.1.96   80:32283/TCP   35m
```

connect to the service on the `External-IP`
```
$ curl http://172.30.1.96
Hello from a container http-2%
$ curl http://172.30.1.96
Hello from a container http-1%
$ curl http://172.30.1.96
Hello from a container http-0%