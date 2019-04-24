# Personal RPM repository
[![Build Status](https://drone.machx.net/api/badges/machsix/rpmbuild/status.svg)](https://drone.machx.net/machsix/rpmbuild)

A CentOS7 yum repository and a customized container used to build RPM for CentOS 7

## Repository
```bash
curl -L https://raw.githubusercontent.com/machsix/rpmbuild/master/machsix.repo > /etc/yum.repos.d/machsix.repo
yum makecache
```

## Container
Check docker file at https://github.com/machsix/rpmbuild. The container has the following packages:
 * wget, curl
 * gcc, automake, autoconf, cmake
 * devtoolset-7
 * epel, scl

## Usage

- Use of docker
```bash
docker pull machsix/rpmbuild:centos7
docker run -dt --name rpmbuild-centos7 \
           -v $(pwd)/volume:/root/volume \
           machsix/rpmbuild:centos7
docker exec -it rpmbuild-centos7 /bin/bash
```

- Use of compiler
```bash
docker run -it --name centos7 -v $(pwd):/root/volume -dit machsix/rpmbuild:centos7 bash -c 'cd /root/volume&&./batch_build.sh'
```

## Build
```bash
docker build -t machsix/rpmbuild:centos7 .
```
