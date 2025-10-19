# Molecule Docker Images

A collection of Docker images optimized for Ansible Molecule testing and CI/CD pipelines, built with consistent Python versions and comprehensive Ansible tooling.

## 🐳 Available Images

| OS | Version | Python | Docker Hub | Pull Command |
|----|---------|--------|------------|--------------|
| Ubuntu | 20.04 | 3.8 | `ghcr.io/ginanck/molecule-ubuntu:20.04` | `docker pull ghcr.io/ginanck/molecule-ubuntu:20.04` |
| Ubuntu | 22.04 | 3.10 | `ghcr.io/ginanck/molecule-ubuntu:22.04` | `docker pull ghcr.io/ginanck/molecule-ubuntu:22.04` |
| Ubuntu | 24.04 | 3.12 | `ghcr.io/ginanck/molecule-ubuntu:24.04` | `docker pull ghcr.io/ginanck/molecule-ubuntu:24.04` |
| Debian | 10 | 3.7 | `ghcr.io/ginanck/molecule-debian:10` | `docker pull ghcr.io/ginanck/molecule-debian:10` |
| Debian | 11 | 3.9 | `ghcr.io/ginanck/molecule-debian:11` | `docker pull ghcr.io/ginanck/molecule-debian:11` |
| Debian | 12 | 3.11 | `ghcr.io/ginanck/molecule-debian:12` | `docker pull ghcr.io/ginanck/molecule-debian:12` |
| AlmaLinux | 8 | 3.6 | `ghcr.io/ginanck/molecule-almalinux:8` | `docker pull ghcr.io/ginanck/molecule-almalinux:8` |
| AlmaLinux | 9 | 3.9 | `ghcr.io/ginanck/molecule-almalinux:9` | `docker pull ghcr.io/ginanck/molecule-almalinux:9` |
| Rocky Linux | 8 | 3.6 | `ghcr.io/ginanck/molecule-rockylinux:8` | `docker pull ghcr.io/ginanck/molecule-rockylinux:8` |
| Rocky Linux | 9 | 3.9 | `ghcr.io/ginanck/molecule-rockylinux:9` | `docker pull ghcr.io/ginanck/molecule-rockylinux:9` |
| Oracle Linux | 8 | 3.6 | `ghcr.io/ginanck/molecule-oraclelinux:8` | `docker pull ghcr.io/ginanck/molecule-oraclelinux:8` |
| Oracle Linux | 9 | 3.9 | `ghcr.io/ginanck/molecule-oraclelinux:9` | `docker pull ghcr.io/ginanck/molecule-oraclelinux:9` |

## 🚀 Features

- **Native Python Versions**: Each distribution uses its native Python version for authentic testing
- **Pre-installed Ansible Stack**: Ansible 8.x, Molecule 6.x, ansible-lint, yamllint
- **systemd Support**: Full systemd support for service testing
- **SSH Ready**: Pre-configured SSH server and client
- **Multi-architecture**: Support for amd64 and arm64 platforms
- **Authentic Distributions**: Each image uses distribution-native packages and tools
- **Regular Updates**: Automated builds and security updates

## 📦 What's Included

Each image includes:
- **Python**: Version-specific Python installation (3.6 to 3.12)
- **Ansible**: Latest Ansible 8.x with comprehensive collections
- **Testing Tools**: Molecule, ansible-lint, yamllint, pytest, testinfra
- **System Tools**: systemd, SSH, sudo, git, curl, wget, vim
- **Development Libraries**: Build tools and Python development headers
- **Non-root User**: `ansible` user with sudo privileges for testing

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
make build-oraclelinux

# Build specific image
make build IMAGE=ubuntu-2204
make build IMAGE=debian-12

# Test all images
make test-all

# Test specific image
make test IMAGE=ubuntu-2204

# Push to GitHub Container Registry
make push-all
make push IMAGE=ubuntu-2204

# Build, test, and push everything
make all

# Get help
make help
```

### In CI/CD Pipelines

Use the images in your GitHub Actions, GitLab CI, or other CI systems:

```yaml
# GitHub Actions example
jobs:
  molecule:
    runs-on: ubuntu-latest
    container:
      image: ghcr.io/ginanck/molecule-ubuntu:22.04
    steps:
      - uses: actions/checkout@v4
      - name: Run Molecule
        run: molecule test
```

### Local Testing

```bash
# Pull and run interactively
docker run -it --rm ghcr.io/ginanck/molecule-ubuntu:22.04 /bin/bash

# Mount your project and test
docker run -it --rm \
  -v $(pwd):/workspace \
  -w /workspace \
  ghcr.io/ginanck/molecule-ubuntu:22.04 \
  molecule test
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Add or modify Dockerfiles in the `images/` directory
4. Update the Makefile if needed
5. Test your changes locally with `make test-all`
6. Submit a pull request

## 📝 License

MIT License - see [LICENSE](LICENSE) file for details.
