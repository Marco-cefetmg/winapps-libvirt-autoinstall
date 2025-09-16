FROM almalinux:9

LABEL dev.containers.features="common"

USER root

RUN dnf install -y \
        systemd sudo git git-core openssl diffutils \
        gettext-libs autoconf automake libtool \
    && dnf clean all \
    && rm -rf /var/cache/yum

ENTRYPOINT ["/sbin/init"]
