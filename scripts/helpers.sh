#!/usr/bin/env bash

# Cross-platform helper functions for macOS and Asahi Linux + Fedora

# Global platform variables (set by detect_platform)
declare -g PLATFORM_OS=""
declare -g PLATFORM_DISTRO=""
declare -g PLATFORM_VERSION=""
declare -g PLATFORM_ARCH=""
declare -g PACKAGE_MANAGER=""

# Configuration mapping
# Format: "source_path:target_path"
# - source_path is relative to configs/
# - target_path is relative to $HOME
declare -a CONFIG_MAPPINGS=(
    # Directories
    "ghostty:.config/ghostty"
    "nvim:.config/nvim"
    "ohmyposh:.config/ohmyposh"
    "zed:.config/zed"
    # Individual files
    ".zshrc:.zshrc"
    ".gitconfig:.gitconfig"
    ".gitignore_global:.gitignore_global"
)

# Package mapping between Homebrew and DNF
declare -A PACKAGE_MAP=(
    # Development tools
    ["git"]="git git"
    ["neovim"]="neovim neovim"
    ["node"]="nodejs nodejs npm"
    ["vim"]="vim vim"
    ["tree"]="tree tree"
    ["fzf"]="fzf fzf"
    ["ripgrep"]="ripgrep ripgrep"
    ["lazygit"]="lazygit lazygit"
    # Media tools
    ["ffmpeg"]="ffmpeg ffmpeg"
    ["yt-dlp"]="yt-dlp yt-dlp"
    # Terminal enhancements
    ["cmatrix"]="cmatrix cmatrix"
    # Fonts (handled separately)
    ["font-jetbrains-mono"]="jetbrains-mono-fonts jetbrains-mono-fonts"
)

# GUI applications mapping
declare -A GUI_APP_MAP=(
    # Development
    ["visual-studio-code"]="flatpak:com.visualstudio.code"
    ["figma"]="flatpak:io.github.Figma_Linux.figma_linux"
    ["obsidian"]="flatpak:md.obsidian.Obsidian"
    # Media & Entertainment
    ["blender"]="blender"
    ["spotify"]="flatpak:com.spotify.Client"
    ["steam"]="steam"
    # Communication
    ["whatsapp"]="flatpak:io.github.mimbrero.WhatsAppDesktop"
    # Utilities
    ["docker"]="docker docker-compose"
    ["utm"]="qemu-kvm libvirt virt-manager"
    ["raycast"]="albert"  # Alternative launcher for Linux
    ["shottr"]="flameshot"  # Screenshot tool alternative
    ["private-internet-access"]="dnf:pia-manager"  # If available in repos
    # Browsers
    ["eloston-chromium"]="chromium"
)

# Logging functions
log_header() { printf "\n\033[1;36m=== %s ===\033[0m\n" "$@"; }
log_success() { printf "\033[0;32m✓ %s\033[0m\n" "$@"; }
log_error() { printf "\033[0;31m⨯ %s\033[0m\n" >&2 "$@"; }
log_info() { printf "\033[0;34m➜ %s\033[0m\n" "$@"; }
log_warn() { printf "\033[0;33m⚠ %s\033[0m\n" "$@"; }

# Platform detection function
detect_platform() {
    local os="" distro="" version="" arch="" pkg_mgr=""
    
    case "$(uname -s)" in
        Linux*)
            os="linux"
            if [[ -f /etc/os-release ]]; then
                source /etc/os-release
                distro="${ID}"
                version="${VERSION_ID:-unknown}"
            elif [[ -f /etc/redhat-release ]]; then
                distro="rhel"
                version=$(grep -oE '[0-9]+\.[0-9]+' /etc/redhat-release | head -1)
            else
                distro="unknown"
                version="unknown"
            fi
            
            # Determine package manager
            if command -v dnf >/dev/null 2>&1; then
                pkg_mgr="dnf"
            elif command -v yum >/dev/null 2>&1; then
                pkg_mgr="yum"
            elif command -v apt >/dev/null 2>&1; then
                pkg_mgr="apt"
            elif command -v pacman >/dev/null 2>&1; then
                pkg_mgr="pacman"
            else
                pkg_mgr="unknown"
            fi
            ;;
        Darwin*)
            os="macos"
            distro="macos"
            version=$(sw_vers -productVersion 2>/dev/null || echo "unknown")
            pkg_mgr="brew"
            ;;
        *)
            os="unknown"
            distro="unknown"
            version="unknown"
            pkg_mgr="unknown"
            ;;
    esac
    
    arch=$(uname -m)
    
    # Set global variables
    readonly PLATFORM_OS="$os"
    readonly PLATFORM_DISTRO="$distro"
    readonly PLATFORM_VERSION="$version"
    readonly PLATFORM_ARCH="$arch"
    readonly PACKAGE_MANAGER="$pkg_mgr"
    
    log_info "Detected platform: $os ($distro $version) on $arch"
    log_info "Package manager: $pkg_mgr"
}

# Check if we're on Asahi Linux specifically
is_asahi_linux() {
    [[ "$PLATFORM_OS" == "linux" ]] && \
    [[ "$PLATFORM_DISTRO" == "fedora" ]] && \
    [[ -f /proc/cpuinfo ]] && \
    grep -q "Apple" /proc/cpuinfo
}

# Package installation functions
install_system_package() {
    local package="$1"
    local force_native="${2:-false}"
    
    if [[ -z "$package" ]]; then
        log_error "Package name required"
        return 1
    fi
    
    case "$PLATFORM_OS" in
        linux)
            case "$PACKAGE_MANAGER" in
                dnf)
                    log_info "Installing $package with DNF..."
                    if sudo dnf install -y "$package"; then
                        log_success "Installed $package"
                    else
                        log_error "Failed to install $package with DNF"
                        return 1
                    fi
                    ;;
                yum)
                    log_info "Installing $package with YUM..."
                    sudo yum install -y "$package"
                    ;;
                apt)
                    log_info "Installing $package with APT..."
                    sudo apt update && sudo apt install -y "$package"
                    ;;
                *)
                    log_error "Unsupported package manager: $PACKAGE_MANAGER"
                    return 1
                    ;;
            esac
            ;;
        macos)
            if command -v brew >/dev/null 2>&1; then
                log_info "Installing $package with Homebrew..."
                if brew install "$package"; then
                    log_success "Installed $package"
                else
                    log_error "Failed to install $package with Homebrew"
                    return 1
                fi
            else
                log_error "Homebrew not available"
                return 1
            fi
            ;;
        *)
            log_error "Unsupported platform: $PLATFORM_OS"
            return 1
            ;;
    esac
}

# Install GUI application
install_gui_app() {
    local app="$1"
    
    if [[ -z "$app" ]]; then
        log_error "App name required"
        return 1
    fi
    
    case "$PLATFORM_OS" in
        linux)
            if [[ "$app" == flatpak:* ]]; then
                local flatpak_id="${app#flatpak:}"
                log_info "Installing $flatpak_id with Flatpak..."
                if command -v flatpak >/dev/null 2>&1; then
                    flatpak install -y flathub "$flatpak_id"
                else
                    log_warn "Flatpak not available, skipping $flatpak_id"
                    return 1
                fi
            else
                install_system_package "$app"
            fi
            ;;
        macos)
            if command -v brew >/dev/null 2>&1; then
                log_info "Installing $app with Homebrew cask..."
                brew install --cask "$app"
            else
                log_error "Homebrew not available"
                return 1
            fi
            ;;
    esac
}

# Setup package managers
setup_package_managers() {
    case "$PLATFORM_OS" in
        linux)
            log_header "Setting up Linux package managers"
            
            # Update system packages
            case "$PACKAGE_MANAGER" in
                dnf)
                    log_info "Updating DNF package cache..."
                    sudo dnf check-update || true  # Don't fail on available updates
                    
                    # Enable RPM Fusion repositories
                    log_info "Enabling RPM Fusion repositories..."
                    sudo dnf install -y \
                        "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
                        "https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm" 2>/dev/null || true
                    ;;
                yum)
                    log_info "Updating YUM package cache..."
                    sudo yum check-update || true
                    ;;
                apt)
                    log_info "Updating APT package cache..."
                    sudo apt update
                    ;;
            esac
            
            # Setup Flatpak if not present
            if ! command -v flatpak >/dev/null 2>&1; then
                log_info "Installing Flatpak..."
                install_system_package "flatpak"
                
                # Add Flathub repository
                log_info "Adding Flathub repository..."
                flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
            fi
            
            # Optionally install Homebrew on Linux for consistency
            if [[ "$ENABLE_HOMEBREW_ON_LINUX" == "true" ]] && ! command -v brew >/dev/null 2>&1; then
                log_info "Installing Homebrew on Linux..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
                
                # Add to PATH
                if [[ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
                    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
                    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bashrc
                fi
            fi
            ;;
            
        macos)
            log_header "Setting up Homebrew"
            
            if ! command -v brew >/dev/null 2>&1; then
                log_info "Installing Homebrew..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
                
                # Add to PATH for Apple Silicon
                if [[ $(uname -m) == "arm64" ]]; then
                    log_info "Adding Homebrew to PATH for Apple Silicon..."
                    echo >> "${HOME}/.zprofile"
                    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "${HOME}/.zprofile"
                    eval "$(/opt/homebrew/bin/brew shellenv)"
                fi
                
                # Disable analytics
                log_info "Disabling Homebrew analytics..."
                brew analytics off
            else
                log_info "Updating Homebrew..."
                brew update
            fi
            ;;
    esac
}

# Install packages from mapping
install_mapped_packages() {
    log_header "Installing development tools"
    
    case "$PLATFORM_OS" in
        linux)
            # Get the second element (Linux package name) from the mapping
            for package in "${!PACKAGE_MAP[@]}"; do
                local linux_packages=$(echo "${PACKAGE_MAP[$package]}" | cut -d' ' -f2-)
                for pkg in $linux_packages; do
                    if [[ "$pkg" != "skip" ]]; then
                        install_system_package "$pkg"
                    fi
                done
            done
            ;;
        macos)
            # Get the first element (Homebrew package name) from the mapping
            for package in "${!PACKAGE_MAP[@]}"; do
                install_system_package "$package"
            done
            ;;
    esac
}

# Install GUI applications from mapping
install_mapped_gui_apps() {
    log_header "Installing GUI applications"
    
    for app in "${!GUI_APP_MAP[@]}"; do
        case "$PLATFORM_OS" in
            linux)
                install_gui_app "${GUI_APP_MAP[$app]}"
                ;;
            macos)
                install_gui_app "$app"
                ;;
        esac
    done
}

# Special installations that need custom handling
install_special_packages() {
    log_header "Installing special packages"
    
    # Oh My Posh (cross-platform prompt)
    if ! command -v oh-my-posh >/dev/null 2>&1; then
        case "$PLATFORM_OS" in
            linux)
                log_info "Installing Oh My Posh for Linux..."
                curl -s https://ohmyposh.dev/install.sh | bash -s
                ;;
            macos)
                install_system_package "oh-my-posh"
                ;;
        esac
    fi
    
    # Ghostty terminal (if available)
    case "$PLATFORM_OS" in
        linux)
            # Ghostty on Linux might need to be built from source or use AppImage
            log_info "Ghostty for Linux requires manual installation"
            log_info "Consider using alternative: kitty, alacritty, or wezterm"
            ;;
        macos)
            # Ghostty is primarily macOS-focused
            install_system_package "ghostty" || log_warn "Ghostty not available via Homebrew yet"
            ;;
    esac
    
    # Zed editor
    case "$PLATFORM_OS" in
        linux)
            log_info "Installing Zed for Linux..."
            # Zed has limited Linux support, might need Flatpak or manual install
            install_gui_app "flatpak:dev.zed.Zed" || log_warn "Zed not available via Flatpak"
            ;;
        macos)
            install_gui_app "zed"
            ;;
    esac
}

# Font installation
install_fonts() {
    log_header "Installing fonts"
    
    case "$PLATFORM_OS" in
        linux)
            local font_dir="$HOME/.local/share/fonts"
            mkdir -p "$font_dir"
            
            # JetBrains Mono from system repos
            install_system_package "jetbrains-mono-fonts" || {
                log_warn "JetBrains Mono not available in repos, downloading manually..."
                local font_url="https://github.com/JetBrains/JetBrainsMono/releases/latest/download/JetBrainsMono.zip"
                local temp_dir=$(mktemp -d)
                
                if command -v curl >/dev/null 2>&1; then
                    curl -L "$font_url" -o "$temp_dir/JetBrainsMono.zip"
                elif command -v wget >/dev/null 2>&1; then
                    wget "$font_url" -O "$temp_dir/JetBrainsMono.zip"
                else
                    log_error "Neither curl nor wget available for font download"
                    return 1
                fi
                
                if command -v unzip >/dev/null 2>&1; then
                    unzip "$temp_dir/JetBrainsMono.zip" "*.ttf" -d "$font_dir/"
                    rm -rf "$temp_dir"
                    
                    # Update font cache
                    fc-cache -f -v
                    log_success "JetBrains Mono installed manually"
                else
                    log_error "unzip not available for font extraction"
                    return 1
                fi
            }
            ;;
        macos)
            install_system_package "font-jetbrains-mono"
            ;;
    esac
}

# Git configuration setup
setup_gitconfig() {
    log_header "Setting up Git configuration"
    
    local gitconfig_path="${DOTFILES_DIR}/configs/.gitconfig"
    
    # Check if template exists
    if [[ ! -f "${gitconfig_path}" ]]; then
        log_error "Git config template not found at ${gitconfig_path}"
        return 1
    fi
    
    # Prompt for Git user information if not already set
    if grep -q "{{GIT_USERNAME}}" "${gitconfig_path}"; then
        read -p "Enter your GitHub username: " git_username
        read -p "Enter your GitHub email: " git_email
        
        # Validate inputs
        if [[ -z "${git_username}" ]] || [[ -z "${git_email}" ]]; then
            log_error "Git username and email are required"
            return 1
        fi
        
        log_info "Updating .gitconfig template with your information..."
        
        # Replace placeholders in the template (cross-platform sed)
        if [[ "$PLATFORM_OS" == "macos" ]]; then
            sed -i '' "s/{{GIT_USERNAME}}/${git_username}/g" "${gitconfig_path}"
            sed -i '' "s/{{GIT_EMAIL}}/${git_email}/g" "${gitconfig_path}"
        else
            sed -i "s/{{GIT_USERNAME}}/${git_username}/g" "${gitconfig_path}"
            sed -i "s/{{GIT_EMAIL}}/${git_email}/g" "${gitconfig_path}"
        fi
        
        log_success "Updated .gitconfig for ${git_username} (${git_email})"
    else
        log_info "Git configuration already personalized"
    fi
    
    # Set global gitignore
    git config --global core.excludesfile ~/.gitignore_global 2>/dev/null || true
}

# SSH key management
setup_ssh_keys() {
    if [[ "$ENABLE_SSH" == false ]]; then
        log_info "SSH setup disabled, skipping..."
        return 0
    fi

    log_header "Setting up SSH keys"

    # Check for existing keys
    if [[ -f "${SSH_KEY_PATH}" ]]; then
        read -p "SSH key already exists. Replace? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Keeping existing SSH key"
            return 0
        fi
    fi

    # Prompt for email
    read -p "Enter email for SSH key: " ssh_email

    # Generate key with proper paths
    ssh-keygen -t ed25519 -C "${ssh_email}" -f "${SSH_KEY_PATH}" -N ""

    # Start SSH agent and add key
    eval "$(ssh-agent -s)"
    
    case "$PLATFORM_OS" in
        macos)
            # Add to macOS Keychain
            ssh-add --apple-use-keychain "${SSH_KEY_PATH}"
            
            # Copy to clipboard
            if command -v pbcopy >/dev/null 2>&1; then
                pbcopy < "${SSH_KEY_PATH}.pub"
                log_success "Public key copied to clipboard"
            fi
            ;;
        linux)
            ssh-add "${SSH_KEY_PATH}"
            
            # Copy to clipboard if available
            if command -v xclip >/dev/null 2>&1; then
                xclip -sel clip < "${SSH_KEY_PATH}.pub"
                log_success "Public key copied to clipboard (xclip)"
            elif command -v xsel >/dev/null 2>&1; then
                xsel --clipboard --input < "${SSH_KEY_PATH}.pub"
                log_success "Public key copied to clipboard (xsel)"
            else
                log_warn "No clipboard utility found (install xclip or xsel)"
            fi
            ;;
    esac

    log_info "Public key:"
    cat "${SSH_KEY_PATH}.pub"
}

# Create symlinks with proper backup
create_symlinks() {
    log_header "Creating configuration symlinks"

    # Create backup directory if enabled
    if [[ $ENABLE_BACKUP == true ]]; then
        backup_dir="${BACKUP_DIR}/$(date +%Y%m%d_%H%M%S)"
        mkdir -p "${backup_dir}"
        log_info "Created backup directory: ${backup_dir}"
    fi

    for mapping in "${CONFIG_MAPPINGS[@]}"; do
        local source_path="${DOTFILES_DIR}/configs/${mapping%%:*}"
        local target_path="${HOME}/${mapping#*:}"

        if [[ ! -e "${source_path}" ]]; then
            log_error "Source path ${source_path} not found"
            continue
        fi

        # Backup existing configuration
        if [[ $ENABLE_BACKUP == true ]] && [[ -e "${target_path}" ]]; then
            cp -R "${target_path}" "${backup_dir}/"
            log_info "Backed up ${target_path}"
        fi

        # Create parent directory
        mkdir -p "$(dirname "${target_path}")"

        # Remove existing symlink or directory
        if [[ -L "${target_path}" ]] || [[ -e "${target_path}" ]]; then
            rm -rf "${target_path}"
        fi

        # Create symlink
        ln -s "${source_path}" "${target_path}"
        log_success "Created symlink for ${mapping%%:*}"
    done
}

# SSH URL conversion
convert_to_ssh_remote() {
    local repo_dir="$1"

    # Check if we're in a git repository
    if ! git -C "$repo_dir" rev-parse --git-dir > /dev/null 2>&1; then
        log_error "Not a git repository: $repo_dir"
        return 1
    fi

    # Get current remote URL
    local current_url=$(git -C "$repo_dir" remote get-url origin)

    # Check if it's already an SSH URL
    if [[ "$current_url" == git@* ]]; then
        log_info "Remote URL is already using SSH"
        return 0
    fi

    # Extract username and repository name from HTTPS URL
    if [[ "$current_url" =~ https://github.com/([^/]+)/([^/]+)(.git)? ]]; then
        local username="${BASH_REMATCH[1]}"
        local repo="${BASH_REMATCH[2]}"

        # Construct SSH URL
        local ssh_url="git@github.com:$username/$repo.git"

        # Update remote URL
        if git -C "$repo_dir" remote set-url origin "$ssh_url"; then
            log_success "Successfully converted remote URL to SSH: $ssh_url"
        else
            log_error "Failed to update remote URL"
            return 1
        fi
    else
        log_error "Invalid GitHub URL format: $current_url"
        return 1
    fi
}

# Show help
show_help() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Cross-platform setup script for macOS and Asahi Linux + Fedora

Options:
    --no-backup    Skip backing up existing configurations
    --no-packages  Skip package installation
    --no-ssh       Skip SSH key generation
    --no-git       Skip Git configuration setup
    --brew-linux   Install Homebrew on Linux for consistency
    --help         Show this help message

Platforms supported:
    - macOS (Intel and Apple Silicon)
    - Asahi Linux + Fedora on Apple Silicon
    - Other Fedora distributions

EOF
}