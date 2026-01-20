#!/bin/bash

# gcmd Installation Script
# Installs the gcmd utility to your system

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

# Installation directory
INSTALL_DIR="/usr/local/bin"
SCRIPT_NAME="gcmd"

print_banner() {
    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}  ${BOLD}gcmd${NC} - Natural Language Shell Commands  ${CYAN}║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════╝${NC}"
    echo ""
}

print_step() {
    echo -e "${BLUE}==>${NC} ${BOLD}$1${NC}"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}!${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1" >&2
}

# Check if running as root when needed
check_permissions() {
    if [ ! -w "$INSTALL_DIR" ]; then
        if [ "$EUID" -ne 0 ]; then
            print_error "Installation requires write access to $INSTALL_DIR"
            echo ""
            echo "Please run with sudo:"
            echo "  sudo ./install.sh"
            echo ""
            exit 1
        fi
    fi
}

# Check for required dependencies
check_dependencies() {
    print_step "Checking dependencies..."

    local missing_deps=()

    if ! command -v curl &> /dev/null; then
        missing_deps+=("curl")
    fi

    if [ ${#missing_deps[@]} -ne 0 ]; then
        print_error "Missing required dependencies: ${missing_deps[*]}"
        echo ""
        echo "Please install them first:"
        if [[ "$OSTYPE" == "darwin"* ]]; then
            echo "  brew install ${missing_deps[*]}"
        elif command -v apt-get &> /dev/null; then
            echo "  sudo apt-get install ${missing_deps[*]}"
        elif command -v yum &> /dev/null; then
            echo "  sudo yum install ${missing_deps[*]}"
        fi
        exit 1
    fi

    print_success "All dependencies satisfied"
}

# Detect the script directory
get_script_dir() {
    local source="${BASH_SOURCE[0]}"
    while [ -L "$source" ]; do
        local dir
        dir=$(cd -P "$(dirname "$source")" && pwd)
        source=$(readlink "$source")
        [[ $source != /* ]] && source="$dir/$source"
    done
    cd -P "$(dirname "$source")" && pwd
}

# Install gcmd
install_gcmd() {
    print_step "Installing gcmd..."

    local script_dir
    script_dir=$(get_script_dir)
    local source_file="${script_dir}/${SCRIPT_NAME}"
    local target_file="${INSTALL_DIR}/${SCRIPT_NAME}"

    # Check if source file exists
    if [ ! -f "$source_file" ]; then
        print_error "Source file not found: $source_file"
        echo "Make sure 'gcmd' script is in the same directory as install.sh"
        exit 1
    fi

    # Copy the script
    cp "$source_file" "$target_file"

    # Make it executable
    chmod +x "$target_file"

    print_success "Installed gcmd to $target_file"
}

# Check for existing API key
check_api_key() {
    print_step "Checking for OpenAI API key..."

    if [ -n "${OPENAI_API_KEY:-}" ]; then
        print_success "OPENAI_API_KEY is already set"
    else
        print_warning "OPENAI_API_KEY is not set"
        echo ""
        echo -e "${YELLOW}To use gcmd, you need to set your OpenAI API key:${NC}"
        echo ""
        echo "  export OPENAI_API_KEY='your-api-key-here'"
        echo ""
        echo "Add this to your shell config file to make it permanent:"

        local shell_config=""
        case "$SHELL" in
            */zsh)
                shell_config="~/.zshrc"
                ;;
            */bash)
                if [[ "$OSTYPE" == "darwin"* ]]; then
                    shell_config="~/.bash_profile"
                else
                    shell_config="~/.bashrc"
                fi
                ;;
            *)
                shell_config="~/.profile"
                ;;
        esac

        echo ""
        echo "  echo \"export OPENAI_API_KEY='your-api-key'\" >> $shell_config"
        echo "  source $shell_config"
    fi
}

# Print usage instructions
print_usage() {
    echo ""
    echo -e "${GREEN}Installation complete!${NC}"
    echo ""
    echo -e "${BOLD}Usage:${NC}"
    echo "  gcmd <natural language description>"
    echo ""
    echo -e "${BOLD}Examples:${NC}"
    echo "  gcmd list all files in current directory"
    echo "  gcmd find all python files modified in last 7 days"
    echo "  gcmd show disk usage sorted by size"
    echo "  gcmd compress the logs folder into a tar.gz"
    echo ""
    echo -e "${BOLD}Options:${NC}"
    echo "  gcmd --help     Show help message"
    echo "  gcmd --version  Show version"
    echo ""
}

# Uninstall function
uninstall_gcmd() {
    print_step "Uninstalling gcmd..."

    local target_file="${INSTALL_DIR}/${SCRIPT_NAME}"

    if [ -f "$target_file" ]; then
        rm "$target_file"
        print_success "Removed $target_file"
    else
        print_warning "gcmd is not installed at $target_file"
    fi

    echo ""
    echo -e "${GREEN}Uninstallation complete!${NC}"
}

# Main
main() {
    print_banner

    # Handle uninstall flag
    if [ "${1:-}" = "--uninstall" ] || [ "${1:-}" = "-u" ]; then
        check_permissions
        uninstall_gcmd
        exit 0
    fi

    # Handle help flag
    if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
        echo "Usage: ./install.sh [options]"
        echo ""
        echo "Options:"
        echo "  -h, --help       Show this help message"
        echo "  -u, --uninstall  Uninstall gcmd"
        echo ""
        exit 0
    fi

    check_permissions
    check_dependencies
    install_gcmd
    check_api_key
    print_usage
}

main "$@"
