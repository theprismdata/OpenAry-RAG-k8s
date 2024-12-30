kubectl create configmap summary-setting-config --from-file=set.yaml
kubectl apply -f  opds-summary-deploy.yml
kubectl get pods