kind delete cluster

docker context use default

cat <<EOF | kind create cluster --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
EOF

echo -e "\e[34mAdding MetalLB\e[0m"
helm repo add metallb https://metallb.github.io/metallb
helm repo update
kubectl create namespace istio-ingress
helm install metallb metallb/metallb -n istio-ingress --wait

helm repo add metallb https://metallb.github.io/metallb
helm install metallb metallb/metallb


cat <<EOF | kubectl apply -f-
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: istio-ingress
  name: metallb-config
data:
  config: |
    address-pools:
    - name: default
      protocol: layer2
      addresses:
      - 172.17.1.0/24
EOF
