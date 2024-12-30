# README #
OPenDocuSea Project
Service Name : OpenAry



#### Minio는 K8S의 전처리될 대상 원본 데이터를 저장함.
#### RabbitMQ는 K8S의 각 컨테이너 서비스간의 데이터 통신에 사용됨.
#### VectorDB는 PGVector를 사용, 사용자 관리는 MariaDB를 사용함.
VectorDB 테이블 구조
```
사용자 테이블명은 sha로 암호화됨.
CREATE TABLE public.f5e4aeaf4ad899a3a0bf79fea05b7b96820b9103 (
	"source" varchar(512) NULL,
	"text" text NULL,
	vector public.vector NULL,
	id serial4 NOT NULL,
	doc_id int4 NULL,
	model_id varchar NULL,
	CONSTRAINT f5e4aeaf4ad899a3a0bf79fea05b7b96820b9103_pk PRIMARY KEY (id)
);
```
관리 테이블 구조
```commandline
CREATE TABLE `tb_llm_doc` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'id',
  `filename` varchar(256) DEFAULT NULL COMMENT '파일경로',
  `summary` longtext DEFAULT NULL COMMENT '요약',
  `filesize` int(11) DEFAULT NULL COMMENT '파일크기',
  `status` varchar(50) DEFAULT NULL COMMENT '상태(upload/processing/complete/delete)',
  `uploaded` datetime DEFAULT NULL COMMENT '등록일시',
  `process_start` datetime DEFAULT NULL COMMENT '처리시작일시',
  `process_end` datetime DEFAULT NULL COMMENT '처리종료일시',
  `etc` varchar(256) DEFAULT NULL COMMENT '기타정보',
  `userid` varchar(256) DEFAULT NULL COMMENT 'userid',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6328 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='문서관리';
```
#### 전처리된 데이터는 각종 메타 정보를 포함하여 Mongodb에 저장됨.

Data Part 구동
## Minio
opds-minio의 opds-minio-docker-compose.yaml 구동
```
sudo docker-compose -f opds-minio-docker-compose.yaml up -d
```
## Datahub 구동
Datahub는 rabbitmq, kafka등이 사용가능하나 여기서는 rabbitmq를 사용함.
```
sudo docker-compose -f opds-rabbitmq-docker-compose.yaml up -d
```


k8s Part 환경에서 전처리, 요약 , 임베딩, 챗봇 서비스 구동
## ngnix ingress controller
ngnix-ingress-controller 폴더의 README.md참조.

## opds-preprocess
사용자가 등록한 문서에서 텍스트를 추출하는 서비스입니다.
open-embedding폴더에서 다음의 명령을 실행합니다.
```
kubectl create configmap embedding-setting-config --from-file=set.yaml
kubectl apply -f  opds-embedding-deploy.yml
```
## opds-summary
추출된 text에 gpt를 결합하여 요약을 수행, 데이터베이스에 저장합니다.
```
kubectl create configmap summary-setting-config --from-file=set.yaml
kubectl apply -f  opds-summary-deploy.yml
```

## opds-embedding
추출된 text에 gpt를 결합하여 행렬로 전환하고 pgvector에 저장합니다.
```
kubectl create configmap embedding-setting-config --from-file=set.yaml
kubectl apply -f  opds-embedding-deploy.yml
```

## opds-chatapi
OPDS LLM 챗봇을 서비스함 RestAPI를 제공  
```
kubectl create configmap chatapi-setting-config --from-file=set.yaml
kubectl apply -f  opds-chatapi-deploy.yml
kubectl apply -f  opds-chatapi-svc.yml
```
## Request
```commandline
curl -X 'POST' \
  'http://user service address:9000/rqa' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d '{
  "email": "theprismdata@gmail.com",
  "question": "정책 집행에 대해 알려줘"
}'
```
## Response
```
{
  "answer": "theprismdata@gmail.com 님 문의하신 내용에 대한 결과 입니다. <br> 정책 집행은 주어진 정책을 어떻게 효과적으로 실행할 것인가에 초점을 맞추는 과정입니다. 민주국가에서는 정책 집행이 합의와 민주적 과정을 통해 이루어지며, 정책의 목표를 가장 적은 예산과 인력으로 달성하는 것이 중요합니다. 그러나 실제로는 다양한 정부 부처와 이익집단이 개입하여 복잡한 양상을 띠게 됩니다.\n\n정책 집행의 문제는 크게 두 가지로 나눌 수 있습니다: 어떤 정책을 집행할 것인가와 어떻게 집행할 것인가. 첫 번째 문제는 민주적 합의의 문제로, 연구의 범위를 벗어납니다. 두 번째 문제는 정책 집행 설계나 수단을 선택하는 것으로, 비용과 인력의 효율적 사용이 핵심입니다.\n\n정책 집행 과정에서는 다양한 이해관계자들이 참여하게 되며, 이로 인해 조정과 협력이 중요해집니다. 예를 들어, 국민연금 문제에서는 여러 정부 부처와 공무원 노조, 일반 국민들이 이해관계자로 참여합니다. 이러한 복잡성 때문에 사건이나 사고가 발생할 때마다 언론은 컨트롤타워의 필요성을 제기합니다. 컨트롤타워는 조직 간 조정을 통해 신속하고 효과적인 대응을 가능하게 하지만, 조정과 협력의 문제가 해결되지 않으면 사회적 비용이 발생할 수 있습니다.\n\n결론적으로, 정책 집행은 다양한 이해관계자와 자원을 조정하여 정책 목표를 달성하는 복잡한 과정이며, 이를 위해서는 면밀한 과학적 분석과 효율적인 자원 배분이 필요합니다.",
  "auth": true,
  "question": "정책 집행에 대해 알려줘",
  "search list": [
    {
      "content": "이창용 “정치와 분리된 경제정책 집행되면 탄핵 영향 제한적” - 파이낸셜뉴스",
      "url": "https://news.google.com/rss/articles/CBMiWkFVX3lxTE82aTQ0WGVtNm94bWdpckRjbHQ2ZjZzTzZSQVptOGVBSU5pUUdudUJDdHMzZ2MzWUVPYk54SGZiY0ktRFNnTnNXQlNSNDY0b09kLVlMc2NFZ0NaUdIBXkFVX3lxTE9IcERCNUctUWZiUnp6ZFlISldCbkRMX1F3QkZEeDJYc3JYQ3VDYXkxZVdLOV9CdF9HcFM3aEh4YTY2UjlBUWJwckZRV3RyZ3V4VW9jRExJLThqSG10ckE?oc=5"
    },
    {
      "content": "이창용 \"경제정책, 정치 프로세스와 분리 집행되야\" - 뉴시스",
      "url": "https://news.google.com/rss/articles/CBMiYEFVX3lxTE1ZMTBOOWk2a3ZuSkczTFJMdkRZQjhtYWRlRUgwSmVZS0VoRnczMXA2OXJNYlY5U2ZnYndfek5Rc1lZVTlkLVA4Q3ZncWVMajRyQW1PQzdUTU1rcm1BWlRFNtIBeEFVX3lxTE1welBrclRSb0VNWVVVTEpPNkk4NWZkUjRKVmxWQjZZWFZiLXg4aFpEX2c2MThBSWtuLWx1c3NfZmY3S3EtRUFUVWtWbmxCX0xjYlJNdkVIUWRublE0c2dxZWVFcXI1ZkdaSlFod1VvWW55N3RNMG9MZg?oc=5"
    },
    {
      "content": "탄핵 정국 부동산 충격 줄이려면... 전문가들 차질없는 정책 집행 중요, 신뢰회복해야 - 아주경제",
      "url": "https://news.google.com/rss/articles/CBMiWkFVX3lxTE9OekROc1FQQ3g2WkVLZE13UUlyZ1dfNUFhbnV2dHVHVE1qTTJZNXowTjdkcnROQWgwQUVjdkJQa0VKbTRBSEZWelhvYlAtU3k4XzYxLUdjZzRkd9IBVkFVX3lxTE9KTzVJVHBzMHdLZXJQVDhRQS1FMC1UZXFtRG9TTGRYZ0llYlJrRm9pcDV4LVlZNVEweVlsQ252bTNNTVc2TTJvNkt1ajRpbERvbWN0cWNR?oc=5"
    }
  ],
  "source list": [
    "[KDI 연구보고서]/2014-05-정책효과성 증대를 위한 집행과학에 관한 연구.pdf"
  ]
}
```