FROM almalinux:8

LABEL maintainer="Your Name <your.email@example.com>"
LABEL description="AlmaLinux 8 image with Python 3.6 optimized for Ansible Molecule testing"
LABEL org.opencontainers.image.source="https://github.com/your-username/docker-images"

ENV container=docker
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

# Install system dependencies and Python
RUN dnf -y update \
    && dnf -y install epel-release \
    && dnf -y install --allowerasing \
        # Python and development tools
        python3 python3-pip python3-devel \
        # Core system packages
        systemd sudo \
        # Development tools and libraries needed for Python packages
        gcc gcc-c++ make \
        openssl-devel libffi-devel \
        pkgconfig \
        # Rust and cargo for cryptography package building
        rust cargo \
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
        # GPG tools for Docker repository
        gnupg2 \
        # Clean up
        && dnf clean all

# Install Docker
RUN dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo \
    && dnf -y install docker-ce-cli \
    && dnf clean all

# Create symlink for python command
RUN ln -sf /usr/bin/python3 /usr/bin/python

# Upgrade pip and install setuptools-rust for cryptography package
COPY requirements.txt /tmp/
RUN python3 -m pip install --upgrade pip setuptools setuptools-rust
# Set environment variable to skip ansible conflict checks for Python 3.6
ENV ANSIBLE_SKIP_CONFLICT_CHECK=1
RUN python3 -m pip install --no-cache-dir -r /tmp/requirements.txt

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
