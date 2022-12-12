# 4주차 - 그럴듯한 서비스 만들기
## 3단계 - 배포 스크립트 작성하기

## 요구사항
- [x] 배포 스크립트 작성하기
  - 아래 내용을 모두 반영할 필요는 없습니다.
  <br>반복적으로 실행하더라도 정상적으로 배포하는 스크립트를 작성해봅니다.


<br>

---
## 힌트
- [x] 반복적으로 사용하는 명령어를 Script로 작성해봅니다.
- [x] 기능 단위로 함수로 만들어봅니다.
- [x] 스크립트 실행시 파라미터를 전달해봅니다.
  - [x] 실행 시 파라미터를 전달하도록 하여 범용성 있는 스크립트를 작성해봅니다.
  - [x] read 명령어를 활용하여 사용자의 Y/N 답변을 받도록 할 수도 있어요.
- [x] 반복적으로 동작하는 스크립트를 작성해봅니다.
  - [x] github branch 변경이 있는 경우에 스크립트가 동작하도록 작성해봅니다.
  - [x] crontab을 활용해봅니다.
    - [x] 매 분마다 동작하도록한 후 log를 확인해보세요.
    - [x] crontab과 /etc/crontab의 차이에 대해 학습해봅니다.


<br>

---
## 스크립트 참고사항
- 파일 위치 `/home/ubuntu/deploy.sh`


- 사용가능 기능
1. service_start
   - 서비스 구동
2. service_stop
   - 서비스 중지
   - 프로세스 종료 확인 시까지 대기
   - 단, 최대 30초까지 대기하고 그 이상 넘어갈 경우 종료 실패한 것으로 간주, 명령종료
3. pull
   - 서비스 구동 중인 app 디렉토리가 아닌 build 디렉토리에 소스 pull
   - 현재 브랜치를 알려주고 원할 경우 다른 브랜치를 pull 받을 수 있음
   - pull 도중 충돌 발생할 경우 merge abort 처리
4. build
   - pull 과 마찬가지로 app 디렉토리가 아닌 build 디렉토리를 사용하여 build
5. backup
   - build 디렉토리 소스 백업
6. delete_backup
   - 백업해둔 build 디렉토리 소스 삭제
7. check_diff
   - 원격 저장소와 비교 후 차이가 존재할 경우 아래의 작업 실행
     1. 백업 디렉토리 삭제
     1. build 디렉토리를 백업
     1. 해당 디렉토리를 사용하여 pull, build
     1. 서비스 중지
     1. app 디렉토리를 build 성공한 디렉토리로 대체
     1. 서비스 구동
8. help
   - 사용자에게 스크립트 실행 시 전달 가능한 인자(기능목록) 안내

```
※ app 디렉토리 : 서비스 구동용 jar 파일 보관
※ build 디렉토리 : 원격 레포지토리와 소스비교, pull, build를 위한 소스 디렉토리
```

<br>

## cron 설정
```
*/5 * * * * /home/ubuntu/deploy.sh check_diff prod >> /home/ubuntu/nextstep/logs/deploy_sh.log 2>&1
```
- 5분마다 git 원격저장소 차이 비교 후 차이 있는 경우 반영, 재시작
- 원격저장소 주소 및 브랜치
  - https://github.com/tlaqk229/infra-subway-deploy.git
  - `step3Test`