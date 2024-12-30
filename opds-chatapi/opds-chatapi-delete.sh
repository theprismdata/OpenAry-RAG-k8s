kubectl delete configmap chatapi-setting-config
kubectl delete -f opds-chatapi-deploy.yml
kubectl delete -f opds-chatapi-svc.yml
kubectl get pods
