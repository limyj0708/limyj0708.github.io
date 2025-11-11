---
toc: true
toc-depth: 3
toc-expand: true
number-sections: true
title: Quarto 101
date: 2024-01-21
categories: [Quarto]
author: limyj0708
comments:
  giscus:
    repo: limyj0708/blog
format:
    html:
        page-layout: full
---

> Quarto로 만든 블로그에 Quarto 사용법을 이제야 정리하다니..

# Github pages에 블로그 생성
- [Quarto Github page 세팅 공식 가이드](https://quarto.org/docs/publishing/github-pages.html)
1. [Quarto CLI](https://quarto.org/docs/get-started/) 설치
2. Github page repository 생성
3. 대상 폴더에 가서 `quarto create project` 실행
4. 생성된 프로젝트 root에 추가할 것들
    - .nojekyll 파일(github page가 jekyll로 페이지를 생성하는 것을 막음)
    - _quarto.yml 세팅
    ```yaml
    project:
    type: website
    output-dir: docs

    website:
    title: "Lim's Code Archive"
    search: true
    page-navigation: true
    navbar:
        right:
        - about.qmd
        - icon: github
            href: https://github.com/limyj0708
        - icon: linkedin
            href: https://www.linkedin.com/feed/

    format:
    html:
        theme: cosmo
        css: styles.css
    ```
    - .gitignore 세팅
    ```yml
    /.quarto/
    .ipynb_checkpoints
    */.ipynb_checkpoints/*
    /_site/
    ```
5. giscus 세팅 : [링크](https://giscus.app/ko)
6. 프로젝트 폴더에 github page repository를 연결

---

# 글 추가
1. jupyter notebook이나 md에 글을 작성하기 전에, 상단에 YAML option 코드를 입력한다. 아래는 예시.
```YAML
---
jupyter: python3
toc: true
toc-depth: 3
number-sections: true
comments:
  giscus:
    repo: limyj0708/blog
format:
    html:
        page-layout: full
author: limyj0708
title: Pandas_02_Indexing, 값 변경, 추가
date: 2021-11-05 00:01
categories: pandas
---
```
2. root에서 `quarto render <대상 파일 경로>`
    - 대상 파일 경로를 넣지 않으면, posts 폴더 안의 모든 문서를 렌더링하여 docs에 저장한다. 글이 많아지면 생각보다 오래 걸리므로 전체를 다 렌더딩 하지는 말자.
3. `quarto preview` 로 미리 로컬에서 렌더링 된 결과를 확인할 수 있다.
4. add, commit 후 push.
5. repository의 github action에서 문제 없이 잘 빌드되는지 확인할 수 있다.

## 소스코드가 변경된 문서만 렌더링 하기
1. _quarto.yml 파일에서 아래와 같은 옵션을 추가하자. [공식 문서 설명](https://quarto.org/docs/projects/code-execution.html#freeze)
```yml
execute:
  freeze: auto  # re-render only when source changes
```

## 상대경로로 포스트 간 링크 추가
- 특정 포스트로 이동
  - `[uv로 프로젝트 환경 세팅하기](../2025-10-08__uv init으로 시작하는 프로젝트 환경 세팅/)`
  - [uv로 프로젝트 환경 세팅하기](../2025-10-08__uv init으로 시작하는 프로젝트 환경 세팅/)
- 특정 포스트의 제목으로 이동
  - `[sshconfig에서-간단-접속-설정](../2025-10-08__Cloud Compute Instance 사용 시 알아두면 좋은 사용법들/#sshconfig에서-간단-접속-설정)`
  - [sshconfig에서-간단-접속-설정](../2025-10-08__Cloud Compute Instance 사용 시 알아두면 좋은 사용법들/#sshconfig에서-간단-접속-설정)
