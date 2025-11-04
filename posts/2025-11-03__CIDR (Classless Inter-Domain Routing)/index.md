---
toc: true
toc-depth: 3
toc-expand: true
number-sections: false  # H tag에 번호를 자동으로 붙임
title: CIDR (Classless Inter-Domain Routing) 이란?
date: 2025-10-08
categories: [Cloud]
author: limyj0708
comments:
  giscus:
    repo: limyj0708/blog
format:
    html:
        page-layout: full
---

# 1. CIDR?
- **CIDR (Classless Inter-Domain Routing)**는 IP 주소 범위를 나타내는 표기
- 표기 방식: [IP 주소]/[프리픽스 길이]
  - IP 주소: 시작하는 IP 주소
  - 프리픽스 길이 (숫자): IP 주소의 32비트(IPv4 기준) 중에서 네트워크 부분을 나타내는 비트 수를 의미. 이 숫자가 작을수록 더 넓은 범위의 IP를 포함함
- 예시:
  - 192.168.1.0/24: 앞의 24비트(192.168.1)는 고정이고, 나머지 8비트(0~255)는 변할 수 있다는 뜻
    - 즉, 192.168.1.0부터 192.168.1.255까지의 256개 IP를 의미함
  - 10.0.0.0/8: 앞의 8비트(10)만 고정이고 나머지 24비트가 변할 수 있다는 뜻
    - 훨씬 더 큰 범위(약 1,600만 개)의 IP를 포함
  - 192.0.2.1/32: 32비트 전체가 고정이라는 뜻으로, 192.0.2.1이라는 단 하나의 IP 주소를 의미

# 2. 그럼 0.0.0.0/0은 무엇인지?
- 0.0.0.0: IP 주소의 시작점.
- /0: 고정되는 비트가 0개라는 뜻. 즉, 32비트 전체가 변할 수 있음을 의미함.
- 결과적으로 0.0.0.0/0은 0.0.0.0부터 255.255.255.255까지, 모든 IPv4 주소 범위 전체를 나타내는 표기법
- 예를 들어, Oracle Compute Instance의 Ingress Rule의 **Source CIDR (소스 CIDR)**에 0.0.0.0/0을 설정하면, 인터넷상의 모든 IP 주소로부터의 접속(TCP 프로토콜)을 허용하겠다는 의미임