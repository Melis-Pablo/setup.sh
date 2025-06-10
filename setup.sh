#!/usr/bin/env bash

set -euo pipefail  # Exit on error, undefined variable, pipe failure

# Script metadata
readonly SCRIPT_VERSION="2.0.0"
readonly SCRIPT_NAME="Cross-Platform Mac + Asahi Linux Setup"

# Script location
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
readonly DOTFILES_DIR

# Source helper functions and configuration
source "${DOTFILES_DIR}/scripts/helpers.sh"
source "${DOTFILES_DIR}/scripts/config.sh"

# Print banner
print_banner() {
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════════════════════╗
║                                                                              ║
║    ╔═╗┬─┐┌─┐┌─┐┌─┐   ╔═╗┬  ┌─┐┌┬┐┌─┐┌─┐┬─┐┌┬┐                              ║
║    ║  ├┬┘│ │└─┐└─┐───╠═╝│  ├─┤ │ ├┤ │ │├┬┘│││                              ║
║    ╚═╝┴└─└─┘└─┘└─┘   ╩  ┴─┘┴ ┴ ┴ └  └─┘┴└─┴ ┴                              ║
║                                                                              ║
║         macOS + Asahi Linux Development Environment Setup                   ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝
EOF
    echo
    log_info "$SCRIPT_NAME v$SCRIPT_VERSION"
    echo
}

# Validate environment
validate_environment() {
    log_header "Validating environment"
    
    # Check if script is being run from the correct directory
    if [[ ! -f "${DOTFILES_DIR}/setup.sh" ]]; then
        log_error "Please run this script from the dotfiles directory"
        exit 1
    fi
    
    # Check for critical directories
    for dir in "configs" "scripts"; do
        if [[ ! -d "${DOTFILES_DIR}/${dir}" ]]; then
            log_error "Required directory missing: ${dir}"
            exit 1
        fi
    done
    
    # Detect platform first
    detect_platform
    
    # Set platform-specific paths
    set_platform_paths
    
    # Check dependencies
    if ! check_dependencies; then
        log_error "Please install missing dependencies and run again"
        exit 1
    fi
    
    # Display detected environment
    log_info "Environment Details:"
    log_info "  OS: $PLATFORM_OS"
    log_info "  Distribution: $PLATFORM_DISTRO"
    log_info "  Version: $PLATFORM_VERSION"
    log_info "  Architecture: $PLATFORM_ARCH"
    log_info "  Package Manager: $PACKAGE_MANAGER"
    
    if is_asahi_linux; then
        log_info "  🍎 Asahi Linux detected!"
        log_info "  GPU: $(detect_gpu)"
    fi
    
    if is_container_or_vm; then
        log_warn "Running in container/VM - some features may be limited"
    fi
    
    log_success "Environment validation completed"
}

# Parse command line arguments
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --no-backup)
                ENABLE_BACKUP=false
                log_info "Backup disabled"
                ;;
            --no-packages)
                ENABLE_PACKAGES=false
                log_info "Package installation disabled"
                ;;
            --no-ssh)
                ENABLE_SSH=false
                log_info "SSH setup disabled"
                ;;
            --no-git)
                ENABLE_GIT=false
                log_info "Git configuration disabled"
                ;;
            --brew-linux)
                ENABLE_HOMEBREW_ON_LINUX=true
                log_info "Homebrew on Linux enabled"
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            --version|-v)
                echo "$SCRIPT_NAME v$SCRIPT_VERSION"
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                echo "Use --help for usage information"
                exit 1
                ;;
        esac
        shift
    done
}

# Confirmation prompt
confirm_setup() {
    log_header "Setup Configuration"
    
    echo "The following operations will be performed:"
    echo
    echo "✓ Platform: $PLATFORM_OS ($PLATFORM_DISTRO)"
    
    if [[ "$ENABLE_PACKAGES" == true ]]; then
        echo "✓ Install development packages and applications"
        echo "✓ Setup package managers ($PACKAGE_MANAGER)"
        if [[ "$ENABLE_HOMEBREW_ON_LINUX" == true && "$PLATFORM_OS" == "linux" ]]; then
            echo "✓ Install Homebrew on Linux"
        fi
    else
        echo "✗ Package installation disabled"
    fi
    
    if [[ "$ENABLE_GIT" == true ]]; then
        echo "✓ Configure Git with your credentials"
    else
        echo "✗ Git configuration disabled"
    fi
    
    if [[ "$ENABLE_SSH" == true ]]; then
        echo "✓ Generate SSH keys (if needed)"
    else
        echo "✗ SSH key generation disabled"
    fi
    
    echo "✓ Symlink configuration files"
    
    if [[ "$ENABLE_BACKUP" == true ]]; then
        echo "✓ Backup existing configurations"
    else
        echo "✗ Configuration backup disabled"
    fi
    
    echo
    read -p "Do you want to continue? (y/N) " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Setup cancelled by user"
        exit 0
    fi
}

# Main setup orchestration
main_setup() {
    # 1. Git configuration (early so we can update templates)
    if [[ "$ENABLE_GIT" == true ]]; then
        setup_gitconfig
    fi
    
    # 2. SSH keys setup
    setup_ssh_keys
    
    # 3. Package managers and system updates
    if [[ "$ENABLE_PACKAGES" == true ]]; then
        setup_package_managers
        
        # 4. Install development tools
        install_mapped_packages
        
        # 5. Install GUI applications
        install_mapped_gui_apps
        
        # 6. Install special packages
        install_special_packages
        
        # 7. Install fonts
        install_fonts
    fi
    
    # 8. Create configuration symlinks
    create_symlinks
    
    # 9. Apply platform optimizations
    apply_platform_optimizations
    
    # 10. Convert git remote to SSH
    convert_to_ssh_remote "${DOTFILES_DIR}"
}

# Post-setup tasks and information
post_setup() {
    log_header "Post-Setup Tasks"
    
    # Shell configuration recommendations
    local current_shell=$(basename "$SHELL")
    local shell_config=$(get_shell_config_file)
    
    case "$PLATFORM_OS" in
        linux)
            log_info "Linux-specific setup complete!"
            
            if [[ "$ENABLE_HOMEBREW_ON_LINUX" == true ]]; then
                log_info "Don't forget to restart your shell or run:"
                log_info "  eval \"\$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)\""
            fi
            
            if is_asahi_linux; then
                log_info "Asahi Linux optimizations applied"
                log_info "GPU acceleration should be available for supported applications"
            fi
            ;;
        macos)
            log_info "macOS setup complete!"
            
            if [[ "$PLATFORM_ARCH" == "arm64" ]]; then
                log_info "Apple Silicon optimizations applied"
                log_info "Don't forget to restart your shell for Homebrew PATH updates"
            fi
            ;;
    esac
    
    # SSH key instructions
    if [[ "$ENABLE_SSH" == true ]] && [[ -f "${SSH_KEY_PATH}.pub" ]]; then
        log_info "SSH key generated. Add the public key to your GitHub account:"
        log_info "  https://github.com/settings/ssh/new"
        
        if [[ -n "$CLIPBOARD_CMD" ]]; then
            log_info "Public key has been copied to clipboard"
        else
            log_info "Public key content:"
            cat "${SSH_KEY_PATH}.pub"
        fi
    fi
    
    # Application-specific notes
    log_info "Application notes:"
    
    case "$PLATFORM_OS" in
        linux)
            log_info "  • Ghostty: Consider using kitty, alacritty, or wezterm as alternatives"
            log_info "  • Zed: Limited Linux support, may need manual installation"
            log_info "  • Some GUI apps installed via Flatpak for better sandboxing"
            ;;
        macos)
            log_info "  • All applications should be available via Homebrew"
            log_info "  • Ghostty may need manual installation if not in Homebrew yet"
            ;;
    esac
    
    # Final shell restart recommendation
    log_info "Recommended next steps:"
    log_info "  1. Restart your terminal or run: source $shell_config"
    log_info "  2. Verify installations with: which nvim git node"
    log_info "  3. Test Oh My Posh theme loading"
    
    if [[ "$PLATFORM_OS" == "linux" ]]; then
        log_info "  4. Run 'fc-cache -fv' if fonts don't appear correctly"
    fi
}

# Error handling
handle_error() {
    local exit_code=$?
    local line_number=$1
    
    log_error "An error occurred on line $line_number (exit code: $exit_code)"
    log_error "Setup incomplete. Check the error messages above."
    
    # Attempt to show helpful debug info
    log_info "Debug information:"
    log_info "  Script: $0"
    log_info "  Working directory: $(pwd)"
    log_info "  Platform: ${PLATFORM_OS:-unknown}"
    log_info "  User: $(whoami)"
    
    exit $exit_code
}

# Setup error trap
trap 'handle_error ${LINENO}' ERR

# Main execution function
main() {
    # Print banner
    print_banner
    
    # Parse command line arguments
    parse_arguments "$@"
    
    # Validate environment
    validate_environment
    
    # Ask for confirmation
    confirm_setup
    
    # Record start time
    local start_time=$(date +%s)
    
    # Run main setup
    log_header "Starting setup process"
    main_setup
    
    # Calculate duration
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    # Show completion message
    log_header "Setup Complete! 🎉"
    log_success "Total setup time: ${duration} seconds"
    
    # Show summary
    log_info "Setup Summary:"
    if [[ "$ENABLE_PACKAGES" == true ]]; then
        log_info "  ✓ Packages and applications installed"
    fi
    if [[ "$ENABLE_GIT" == true ]]; then
        log_info "  ✓ Git configuration updated"
    fi
    if [[ "$ENABLE_SSH" == true ]]; then
        log_info "  ✓ SSH keys configured"
    fi
    log_info "  ✓ Configuration files symlinked"
    if [[ "$ENABLE_BACKUP" == true ]]; then
        log_info "  ✓ Existing configurations backed up"
    fi
    
    # Post-setup information
    post_setup
    
    log_success "Your development environment is ready!"
}

# Execute main function with all arguments
main "$@"