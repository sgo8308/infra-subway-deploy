#!/bin/bash

## 변수 설정

txtrst='\033[1;37m' # White
txtylw='\033[1;33m' # Yellow
txtgrn='\033[1;32m' # Green

execution_path=$(pwd)
shell_script_path=$(dirname $0)
branch=$1
profile='prod'

function check_parameter() {
  echo ==== check parameter ====
  if [ $1 -ne 1 ]; then
    echo "Invalid Arguments: you need to put one parameter 1.branch name" 
    exit 2
  fi
}

function is_remote_update() {
  git fetch origin
  master=$(git rev-parse $branch)
  remote=$(git rev-parse origin/$branch)

  if [ $master == $remote ]; then
    echo "false"
  else
    echo "true" 
  fi 
}

function is_server_running() {
  pid=$(ps -ef | grep java | grep subway | awk '{print $2}')
  if [ -n "$pid" ]; then
    echo "true"
  else
    echo "false" 
  fi
}

function git_pull(){
  echo ==== git pull ====
  git pull origin $branch
}

function build(){
  echo ==== gradle build ====
  ./gradlew clean build
}

function run_server(){
  echo ==== run server ====
  name=$(find ./ -name "*jar")
  nohup java -jar -Dspring.profiles.active=$profile $name 1> server-log 2>&1 &
}

function kill_running_server(){
  echo ==== kill previous running server ====
  pid=$(ps -ef | grep java | grep subway | awk '{print $2}')
  kill -15 $pid
}

echo -e "${txtylw}=======================================${txtrst}"
echo -e "${txtgrn}  << 스크립트 >>${txtrst}"
echo -e "${txtylw}=======================================${txtrst}"

check_parameter $#

echo -e "${txtgrn}  << 브랜치 $branch >>${txtrst}"
echo -e "${txtgrn}  << Profile $profile >>${txtrst}"

echo "=== go to script path === "
cd /home/ubuntu/infra-subway-deploy

echo "==== run server if not running ===="

if [ "$(is_server_running)" = "false" ]; then
  echo "==== there is no running server ===="

  git_pull 
  build
  run_server
  exit 0
fi

echo "==== there is running server ===="

echo "==== check if remote update ===="
if [ "$(is_remote_update)" = "true" ]; then
  echo "there is change !"
  git_pull 
  build
  kill_running_server
  run_server
else
  echo "[$(date)] Nothing change !"
fi
