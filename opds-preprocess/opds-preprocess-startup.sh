kubectl create configmap preprocess-setting-config --from-file=set.yaml
kubectl apply -f  opds-preprocess-deploy.yml
kubectl get pods