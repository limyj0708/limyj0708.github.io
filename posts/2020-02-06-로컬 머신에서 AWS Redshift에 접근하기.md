---
title: 로컬 머신에서 AWS Redshift에 접근하기
toc : True
category: 학습_정리
layout: post
---

Redshift [공식 메뉴얼](https://docs.aws.amazon.com/ko_kr/redshift/index.html)에서 명료하게 설명하지 않았거나, 없는 내용에 대한 정리이다.

## 1. Virtual Private Cloud(VPC) 보안 그룹 설정
* [VPC](https://docs.aws.amazon.com/ko_kr/vpc/latest/userguide/what-is-amazon-vpc.html)의 보안 그룹 설정이 필요하다.
* 클러스터 선택 -> 속성 -> 네트워크 및 보안 -> VPC 보안 그룹 메뉴로
* Inbound 설정에서, 유형 Redshift, 연결을 원하는 머신의 IP를 Source로 설정하자.

## 2. "공개적으로 액세스 할 수 있음" 설정
* 너무 간단한 내용이지만, 메뉴얼에 없었다...
* 클러스터 선택 -> 속성 -> 네트워크 및 보안 -> 공개적으로 액세스 할 수 있음 메뉴에서 '예'로 바꿔주면 된다.

## 3. TablePlus에서 연결하기
* Mac용 SQL 클라이언트 중에서는 TablePlus가 제일 좋은 것 같다.
* 클러스터 Endpoint는 이런 구조다.
    * CLUSTER-NAME.CLUSTER-KEY.CLUSTER-REGION.redshift.amazonaws.com:PORT/DATABASE-NAME
* Host에 입력할 값
    * CLUSTER-NAME.CLUSTER-KEY.CLUSTER-REGION.redshift.amazonaws.com
* Port, User, Password, Database는 설정했던 값을 입력
* 나머지 옵션은 조절하지 않아도 됨

## 4. psycopg2에서 연결하기
* 간단해서 코드로 대신함
```Python
import psycopg2
dbname='YOUR-DB-NAME' # 최초의 기본 db명은 dev
host='CLUSTER-NAME.CLUESTER-KEY.CLUESTER-REGION.redshift.amazonaws.com'
port=5439
user='USER-NAME'
password='********'
con=psycopg2.connect(dbname=dbname, host=host, port=port, user=user, password=password)
cur = con.cursor()
```

* 매번 connect, cursor를 닫기 번거로우니 with 구문을 사용하자.

```Python
dbname='YOUR-DB-NAME' # 최초의 기본 db명은 dev
host='CLUSTER-NAME.CLUESTER-KEY.CLUESTER-REGION.redshift.amazonaws.com'
port=5439
user='USER-NAME'
password='********'
connect_param = dict({'dbname':dbname, 'host':host, 'port':port, 'user':user, 'password':password})

with psycopg2.connect(**connect_param) as con:
    with con.cursor() as cur:
        do something
```