# Docker Images Repository for CI/CD

This repository contains Docker images optimized for Ansible Molecule testing and CI/CD pipelines.

## Project Structure
- `images/` - Contains Dockerfiles for different OS variants
- `.github/workflows/` - GitHub Actions workflows for building and pushing images
- `scripts/` - Helper scripts for building and testing images

## Docker Images
- Ubuntu variants (20.04, 22.04, 24.04)
- CentOS variants (7, 8, 9)
- Debian variants (11, 12)

## Build Strategy
Uses GitHub Actions matrix strategy to build all image variants automatically and push to Docker Hub.

## Progress Checklist
- [x] Clarify Project Requirements - Docker image repository for CI/CD
- [x] Scaffold the Project
- [x] Customize the Project
- [x] Install Required Extensions - No extensions needed
- [x] Compile the Project - N/A for Docker images
- [x] Create and Run Task - N/A for Docker images
- [x] Launch the Project - N/A for Docker images
- [x] Ensure Documentation is Complete
