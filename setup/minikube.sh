minikube start \
    --extra-config=apiserver.service-node-port-range=1-65535 \
    --memory=8g \
    --cpus=4 \
    --disk-size=50g 
minikube addons enable metrics-server
minikube addons enable dashboard
minikube addons enable registry
kubectl create namespace istio-ingress
minikube tunnel -c