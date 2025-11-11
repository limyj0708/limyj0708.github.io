---
toc: true
toc-depth: 3
toc-expand: true
number-sections: false  # H tag에 번호를 자동으로 붙임
title: Airflow DockerOperator 적용 예시 (Docker-out-of-Docker)
date: 2025-10-28
categories: [Airflow]
author: limyj0708
comments:
  giscus:
    repo: limyj0708/blog
format:
    html:
        page-layout: full
---
# 왜 DockerOperator를 사용하게 되었나
1. 네이버 뉴스 API를 10분 간격으로 호출하여, 특정 키워드가 들어간 최신 기사를 slack으로 전송하는 반복 작업이 필요
2. PythonOperator, BashOperator를 사용하고 싶지 않았음
    - Airflow 환경과 Application 환경을 완전히 분리하여 의존성을 제거하고 싶었음
    - Application이 메모리를 많이 사용해도, Airflow 안정성이 보장되었으면 함
3. Airflow : Docker Container에서 실행 중
4. Application : 다른 Docker Image로 관리 중
    - 이런 경우, 임시 Docker Container를 생성한 후 대상을 실행함
    - 그리고 임시 Docker Container를 제거

# 코드 예시
- Airflow Container와 같은 머신에 있는 Container를 실행하는 경우 (Docker-out-of-Docker)
```Python
"""
서울 지하철 뉴스 봇 DAG

10분 간격으로 실행되며, 다음 작업을 순차적으로 수행:
1. 뉴스 검색 (Naver API)
2. 중복 필터링
3. 슬랙 알림 전송 및 CSV 저장
4. 오래된 파일 정리

각 작업은 별도의 Docker 컨테이너에서 실행됨
"""

from datetime import datetime, timedelta
from airflow import DAG
from airflow.providers.docker.operators.docker import DockerOperator
from docker.types import Mount

# ============================================================
# DAG 기본 설정
# ============================================================
default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': datetime(2025, 10, 19),
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=1),
}

# ============================================================
# Docker 컨테이너 공통 설정
# ============================================================
DOCKER_IMAGE = 'seoul_metro_news_bot:latest'  # Docker 이미지 이름
NETWORK_MODE = 'shared_network'  # 공유 네트워크 (미리 생성)

# ============================================================
# 볼륨 마운트 설정
# - data 디렉토리: CSV 파일 및 임시 파일 저장
# - .env 파일: 환경 변수 설정 (네이버 API, 텔레그램 등)
# ============================================================
MOUNTS = [
    Mount(
        source='/데이터 경로/data',  # 호스트의 경로
        target='/app/data',
        type='bind'
    ),
    Mount(
        source='/환경변수 경로/.env', # 호스트의 경로
        target='/app/.env',
        type='bind',
        read_only=True  # 읽기 전용으로 마운트
    )
]

# ============================================================
# DAG 정의
# ============================================================
dag = DAG(
    'seoul_metro_news_bot',
    default_args=default_args,
    description='서울 지하철 뉴스 수집 및 알림 봇 (DockerOperator)',
    schedule_interval='*/10 * * * *',  # 10분마다 실행
    catchup=False,  # 과거 실행 건너뛰기
    tags=['news', 'seoul_metro', 'docker'],
)

# ============================================================
# Task 1: 뉴스 검색
# ============================================================
fetch_news = DockerOperator(
    task_id='fetch_news',
    image=DOCKER_IMAGE,
    api_version='auto', # Docker SDK가 연결된 Docker 데몬의 API 버전을 자동으로 감지하고, 호환되는 최신 버전을 사용
    auto_remove=True,  # 컨테이너 실행 완료 후 자동 삭제
    command='python scripts/1_fetch_news.py',  # 실행할 명령어
    docker_url='unix://var/run/docker.sock',  # Docker 소켓
    network_mode=NETWORK_MODE,  # 어떤 공유 네트워크를 사용할 것인지 지정. 컨테이너 간 통신이 존재한다면 필요하며, 컨테이너 간 통신이 없다면 필요 없는 옵션.
    mounts=MOUNTS,  # 데이터 디렉토리 및 .env 파일 마운트
    mount_tmp_dir=False,  # /tmp 마운트 비활성화. 이미 data 디렉토리가 마운트되어 있음. 비활성화를 하지 않으면 자동으로 호스트의 /tmp에 마운트함 
    dag=dag,
)

# ============================================================
# Task 2: 중복 필터링
# ============================================================
filter_duplicates = DockerOperator(
    task_id='filter_duplicates',
    image=DOCKER_IMAGE,
    api_version='auto',
    auto_remove=True,
    command='python scripts/2_filter_duplicates.py',
    docker_url='unix://var/run/docker.sock',
    network_mode=NETWORK_MODE,
    mounts=MOUNTS,
    mount_tmp_dir=False,
    dag=dag,
)

# ============================================================
# Task 3: 슬랙 알림 전송
# ============================================================
send_notifications = DockerOperator(
    task_id='send_notifications',
    image=DOCKER_IMAGE,
    api_version='auto',
    auto_remove=True,
    command='python scripts/3_send_notifications.py',
    docker_url='unix://var/run/docker.sock',
    network_mode=NETWORK_MODE,
    mounts=MOUNTS,
    mount_tmp_dir=False,
    dag=dag,
)

# ============================================================
# Task 4: 파일 정리
# ============================================================
cleanup = DockerOperator(
    task_id='cleanup',
    image=DOCKER_IMAGE,
    api_version='auto',
    auto_remove=True,
    command='python scripts/4_cleanup.py',
    docker_url='unix://var/run/docker.sock',
    network_mode=NETWORK_MODE,
    mounts=MOUNTS,
    mount_tmp_dir=False,
    dag=dag,
)

# ============================================================
# Task 의존성 설정 (순차 실행)
# ============================================================
fetch_news >> filter_duplicates >> send_notifications >> cleanup
```

# 그런데 보안 취약점이 있다
## Docker Socket
- `docker_url='unix://var/run/docker.sock'`
  - unix:// 프로토콜은 같은 머신 내에서 통신할 때 사용
  - /var/run/docker.sock는 Unix 도메인 소켓 파일로, Docker 클라이언트가 Docker 데몬(dockerd)과 통신하기 위한 통로
- docker.sock 파일 상세
```sh
ls -l /var/run/docker.sock
srw-rw---- 1 root docker 0 Oct  9 14:31 /var/run/docker.sock
```
- 소유자(Owner) 권한: rw-
  - 소유자: root
  - r (read): 읽기 가능
  - w (write): 쓰기 가능
  - (execute): 실행 권한 없음
- 그룹(Group) 권한: rw-
  - 그룹: docker
  - r (read): 읽기 가능
  - w (write): 쓰기 가능
  - (execute): 실행 권한 없음
- 기타(Others) 권한: ---
  - ---: 아무 권한 없음
- Docker 소켓 접근 권한이 있으면 사실상 root 권한을 얻을 수 있음
  - 예: 호스트 파일시스템을 마운트한 컨테이너 실행 가능. 파일을 원하는대로 조작 가능

## 어떻게 보안 취약점을 해결하는가
1. Docker 데몬을 다른 작업용 서버에 띄운다
    - Airflow 워커가 있는 호스트가 아닌, 별도의 전용 VM/서버에 Docker 데몬을 띄움. Airflow는 TLS 인증서를 통해 네트워크로 이 원격 데몬에 docker run을 요청.
    - 효과: 악의적인 DAG가 배포되거나 Task 컨테이너가 침해되어 Docker socket을 악용하려 해도, 피해 범위는 격리된 작업용 서버로 한정됨
2. Docker Socket Proxy 사용
    - 워커에 docker.sock를 직접 마운트하는 대신, API 호출을 필터링하는 프록시 소켓을 마운트.
    - 효과: --privileged나 위험한 볼륨 마운트(-v /:/host_root) 같은 위험한 명령어를 원천 차단
3. 위험을 감수하고 사용
    - DooD 방식의 취약점을 알지만, 특정 조건 하에 위험을 수용하고 그냥 사용
    - 위험 수용 조건
      - 강력한 내부 통제: DAG를 작성하고 배포할 수 있는 사람이 소수의 신뢰할 수 있는 엔지니어로 완벽하게 통제되는 환경. (즉, 악의적인 코드가 유입될 경로가 없다고 신뢰)
      - 완전한 폐쇄망: 해당 Airflow 클러스터가 인터넷은 물론, 회사 내부의 다른 중요 시스템과도 네트워크가 완전히 분리된 환경. (즉, 탈취당해도 피해 범위가 해당 클러스터로 한정됨)
4. Kubernetes로의 이전
    - DockerOperator가 해결하려던 의존성 격리 문제를, **KubernetesPodOperator**를 사용하여 해결
    - KubernetesPodOperator는 Task마다 별도의 Pod를 생성하여 작업을 실행하고 종료
    - 또는 Airflow 전체를 **KubernetesExecutor**로 전환하여 모든 Task를 자동으로 Pod에서 실행 가능