kubectl create configmap embedding-setting-config --from-file=set.yaml
kubectl apply -f  opds-embedding-deploy.yml
kubectl get pods