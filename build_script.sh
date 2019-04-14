#/bin/bash -e
# Instruction
# - mount the whole git directory to /root/volume in the docker
# - invoke this script as
#      ./build_script name_of_pkg location_of_git_repo gcc_version
NAME=$1
GCC_VER=${2:-4}
GIT_REPO=${3:-/root/volume}
RPM_BUILD=/root/rpmbuild
if [ $GCC_VER == '7' ]; then
  source scl_source enable devtoolset-7
  echo 'enable gcc-7 from scl'
else
  echo 'use gcc-4.8 from centos-7'
fi
cd ${RPM_BUILD}
cp ${GIT_REPO}/PKGS/${NAME}/${NAME}.spec SPECS/
cp ${GIT_REPO}/PKGS/${NAME}/*.patch SOURCES/ || true
cp ${GIT_REPO}/PKGS/${NAME}/*.tar.* SOURCES/ || true
mkdir -p ${GIT_REPO}/{RPMS,SRPMS}

spectool -g -R SPECS/${NAME}.spec
yum-builddep -y SPECS/${NAME}.spec
rpmbuild -bb SPECS/${NAME}.spec

rc=$?
if [[ $rc != 0 ]]; then
  exit $rc
else
  rsync -av RPMS/ ${GIT_REPO}/RPMS
  rsync -av SRPMS/ ${GIT_REPO}/SRPMS
fi
