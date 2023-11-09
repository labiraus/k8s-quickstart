
echo Creating minikube cluster

minikube start --profile custom --extra-config=apiserver.service-node-port-range=1-65535

# Add ingress 
minikube addons enable ingress -p custom

echo Pulling istio into helm repo

# Add istio to helm
helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo update

echo Installing Isto helm chart
# Install istio helm chart
kubectl create namespace istio-system
helm install istio-base istio/base -n istio-system --set defaultRevision=default --wait
helm install istiod istio/istiod -n istio-system --wait