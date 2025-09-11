# Molecule Docker Images

A collection of Docker images optimized for Ansible Molecule testing and CI/CD pipelines, built with consistent Python versions and comprehensive Ansible tooling.

## 🐳 Available Images

| OS | Version | Python | Docker Hub | Pull Command |
|----|---------|--------|------------|--------------|
| Ubuntu | 20.04 | 3.9 | `ghcr.io/your-username/molecule-ubuntu:20.04` | `docker pull ghcr.io/your-username/molecule-ubuntu:20.04` |
| Ubuntu | 22.04 | 3.10 | `ghcr.io/your-username/molecule-ubuntu:22.04` | `docker pull ghcr.io/your-username/molecule-ubuntu:22.04` |
| Ubuntu | 24.04 | 3.11 | `ghcr.io/your-username/molecule-ubuntu:24.04` | `docker pull ghcr.io/your-username/molecule-ubuntu:24.04` |
| Debian | 10 | 3.9 | `ghcr.io/your-username/molecule-debian:10` | `docker pull ghcr.io/your-username/molecule-debian:10` |
| Debian | 11 | 3.10 | `ghcr.io/your-username/molecule-debian:11` | `docker pull ghcr.io/your-username/molecule-debian:11` |
| Debian | 12 | 3.11 | `ghcr.io/your-username/molecule-debian:12` | `docker pull ghcr.io/your-username/molecule-debian:12` |
| AlmaLinux | 8 | 3.9 | `ghcr.io/your-username/molecule-almalinux:8` | `docker pull ghcr.io/your-username/molecule-almalinux:8` |
| AlmaLinux | 9 | 3.9 | `ghcr.io/your-username/molecule-almalinux:9` | `docker pull ghcr.io/your-username/molecule-almalinux:9` |
| Rocky Linux | 8 | 3.9 | `ghcr.io/your-username/molecule-rockylinux:8` | `docker pull ghcr.io/your-username/molecule-rockylinux:8` |
| Rocky Linux | 9 | 3.9 | `ghcr.io/your-username/molecule-rockylinux:9` | `docker pull ghcr.io/your-username/molecule-rockylinux:9` |

## 🚀 Features

- **Consistent Python Versions**: Each OS family uses optimized Python versions
- **Pre-installed Ansible Stack**: Ansible 8.x, Molecule 6.x, ansible-lint, yamllint
- **systemd Support**: Full systemd support for service testing
- **SSH Ready**: Pre-configured SSH server and client
- **Multi-architecture**: Support for amd64 and arm64 platforms
- **Optimized Builds**: Multi-stage builds with Python base images for smaller sizes
- **Regular Updates**: Automated builds and security updates

## 📦 What's Included

Each image includes:
- **Python**: Version-specific Python installation (3.9, 3.10, or 3.11)
- **Ansible**: Latest Ansible 8.x with comprehensive collections
- **Testing Tools**: Molecule, ansible-lint, yamllint, pytest, testinfra
- **System Tools**: systemd, SSH, sudo, git, curl, wget, vim
- **Development Libraries**: Build tools and Python development headers
- **Non-root User**: `ansible` user with sudo privileges for testing

## 📁 Repository Structure

```
images/
├── ubuntu-2004/          # Ubuntu 20.04 with Python 3.9
├── ubuntu-2204/          # Ubuntu 22.04 with Python 3.10
├── ubuntu-2404/          # Ubuntu 24.04 with Python 3.11
├── debian-10/            # Debian 10 with Python 3.9
├── debian-11/            # Debian 11 with Python 3.10
├── debian-12/            # Debian 12 with Python 3.11
├── almalinux-8/          # AlmaLinux 8 with Python 3.9
├── almalinux-9/          # AlmaLinux 9 with Python 3.9
├── rockylinux-8/         # Rocky Linux 8 with Python 3.9
└── rockylinux-9/         # Rocky Linux 9 with Python 3.9
```

## 📋 Python Version Matrix

| OS Family | Versions | Python Version | Base Image |
|-----------|----------|----------------|------------|
| Ubuntu | 20.04 | 3.9 | python:3.9-slim-bullseye |
| Ubuntu | 22.04 | 3.10 | python:3.10-slim-bullseye |
| Ubuntu | 24.04 | 3.11 | python:3.11-slim-bookworm |
| Debian | 10 (Buster) | 3.9 | python:3.9-slim-buster |
| Debian | 11 (Bullseye) | 3.10 | python:3.10-slim-bullseye |
| Debian | 12 (Bookworm) | 3.11 | python:3.11-slim-bookworm |
| AlmaLinux | 8, 9 | 3.9 | python:3.9-slim-bullseye |
| Rocky Linux | 8, 9 | 3.9 | python:3.9-slim-bullseye |

## 🔧 Usage

### Using Makefile (Recommended)

```bash
# Build all images
make build-all

# Build specific OS family
make build-ubuntu
make build-debian
make build-almalinux
make build-rockylinux

# Build specific image
make build-ubuntu-2204
make build-debian-12

# Test all images
make test-all

# Test specific image
make test-ubuntu-2204

# Push to GitHub Container Registry
make push-all
make push-ubuntu-2204

# Build, test, and push everything
make all

# Get help
make help
```

### In GitHub Actions

```yaml
jobs:
  molecule:
    runs-on: ubuntu-latest
    container:
      image: ghcr.io/your-username/molecule-ubuntu:22.04
      credentials:
        username: ${{ github.actor }}
        password: ${{ secrets.GITHUB_TOKEN }}
    steps:
      - uses: actions/checkout@v4
      - name: Run Molecule
        run: molecule test
```

### In GitLab CI

```yaml
test:
  image: ghcr.io/your-username/molecule-ubuntu:22.04
  script:
    - molecule test
```

### Local Testing

```bash
# Pull and run interactively
docker run -it --rm ghcr.io/your-username/molecule-ubuntu:22.04 /bin/bash

# Mount your project and test
docker run -it --rm \
  -v $(pwd):/workspace \
  -w /workspace \
  ghcr.io/your-username/molecule-ubuntu:22.04 \
  molecule test
```

## 🏗️ Building Locally

### Prerequisites

- Docker 20.10+
- Make
- Git

### Quick Start

```bash
# Clone the repository
git clone https://github.com/your-username/docker-images.git
cd docker-images

# Check prerequisites
make check-prereqs

# Build development image (Ubuntu 22.04)
make dev-build

# Test development image
make dev-test

# Build all images
make build-all

# Build and test all images
make build-and-test
```

### Manual Build

```bash
# Build a specific image manually
docker build -t ghcr.io/your-username/molecule-ubuntu:22.04 \
  --build-arg PYTHON_VERSION=3.10 \
  ./images/ubuntu-2204

# Test the image
docker run --rm ghcr.io/your-username/molecule-ubuntu:22.04 python3 --version
docker run --rm ghcr.io/your-username/molecule-ubuntu:22.04 ansible --version
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Add or modify Dockerfiles in the `images/` directory
4. Update the Makefile if needed
5. Test your changes locally with `make test-all`
6. Submit a pull request

## 📋 Requirements

- Docker 20.10+
- Make (for using Makefile)
- Git (for version control)

## 🔄 Automated Builds

Images are automatically built and pushed to GitHub Container Registry on:
- Push to main branch
- Weekly schedule (Sundays at 2 AM UTC for security updates)
- Manual workflow dispatch
- Pull requests (build only, no push)

## 🏷️ Versioning and Tagging

- `latest` - Always points to the most recent build of each OS
- OS version tags (e.g., `22.04`, `11`, `9`)
- Date-based tags for scheduled builds (`YYYY-MM-DD`)

## 🛡️ Security

- Weekly automated security scans with Trivy
- Regular base image updates
- Minimal attack surface with optimized builds
- Non-root user for container execution

## 📝 License

MIT License - see [LICENSE](LICENSE) file for details.

---

**Note**: Replace `your-username` with your actual GitHub username in all examples above.
