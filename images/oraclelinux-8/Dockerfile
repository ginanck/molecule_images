FROM oraclelinux:8

LABEL maintainer="Gorkem Korkmaz"
LABEL description="Oracle Linux 8 image with Python 3.6 optimized for Ansible Molecule testing"
LABEL org.opencontainers.image.source="https://github.com/ginanck/molecule_images"

ENV container=docker
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

# Install system dependencies and Python
RUN dnf clean all \
    && dnf -y install epel-release \
    && dnf -y install --allowerasing --nodocs --setopt=install_weak_deps=False \
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

# Configure systemd
RUN systemctl set-default multi-user.target \
    && systemctl mask \
        dev-hugepages.mount \
        sys-fs-fuse-connections.mount \
        sys-kernel-config.mount \
        display-manager.service \
        graphical.target \
        systemd-logind.service

# Configure SSH
RUN mkdir -p /var/run/sshd \
    && ssh-keygen -A \
    && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config \
    && systemctl enable sshd

# Create a non-root user for testing
RUN useradd -m -s /bin/bash -G wheel ansible \
    && echo 'ansible:ansible' | chpasswd \
    && echo 'ansible ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
    && mkdir -p /home/ansible/.ssh \
    && chown -R ansible:ansible /home/ansible/.ssh

# Set up working directory
WORKDIR /opt/ansible
RUN chown ansible:ansible /opt/ansible

# Create volume for molecule testing
VOLUME ["/sys/fs/cgroup"]

# Expose SSH port
EXPOSE 22

# Use systemd as the init system
CMD ["/usr/sbin/init"]

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD systemctl is-system-running || exit 1
