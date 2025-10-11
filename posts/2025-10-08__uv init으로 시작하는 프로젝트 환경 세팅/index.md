---
toc: true
toc-depth: 3
toc-expand: true
number-sections: false
title: uv init으로 시작하는 프로젝트 환경 세팅
date: 2025-10-08
categories: [Python]
author: limyj0708
comments:
  giscus:
    repo: limyj0708/blog
format:
    html:
        page-layout: full
---

# 1. 프로젝트 디렉토리로 이동
- `cd /path/to/project`

# 2. uv로 가상환경 생성

1. 특정 python 버전으로 생성
```sh
# Python 3.12로 가상환경 생성
uv venv --python 3.12
```

2. uv 프로젝트로 초기화
```sh
# 프로젝트 초기화 (pyproject.toml 생성)
uv init
```
- .python-version 파일이 생성되는데, 여기서 가상환경에 사용될 python 버전을 설정할 수 있음
- 2025-10-09 시점에는 3.12로 생성됨

```sh
# pyproject.toml 의존성 설치
uv sync
```

# 3. 가상환경 활성화
```sh
# 가상환경 활성화
source .venv/bin/activate

# 특정 이름으로 생성한 경우
source .venv_some_project/bin/activate
```

# 4. 가상환경 비활성화
```sh
deactivate
```