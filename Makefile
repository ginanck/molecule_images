# Makefile for Docker Images CI/CD
# Usage: make build, make push, make test, etc.

# Configuration
REGISTRY := ghcr.io
GITHUB_USERNAME := ginanck
REPO_NAME := $(shell basename `git rev-parse --show-toplevel`)

# Image definitions with native Python versions
UBUNTU_IMAGES := ubuntu-2004:20.04:3.8 ubuntu-2204:22.04:3.10 ubuntu-2404:24.04:3.12
DEBIAN_IMAGES := debian-10:10:3.7 debian-11:11:3.9 debian-12:12:3.11
ALMALINUX_IMAGES := almalinux-8:8:3.6 almalinux-9:9:3.9
ROCKYLINUX_IMAGES := rockylinux-8:8:3.6 rockylinux-9:9:3.9

ALL_IMAGES := $(UBUNTU_IMAGES) $(DEBIAN_IMAGES) $(ALMALINUX_IMAGES) $(ROCKYLINUX_IMAGES)

# Default target
.DEFAULT_GOAL := help

# Colors for output
BOLD := \033[1m
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[1;33m
BLUE := \033[0;34m
NC := \033[0m # No Color

# Helper functions
define build_image
	$(eval IMAGE_SPEC := $(1))
	$(eval IMAGE_NAME_FOLDER := $(word 1,$(subst :, ,$(IMAGE_SPEC))))
	$(eval VERSION := $(word 2,$(subst :, ,$(IMAGE_SPEC))))
	$(eval PYTHON_VERSION := $(word 3,$(subst :, ,$(IMAGE_SPEC))))
	$(eval OS := $(word 1,$(subst -, ,$(IMAGE_NAME_FOLDER))))
	$(eval IMAGE_NAME := $(REGISTRY)/$(GITHUB_USERNAME)/molecule-$(OS):$(VERSION))
	$(eval BUILD_CONTEXT := ./images/$(IMAGE_NAME_FOLDER))
	
	@echo "$(BLUE)Building $(IMAGE_NAME_FOLDER) ($(OS):$(VERSION)) with Python $(PYTHON_VERSION)$(NC)"
	@if [ ! -f "$(BUILD_CONTEXT)/Dockerfile" ]; then \
		echo "$(RED)Error: Dockerfile not found at $(BUILD_CONTEXT)/Dockerfile$(NC)"; \
		exit 1; \
	fi
	@cp requirements.txt $(BUILD_CONTEXT)/
	docker build \
		--platform linux/amd64 \
		--tag $(IMAGE_NAME) \
		--tag $(REGISTRY)/$(GITHUB_USERNAME)/molecule-$(OS):latest \
		--label "org.opencontainers.image.source=https://github.com/$(GITHUB_USERNAME)/$(REPO_NAME)" \
		--label "org.opencontainers.image.description=$(OS) $(VERSION) with Python $(PYTHON_VERSION) for Ansible Molecule testing" \
		--label "org.opencontainers.image.version=$(VERSION)" \
		$(BUILD_CONTEXT)
	@rm -f $(BUILD_CONTEXT)/requirements.txt
	@echo "$(GREEN)✅ Successfully built $(IMAGE_NAME)$(NC)"
endef

define push_image
	$(eval IMAGE_SPEC := $(1))
	$(eval IMAGE_NAME_FOLDER := $(word 1,$(subst :, ,$(IMAGE_SPEC))))
	$(eval VERSION := $(word 2,$(subst :, ,$(IMAGE_SPEC))))
	$(eval OS := $(word 1,$(subst -, ,$(IMAGE_NAME_FOLDER))))
	$(eval IMAGE_NAME := $(REGISTRY)/$(GITHUB_USERNAME)/molecule-$(OS):$(VERSION))
	
	@echo "$(BLUE)Pushing $(IMAGE_NAME)$(NC)"
	docker push $(IMAGE_NAME)
	docker push $(REGISTRY)/$(GITHUB_USERNAME)/molecule-$(OS):latest
	@echo "$(GREEN)✅ Successfully pushed $(IMAGE_NAME)$(NC)"
endef

define test_image
	$(eval IMAGE_SPEC := $(1))
	$(eval IMAGE_NAME_FOLDER := $(word 1,$(subst :, ,$(IMAGE_SPEC))))
	$(eval VERSION := $(word 2,$(subst :, ,$(IMAGE_SPEC))))
	$(eval OS := $(word 1,$(subst -, ,$(IMAGE_NAME_FOLDER))))
	$(eval IMAGE_NAME := $(REGISTRY)/$(GITHUB_USERNAME)/molecule-$(OS):$(VERSION))
	
	@echo "$(BLUE)Testing $(IMAGE_NAME)$(NC)"
	@echo "Testing Python..."
	@docker run --rm --platform linux/amd64 $(IMAGE_NAME) python3 --version
	@echo "Testing Ansible..."
	@docker run --rm --platform linux/amd64 $(IMAGE_NAME) ansible --version
	@echo "Testing Molecule..."
	@docker run --rm --platform linux/amd64 $(IMAGE_NAME) molecule --version
	@echo "$(GREEN)✅ Tests passed for $(IMAGE_NAME)$(NC)"
endef

# Help target
.PHONY: help
help: ## Show this help message
	@echo "$(BOLD)Docker Images Makefile$(NC)"
	@echo ""
	@echo "$(BOLD)Available targets:$(NC)"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(BLUE)%-20s$(NC) %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo ""
	@echo "$(BOLD)Available images:$(NC)"
	@echo "  Ubuntu: ubuntu-2004 (20.04, Python 3.9), ubuntu-2204 (22.04, Python 3.10), ubuntu-2404 (24.04, Python 3.11)"
	@echo "  Debian: debian-10 (10, Python 3.9), debian-11 (11, Python 3.10), debian-12 (12, Python 3.11)"
	@echo "  AlmaLinux: almalinux-8 (8, Python 3.9), almalinux-9 (9, Python 3.9)"
	@echo "  Rocky Linux: rockylinux-8 (8, Python 3.9), rockylinux-9 (9, Python 3.9)"
	@echo ""
	@echo "$(BOLD)Examples:$(NC)"
	@echo "  make build-ubuntu-2204     # Build specific image"
	@echo "  make push-ubuntu-2204      # Push specific image"
	@echo "  make test-ubuntu-2204      # Test specific image"
	@echo "  make build-all             # Build all images"
	@echo "  make push-all              # Push all images"

# Check prerequisites
.PHONY: check-prereqs
check-prereqs: ## Check if required tools are installed
	@echo "$(BLUE)Checking prerequisites...$(NC)"
	@command -v docker >/dev/null 2>&1 || { echo "$(RED)Docker is required but not installed$(NC)"; exit 1; }
	@docker info >/dev/null 2>&1 || { echo "$(RED)Docker daemon is not running$(NC)"; exit 1; }
	@command -v git >/dev/null 2>&1 || { echo "$(RED)Git is required but not installed$(NC)"; exit 1; }
	@[ -f requirements.txt ] || { echo "$(RED)requirements.txt not found$(NC)"; exit 1; }
	@echo "$(GREEN)✅ All prerequisites satisfied$(NC)"

# Login to GitHub Container Registry
.PHONY: login
login: ## Login to GitHub Container Registry
	@echo "$(BLUE)Logging in to GitHub Container Registry...$(NC)"
	@echo "$(GITHUB_TOKEN)" | docker login $(REGISTRY) -u $(GITHUB_USERNAME) --password-stdin
	@echo "$(GREEN)✅ Successfully logged in$(NC)"

# Build targets
.PHONY: build-all
build-all: check-prereqs ## Build all Docker images
	@echo "$(BOLD)Building all Docker images...$(NC)"
	@for image in $(ALL_IMAGES); do \
		$(call build_image,$$image) || exit 1; \
	done
	@echo "$(GREEN)$(BOLD)✅ All images built successfully!$(NC)"

.PHONY: build-ubuntu
build-ubuntu: check-prereqs ## Build all Ubuntu images
	@echo "$(BOLD)Building Ubuntu images...$(NC)"
	@for image in $(UBUNTU_IMAGES); do \
		$(call build_image,$$image) || exit 1; \
	done

.PHONY: build-debian
build-debian: check-prereqs ## Build all Debian images
	@echo "$(BOLD)Building Debian images...$(NC)"
	@for image in $(DEBIAN_IMAGES); do \
		$(call build_image,$$image) || exit 1; \
	done

.PHONY: build-almalinux
build-almalinux: check-prereqs ## Build all AlmaLinux images
	@echo "$(BOLD)Building AlmaLinux images...$(NC)"
	@for image in $(ALMALINUX_IMAGES); do \
		$(call build_image,$$image) || exit 1; \
	done

.PHONY: build-rockylinux
build-rockylinux: check-prereqs ## Build all Rocky Linux images
	@echo "$(BOLD)Building Rocky Linux images...$(NC)"
	@for image in $(ROCKYLINUX_IMAGES); do \
		$(call build_image,$$image) || exit 1; \
	done

# Individual build targets
$(foreach image,$(ALL_IMAGES),$(eval $(call INDIVIDUAL_BUILD_TARGET,$(image))))
define INDIVIDUAL_BUILD_TARGET
.PHONY: build-$(word 1,$(subst :, ,$(1)))
build-$(word 1,$(subst :, ,$(1))): check-prereqs ## Build $(word 1,$(subst :, ,$(1))) image
	$(call build_image,$(1))
endef

# Push targets
.PHONY: push-all
push-all: ## Push all Docker images to registry
	@echo "$(BOLD)Pushing all Docker images...$(NC)"
	@for image in $(ALL_IMAGES); do \
		$(call push_image,$$image) || exit 1; \
	done
	@echo "$(GREEN)$(BOLD)✅ All images pushed successfully!$(NC)"

# Individual push targets
$(foreach image,$(ALL_IMAGES),$(eval $(call INDIVIDUAL_PUSH_TARGET,$(image))))
define INDIVIDUAL_PUSH_TARGET
.PHONY: push-$(word 1,$(subst :, ,$(1)))
push-$(word 1,$(subst :, ,$(1))): ## Push $(word 1,$(subst :, ,$(1))) image
	$(call push_image,$(1))
endef

# Test targets
.PHONY: test-all
test-all: ## Test all Docker images
	@echo "$(BOLD)Testing all Docker images...$(NC)"
	@for image in $(ALL_IMAGES); do \
		$(call test_image,$$image) || exit 1; \
	done
	@echo "$(GREEN)$(BOLD)✅ All images tested successfully!$(NC)"

# Individual test targets
$(foreach image,$(ALL_IMAGES),$(eval $(call INDIVIDUAL_TEST_TARGET,$(image))))
define INDIVIDUAL_TEST_TARGET
.PHONY: test-$(word 1,$(subst :, ,$(1)))
test-$(word 1,$(subst :, ,$(1))): ## Test $(word 1,$(subst :, ,$(1))) image
	$(call test_image,$(1))
endef

# Combined targets
.PHONY: build-and-test
build-and-test: build-all test-all ## Build and test all images

.PHONY: build-and-push
build-and-push: build-all push-all ## Build and push all images

.PHONY: all
all: build-and-test push-all ## Build, test, and push all images

# Cleanup targets
.PHONY: clean
clean: ## Remove all built images
	@echo "$(BLUE)Cleaning up images...$(NC)"
	@for image in $(ALL_IMAGES); do \
		IMAGE_NAME_FOLDER=$$(echo $$image | cut -d: -f1); \
		VERSION=$$(echo $$image | cut -d: -f2); \
		OS=$$(echo $$IMAGE_NAME_FOLDER | cut -d- -f1); \
		docker rmi -f $(REGISTRY)/$(GITHUB_USERNAME)/molecule-$$OS:$$VERSION 2>/dev/null || true; \
		docker rmi -f $(REGISTRY)/$(GITHUB_USERNAME)/molecule-$$OS:latest 2>/dev/null || true; \
	done
	@echo "$(GREEN)✅ Cleanup completed$(NC)"

.PHONY: clean-dangling
clean-dangling: ## Remove dangling images
	@echo "$(BLUE)Removing dangling images...$(NC)"
	@docker image prune -f
	@echo "$(GREEN)✅ Dangling images removed$(NC)"

# Info targets
.PHONY: list-images
list-images: ## List all built images
	@echo "$(BOLD)Built images:$(NC)"
	@docker images | grep "$(REGISTRY)/$(GITHUB_USERNAME)/molecule-" || echo "No images found"

.PHONY: info
info: ## Show configuration information
	@echo "$(BOLD)Configuration:$(NC)"
	@echo "  Registry: $(REGISTRY)"
	@echo "  GitHub Username: $(GITHUB_USERNAME)"
	@echo "  Repository: $(REPO_NAME)"
	@echo ""
	@echo "$(BOLD)Images to build:$(NC)"
	@for image in $(ALL_IMAGES); do \
		IMAGE_NAME_FOLDER=$$(echo $$image | cut -d: -f1); \
		VERSION=$$(echo $$image | cut -d: -f2); \
		PYTHON=$$(echo $$image | cut -d: -f3); \
		OS=$$(echo $$IMAGE_NAME_FOLDER | cut -d- -f1); \
		echo "  $(REGISTRY)/$(GITHUB_USERNAME)/molecule-$$OS:$$VERSION ($$IMAGE_NAME_FOLDER, Python $$PYTHON)"; \
	done

# Development targets
.PHONY: dev-build
dev-build: ## Quick build for development (Ubuntu 22.04 only)
	$(call build_image,ubuntu-2204:22.04:3.10)

.PHONY: dev-test
dev-test: ## Quick test for development (Ubuntu 22.04 only)
	$(call test_image,ubuntu-2204:22.04:3.10)

# Security scan
.PHONY: scan
scan: ## Run security scan on Ubuntu 22.04 image
	@echo "$(BLUE)Running security scan...$(NC)"
	@docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
		aquasec/trivy:latest image $(REGISTRY)/$(GITHUB_USERNAME)/molecule-ubuntu:22.04

# Generate documentation
.PHONY: docs
docs: ## Generate image documentation
	@echo "$(BOLD)Generating documentation...$(NC)"
	@echo "# Available Docker Images" > IMAGES.md
	@echo "" >> IMAGES.md
	@for image in $(ALL_IMAGES); do \
		IMAGE_NAME_FOLDER=$$(echo $$image | cut -d: -f1); \
		VERSION=$$(echo $$image | cut -d: -f2); \
		PYTHON=$$(echo $$image | cut -d: -f3); \
		OS=$$(echo $$IMAGE_NAME_FOLDER | cut -d- -f1); \
		echo "## $$IMAGE_NAME_FOLDER ($$OS $$VERSION)" >> IMAGES.md; \
		echo "" >> IMAGES.md; \
		echo "- **Base OS**: $$OS $$VERSION" >> IMAGES.md; \
		echo "- **Python Version**: $$PYTHON" >> IMAGES.md; \
		echo "- **Image**: \`$(REGISTRY)/$(GITHUB_USERNAME)/molecule-$$OS:$$VERSION\`" >> IMAGES.md; \
		echo "- **Pull Command**: \`docker pull $(REGISTRY)/$(GITHUB_USERNAME)/molecule-$$OS:$$VERSION\`" >> IMAGES.md; \
		echo "" >> IMAGES.md; \
	done
	@echo "$(GREEN)✅ Documentation generated in IMAGES.md$(NC)"
