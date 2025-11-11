---
toc: true
toc-depth: 3
toc-expand: true
number-sections: false  # H tag에 번호를 자동으로 붙임
title: 개인 프로젝트에는 SSH 터널링이라도 사용하자
date: 2025-10-28
categories: [Cloud]
author: limyj0708
comments:
  giscus:
    repo: limyj0708/blog
format:
    html:
        page-layout: full
---
# SSH 터널링 수행
## 1. 터미널에서 아래와 같은 명령어를 실행해 보자.
```sh
ssh -L 9999:localhost:8888 -p 22 -i ~/.ssh/id_rsa user@000.000.0.00
# ssh -L [로컬포트]:[서버에서 본 목적지]:[목적지포트] -p [SSH포트] -i [키파일경로] [유저]@[서버IP]
```
- `-L`: Local Port Forwarding (로컬 포트 포워딩)
- localhost:9999 주소를 통해서 서버의 8888포트에 접근할 수 있게 된다.
- 이 명령어를 실행할 경우, SSH를 통해 서버의 쉘에 접속된다.

## 2. [sshconfig에서-간단-접속-설정](../2025-10-08__Cloud Compute Instance 사용 시 알아두면 좋은 사용법들/#sshconfig에서-간단-접속-설정) 에서와 같이, 미리 config 파일에 ssh 접속 설정을 해 두었다면 명령어가 좀 더 간단함
```sh
ssh -L 9999:localhost:8888 config에서_지정한_호스트_이름
```

## 3. SSH 터널링을 백그라운드에서 실행시키고 싶을 경우
```sh
ssh -fN -L 9999:localhost:8888 사용할_호스트_이름
```
- `-f`: SSH를 백그라운드로 실행
- `-N`: 원격 명령을 실행하지 않음 (포트 포워딩만 수행)
- 터널을 끄고 싶은 경우
  - `ps aux | grep "ssh -fN"` 명령어로 터널링

## 4. 터널이 끊겼을 때 자동으로 연결시키고 싶은 경우
```sh
# autossh 설치 (macOS)
brew install autossh

# 자동 재연결 터널링 실행
autossh -M 0 -f -N -L 8888:localhost:8888 사용할_호스트_이름
```
- `-M 0` : SSH의 내장 기능인 ServerAliveInterval과 ServerAliveCountMax를 사용하여 연결 상태 확인
  - 이 경우, config에 이미 아래와 같이 세팅되어 있음
  ```config
  ServerAliveInterval 60   # 60초마다 서버에 신호를 보냄
  ServerAliveCountMax 3    # 3번 연속 응답이 없으면 연결이 끊어진 것으로 판단하고 재연결
  ```
  - 정확히는 모니터링 포트 기능을 끈 것
    - `-M 20000` 이라고 세팅하면, 20000과 20001 포트를 사용하여 연결 상태를 확인하게 됨

## 5. SSH 터널 로그를 남기고 싶은 경우
```sh
ssh -N -L 8888:localhost:8888 사용할_호스트_이름 -v 2>&1 | tee ~/ssh_tunnel.log &
```
- `-v` : SSH의 상세 로그를 출력
- `2>&1`
  - `2`: stderr (표준 에러 출력)
  - `>&1`: stdout (표준 출력)으로 리다이렉트
  - 의미: 에러 메시지를 일반 출력으로 합침
  - SSH의 verbose 출력은 stderr로 나오기 때문에 이것을 stdout으로 보내야 파이프로 전달 가능
- `tee ~/ssh_tunnel.log`
  - 입력받은 데이터를 두 곳에 동시에 출력
    - 화면 (터미널)
    - 파일 (~/ssh_tunnel.log)
  - 로그를 저장하면서 동시에 실시간으로 확인 가능
- `&` (Shell 백그라운드)
  - SSH 백그라운드 옵션인 `-f`를 사용하면 stdout/stderr이 /dev/null로 자동 리다이렉트되어 로그를 캡쳐할 수 없음

## 6. 여러 포트를 동시에 포워딩
```sh
ssh -fN -L 8888:localhost:8888 -L 5432:localhost:5432 사용할_호스트_이름
```
