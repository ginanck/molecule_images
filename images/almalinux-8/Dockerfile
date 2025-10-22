FROM almalinux:8.10

LABEL maintainer="Gorkem Korkmaz"
LABEL org.opencontainers.image.source=https://github.com/ginanck/molecule_images
LABEL org.opencontainers.image.description="AlmaLinux 8 image"

ENV container=docker
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

# Install system dependencies and Python
RUN dnf -y update \
    && dnf -y install epel-release \
    && dnf -y install --allowerasing --nodocs \
        python3 python3-pip \
        systemd sudo \
        openssl-devel libffi-devel \
        openssh-server openssh-clients \
        git curl wget gpg \
        procps-ng \
        ca-certificates \
        && dnf clean all \
        && rm -rf /var/cache/dnf /var/log/*

# Create symlink for python command
RUN ln -sf /usr/bin/python3 /usr/bin/python

RUN systemctl set-default multi-user.target \
    && systemctl mask \
        dev-hugepages.mount \
        sys-fs-fuse-connections.mount \
        sys-kernel-config.mount \
        display-manager.service \
        graphical.target \
        systemd-logind.service

RUN mkdir -p /var/run/sshd \
    && ssh-keygen -A \
    && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config \
    && systemctl enable sshd

RUN useradd -m -s /bin/bash -G wheel ansible \
    && echo 'ansible:ansible' | chpasswd \
    && echo 'ansible ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
    && mkdir -p /home/ansible/.ssh \
    && chown -R ansible:ansible /home/ansible/.ssh

WORKDIR /opt/ansible
RUN chown ansible:ansible /opt/ansible

VOLUME ["/sys/fs/cgroup"]

EXPOSE 22

CMD ["/usr/sbin/init"]

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD systemctl is-system-running || exit 1
