---
toc: true
toc-depth: 3
toc-expand: true
number-sections: true
title: Ubuntu에서 메인 Python 버전 새로 설치하기 (with uv)
date: 2025-02-02
categories: [Ubuntu]
author: limyj0708
comments:
  giscus:
    repo: limyj0708/blog
format:
    html:
        page-layout: full
---

# Ubuntu에서 실사용 Python 버전 교체 (with uv)
- 기본으로 설치되어 있는 버전은 그대로 두고, 새로운 버전을 설치, 해당 버전을 기반으로 개발을 진행하려고 함

## 1. deadsnakes PPA 추가 및 원하는 버전의 Python 설치
```Bash
# PPA 추가 및 패키지 목록 업데이트
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt update

# Python 3.13 및 관련 개발 도구 설치
sudo apt install python3.13 python3.13-venv python3.13-dev
```

## 2. uv 설치
```bash
# macOS / Linux
curl -LsSf https://astral.sh/uv/install.sh | sh
```

## 3. uv를 사용하여 원하는 python 버전 기반 메인 가상환경 생성
```bash
uv venv -p 3.13 main
```
- 해당 가상환경 활성화
```bash
source main/bin/activate
```


