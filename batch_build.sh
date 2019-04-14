#!/bin/bash -e
# Instructions
# - mount the whole git directory to /root/volume in the docker
# - invoke this script in /root/volume directory
#
#yum install -y jq || true
#apt install -y jq || true
PKGS=(`cat rpm_list.json | jq -r '.[]|.name'`)
VER=(`cat rpm_list.json | jq -r '.[]|.version'`)
GVER=(`cat rpm_list.json | jq -r '.[]|.gcc'`)
NPKGS=${#PKGS[@]}
SYS=x86_64
DIST=el7
GIT_REPO=$(pwd)
CH=${DRONE_COMMIT_SHA:-`git rev-parse HEAD`}

echo -e "\e[1m\e[41m\e[97mGIT_REPO: ${GIT_REPO}\e[0m"
mkdir -p {LOGS,RPM,SRPMS}

echo "DroneCI BUILD ${CH} [ci skip]" > build.log
for i in $(seq 0 $(expr $NPKGS - 1)); do
  NAME=${PKGS[$i]}-${VER[$i]}.${DIST}.${SYS}.rpm
  echo -e "\e[1m\e[41m\e[97mTASK: ${NAME}\e[0m"
  if [ ! -f RPMS/${SYS}/$NAME ]; then
    echo -e "\e[1m\e[41m\e[97m  BUILD: ${NAME}\e[0m"
    echo "- $NAME" >> build.log
    if [ ${GVER[$i]} == "7" ]; then
      echo -e "\e[1m\e[41m\e[97m  GCC: 7\e[0m"
      ./build_script.sh ${PKGS[$i]} 7 ${GIT_REPO}| tee LOGS/${NAME}.log
    else
      echo -e "\e[1m\e[41m\e[97m  GCC: 4\e[0m"
      ./build_script.sh ${PKGS[$i]} 4 ${GIT_REPO}| tee LOGS/${NAME}.log
    fi
  fi
done

if [ `cat build.log|wc -l` == "1" ]; then
  rm build.log
fi
