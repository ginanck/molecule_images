FROM python:3.10-slim-bullseye as base

# Use Ubuntu 22.04 as the final base
FROM ubuntu:22.04

LABEL maintainer="Your Name <your.email@example.com>"
LABEL description="Ubuntu 22.04 image with Python 3.10 optimized for Ansible Molecule testing"
LABEL org.opencontainers.image.source="https://github.com/your-username/docker-images"

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive
ENV container=docker
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

# Set timezone
ENV TZ=UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Copy Python from the python base image
COPY --from=base /usr/local /usr/local

# Install system dependencies
RUN apt-get update && apt-get install -y \
    # Core system packages
    systemd systemd-cron \
    sudo \
    # Development tools and libraries needed for Python packages
    build-essential \
    libffi-dev \
    libssl-dev \
    pkg-config \
    # SSH
    openssh-server openssh-client \
    # Development tools
    git curl wget vim nano \
    # Network tools
    iproute2 iputils-ping net-tools \
    # Archive tools
    tar gzip unzip \
    # Process management
    procps \
    # Certificate management
    ca-certificates \
    # Additional tools
    rsync \
    lsb-release \
    # Clean up
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

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
