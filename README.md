# Molecule Docker Images

Docker images optimized for Ansible Molecule testing with pre-installed Ansible, Python, and testing tools.

## Table of Contents

- [Ubuntu Images](#ubuntu-images)
- [Debian Images](#debian-images)  
- [AlmaLinux Images](#almalinux-images)
- [Rocky Linux Images](#rocky-linux-images)
- [Oracle Linux Images](#oracle-linux-images)
- [Quick Start](#quick-start)
- [License](#license)

## Ubuntu Images

| Version | Python | Docker Pull Command |
|---------|--------|---------------------|
| 24.04   | 3.12   | `docker pull ghcr.io/ginanck/molecule-ubuntu:24.04` |
| 22.04   | 3.10   | `docker pull ghcr.io/ginanck/molecule-ubuntu:22.04` |
| 20.04   | 3.8    | `docker pull ghcr.io/ginanck/molecule-ubuntu:20.04` |

## Debian Images

| Version | Python | Docker Pull Command |
|---------|--------|---------------------|
| 12      | 3.11   | `docker pull ghcr.io/ginanck/molecule-debian:12` |
| 11      | 3.9    | `docker pull ghcr.io/ginanck/molecule-debian:11` |
| 10      | 3.7    | `docker pull ghcr.io/ginanck/molecule-debian:10` |

## AlmaLinux Images

| Version | Python | Docker Pull Command |
|---------|--------|---------------------|
| 9       | 3.9    | `docker pull ghcr.io/ginanck/molecule-almalinux:9` |
| 8       | 3.6    | `docker pull ghcr.io/ginanck/molecule-almalinux:8` |

## Rocky Linux Images

| Version | Python | Docker Pull Command |
|---------|--------|---------------------|
| 9       | 3.9    | `docker pull ghcr.io/ginanck/molecule-rockylinux:9` |
| 8       | 3.6    | `docker pull ghcr.io/ginanck/molecule-rockylinux:8` |

## Oracle Linux Images

| Version | Python | Docker Pull Command |
|---------|--------|---------------------|
| 9       | 3.9    | `docker pull ghcr.io/ginanck/molecule-oraclelinux:9` |
| 8       | 3.6    | `docker pull ghcr.io/ginanck/molecule-oraclelinux:8` |

## Quick Start

1. **Pull an image:**

   ```bash
   docker pull ghcr.io/ginanck/molecule-ubuntu:22.04
   ```

2. **Run Molecule tests:**

   ```bash
   docker run -it --rm -v $(pwd):/workspace -w /workspace ghcr.io/ginanck/molecule-ubuntu:22.04 molecule test
   ```

3. **Interactive shell:**

   ```bash
   docker run -it --rm ghcr.io/ginanck/molecule-ubuntu:22.04 /bin/bash
   ```

Each image includes Ansible, Molecule, ansible-lint, yamllint, and systemd support for comprehensive testing.

## Local Development

Build images locally using the provided Makefile:

1. **Build a specific image:**

   ```bash
   make build IMAGE=ubuntu-2204
   make build IMAGE=debian-12
   make build IMAGE=rockylinux-9
   ```

2. **Build all images for a distribution:**

   ```bash
   make build-ubuntu     # Builds all Ubuntu images
   make build-debian     # Builds all Debian images
   make build-almalinux  # Builds all AlmaLinux images
   make build-rockylinux # Builds all Rocky Linux images
   make build-oraclelinux # Builds all Oracle Linux images
   ```

3. **Build all images:**

   ```bash
   make build-all
   ```

4. **Test images after building:**

   ```bash
   make test IMAGE=ubuntu-2204  # Test specific image
   make test-all                # Test all built images
   ```

5. **See all available commands:**

   ```bash
   make help
   ```

## License

MIT License - see [LICENSE](LICENSE) file for details.
