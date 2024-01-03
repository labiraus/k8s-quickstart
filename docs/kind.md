# KinD

## Notes

Kind needs to have ingress entrypoints baked in from start. If you install kind with choco then it installs docker desktop with it. It's possible to refuse docker desktop during windows installation and it still work successfully, however the kind cli doesn't work properly if the host is on a different machine.

Kind creates a bare metal cluster and doesn't support LoadBalancers out of the box, unlike Minikube. Instead the (installation script)[setup/kind.sh] sets up MetalLB instead.