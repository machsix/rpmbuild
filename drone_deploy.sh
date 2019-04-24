#!/bin/bash -e
if [ -f build.log ]; then
  # upload
  RPMS=(`git status -s | awk '{print }'| awk '/^.*\.rpm$/ {print -bash}'`)
  for RPMF in ${RPMS[@]}; do
    curl -v -F package=@${RPMF} https://${FURY_TOKEN}@push.fury.io/machsix/
  done

  # upload rpm back to github
  git config user.email "drone@drone.machx.net"
  git config user.name   "DroneCI-github"
  git add RPMS || true
  git add SRPMS || true
  git add LOGS || true
  git commit -F build.log
  git remote set-url origin https://machsix:${GH_TOKEN}@github.com/machsix/rpmbuild.git
  git fetch
  git push
fi

