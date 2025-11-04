---
toc: true
toc-depth: 3
toc-expand: true
number-sections: false  # H tag에 번호를 자동으로 붙임
title: Airflow_DockerOperator를 사용해 보자
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
1. Airflow : Docker Container에서 실행 중
2. 실행해야 할 대상 : 다른 Docker Image로 관리 중
  - 이런 경우, 임시 Docker Container를 생성한 후 대상을 실행함
  - 그리고 임시 Docker Container를 제거

# 코드 예시
- Airflow Container와 같은 머신에 있는 Container를 실행하는 경우
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
    api_version='auto',
    auto_remove=True,  # 컨테이너 실행 완료 후 자동 삭제
    command='python scripts/1_fetch_news.py',  # 실행할 명령어
    docker_url='unix://var/run/docker.sock',  # Docker 소켓
    network_mode=NETWORK_MODE,  # shared_network 사용. 미리 생성해줘야 함
    mounts=MOUNTS,  # 데이터 디렉토리 및 .env 파일 마운트
    mount_tmp_dir=False,  # /tmp 마운트 비활성화
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
# Task 3: 텔레그램 알림 전송
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

# 추가 설명
## Docker Socket
- `docker_url='unix://var/run/docker.sock'`
  - unix:// 프로토콜은 같은 머신 내에서 통신할 때 사용
  - /var/run/docker.sock는 Unix 도메인 소켓 파일로, Docker 클라이언트가 Docker 데몬(dockerd)과 통신하기 위한 통로
- docker.sock 파일의 권한을 확인해 보면
```sh
ls -l /var/run/docker.sock
srw-rw---- 1 root docker 0 Oct  9 14:31 /var/run/docker.sock
```
- 