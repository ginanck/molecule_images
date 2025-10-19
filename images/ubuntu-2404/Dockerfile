FROM ubuntu:24.04

LABEL maintainer="Gorkem Korkmaz"
LABEL description="Ubuntu 24.04 image with Python 3.12 optimized for Ansible Molecule testing"
LABEL org.opencontainers.image.source="https://github.com/ginanck/molecule_images"

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive
ENV container=docker
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

# Set timezone
ENV TZ=UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies and Python
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 python3-pip python3-dev python3-venv \
    systemd \
    sudo \
    libffi-dev \
    libssl-dev \
    openssh-server openssh-client \
    git curl wget \
    procps \
    ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Create symlink for python command
RUN ln -sf /usr/bin/python3 /usr/bin/python

COPY requirements.txt /tmp/
RUN python3 -m pip install --no-cache-dir --break-system-packages -r /tmp/requirements.txt \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Configure systemd
RUN systemctl set-default multi-user.target \
    && systemctl mask \
        dev-hugepages.mount \
        sys-fs-fuse-connections.mount \
        sys-kernel-config.mount \
        display-manager.service \
        graphical.target \
        systemd-logind.service \
        systemd-resolved.service

# Configure SSH
RUN mkdir -p /var/run/sshd \
    && ssh-keygen -A \
    && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config \
    && systemctl enable ssh

# Create a non-root user for testing
RUN useradd -m -s /bin/bash -G sudo ansible \
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
CMD ["/lib/systemd/systemd"]

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD systemctl is-system-running || exit 1
