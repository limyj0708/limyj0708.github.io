---
toc: true
toc-depth: 3
toc-expand: true
number-sections: true
title: FastAPI_02 Routing, URL prefix 지정
date: 2025-02-02
categories: [Python, FastAPI]
author: limyj0708
comments:
  giscus:
    repo: limyj0708/blog
format:
    html:
        page-layout: full
---
# 디렉토리 구조
```
fastAPI/
  ├── docker-compose.yaml
  ├── dockerfile
  ├── main.py
  ├── pyproject.toml
  ├── poetry.lock
  └── router/
      ├── hello_world.py
      └── greetings.py
```

- router 폴더 내에 각 모듈들을 생성한다.

## main.py
```python
from fastapi import FastAPI
from router import hello_world, greetings

app = FastAPI(
    title="FastAPI sample"
  , version="1.0.0"
  #, docs_url="/api/docs"             # API root URL을 0.0.0.0/api 로 사용하고 싶다면
  #, openapi_url="/api/openapi.json"  # OpenAPI schema 경로도 지정해주어야 함
)

app.include_router(
    hello_world.router
  # , prefix="/api"  # API root URL을 0.0.0.0/api 로 사용하고 싶다면
  , tags=["hello_world"])
app.include_router(greetings.router, tags=["greetings"])

# @app.get("/api") # API root URL을 0.0.0.0/api 로 사용하고 싶다면
@app.get("/")
async def read_root():
    return {"Readme": "Welcome to FastAPI sample!"}
```

## hello_world.py
```python
from fastapi import APIRouter

router = APIRouter()

@router.get("/hello_world")  # http://0.0.0.0:8000/hello_world URL로 접근
async def hello_world():
    return {"message": "Hello World, with Routing!"}
```

## greetings.py
```python
from fastapi import APIRouter

router = APIRouter()

@router.get("/greetings")  # http://0.0.0.0:8000/greetings URL로 접근
async def greetings():
    return {"message": "Greetings, Traveller!"}
```

# 어떻게 접근하게 되나?
## prefix "/api"를 세팅한 경우
- http://0.0.0.0:8000/api/hello_world
- http://0.0.0.0:8000/api/greetings

## prefix "/api"를 세팅하지 않은 경우
- http://0.0.0.0:8000/hello_world
- http://0.0.0.0:8000/greetings