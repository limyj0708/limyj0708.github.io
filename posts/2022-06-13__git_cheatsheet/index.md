---
jupyter: python3
toc: true
toc-depth: 3
toc-expand: true
number-sections: true
date: 2022-06-13
title: Git CheatSheet (지속적으로 업데이트함)
categories: [git]
author: limyj0708
comments:
  giscus: 
    repo: limyj0708/blog
---

> 안 쓰면 잊어버리는, git 주요 조작법들을 정리

**교과서 : https://git-scm.com/book/ko/v2**

# 기존 디렉토리를 Git 저장소로 만들기
- 원하는 폴더로 이동 후 `git init`

# 수정과 저장

![lifecycle.png](https://git-scm.com/book/en/v2/images/lifecycle.png)

워킹 디렉토리의 모든 파일은 크게 Tracked(관리대상임)와 Untracked(관리대상이 아님)로 나눈다. Tracked 파일은 이미 스냅샷에 포함돼 있던 파일이다. Tracked 파일은 또 Unmodified(수정하지 않음)와 Modified(수정함) 그리고 Staged(커밋으로 저장소에 기록할) 상태 중 하나이다. 간단히 말하자면 Git이 알고 있는 파일이라는 것이다.

그리고 나머지 파일은 모두 Untracked 파일이다. Untracked 파일은 워킹 디렉토리에 있는 파일 중 스냅샷에도 Staging Area에도 포함되지 않은 파일이다. 처음 저장소를 Clone 하면 모든 파일은 Tracked이면서 Unmodified 상태이다. 파일을 Checkout 하고 나서 아무것도 수정하지 않았기 때문에 그렇다.

마지막 커밋 이후 아직 아무것도 수정하지 않은 상태에서 어떤 파일을 수정하면 Git은 그 파일을 Modified 상태로 인식한다. 실제로 커밋을 하기 위해서는 이 수정한 파일을 Staged 상태로 만들고, Staged 상태의 파일을 커밋한다. 이런 라이프사이클을 계속 반복한다.

## 상태 확인
  - `git status`
  
```PowerShell
  PS C:\Users\limyj0708\fastpages> git status
On branch master
Your branch is up to date with 'origin/master'.

Untracked files:
  (use "git add <file>..." to include in what will be committed)
        _notebooks/2022-06-13-git_cheatsheet.ipynb

nothing added to commit but untracked files present (use "git add" to track)
```
  
  - 2022-06-13-git_cheatsheet.ipynb 파일이 untracked 상태
  - Git은 Untracked 파일을 아직 스냅샷(커밋)에 넣어지지 않은 파일이라고 본다. 파일이 Tracked 상태가 되기 전까지는 Git은 절대 그 파일을 커밋하지 않는다. 그래서 일하면서 생성하는 바이너리 파일 같은 것을 커밋하는 실수는 하지 않게 된다.

## 파일을 새로 추적하기
- `git add _notebooks/2022-06-13-git_cheatsheet.ipynb`
- 이후 다시 status를 보면

```PowerShell
PS C:\Users\limyj0708\fastpages> git status
On branch master
Your branch is up to date with 'origin/master'.

Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
        new file:   _notebooks/2022-06-13-git_cheatsheet.ipynb
```

- “Changes to be committed” 에 들어 있는 파일은 Staged 상태라는 것을 의미한다. 커밋하면 git add 를 실행한 시점의 파일이 커밋되어 저장소 히스토리에 남는다.
- git add 명령은 파일 또는 디렉토리의 경로를 argument로 받는다. 디렉토리면 아래에 있는 모든 파일들까지 재귀적으로 추가한다.
- `git add .` 의 경우, .은 현재 디렉토리를 나타내므로, 현재 디렉토리와 하위 디렉토리의 모든 파일들을 Staged 상태로 만든다.

## Modified 상태의 파일을 Staging 하기

- 2022-06-13-git_cheatsheet.ipynb를 수정한 후에 `git status`를 해 보면?

```PowerShell
On branch master
Your branch is up to date with 'origin/master'.

Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
        new file:   _notebooks/2022-06-13-git_cheatsheet.ipynb

Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
        modified:   _notebooks/2022-06-13-git_cheatsheet.ipynb
```

- “Changes not staged for commit” 에 있다. 이것은 수정한 파일이 Tracked 상태이지만 아직 Staged 상태는 아니라는 것이다. Staged 상태로 만들려면 git add 명령을 실행해야 한다. git add 명령은 파일을 새로 추적할 때도 사용하고 수정한 파일을 Staged 상태로 만들 때도 사용한다. Merge 할 때 충돌난 상태의 파일을 Resolve 상태로 만들때도 사용한다. add의 의미는 프로젝트에 파일을 추가한다기 보다는 다음 커밋에 추가한다고 받아들이는게 좋다.

- `git add _notebooks/2022-06-13-git_cheatsheet.ipynb`후 다시 `git status`를 해 보자.

```PowerShell
PS C:\Users\limyj0708\fastpages> git status
On branch master
Your branch is up to date with 'origin/master'.

Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
        new file:   _notebooks/2022-06-13-git_cheatsheet.ipynb
```

- “Changes to be committed”에 잘 들어갔는데, 여기서 또 수정을 하고 `git status`를 하면?

```PowerShell
PS C:\Users\limyj0708\fastpages> git status
On branch master
Your branch is up to date with 'origin/master'.

Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
        new file:   _notebooks/2022-06-13-git_cheatsheet.ipynb

Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
        modified:   _notebooks/2022-06-13-git_cheatsheet.ipynb
```

- Changes to be committed / Changes not staged for commit에 둘 다 2022-06-13-git_cheatsheet.ipynb이 들어있는 이유
  - 지금 이 시점에서 커밋을 하면 git commit 명령을 실행하는 시점의 버전이 커밋되는 것이 아니라 마지막으로 git add 명령을 실행했을 때의 버전이 커밋된다. 그러니까 git add 명령을 실행한 후에 또 파일을 수정하면 git add 명령을 다시 실행해서 최신 버전을 Staged 상태로 만들어야 한다.

## commit
- Staged 상태가 된 파일을 저장소에 기록
- 커밋 메세지를 첨부하려면 -m을 붙이고 메시지를 기재
```Shell
git commit -m "modify readme"
[main c524828] modify readme
 1 file changed, 23 insertions(+), 24 deletions(-)
```
- main branch에 기록되었으며, 체크섬은 c524828
- -a 옵션을 붙이면, add를 해서 staging area에 변경된 파일을 추가하는 작업을 자동으로 처리해 줌
    - `git commit -a -m "modify readme"`

## 파일 삭제
- `git rm [파일명 or 디렉토리명]`
    - 파일이 실제로 삭제된다.
- 파일을 그냥 삭제하면, 파일이 unstaged 상태에 있다고 표시된다.
    - 파일을 그냥 삭제하였다면, git rm을 적용해 주어야 staged 상태가 된다.
    - 그리고 commit을 하면, 더 이상 파일을 추적하지 않는다. 
- 파일을 수정했는데 지우고 싶거나, staging area에 추가했다면, -f 옵션을 주어서 강제로 삭제해야 한다.
- Staging Area에서만 제거하고 디렉토리에 있는 파일은 지우지 않고 남겨두기
    - --cached 옵션 사용
    - `git rm --cached README`
- 한 번에 여러 파일 삭제하기
    - `git rm log/\*.log`
        - log 폴더 내의, .log 확장자인 파일을 모두 삭제함
    - `git rm \*~`
        - 이름이 ~로 끝나는 파일을 모두 삭제함

## 파일 이동, 이름 바꾸기
- `git mv README.md README`
    - README.md를 README로 이름 변경

# 원격 저장소

## 원격 저장소 확인하기
```shell
$ git remote -v
origin  https://github.com/limyj0708/bigquery_module.git (fetch)
origin  https://github.com/limyj0708/bigquery_module.git (push)

```

## 원격 저장소 추가하기
  - `git remote add <원격 저장소 이름> <url>`
      - clone 시에는, 단축이름이 자동으로 origin이 된다.
      - `git clone https://github.com/limyj0708/fastpages.git` : 이런 식으로 할 경우
  - 현재 디렉토리에 추가된 원격 저장소가 있는데, 다른 원격 저장소로 바꾸고 싶을 경우
      - https://shanepark.tistory.com/284 참조

## 원격 저장소에서 Pull, Fetch
- `git fetch <원격 저장소 이름>`
    - 로컬에는 없는데, 원격 저장소에 있는 내용을 모두 가져온다.
    - 가져오긴 하지만 branch를 merge 하지는 않으므로, 수동으로 merge 해야 한다.
- `git pull <원격 저장소 이름>`
    - 원격 저장소에 있는 내용을 모두 가져온 후, branch merge까지 알아서 진행한다.
    - 최초에 내용을 `git clone`으로 가져왔을 경우, 자동으로 로컬의 master branch가 리모트 저장소의 master branch를 추적하도록 한다(물론 리모트 저장소에 master 브랜치가 있다는 가정에서).

## 원격 저장소에 Push 하기
- `git push <원격 저장소 이름> <브랜치 이름>`
    - 최초에 `git clone`으로 가져왔을 경우, 단축이름은 origin이고 branch 이름은 master이므로 아래와 같이 된다.
    - `git push origin master`
- 이 명령은 Clone 한 리모트 저장소에 쓰기 권한이 있고, Clone 하고 난 이후 아무도 Upstream 저장소에 Push 하지 않았을 때만 사용할 수 있다. 다시 말해서 Clone 한 사람이 여러 명 있을 때, 다른 사람이 Push 한 후에 Push 하려고 하면 Push 할 수 없다. 먼저 다른 사람이 작업한 것을 가져와서 Merge 한 후에 Push 할 수 있다. 

## 원격 저장소 정보 보기
- `git remote show <원격 저장소 이름>`

```shell
$ git remote show origin
* remote origin
  Fetch URL: https://github.com/schacon/ticgit
  Push  URL: https://github.com/schacon/ticgit
  HEAD branch: master
  Remote branches:
    master                               tracked
    dev-branch                           tracked
  Local branch configured for 'git pull':
    master merges with remote master
  Local ref configured for 'git push':
    master pushes to master (up to date)
```

- 원격 저장소의 URL과 추적하는 branch를 출력한다. 이 명령은 git pull 명령을 실행할 때 master branch와 Merge할 branch가 무엇인지 보여준다. git pull 명령은 원격 저장소 branch의 데이터를 모두 가져오고 나서 자동으로 Merge할 것이다. 

## 원격 저장소 이름 바꾸기, 삭제하기
- `git remote rename <기존 원격 저장소 이름> <바꿀 원격 저장소 이름>`
- `git remote remove <원격 저장소 이름>`

# 다중 계정 사용
## config 분리
- 한 PC에서 업무용 repository 접근계정, 개인용 repository 접근계정을 분리해서 사용하고 싶을 때
- 윈도우의 경우, C:\Users\{계정명} 에 .gitconfig가 존재한다.
- .gitconfig에 아래 항목 추가
```config
[includeIf "gitdir/i:C:/Code/limyj0708_code_archive/"]
    path = .gitconfig_personal.config
```
- C:/Code/limyj0708_code_archive/ 아래에 있는 repository에 접근 시에는, .gitconfig_personal.config의 정보를 사용하겠다는 의미이다.
- C:\Users\{계정명} 에 .gitconfig_personal.config를 만들고, users 항목을 입력한다.
```config
[user]
	email = limyj0708@gmail.com
	name = limyj0708
```
- 확인해보면, 원하는 대로 잘 된다.
```Bash
$ git config --show-origin user.email
file:C:/Users/limyj0708/.gitconfig_personal.config      limyj0708@gmail.com
```

## ssh_key 등록
- ssh_key를 각각 분리해서 등록해주면, 원격 저장소에 push할 때 귀찮은 일이 없어진다.
```
> ssh-keygen
Generating public/private rsa key pair.
Enter file in which to save the key (C:\Users\limyj0708/.ssh/id_rsa):
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in C:\Users\limyj0708/.ssh/id_rsa.
Your public key has been saved in C:\Users\limyj0708/.ssh/id_rsa.pub.
The key fingerprint is:
```
- passphrase는 [설정을 권장](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/working-with-ssh-key-passphrases)하고 있으므로 설정해준다.
- `C:\Users\limyj0708\.ssh`에 가서, 공개키(pub)를 열고 내용을 복사하자.
- github 계정 > Settings > SSH and GPG keys 메뉴로 이동
  - SSH keys > New SSH key
  - 공개키 내용을 붙여넣고, 적절히 이름을 붙여서 등록
- `C:\Users\limyj0708\.ssh\config`에 내용을 추가하자.
```Config
Host github_personal
  IdentityFile C:\Users\limyj0708\.ssh\{비밀키 파일명}
  User git
  HostName github.com
```
- 이후, 로컬 저장소에서 원격 저장소를 어떻게 등록해주면 되냐면...
  - `git remote add origin git@github_personal:limyj0708/blog.git`
    - git@github.com:limyj0708/blog.git에서, github.com 부분을 github_personal으로 바꿔 준 것이다.
  - 이미 연결되어있던 원격 저장소가 있어서, 바꿔줘야 되는 상황이라면 미리 `git remote remove {저장소명}`을 해 주자.
- 이제 원격 저장소로 push 할 때, passphrase만 잘 입력해 주면 추가 조치 없이 잘 진행된다.
- 회사 계정은 github_work 등으로 추가할 수 있다.


# Branch

## Branch 목록 확인
- `git branch`
  - 로컬 브랜치 목록을 보여준다
  - 현재 작업 중인 브랜치 앞에 `*` 표시가 붙는다
  
```shell
$ git branch
* master
  develop
  feature-1
```

- `git branch -v`
  - 각 브랜치의 마지막 커밋 메시지도 함께 보여준다
  
```shell
$ git branch -v
* master    c524828 modify readme
  develop   a3f2b1c add new feature
  feature-1 d8e9f0a fix bug
```

- `git branch -a`
  - 로컬 브랜치와 원격 브랜치를 모두 보여준다
  
- `git branch -r`
  - 원격 브랜치만 보여준다

## Branch 생성
- `git branch <브랜치명>`
  - 새로운 브랜치를 생성한다
  - 생성만 할 뿐 해당 브랜치로 전환하지는 않는다
  
```shell
$ git branch develop
$ git branch
  develop
* master
```

- `git checkout -b <브랜치명>`
  - 새로운 브랜치를 생성하고 바로 전환한다
  - `git branch <브랜치명>` + `git checkout <브랜치명>`을 한 번에 실행
  
```shell
$ git checkout -b feature-2
Switched to a new branch 'feature-2'
```

- `git switch -c <브랜치명>`
  - Git 2.23 버전 이후 추가된 명령어
  - `git checkout -b`와 동일한 기능 (브랜치 생성 + 전환)
  
```shell
$ git switch -c feature-3
Switched to a new branch 'feature-3'
```

## Branch 전환
- `git checkout <브랜치명>`
  - 지정한 브랜치로 전환한다
  - 워킹 디렉토리의 파일들이 해당 브랜치의 상태로 변경된다
  
```shell
$ git checkout develop
Switched to branch 'develop'
```

- `git switch <브랜치명>`
  - Git 2.23 버전 이후 추가된 명령어
  - `git checkout`보다 명확하게 브랜치 전환 용도로 사용
  
```shell
$ git switch master
Switched to branch 'master'
```

- 주의사항
  - 브랜치를 전환하기 전에 현재 작업 중인 내용을 커밋하거나 stash 해야 한다
  - 그렇지 않으면 변경사항이 사라지거나 충돌이 발생할 수 있다

## Branch 삭제
- `git branch -d <브랜치명>`
  - 로컬 브랜치를 삭제한다
  - 병합되지 않은 브랜치는 삭제되지 않는다 (안전장치)
  
```shell
$ git branch -d feature-1
Deleted branch feature-1 (was d8e9f0a).
```

- `git branch -D <브랜치명>`
  - 강제로 브랜치를 삭제한다
  - 병합되지 않은 브랜치도 삭제된다
  
```shell
$ git branch -D feature-2
Deleted branch feature-2 (was a1b2c3d).
```

- 원격 브랜치 삭제
  - `git push <원격 저장소> --delete <브랜치명>`
  - 또는 `git push <원격 저장소> :<브랜치명>`
  
```shell
$ git push origin --delete feature-1
To https://github.com/user/repo.git
 - [deleted]         feature-1
```

## Branch 병합 (Merge)
- `git merge <브랜치명>`
  - 현재 브랜치에 지정한 브랜치의 내용을 병합한다
  - 예: develop 브랜치의 내용을 master에 병합하고 싶다면
  
```shell
$ git checkout master
$ git merge develop
Updating c524828..a3f2b1c
Fast-forward
 README.md | 10 ++++++++++
 1 file changed, 10 insertions(+)
```

- Fast-forward 병합
  - 현재 브랜치가 병합할 브랜치의 직접적인 조상인 경우
  - Git은 단순히 포인터를 앞으로 이동시킨다
  
- 3-way Merge
  - 현재 브랜치와 병합할 브랜치가 갈라진 경우
  - Git은 공통 조상, 현재 브랜치, 병합할 브랜치를 비교하여 새로운 커밋을 생성
  - 시나리오 1 (성공):
    - Mine은 file1.txt를 수정.
    - Theirs는 file2.txt를 수정.
    - 결과: 겹치는 부분이 없으므로, 두 변경 사항을 모두 적용한 새 커밋을 만듭니다.
  - 시나리오 2 (성공):
    - Mine은 file1.txt의 10번째 줄을 수정.
    - Theirs는 file1.txt의 50번째 줄을 수정.
    - 결과: 같은 파일이지만 수정한 위치가 다르므로, 두 변경 사항을 모두 적용
  - 시나리오 3 (실패: 병합 충돌!)
    - Mine은 file1.txt의 10번째 줄을 A라고 수정.
    - Theirs도 file1.txt의 10번째 줄을 B라고 수정.
  - 결과: Git은 **원본(Base)**과 비교해 보니 둘 다 같은 곳을 다르게 수정했음을 확인. Git은 "둘 중 뭘 선택해야 할지 모르겠어!"라며 **병합 충돌(Merge Conflict)**을 일으키고 사용자에게 해결을 요청함
  - 충돌이 없거나, 충돌을 모두 해결하고 나면 Git은 이 모든 변경 사항을 합친 **새로운 커밋 M**을 생성
```
     A---B---C  (feature)  <- 병합할 브랜치 (Theirs)
    /
---O---D---E       (main)     <- 현재 브랜치 (Mine)

      A---B---C
     /         \
---O---D---E---M   (main)
```
- 병합 충돌 해결
  - 같은 파일의 같은 부분을 수정한 경우 충돌이 발생한다
  - 충돌이 발생하면 Git은 해당 파일에 충돌 마커를 추가한다
  
```shell
<<<<<<< HEAD
현재 브랜치의 내용
=======
병합하려는 브랜치의 내용
>>>>>>> develop
```

  - 수동으로 충돌을 해결한 후 `git add`로 해결 표시
  - `git commit`으로 병합 완료

## Branch 이름 변경
- `git branch -m <기존 브랜치명> <새 브랜치명>`
  - 브랜치 이름을 변경한다
  
```shell
$ git branch -m old-name new-name
```

- 현재 브랜치의 이름을 변경하려면
  
```shell
$ git branch -m new-name
```
