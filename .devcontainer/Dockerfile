FROM almalinux:9

LABEL dev.containers.features="common"

USER root

RUN dnf install -y dnf-plugin-config-manager dnf-plugins-core epel-release \
    && dnf -y copr enable ligenix/enterprise-qemu-wider \
    && dnf config-manager --setopt=*.priority=10 --setopt=*qemu*.priority=1 --save \
    && dnf install -y \
        systemd sudo git git-core openssl diffutils \
        gettext-libs autoconf automake libtool \
        genisoimage dialog freerdp git iproute libnotify nmap-ncat \
        libvirt virt-install virt-manager spice-html5 python3-websockify \
    && (cd /lib/systemd/system/sysinit.target.wants/ ; for i in * ; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i ; done) \
    && rm -f /lib/systemd/system/multi-user.target.wants/* \
    && rm -f /etc/systemd/system/*.wants/* \
    && rm -f /lib/systemd/system/local-fs.target.wants/* \
    && rm -f /lib/systemd/system/sockets.target.wants/*udev* \
    && rm -f /lib/systemd/system/sockets.target.wants/*initctl* \
    && rm -f /lib/systemd/system/basic.target.wants/* \
    && rm -f /lib/systemd/system/anaconda.target.wants/* \
    && dnf clean all \
    && rm -rf /var/cache/yum

RUN systemctl enable libvirtd \
    && systemctl enable virtlockd \
    && systemctl enable virtlogd \
    && sed -i "/Service/a ExecStartPost=\/bin\/chmod 666 /dev/kvm" /usr/lib/systemd/system/libvirtd.service \
    && mkdir -p /var/lib/libvirt/images/

ENV LIBVIRT_DEFAULT_URI="qemu:///system"

ENTRYPOINT ["/usr/sbin/init"]
