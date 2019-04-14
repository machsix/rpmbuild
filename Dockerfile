FROM centos:latest

LABEL name="machsix/rpmbuild:centos7"
LABEL maintainer="machsix <28209092+machsix@users.noreply.github.com>"
LABEL description="Docker image to build rpm for CentOS"
USER root

RUN yum install -y yum-utils && \
     yum install -y epel-release && \
     yum install -y centos-release-scl && \
     yum-config-manager --enable epel > /dev/null && \
     yum-config-manager --enable centos-sclo-rh > /dev/null && \
     yum-config-manager --enable centos-sclo-sclo > /dev/null && \
     yum update -y

RUN yum install -y gcc gcc-c++ gcc-gfortran \
                   rpm-build redhat-rpm-config \
                   rpmdevtools \
                   libtool libtool-ltdl \
                   sudo git \
                   make automake autoconf pkgconfig

RUN yum install -y devtoolset-7

RUN yum install -y wget curl nano tmux rsync jq

RUN yum clean all && \
      rm -rf /var/cache/yum && \
      rm -rf /tmp/*


RUN mkdir -p /root/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS} && \
     echo "# macros"                    >  /root/rpmbuild/.rpmmacros && \
     echo "%_topdir /root/rpmbuild" >> /root/rpmbuild/.rpmmacros && \
     echo "%_sourcedir %{_topdir}"      >> /root/rpmbuild/.rpmmacros && \
     echo "%_builddir %{_topdir}"       >> /root/rpmbuild/.rpmmacros && \
     echo "%_specdir %{_topdir}"        >> /root/rpmbuild/.rpmmacros && \
     echo "%_rpmdir %{_topdir}"         >> /root/rpmbuild/.rpmmacros && \
     echo "%_srcrpmdir %{_topdir}"      >> /root/rpmbuild/.rpmmacros

ENV FLAVOR=rpmbuild OS=centos DIST=el7 VERSON_ID=7

# the mounting point for SPECS and SOURCE
VOLUME ["/root/volume"]

WORKDIR /root/rpmbuild

# the script to package rpm
ADD --chown=root:root build_script.sh /root/rpmbuild
ADD Dockerfile /root/rpmbuild

CMD ["/bin/bash"]

# Step 1:
#    docker run -dit -v ${PATH_PACKAGE}/../:/root/volume --name centos7 machsix/rpmbuild:centos7
#
# Step 2:
#   use gcc 7:
#     docker exec -it centos7 bash /root/rpmbuild/buid_script.sh ${NAME_PACKAGE} 7
#   use gcc 4:
#     docker exec -it centos7 bash /root/rpmbuild/buid_script.sh ${NAME_PACKAGE}

