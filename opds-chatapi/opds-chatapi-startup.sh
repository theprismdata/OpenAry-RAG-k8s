kubectl create configmap chatapi-setting-config --from-file=set.yaml
kubectl apply -f  opds-chatapi-deploy.yml
kubectl apply -f  opds-chatapi-svc.yml
kubectl get pods
kubectl get svc