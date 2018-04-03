Installation of Rancher 2.0 server

on any node running docker
```
docker run -d --restart=unless-stopped -p 80:80 -p 443:443 rancher/server:preview
```

TODO: make this a kubernetes manifest, using a persistent volume for the database

I added a specific entry in our local DNS to the IP address of the node hosting the container.

reach the Rancher UI at https://rancher.os

at this time, Rancher 2.0 is still in alpha version. the installation process and the features are being changed weekly, trying also to follow kubernetes evolution at the same time...

There is some issue (or misunderstanding from us because of lack of documentation for now) with the way projects, namespaces and network policies and map with each other. 

It happened that the kube-dns service was not accessible anymore to all the other namespaces but the ones in the same project as the `kube-system` namespace. 

in order to quickly fix this, the following network policy can be used, allowing ingress traffic on UDP port 53 to the pods labelled `app=kube-dns`, and allowing egress to any namespace from those same pods.

```
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-kube-dns-access
  namespace: kube-system
spec:
  podSelector:
    matchLabels:
      k8s-app: kube-dns
  ingress:
  - from:
    - namespaceSelector: {}
  - to:
    ports:
    - protocol: UDP
      port: 53
  egress: 
  - {}
  policyTypes:
  - Egress
  - Ingress
```

Apply this policy as follow
```
kubectl apply -f dns.np.yml
```
