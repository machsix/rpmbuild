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
                   libtool libtool-ltdl \
                   sudo \
                   make cmake \
                   automake autoconf \
                   git pkgconfig \
                   wget curl && \
     yum install -y devtoolset-7 && \
     yum clean all && \
     rm -rf /var/cache/yum

RUN mkdir -p /root/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS} && \
     echo "# macros"                    >  /root/rpmbuild/.rpmmacros && \
     echo "%_topdir /root/rpmbuild/rpm" >> /root/rpmbuild/.rpmmacros && \
     echo "%_sourcedir %{_topdir}"      >> /root/rpmbuild/.rpmmacros && \
     echo "%_builddir %{_topdir}"       >> /root/rpmbuild/.rpmmacros && \
     echo "%_specdir %{_topdir}"        >> /root/rpmbuild/.rpmmacros && \
     echo "%_rpmdir %{_topdir}"         >> /root/rpmbuild/.rpmmacros && \
     echo "%_srcrpmdir %{_topdir}"      >> /root/rpmbuild/.rpmmacros

ENV FLAVOR=rpmbuild OS=centos DIST=el7 VERSON_ID=7
VOLUME ["/root/volume"]

WORKDIR /root/rpmbuild
CMD ["/bin/bash"]

