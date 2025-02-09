#!/bin/bash

set -e  # Exit on error
set -u  # Exit on undefined variable

# Script location
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Source helper functions
source "${DOTFILES_DIR}/scripts/helpers.sh"
source "${DOTFILES_DIR}/scripts/config.sh"

# Main installation function
main() {
    log_header "Starting M1 Mac Setup"

    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --no-backup) ENABLE_BACKUP=false ;;
            --no-brew) ENABLE_BREW=false ;;
            --no-ssh) ENABLE_SSH=false ;;
            --help) show_help; exit 0 ;;
            *) log_error "Unknown option: $1"; exit 1 ;;
        esac
        shift
    done

    # Setup components based on configuration
    setup_ssh_keys

    if [[ $ENABLE_BREW == true ]]; then
        setup_homebrew
        install_packages
    fi

    create_symlinks

    log_success "Installation completed successfully!"
}

main "$@"