kind delete cluster --name bitops

kind create cluster --config kind.yaml

kubectl cluster-info --context kind-bitops

# NGINX Ingress installation might differ for your k8s provider
kubectl apply \
    -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/kind/deploy.yaml

kubectl -n ingress-nginx rollout status deployment.apps/ingress-nginx-controller

# If not using kind, replace `127.0.0.1` with the base host accessible through NGINX Ingress
export INGRESS_HOST=127.0.0.1

kubectl create namespace argocd
kubectl apply \
    -n argocd \
    -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

kubectl -n argocd rollout status all

echo "\nAPPLYING INGRESS *********************\n"

kubectl apply \
    -f ingress-argocd.yaml

sleep 20

export PASS=$(kubectl \
    --namespace argocd \
    get secret argocd-initial-admin-secret \
    --output jsonpath="{.data.password}" \
    | base64 --decode)

argocd login \
    --insecure \
    --username admin \
    --password $PASS \
    --grpc-web \
    argocd.$INGRESS_HOST.nip.io

argocd account update-password \
    --current-password $PASS \
    --new-password admin123

echo http://argocd.$INGRESS_HOST.nip.io