FROM centos:6.8

ENV container docker

RUN \
  (echo 'include_only=.jp' >>/etc/yum/pluginconf.d/fastestmirror.conf) \
  && yum -y update \
  && yum -y reinstall glibc-common \
  && yum clean all \
  && cp -f /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
COPY files/etc/sysconfig/i18n /etc/sysconfig/i18n
COPY files/etc/sysconfig/clock /etc/sysconfig/clock
COPY files/etc/sysconfig/keyboard /etc/sysconfig/keyboard

ENV LANG ja_JP.UTF-8

RUN \
  yum -y install openssh-server openssh-clients passwd sudo \
  && yum clean all \
  && sed -ri 's/^#UseDNS yes/UseDNS no/' /etc/ssh/sshd_config \
  && sed -ri 's/^GSSAPIAuthentication yes/GSSAPIAuthentication no/' /etc/ssh/sshd_config \
  && sed -ri 's/^UsePrivilegeSeparation sandbox/UsePrivilegeSeparation no/' /etc/ssh/sshd_config \
  && sed -ri 's/^UsePAM yes/UsePAM no/' /etc/ssh/sshd_config \
  && chkconfig sshd on

RUN \
  (echo "root" | passwd root --stdin) \
  && groupadd docker \
  && useradd -g docker docker \
  && (echo "docker" | passwd docker --stdin) \
  && sed -i 's/Defaults.*requiretty/#Defaults requiretty/g' /etc/sudoers \
  && ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key \
  && ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key \
  && sed -ri 's/session    required     pam_loginuid.so/#session    required     pam_loginuid.so/g' /etc/pam.d/sshd \
  && (echo "docker ALL=(ALL) NOPASSWD: ALL" >/etc/sudoers.d/docker)

CMD ["/sbin/init"]
