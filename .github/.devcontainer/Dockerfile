FROM almalinux:9

LABEL dev.containers.features="common"

USER root

RUN dnf install -y dnf-plugin-config-manager dnf-plugins-core epel-release \
    && dnf -y copr enable ligenix/enterprise-qemu-wider \
    && dnf config-manager --setopt=*.priority=10 --setopt=*qemu*.priority=1 --save \
    && dnf install -y \
        systemd sudo \
        gawk bash-completion openssh-clients gnupg2 iproute procps lsof \
        net-tools psmisc wget ca-certificates rsync unzip xz zip nano \
        vim-minimal less jq openssl-libs krb5-libs libicu zlib sudo sed \
        grep which man-db strace git zsh \
        genisoimage dialog freerdp libnotify nmap-ncat \
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

RUN usermod -aG libvirt root && usermod -aG kvm root

RUN systemctl enable libvirtd \
    && systemctl enable virtlockd \
    && systemctl enable virtlogd \
    && sed -i "/Service/a ExecStartPost=bash -c \"\/bin\/chmod 666 /dev/kvm && \/sbin\/usermod -aG libvirt,kvm vscode\"" /usr/lib/systemd/system/libvirtd.service \
    && sed -i "s/#remember_owner = 1/remember_owner = 0/g" /etc/libvirt/qemu.conf \
    && mkdir -p /var/lib/libvirt/images/

ENV LIBVIRT_DEFAULT_URI="qemu:///system"

ENTRYPOINT ["/usr/sbin/init"]
