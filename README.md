# Molecule Docker Images

Lightweight Docker images optimized for Ansible Molecule testing with pre-installed Ansible, Python, and testing tools.

## Table of Contents

- [Available Images](#available-images)
- [Quick Start](#quick-start)
- [Features](#features)
- [Local Development](#local-development)
- [License](#license)

## Available Images

### Ubuntu Images

| Version | Python | Docker Tags             |
|---------|--------|-------------------------|
| 24.04   | 3.12   | `24.04-latest`, `24.04` |
| 22.04   | 3.10   | `22.04-latest`, `22.04` |
| 20.04   | 3.8    | `20.04-latest`, `20.04` |

### Debian Images

| Version | Python | Docker Tags       |
|---------|--------|-------------------|
| 13      | 3.11   | `13-latest`, `13` |
| 12      | 3.11   | `12-latest`, `12` |
| 11      | 3.9    | `11-latest`, `11` |
| 10      | 3.7    | `10-latest`, `10` |

### AlmaLinux Images

| Version  | Python | Docker Tags       |
|----------|--------|-------------------|
| 10       | 3.9    | `10-latest`, `10` |
| 9        | 3.9    | `9-latest`, `9`   |
| 8        | 3.6 (3.11 installed) | `8-latest`, `8`   |

### Rocky Linux Images

| Version  | Python | Docker Tags       |
|----------|--------|-------------------|
| 10       | 3.9    | `10-latest`, `10` |
| 9        | 3.9    | `9-latest`, `9`   |
| 8        | 3.6 (3.11 installed) | `8-latest`, `8`   |

### Oracle Linux Images

| Version  | Python | Docker Tags       |
|----------|--------|-------------------|
| 10       | 3.9    | `10-latest`, `10` |
| 9        | 3.9    | `9-latest`, `9`   |
| 8        | 3.6 (3.11 installed) | `8-latest`, `8`   |

## Quick Start

1. **Pull an image:**

   ```bash
   docker pull ghcr.io/ginanck/molecule-ubuntu:latest
   ```

2. **Run Molecule tests:**

   ```bash
   docker run -it --rm -v $(pwd):/workspace -w /workspace ghcr.io/ginanck/molecule-ubuntu:latest molecule test
   ```

3. **Interactive shell:**

   ```bash
   docker run -it --rm ghcr.io/ginanck/molecule-ubuntu:latest /bin/bash
   ```

## Features

Each image includes:

- **Ansible Ecosystem**: ansible-core, ansible-lint, ansible-compat
- **Molecule Testing**: molecule, molecule-docker, molecule-podman
- **Python Tools**: flake8, cryptography, PyYAML
- **System Tools**: Docker CLI, Git, SSH client, Bash, `iproute` (Ansible network facts)
- **Build Tools**: GCC, musl-dev, libffi-dev (for package compilation)
- **Collections**: Pre-installed community.docker collection
- **User Setup**: Dedicated `ansible` user (UID 1000) with proper permissions
- **Multi-Architecture Support**: Images are built for both AMD64 and ARM64 architectures

## Image contract

Every image provides, for Molecule to work unchanged across distros:

- systemd as PID 1, with the usual container masks, so `systemd`-managed roles can be tested.
- `sshd` enabled and an `ansible` user (UID 1000, sudo without password).
- `iproute`/`iproute2`, so Ansible gathers `ansible_default_ipv4`, `ansible_interfaces` and the
  other network facts.
- A Python interpreter that ansible-core 2.17+ can manage. Rocky 8, AlmaLinux 8 and Oracle Linux 8
  ship 3.6 by default; those images also install Python 3.11 and set
  `ANSIBLE_PYTHON_INTERPRETER=/usr/bin/python3.11`, leaving the system interpreter untouched.
  Debian 10 ships 3.7, which is below the ansible-core 2.21 target minimum: use the Debian 11+
  images or a legacy runner for Debian 10.

## Local Development

Build images manually

   ```bash
   docker build -t molecule-ubuntu:24.04 ./images/ubuntu-2404
   docker build -t molecule-debian:12 ./images/debian-12
   docker build -t molecule-rockylinux:9 ./images/rockylinux-9
   ```

### GitHub Actions

The repository uses GitHub Actions to automatically build and push images to GitHub Container Registry on:

- **Push to master**: Builds and pushes all versions
- **Pull Requests**: Builds images for testing (no push)
- **Manual Trigger**: Workflow can be manually triggered with force push option

Images are built for multiple architectures (AMD64 and ARM64) and tagged with:

- `version-latest` - Latest build for specific version
- `version` - Specific version tag

## License

MIT License - see [LICENSE](LICENSE) file for details.
