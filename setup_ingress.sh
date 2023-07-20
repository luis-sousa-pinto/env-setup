kubectl cluster-info --context kind-bitops

echo "\nAPPLYING INGRESS *********************\n"

kubectl apply \
    -f ingress-argocd.yaml

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