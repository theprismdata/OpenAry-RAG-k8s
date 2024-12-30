## helm으로 nginx ingress controller 설치
## Short sequence
```bash
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
실행 (bash로 실행)
./get_helm.sh
```
```
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm search repo nginx
```
```commandline
cd ~opds_k8s/nginx-ingress-controller
kubectl create namespace mynginx
kubectl get namespace

helm install --namespace mynginx --generate-name bitnami/nginx-ingress-controller -f values.yaml
helm ls --namespace mynginx
kubectl get all --namespace mynginx
helm repo add metallb https://metallb.github.io/metallb
helm search repo metallb
```
```commandline
cd  ~opds_k8s/metallb/
kubectl create namespace mymetallb
helm install --namespace mymetallb --generate-name metallb/metallb -f values.yaml
kubectl get all --namespace mymetallb
kubectl apply -f metallb-config.yaml
kubectl get ipaddresspool.metallb.io --namespace mymetallb
kubectl describe ipaddresspool.metallb.io my-metallb-config --namespace mymetallb
kubectl get all --namespace mynginx
```

## Long Detail sequence
### step1. helm chart 설치
```
helm repo add bitnami https://charts.bitnami.com/bitnami
```

local repository update
```
helm repo update
```

### step2 . helm을 이용한 nginx ingress controller 설치
nginx 검색
```
helm search repo nginx
```
```
NAME                                    CHART VERSION   APP VERSION     DESCRIPTION
bitnami/nginx                           18.2.3          1.27.2          NGINX Open Source is a web server that can be a...
bitnami/nginx-ingress-controller        11.4.4          1.11.3          NGINX Ingress Controller is an Ingress controll...
bitnami/nginx-intel                     2.1.15          0.4.9           DEPRECATED NGINX Open Source for Intel is a lig...
```
```
helm pull bitnami/nginx-ingress-controller
tar xvfz nginx-ingress-controller-11.4.4.tgz
cd nginx-ingress-controller
```

### step3. namespace 생성, nginx ingress controller 설치

kubectl create namespace mynginx

kubectl get namespace
```
NAME              STATUS   AGE
default           Active   24m
kube-node-lease   Active   24m
kube-public       Active   24m
kube-system       Active   24m
mynginx           Active   77s
```
helm install --namespace mynginx --generate-name bitnami/nginx-ingress-controller -f values.yaml

- Response
    
    ```
    NAME: nginx-ingress-controller-1728983093
    LAST DEPLOYED: Tue Oct 15 18:04:55 2024
    #namespace: mynginx
    STATUS: deployed
    REVISION: 1
    TEST SUITE: None
    NOTES:
    CHART NAME: nginx-ingress-controller
    CHART VERSION: 11.4.4
    APP VERSION: 1.11.3
    
    ** Please be patient while the chart is being deployed **
    
    The nginx-ingress controller has been installed.
    
    Get the application URL by running these commands:
    
     NOTE: It may take a few minutes for the LoadBalancer IP to be available.
            You can watch its status by running 'kubectl get --#namespace mynginx svc -w nginx-ingress-controller-1728983093'
    
        export SERVICE_IP=$(kubectl get svc --#namespace mynginx nginx-ingress-controller-1728983093 -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
        echo "Visit http://${SERVICE_IP} to access your application via HTTP."
        echo "Visit https://${SERVICE_IP} to access your application via HTTPS."
    
    An example Ingress that makes use of the controller:
    
      apiVersion: networking.k8s.io/v1
      kind: Ingress
      metadata:
        name: example
        #namespace: mynginx
      spec:
        ingressClassName: nginx
        rules:
          - host: www.example.com
            http:
              paths:
                - backend:
                    service:
                      name: example-service
                      port:
                        number: 80
                  path: /
                  pathType: Prefix
        # This section is only required if TLS is to be enabled for the Ingress
        tls:
            - hosts:
                - www.example.com
              secretName: example-tls
    
    If TLS is enabled for the Ingress, a Secret containing the certificate and key must also be provided:
    
      apiVersion: v1
      kind: Secret
      metadata:
        name: example-tls
        #namespace: mynginx
      data:
        tls.crt: <base64 encoded cert>
        tls.key: <base64 encoded key>
      type: kubernetes.io/tls
    
    WARNING: There are "resources" sections in the chart not set. Using "resourcesPreset" is not recommended for production. For production installations, please set the following values according to your workload needs:
      - defaultBackend.resources
      - resources
    +info https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/
    ```
    
```
helm ls --namespace mynginx
```

```
NAME                                    #namespace       REVISION        UPDATED                                 STATUS          CHART                           APP VERSION
nginx-ingress-controller-1728983093     mynginx**         1               2024-10-15 18:04:55.0453453 +0900 KST   deployed        nginx-ingress-controller-11.4.4 1.11.3
```

```
kubectl.exe get all
```

```
NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   9m33s
```

```
kubectl.exe get all --namespace mynginx
```

```
NAME                                                                  READY   STATUS    RESTARTS   AGE
pod/nginx-ingress-controller-1729402641-7dbd564fdb-8pr8f              1/1     Running   0          2m4s
pod/nginx-ingress-controller-1729402641-default-backend-57c7c6qv8cf   1/1     Running   0          2m4s

NAME                                                          TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)
         AGE
service/nginx-ingress-controller-1729402641                   LoadBalancer   10.101.247.125   localhost     80:31465/TCP,443:32024/TCP   2m5s
service/nginx-ingress-controller-1729402641-default-backend   ClusterIP      10.106.10.9      <none>        80/TCP
         2m5s

NAME                                                                  READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/nginx-ingress-controller-1729402641                   1/1     1            1           2m5s
deployment.apps/nginx-ingress-controller-1729402641-default-backend   1/1     1            1           2m5s

NAME                                                                            DESIRED   CURRENT   READY   AGE
replicaset.apps/nginx-ingress-controller-1729402641-7dbd564fdb                  1         1         1       2m4s
replicaset.apps/nginx-ingress-controller-1729402641-default-backend-57c7c6ddb   1         1         1       2m4s
```


### step4. metallb 설치
#### 가. metallb 저장소 추가
```
helm repo add metallb https://metallb.github.io/metallb
```
#### 나. metallb 조회 및 다운로드
```
helm search repo metallb
```

```
NAME            CHART VERSION   APP VERSION     DESCRIPTION
bitnami/metallb 6.3.13          0.14.8          MetalLB is a load-balancer implementation for b...
metallb/metallb 0.14.8          v0.14.8         A network load-balancer implementation for Kube...

shell>helm pull metallb/metallb
shell>cd metallb
```

```
helm pull metallb/metallb
cd metallb
```
#### 다. metallb 네임스페이스 생성
```
kubectl create namespace mymetallb
```
#### 라. helm을 이용한 metallb 설치
```
helm install --namespace mymetallb --generate-name metallb/metallb -f values.yaml
```
```
NAME: metallb-1728985245
LAST DEPLOYED: Tue Oct 15 18:40:47 2024
namespace: mymetallb
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
MetalLB is now running in the cluster.

Now you can configure it via its CRs. Please refer to the metallb official docs
on how to use the CRs.
```

```
kubectl get all --namespace mymetallb
```

```

NAME                                                 READY   STATUS    RESTARTS   AGE
pod/metallb-1728985245-controller-6b567cbf78-9vlw6   1/1     Running   0          80s
pod/metallb-1728985245-speaker-8jn44                 4/4     Running   0          80s

NAME                              TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
service/metallb-webhook-service   ClusterIP   10.43.60.244   <none>        443/TCP   80s

NAME                                        DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
daemonset.apps/metallb-1728985245-speaker   1         1         1       1            1           kubernetes.io/os=linux   80s

NAME                                            READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/metallb-1728985245-controller   1/1     1            1           80s

NAME                                                       DESIRED   CURRENT   READY   AGE
replicaset.apps/metallb-1728985245-controller-6b567cbf78   1         1         1       80s
```

### 마. IP Pool 설정

```
metallb-config.yaml
---
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: my-metallb-config
  #namespace: mymetallb
spec:
  addresses:
  - 192.168.50.110-192.168.50.120
  autoAssign: true
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: my-metallb-config
  #namespace: mymetallb
spec:
  ipAddressPools:
    - my-metallb-config
```

```
IP 설정 적용
kubectl apply -f metallb-config.yaml #시간이 몇초 좀 걸릴 수 있음
```

```
ipaddresspool.metallb.io/my-metallb-config created
l2advertisement.metallb.io/my-metallb-config created
```

```
kubectl get ipaddresspool.metallb.io --namespace mymetallb
```

```
NAME                AUTO ASSIGN   AVOID BUGGY IPS   ADDRESSES
my-metallb-config   true          false             ["192.168.50.110-192.168.50.120"]
```

```
kubectl describe ipaddresspool.metallb.io my-metallb-config --namespace mymetallb
```

```
Name:         my-metallb-config
namespace:    mymetallb
Labels:       <none>
Annotations:  <none>
API Version:  metallb.io/v1beta1
Kind:         IPAddressPool
Metadata:
  Creation Timestamp:  2024-10-15T09:49:26Z
  Generation:          1
  Resource Version:    2583
  UID:                 45cd24cd-8854-4ff4-b808-cb7de603b5d5
Spec:
  Addresses:
    192.168.50.110-192.168.50.120
  Auto Assign:       true
  Avoid Buggy I Ps:  false
Events:              <none>
```

```
kubectl get all --namespace mynginx
```

```
NAME                                                                  READY   STATUS    RESTARTS   AGE
pod/nginx-ingress-controller-1729402641-7dbd564fdb-8pr8f              1/1     Running   0          11m
pod/nginx-ingress-controller-1729402641-default-backend-57c7c6qv8cf   1/1     Running   0          11m

NAME                                                          TYPE           CLUSTER-IP       EXTERNAL-IP      PORT(S)                      AGE
service/nginx-ingress-controller-1729402641                   LoadBalancer   10.101.247.125   192.168.50.110   80:31465/TCP,443:32024/TCP   11m
service/nginx-ingress-controller-1729402641-default-backend   ClusterIP      10.106.10.9      <none>           80/TCP                       11m

NAME                                                                  READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/nginx-ingress-controller-1729402641                   1/1     1            1           11m
deployment.apps/nginx-ingress-controller-1729402641-default-backend   1/1     1            1           11m

NAME                                                                            DESIRED   CURRENT   READY   AGE
replicaset.apps/nginx-ingress-controller-1729402641-7dbd564fdb                  1         1         1       11m
replicaset.apps/nginx-ingress-controller-1729402641-default-backend-57c7c6ddb   1         1         1       11m
```

```
kubectl describe service/nginx-ingress-controller-1729402641 --namespace mynginx
```

```
Name:                     nginx-ingress-controller-1729402641
#namespace:                mynginx
Labels:                   app.kubernetes.io/component=controller
                          app.kubernetes.io/instance=nginx-ingress-controller-1729402641
                          app.kubernetes.io/managed-by=Helm
                          app.kubernetes.io/name=nginx-ingress-controller
                          app.kubernetes.io/version=1.11.3
                          helm.sh/chart=nginx-ingress-controller-11.4.4
Annotations:              meta.helm.sh/release-name: nginx-ingress-controller-1729402641
                          meta.helm.sh/release-#namespace: mynginx
                          metallb.universe.tf/ip-allocated-from-pool: my-metallb-config
Selector:                 app.kubernetes.io/component=controller,app.kubernetes.io/instance=nginx-ingress-controller-1729402641,app.kubernetes.io/name=nginx-ingress-controller
Type:                     LoadBalancer
IP Family Policy:         SingleStack
IP Families:              IPv4
IP:                       10.101.247.125
IPs:                      10.101.247.125
LoadBalancer Ingress:     192.168.50.110
Port:                     http  80/TCP
TargetPort:               http/TCP
NodePort:                 http  31465/TCP
Endpoints:                10.1.0.7:8080
Port:                     https  443/TCP
TargetPort:               https/TCP
NodePort:                 https  32024/TCP
Endpoints:                10.1.0.7:8443
Session Affinity:         None
External Traffic Policy:  Cluster
Events:
  Type    Reason       Age    From                Message
  ----    ------       ----   ----                -------
  Normal  IPAllocated  4m10s  metallb-controller  Assigned IP ["192.168.50.110"]
```

