
# dirty brutal way of cleaning up behind RKE

# stop all containers and remove all images
# remove rook metadata
for h in `cat hosts`; do echo $h; ssh platform@$h "sudo rm -rf /var/lib/rook; docker ps -qa| xargs docker stop; docker ps -qa | xargs docker rm; docker images -q | xargs docker rmi"; done

# cleanup iptables...
for h in `cat hosts`; do echo $h; ssh platform@$h "sudo iptables-save | grep -v KUBE- | grep -v 10.233.64 | sudo iptables-restore"; done