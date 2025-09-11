FROM python:3.9-slim-bullseye as base

# Use AlmaLinux 9 as the final base
FROM almalinux:9

LABEL maintainer="Your Name <your.email@example.com>"
LABEL description="AlmaLinux 9 image with Python 3.9 optimized for Ansible Molecule testing"
LABEL org.opencontainers.image.source="https://github.com/your-username/docker-images"

ENV container=docker
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

# Copy Python from the python base image
COPY --from=base /usr/local /usr/local

# Install system dependencies
RUN dnf -y update \
    && dnf -y install \
        # Core system packages
        systemd sudo \
        # Development tools and libraries needed for Python packages
        gcc gcc-c++ make \
        openssl-devel libffi-devel \
        pkgconfig \
        # SSH
        openssh-server openssh-clients \
        # Development tools
        git curl wget vim nano \
        # Network tools
        iproute net-tools \
        # Archive tools
        tar gzip unzip \
        # Process management
        procps-ng \
        # Certificate management
        ca-certificates \
        # Additional tools
        rsync \
        # EPEL repository for additional packages
        epel-release \
    && dnf clean all \
    && rm -rf /var/cache/dnf

# Copy requirements and install Python packages
COPY requirements.txt /tmp/requirements.txt
RUN pip3 install --no-cache-dir --upgrade pip setuptools wheel \
    && pip3 install --no-cache-dir -r /tmp/requirements.txt \
    && rm /tmp/requirements.txt

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
