
docker@minikube:~$ ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
2: docker0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default
    link/ether 02:42:49:48:06:fe brd ff:ff:ff:ff:ff:ff
    inet 172.17.0.1/16 brd 172.17.255.255 scope global docker0
       valid_lft forever preferred_lft forever
3: bridge: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether e2:f2:a3:06:5a:24 brd ff:ff:ff:ff:ff:ff
    inet 10.244.0.1/16 brd 10.244.255.255 scope global bridge
       valid_lft forever preferred_lft forever
6: veth1cfd3ba3@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master bridge state UP group default
    link/ether 46:fa:24:06:3f:3a brd ff:ff:ff:ff:ff:ff link-netnsid 1
7: vethef9f07ff@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master bridge state UP group default
    link/ether 22:87:75:97:ff:dd brd ff:ff:ff:ff:ff:ff link-netnsid 2
37: eth0@if38: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default
    link/ether 02:42:c0:a8:31:02 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 192.168.49.2/24 brd 192.168.49.255 scope global eth0
       valid_lft forever preferred_lft forever
docker@minikube:~$ ip route
default via 192.168.49.1 dev eth0 
10.244.0.0/16 dev bridge proto kernel scope link src 10.244.0.1 
172.17.0.0/16 dev docker0 proto kernel scope link src 172.17.0.1 linkdown 
192.168.49.0/24 dev eth0 proto kernel scope link src 192.168.49.2 
docker@minikube:~$ cat /etc/resolv.conf
nameserver 192.168.49.1
options ndots:0

docker@minikube:~$ sudo iptables -L -n
Chain INPUT (policy ACCEPT)
target     prot opt source               destination
KUBE-PROXY-FIREWALL  all  --  0.0.0.0/0            0.0.0.0/0            ctstate NEW /* kubernetes load balancer firewall */
KUBE-NODEPORTS  all  --  0.0.0.0/0            0.0.0.0/0            /* kubernetes health check service ports */
KUBE-EXTERNAL-SERVICES  all  --  0.0.0.0/0            0.0.0.0/0            ctstate NEW /* kubernetes externally-visible service portals */
KUBE-FIREWALL  all  --  0.0.0.0/0            0.0.0.0/0

Chain FORWARD (policy ACCEPT)
target     prot opt source               destination
DOCKER-USER  all  --  0.0.0.0/0            0.0.0.0/0
DOCKER-ISOLATION-STAGE-1  all  --  0.0.0.0/0            0.0.0.0/0
ACCEPT     all  --  0.0.0.0/0            0.0.0.0/0            ctstate RELATED,ESTABLISHED
DOCKER     all  --  0.0.0.0/0            0.0.0.0/0
ACCEPT     all  --  0.0.0.0/0            0.0.0.0/0
ACCEPT     all  --  0.0.0.0/0            0.0.0.0/0
KUBE-PROXY-FIREWALL  all  --  0.0.0.0/0            0.0.0.0/0            ctstate NEW /* kubernetes load balancer firewall */
KUBE-FORWARD  all  --  0.0.0.0/0            0.0.0.0/0            /* kubernetes forwarding rules */
KUBE-SERVICES  all  --  0.0.0.0/0            0.0.0.0/0            ctstate NEW /* kubernetes service portals */
KUBE-EXTERNAL-SERVICES  all  --  0.0.0.0/0            0.0.0.0/0            ctstate NEW /* kubernetes externally-visible service portals */

Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination
KUBE-PROXY-FIREWALL  all  --  0.0.0.0/0            0.0.0.0/0            ctstate NEW /* kubernetes load balancer firewall */
KUBE-SERVICES  all  --  0.0.0.0/0            0.0.0.0/0            ctstate NEW /* kubernetes service portals */
KUBE-FIREWALL  all  --  0.0.0.0/0            0.0.0.0/0

Chain DOCKER (1 references)
target     prot opt source               destination

Chain DOCKER-ISOLATION-STAGE-1 (1 references)
target     prot opt source               destination
DOCKER-ISOLATION-STAGE-2  all  --  0.0.0.0/0            0.0.0.0/0
RETURN     all  --  0.0.0.0/0            0.0.0.0/0

Chain DOCKER-ISOLATION-STAGE-2 (1 references)
target     prot opt source               destination
DROP       all  --  0.0.0.0/0            0.0.0.0/0
RETURN     all  --  0.0.0.0/0            0.0.0.0/0

Chain DOCKER-USER (1 references)
target     prot opt source               destination
RETURN     all  --  0.0.0.0/0            0.0.0.0/0

Chain KUBE-EXTERNAL-SERVICES (2 references)
target     prot opt source               destination
REJECT     tcp  --  0.0.0.0/0            127.0.0.1            /* istio-ingress/istio-ingressgateway:status-port has no endpoints */ tcp dpt:15021 reject-with icmp-port-unreachable
REJECT     tcp  --  0.0.0.0/0            0.0.0.0/0            /* istio-ingress/istio-ingressgateway:status-port has no endpoints */ ADDRTYPE match dst-type LOCAL tcp dpt:7084 reject-with icmp-port-unreachable
REJECT     tcp  --  0.0.0.0/0            127.0.0.1            /* istio-ingress/istio-ingressgateway:http2 has no endpoints */ tcp dpt:80 reject-with icmp-port-unreachable
REJECT     tcp  --  0.0.0.0/0            0.0.0.0/0            /* istio-ingress/istio-ingressgateway:http2 has no endpoints */ ADDRTYPE match dst-type LOCAL tcp dpt:63676 reject-with icmp-port-unreachable
REJECT     tcp  --  0.0.0.0/0            127.0.0.1            /* istio-ingress/istio-ingressgateway:https has no endpoints */ tcp dpt:443 reject-with icmp-port-unreachable
REJECT     tcp  --  0.0.0.0/0            0.0.0.0/0            /* istio-ingress/istio-ingressgateway:https has no endpoints */ ADDRTYPE match dst-type LOCAL tcp dpt:7815 reject-with icmp-port-unreachable

Chain KUBE-FIREWALL (2 references)
target     prot opt source               destination
DROP       all  -- !127.0.0.0/8          127.0.0.0/8          /* block incoming localnet connections */ ! ctstate RELATED,ESTABLISHED,DNAT

Chain KUBE-FORWARD (1 references)
target     prot opt source               destination
DROP       all  --  0.0.0.0/0            0.0.0.0/0            ctstate INVALID
ACCEPT     all  --  0.0.0.0/0            0.0.0.0/0            /* kubernetes forwarding rules */ mark match 0x4000/0x4000
ACCEPT     all  --  0.0.0.0/0            0.0.0.0/0            /* kubernetes forwarding conntrack rule */ ctstate RELATED,ESTABLISHED  

Chain KUBE-KUBELET-CANARY (0 references)
target     prot opt source               destination

Chain KUBE-NODEPORTS (1 references)
target     prot opt source               destination
Chain KUBE-SERVICES (2 references)
target     prot opt source               destination
REJECT     tcp  --  0.0.0.0/0            10.97.126.17         /* istio-system/istiod:http-monitoring has no endpoints */ tcp dpt:15014 reject-with icmp-port-unreachable
REJECT     tcp  --  0.0.0.0/0            10.97.126.17         /* istio-system/istiod:grpc-xds has no endpoints */ tcp dpt:15010 reject-with icmp-port-unreachable
REJECT     tcp  --  0.0.0.0/0            10.98.9.255          /* istio-ingress/istio-ingressgateway:status-port has no endpoints */ tcp dpt:15021 reject-with icmp-port-unreachable       
REJECT     tcp  --  0.0.0.0/0            10.98.9.255          /* istio-ingress/istio-ingressgateway:http2 has no endpoints */ tcp dpt:80 reject-with icmp-port-unreachable
REJECT     tcp  --  0.0.0.0/0            10.98.9.255          /* istio-ingress/istio-ingressgateway:https has no endpoints */ tcp dpt:443 reject-with icmp-port-unreachable
REJECT     tcp  --  0.0.0.0/0            10.97.126.17         /* istio-system/istiod:https-dns has no endpoints */ tcp dpt:15012 reject-with icmp-port-unreachable
REJECT     tcp  --  0.0.0.0/0            10.97.126.17         /* istio-system/istiod:https-webhook has no endpoints */ tcp dpt:443 reject-with icmp-port-unreachable
docker@minikube:~$
