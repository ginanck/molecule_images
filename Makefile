# Makefile for Molecule Docker Images
# Simple and robust commands to build, test, and push Docker images for Ansible Molecule testing

# Configuration
REGISTRY := ghcr.io
GITHUB_USERNAME := ginanck

# Image definitions: folder_name:version:python_version
IMAGES := \
	ubuntu-2004:20.04:3.8 \
	ubuntu-2204:22.04:3.10 \
	ubuntu-2404:24.04:3.12 \
	debian-10:10:3.7 \
	debian-11:11:3.9 \
	debian-12:12:3.11 \
	almalinux-8:8:3.6 \
	almalinux-9:9:3.9 \
	rockylinux-8:8:3.6 \
	rockylinux-9:9:3.9 \
	oraclelinux-8:8:3.6 \
	oraclelinux-9:9:3.9

# Colors for output
BLUE := \033[0;34m
GREEN := \033[0;32m
RED := \033[0;31m
NC := \033[0m

# Default goal
.DEFAULT_GOAL := help

# Prerequisites check
.PHONY: check-prereqs
check-prereqs:
	@echo "$(BLUE)Checking prerequisites...$(NC)"
	@which docker > /dev/null || (echo "$(RED)❌ Docker not found. Please install Docker 20.10+.$(NC)"; exit 1)
	@docker --version | grep -q "20\." || (echo "$(RED)❌ Docker version 20.10+ required.$(NC)"; exit 1)
	@which make > /dev/null || (echo "$(RED)❌ Make not found.$(NC)"; exit 1)
	@test -f requirements-common.txt || (echo "$(RED)❌ requirements-common.txt not found.$(NC)"; exit 1) \
	&& test -f requirements-3.6.txt || (echo "$(RED)❌ requirements-3.6.txt not found.$(NC)"; exit 1) \
	&& test -f requirements-3.7.txt || (echo "$(RED)❌ requirements-3.7.txt not found.$(NC)"; exit 1) \
	&& test -f requirements-3.8.txt || (echo "$(RED)❌ requirements-3.8.txt not found.$(NC)"; exit 1) \
	&& test -f requirements-3.9.txt || (echo "$(RED)❌ requirements-3.9.txt not found.$(NC)"; exit 1) \
	&& test -f requirements-3.10.txt || (echo "$(RED)❌ requirements-3.10.txt not found.$(NC)"; exit 1) \
	&& test -f requirements-3.11.txt || (echo "$(RED)❌ requirements-3.11.txt not found.$(NC)"; exit 1) \
	&& test -f requirements-3.12.txt || (echo "$(RED)❌ requirements-3.12.txt not found.$(NC)"; exit 1)
	@echo "$(GREEN)✅ All prerequisites met!$(NC)"

# Help - show available commands
.PHONY: help
help:
	@echo "$(BLUE)Molecule Docker Images - Makefile Commands$(NC)"
	@echo ""
	@echo "Prerequisites:"
	@echo "  make check-prereqs              Check if all required tools are installed"
	@echo ""
	@echo "Build Commands:"
	@echo "  make build IMAGE=ubuntu-2204    Build a specific image"
	@echo "  make build-all                   Build all images"
	@echo "  make all                         Build and test all images"
	@echo ""
	@echo "Test Commands:"
	@echo "  make test IMAGE=ubuntu-2204      Test a specific image"
	@echo "  make test-all                    Test all images"
	@echo ""
	@echo "Push Commands:"
	@echo "  make push IMAGE=ubuntu-2204      Push a specific image to registry"
	@echo "  make push-all                    Push all images to registry"
	@echo ""
	@echo "Utility Commands:"
	@echo "  make list                        List all available images"
	@echo "  make clean                       Remove all built images"
	@echo "  make help                        Show this help message"
	@echo ""
	@echo "Available Images:"
	@echo "  Ubuntu:      ubuntu-2004, ubuntu-2204, ubuntu-2404"
	@echo "  Debian:      debian-10, debian-11, debian-12"
	@echo "  AlmaLinux:   almalinux-8, almalinux-9"
	@echo "  RockyLinux:  rockylinux-8, rockylinux-9"
	@echo "  OracleLinux: oraclelinux-8, oraclelinux-9"

# List all images
.PHONY: list
list:
	@echo "$(BLUE)Available Images:$(NC)"
	@for img in $(IMAGES); do \
		folder=$$(echo $$img | cut -d: -f1); \
		version=$$(echo $$img | cut -d: -f2); \
		python=$$(echo $$img | cut -d: -f3); \
		os=$$(echo $$folder | cut -d- -f1); \
		echo "  $$folder -> $(REGISTRY)/$(GITHUB_USERNAME)/molecule-$$os:$$version (Python $$python)"; \
	done

# Build all images and test them
.PHONY: all
all: build-all test-all
	@echo "$(GREEN)✅ All images built and tested successfully!$(NC)"

# Build a specific image
.PHONY: build
build: check-prereqs
ifndef IMAGE
	@echo "$(RED)❌ Usage: make build IMAGE=ubuntu-2204$(NC)"
	@exit 1
endif
	@folder=$(IMAGE); \
	found=0; \
	for img in $(IMAGES); do \
		img_folder=$$(echo $$img | cut -d: -f1); \
		if [ "$$img_folder" = "$$folder" ]; then \
			found=1; \
			version=$$(echo $$img | cut -d: -f2); \
			python=$$(echo $$img | cut -d: -f3); \
			os=$$(echo $$folder | cut -d- -f1); \
			image_name="$(REGISTRY)/$(GITHUB_USERNAME)/molecule-$$os:$$version"; \
			echo "$(BLUE)Building $$folder ($$os:$$version, Python $$python)...$(NC)"; \
			if [ ! -f requirements-$$python.txt ]; then \
				echo "$(RED)❌ requirements-$$python.txt not found$(NC)"; \
				exit 1; \
			fi; \
			echo "$(BLUE)Merging requirements-$$python.txt with requirements-common.txt...$(NC)"; \
			cat requirements-$$python.txt requirements-common.txt > ./images/$$folder/requirements.txt; \
			if docker build -t $$image_name ./images/$$folder/; then \
				rm -f ./images/$$folder/requirements.txt; \
				echo "$(GREEN)✅ Built: $$image_name$(NC)"; \
			else \
				rm -f ./images/$$folder/requirements.txt; \
				echo "$(RED)❌ Failed to build: $$image_name$(NC)"; \
				exit 1; \
			fi; \
			break; \
		fi; \
	done; \
	if [ $$found -eq 0 ]; then \
		echo "$(RED)❌ Error: Image '$$folder' not found. Run 'make list' to see available images.$(NC)"; \
		exit 1; \
	fi

# Build all images
.PHONY: build-all
build-all: check-prereqs
	@echo "$(BLUE)Building all images...$(NC)"
	@for img in $(IMAGES); do \
		folder=$$(echo $$img | cut -d: -f1); \
		version=$$(echo $$img | cut -d: -f2); \
		python=$$(echo $$img | cut -d: -f3); \
		os=$$(echo $$folder | cut -d- -f1); \
		image_name="$(REGISTRY)/$(GITHUB_USERNAME)/molecule-$$os:$$version"; \
		echo "$(BLUE)Building $$folder (Python $$python)...$(NC)"; \
		if [ ! -f requirements-$$python.txt ]; then \
			echo "$(RED)❌ requirements-$$python.txt not found$(NC)"; \
			exit 1; \
		fi; \
		echo "$(BLUE)Merging requirements-$$python.txt with requirements-common.txt...$(NC)"; \
		cat requirements-$$python.txt requirements-common.txt > ./images/$$folder/requirements.txt; \
		if docker build -t $$image_name ./images/$$folder/; then \
			rm -f ./images/$$folder/requirements.txt; \
			echo "$(GREEN)✅ Built: $$image_name$(NC)"; \
		else \
			rm -f ./images/$$folder/requirements.txt; \
			echo "$(RED)❌ Failed to build: $$image_name$(NC)"; \
			exit 1; \
		fi; \
	done
	@echo "$(GREEN)✅ All images built successfully!$(NC)"

# Test a specific image
.PHONY: test
test:
ifndef IMAGE
	@echo "$(RED)❌ Usage: make test IMAGE=ubuntu-2204$(NC)"
	@exit 1
endif
	@folder=$(IMAGE); \
	found=0; \
	for img in $(IMAGES); do \
		img_folder=$$(echo $$img | cut -d: -f1); \
		if [ "$$img_folder" = "$$folder" ]; then \
			found=1; \
			version=$$(echo $$img | cut -d: -f2); \
			os=$$(echo $$folder | cut -d- -f1); \
			image_name="$(REGISTRY)/$(GITHUB_USERNAME)/molecule-$$os:$$version"; \
			echo "$(BLUE)Testing $$image_name...$(NC)"; \
			if docker run --rm $$image_name python3 --version >/dev/null 2>&1 && \
			   docker run --rm $$image_name ansible --version >/dev/null 2>&1 && \
			   docker run --rm $$image_name molecule --version >/dev/null 2>&1; then \
				echo "$(GREEN)✅ Tests passed for $$image_name$(NC)"; \
			else \
				echo "$(RED)❌ Tests failed for $$image_name$(NC)"; \
				exit 1; \
			fi; \
			break; \
		fi; \
	done; \
	if [ $$found -eq 0 ]; then \
		echo "$(RED)❌ Error: Image '$$folder' not found.$(NC)"; \
		exit 1; \
	fi

# Test all images
.PHONY: test-all
test-all:
	@echo "$(BLUE)Testing all images...$(NC)"
	@for img in $(IMAGES); do \
		folder=$$(echo $$img | cut -d: -f1); \
		version=$$(echo $$img | cut -d: -f2); \
		os=$$(echo $$folder | cut -d- -f1); \
		image_name="$(REGISTRY)/$(GITHUB_USERNAME)/molecule-$$os:$$version"; \
		echo "$(BLUE)Testing $$image_name...$(NC)"; \
		if docker run --rm $$image_name python3 --version >/dev/null 2>&1 && \
		   docker run --rm $$image_name ansible --version >/dev/null 2>&1 && \
		   docker run --rm $$image_name molecule --version >/dev/null 2>&1; then \
			echo "$(GREEN)✅ Tests passed for $$image_name$(NC)"; \
		else \
			echo "$(RED)❌ Tests failed for $$image_name$(NC)"; \
			exit 1; \
		fi; \
	done
	@echo "$(GREEN)✅ All images tested successfully!$(NC)"

# Push a specific image
.PHONY: push
push:
ifndef IMAGE
	@echo "$(RED)❌ Usage: make push IMAGE=ubuntu-2204$(NC)"
	@exit 1
endif
	@folder=$(IMAGE); \
	found=0; \
	for img in $(IMAGES); do \
		img_folder=$$(echo $$img | cut -d: -f1); \
		if [ "$$img_folder" = "$$folder" ]; then \
			found=1; \
			version=$$(echo $$img | cut -d: -f2); \
			os=$$(echo $$folder | cut -d- -f1); \
			image_name="$(REGISTRY)/$(GITHUB_USERNAME)/molecule-$$os:$$version"; \
			echo "$(BLUE)Pushing $$image_name...$(NC)"; \
			if docker push $$image_name; then \
				echo "$(GREEN)✅ Pushed: $$image_name$(NC)"; \
			else \
				echo "$(RED)❌ Failed to push: $$image_name$(NC)"; \
				exit 1; \
			fi; \
			break; \
		fi; \
	done; \
	if [ $$found -eq 0 ]; then \
		echo "$(RED)❌ Error: Image '$$folder' not found.$(NC)"; \
		exit 1; \
	fi

# Push all images
.PHONY: push-all
push-all:
	@echo "$(BLUE)Pushing all images...$(NC)"
	@for img in $(IMAGES); do \
		folder=$$(echo $$img | cut -d: -f1); \
		version=$$(echo $$img | cut -d: -f2); \
		os=$$(echo $$folder | cut -d- -f1); \
		image_name="$(REGISTRY)/$(GITHUB_USERNAME)/molecule-$$os:$$version"; \
		echo "$(BLUE)Pushing $$image_name...$(NC)"; \
		if docker push $$image_name; then \
			echo "$(GREEN)✅ Pushed: $$image_name$(NC)"; \
		else \
			echo "$(RED)❌ Failed to push: $$image_name$(NC)"; \
			exit 1; \
		fi; \
	done
	@echo "$(GREEN)✅ All images pushed successfully!$(NC)"

# Clean up all built images
.PHONY: clean
clean:
	@echo "$(BLUE)Cleaning up images...$(NC)"
	@for img in $(IMAGES); do \
		folder=$$(echo $$img | cut -d: -f1); \
		version=$$(echo $$img | cut -d: -f2); \
		os=$$(echo $$folder | cut -d- -f1); \
		image_name="$(REGISTRY)/$(GITHUB_USERNAME)/molecule-$$os:$$version"; \
		docker rmi -f $$image_name 2>/dev/null || true; \
	done
	@echo "$(GREEN)✅ Cleanup completed$(NC)"

