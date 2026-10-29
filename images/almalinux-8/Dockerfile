FROM almalinux:8.10

LABEL maintainer="Gorkem Korkmaz"
LABEL org.opencontainers.image.source=https://github.com/ginanck/molecule_images
LABEL org.opencontainers.image.description="AlmaLinux 8 image"

ENV container=docker
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

# Oracle/Alma/Rocky mirrors occasionally fail DNS resolution on CI runners.
# Make dnf retry package downloads instead of failing the whole layer.
RUN printf 'retries=10\ntimeout=60\nminrate=0\n' >> /etc/dnf/dnf.conf

# Install system dependencies and Python
RUN dnf -y update \
    && dnf -y install epel-release \
    && dnf -y install --allowerasing --nodocs \
        python3 python3-pip \
        python3.11 \
        systemd sudo \
        openssl-devel libffi-devel \
        openssh-server openssh-clients \
        git curl wget gpg \
        procps-ng \
        iproute \
        ca-certificates \
        && dnf clean all \
        && rm -rf /var/cache/dnf /var/log/*

# EL8 ships Python 3.6, which ansible-core 2.17+ cannot manage.
# Install 3.11 and point Ansible at it; the system Python stays untouched.
ENV ANSIBLE_PYTHON_INTERPRETER=/usr/bin/python3.11

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
