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
            --no-git) ENABLE_GIT=false ;;
            --help) show_help; exit 0 ;;
            *) log_error "Unknown option: $1"; exit 1 ;;
        esac
        shift
    done

    if [[ $ENABLE_GIT == true ]]; then
        setup_gitconfig
    fi
    
    setup_ssh_keys

    if [[ $ENABLE_BREW == true ]]; then
        setup_homebrew
        install_packages
    fi

    create_symlinks

    convert_to_ssh_remote "${DOTFILES_DIR}"

    log_success "Installation completed successfully!"
    
    # Show final status
    log_info "Setup Summary:"
    if [[ $ENABLE_GIT == true ]]; then
        log_info "  Git configuration: Created and symlinked"
    fi
    if [[ $ENABLE_SSH == true ]]; then
        log_info "  SSH keys: Configured"
    fi
    if [[ $ENABLE_BREW == true ]]; then
        log_info "  Homebrew packages: Installed"
    fi
    
    log_info "Your Mac is now configured and ready to use!"
}

main "$@"
