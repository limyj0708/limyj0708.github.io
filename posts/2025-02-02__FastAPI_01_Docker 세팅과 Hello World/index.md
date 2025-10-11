---
toc: true
toc-depth: 3
toc-expand: true
number-sections: true
title: FastAPI_01 Docker 세팅과 Hello World
date: 2025-02-02
categories: [FastAPI]
author: limyj0708
comments:
  giscus:
    repo: limyj0708/blog
format:
    html:
        page-layout: full
---
# Docker와 Docker-compose 설치
- Docker Desktop의 유료화 이후로 여러 대체품들이 나왔지만, 그냥 Docker Desktop을 사용하는 것이 시간과 정신건강에 좋다.
- [https://www.docker.com/products/docker-desktop/](https://www.docker.com/products/docker-desktop/)
- 터미널에서 `docker-compose --version`으로 버전을 확인하자.

# Dockerfile, docker-compose.yml 구성
## Dockerfile
```dockerfile
# 이 dockerfile은 로컬의 fastAPI 폴더 안에 존재
# python:3.12-slim image를 base image로 사용. alias 'builder'는 향후 밑에서 사용 예정.
FROM python:3.12-slim AS builder

# python 사용을 위한 패키지를 직접 컴파일 할 필요가 있을 경우를 대비하여 패키지 설치 및 업데이트
RUN apt-get update && apt-get install -y --no-install-recommends build-essential

FROM builder

# 컨테이너 내의 작업 경로 설정. 이어지는 작업들은 모두 해당 작업 경로 안에서 이루어진다.
WORKDIR /fastAPI

# poetry로 패키지 의존성을 관리. dockerfile과 같은 경로에 있는 toml 파일과 lock 파일을 복사한다.
COPY pyproject.toml poetry.lock ./

# pip 업데이트, 컨테이너 내 의존성 관리를 위한 poetry 설치.
RUN pip3 install --upgrade pip && pip3 install poetry

# poetry에서 가상환경을 생성하지 않고, 컨테이너 내 system-wide 환경에 패키지들을 바로 설치.
RUN poetry config virtualenvs.create false

# poetry를 통해 명시된 패키지들을 설치.
# --no-root : pyproject.toml 파일에 `package-mode=false`를 설정하지 않으면, poetry는 프로젝트 자체를 하나의 패키지로 취급한다.
# 그러면 매번 프로젝트를 재설치하게 된다. --no-root를 붙이면, root package, 즉 프로젝트 자체를 설치하는 과정을 실행하지 않는다.
# --no-interaction : 상호작용을 하지 않음 (Y/N 선택 등). CI/CD 환경에서 작동해야 할 때 유용함.
RUN poetry install --no-root --no-interaction

# dockerfile이 위치하는 로컬 fastAPI 폴더 내의 모든 내용을, 현재 컨테이너의 작업 경로로 복사함
COPY . .

# 포트 오픈
EXPOSE 8000

# ENTRYPOINT는 컨테이너가 시작할 때 실행되는 명령어
# 아래 명령어는, 터미널에서 main:app 모듈을 서빙하는 uvicorn을 실행시킨다. (포트 8000 오픈)
# main.py가 WORKDIR의 가장 외부에 존재할 경우에는 이렇게 실행하면 된다.
ENTRYPOINT ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

## docker-compose.yml
```yaml
services:                           # 하위에 여러 개의 서비스를 지정할 수 있음
  fastapi_sample:                   # 서비스 이름
    build:                          # 이제부터 Docker가 어떻게 이미지를 빌드할 것인지 세팅함
      context: .                    # 이미지 빌드 시에, 현재 디렉토리에 있는 모든 요소를 Docker daemon에 보낸다
      dockerfile: dockerfile        # 어떤 dockerfile을 사용할지 지정
    container_name: fastapi_sample  # 컨테이너 이름
    ports:                          # `host의 포트 : 컨테이너의 포트`를 매핑함.
      - 8000:8000
```

# fastAPI Hello world 코드 구성
```python
# main.py
from fastapi import FastAPI

app = FastAPI()

@app.get("/")
async def root():
    return {"message": "Hello World"}
```

# Docker Container 빌드
- `docker compose -f docker-compose.yaml up --build`
  - docker-compose.yaml 파일에 지정된 내용대로 컨테이너를 생성한다.
  - --build 옵션을 붙이면, 항상 이미지를 새로 빌드한다. context나 dockerfile에 발생한 수정사항이 항상 반영된다.

# 호출해보기
- 앱 실행 후, 0.0.0.0:8000으로 브라우저에서 접근 시 아래와 같은 JSON 메시지를 볼 수 있다.
```json
{
    "message": "Hello World"
}
```

# 디렉토리 구조
```
fastAPI/
  ├── docker-compose.yaml
  ├── dockerfile
  ├── main.py
  ├── pyproject.toml
  └── poetry.lock
```