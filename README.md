# Centos 7 RPM Build

Customized container used to build RPM for CentOS 7

## Container
Check docker file at https://github.com/machsix/rpmbuild. The container has the following packages:
 * wget, curl
 * gcc, automake, autoconf, cmake
 * devtoolset-7
 * epel, scl

## Usage
```bash
docker pull machsix/rpmbuild:centos7
docker run -dt --name rpmbuild-centos7 \
           -v $(pwd)/volume:/root/volume \
           machsix/rpmbuild:centos7
docker exec -it rpmbuild-centos7 /bin/bash
```

## Build
```bash
docker build -t machsix/rpmbuild:centos7 .
```