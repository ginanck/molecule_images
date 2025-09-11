#!/bin/bash

# Docker Image Testing Script
# This script tests the built Docker images for basic functionality

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
REGISTRY="${REGISTRY:-ghcr.io}"
GITHUB_USERNAME="${GITHUB_USERNAME:-ginanck}"

# Test function
test_image() {
    local os=$1
    local version=$2
    local image_tag="${REGISTRY}/${GITHUB_USERNAME}/molecule-${os}:${version}"
    
    echo -e "${YELLOW}Testing image: ${image_tag}${NC}"
    
    # Test if image exists locally or can be pulled
    if ! docker image inspect "$image_tag" > /dev/null 2>&1; then
        echo -e "${YELLOW}Image not found locally, attempting to pull...${NC}"
        if ! docker pull "$image_tag"; then
            echo -e "${RED}Failed to pull image: $image_tag${NC}"
            return 1
        fi
    fi
    
    echo -e "  ${GREEN}✓${NC} Testing Python version..."
    if ! docker run --rm --platform linux/amd64 "$image_tag" python3 --version; then
        echo -e "${RED}Failed to run Python test${NC}"
        return 1
    fi
    
    echo -e "  ${GREEN}✓${NC} Testing Ansible version..."
    if ! docker run --rm --platform linux/amd64 "$image_tag" ansible --version; then
        echo -e "${RED}Failed to run Ansible test${NC}"
        return 1
    fi
    
    echo -e "  ${GREEN}✓${NC} Testing Molecule installation..."
    if ! docker run --rm --platform linux/amd64 "$image_tag" python3 -c "import molecule; print(f'Molecule version: {molecule.__version__}')"; then
        echo -e "${RED}Failed to run Molecule test${NC}"
        return 1
    fi
    
    echo -e "  ${GREEN}✓${NC} Testing Docker client..."
    if ! docker run --rm --platform linux/amd64 "$image_tag" docker --version; then
        echo -e "${RED}Failed to run Docker client test${NC}"
        return 1
    fi
    
    echo -e "  ${GREEN}✓${NC} Testing systemd (if available)..."
    if docker run --rm --platform linux/amd64 "$image_tag" systemctl --version > /dev/null 2>&1; then
        echo -e "    ${GREEN}✓${NC} systemd is available"
    else
        echo -e "    ${YELLOW}⚠${NC} systemd not available or not working (this might be expected in containers)"
    fi
    
    echo -e "${GREEN}✓ All tests passed for ${image_tag}${NC}\n"
}

# Test locally built images
test_local_images() {
    echo -e "${YELLOW}Testing locally built images...${NC}\n"
    
    # Get list of local molecule images
    local images=$(docker images --format "{{.Repository}}:{{.Tag}}" | grep "molecule-" | grep -E "(ubuntu|debian|almalinux|rockylinux|oraclelinux)" || true)
    
    if [ -z "$images" ]; then
        echo -e "${RED}No local molecule images found. Build some images first.${NC}"
        return 1
    fi
    
    while IFS= read -r image; do
        if [ -n "$image" ]; then
            echo -e "${YELLOW}Testing local image: $image${NC}"
            # Extract OS and version from image name
            local os_version=$(echo "$image" | sed 's/.*molecule-\([^:]*\):.*/\1/')
            local version=$(echo "$image" | sed 's/.*://')
            
            # Test the image directly
            echo -e "  ${GREEN}✓${NC} Testing Python version..."
            docker run --rm --platform linux/amd64 "$image" python3 --version
            
            echo -e "  ${GREEN}✓${NC} Testing Ansible version..."
            docker run --rm --platform linux/amd64 "$image" ansible --version
            
            echo -e "${GREEN}✓ Tests passed for $image${NC}\n"
        fi
    done <<< "$images"
}

# Main function
main() {
    echo -e "${YELLOW}Docker Image Testing Script${NC}\n"
    
    case "${1:-local}" in
        "local")
            test_local_images
            ;;
        "registry")
            echo -e "${YELLOW}Testing images from registry...${NC}\n"
            
            # Ubuntu variants
            test_image "ubuntu" "20.04"
            test_image "ubuntu" "22.04"
            test_image "ubuntu" "24.04"
            
            # Debian variants
            test_image "debian" "10"
            test_image "debian" "11"
            test_image "debian" "12"
            
            # AlmaLinux variants
            test_image "almalinux" "8"
            test_image "almalinux" "9"
            
            # Rocky Linux variants
            test_image "rockylinux" "8"
            test_image "rockylinux" "9"
            
            # Oracle Linux variants
            test_image "oraclelinux" "8"
            test_image "oraclelinux" "9"
            ;;
        "single")
            if [ -z "$2" ] || [ -z "$3" ]; then
                echo -e "${RED}Usage: $0 single <os> <version>${NC}"
                echo -e "Example: $0 single ubuntu 20.04"
                exit 1
            fi
            test_image "$2" "$3"
            ;;
        *)
            echo -e "${RED}Usage: $0 [local|registry|single <os> <version>]${NC}"
            echo -e "  local    - Test locally built images"
            echo -e "  registry - Test images from registry"
            echo -e "  single   - Test a single image"
            exit 1
            ;;
    esac
}

main "$@"