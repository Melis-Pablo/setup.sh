#!/usr/bin/env bash

# Cross-platform configuration variables

# User configuration paths
BACKUP_DIR="${HOME}/.config/.dotfiles_backup"
SSH_KEY_PATH="${HOME}/.ssh/id_ed25519"

# Feature flags
ENABLE_BACKUP=true
ENABLE_PACKAGES=true
ENABLE_SSH=true
ENABLE_GIT=true
ENABLE_HOMEBREW_ON_LINUX=false  # Set to true to install Homebrew on Linux for consistency

# Platform-specific paths (will be set by detect_platform)
declare -g CONFIG_BASE_DIR=""
declare -g FONT_DIR=""
declare -g CLIPBOARD_CMD=""

# Set platform-specific paths based on detected OS
set_platform_paths() {
    case "$PLATFORM_OS" in
        linux)
            CONFIG_BASE_DIR="${HOME}/.config"
            FONT_DIR="${HOME}/.local/share/fonts"
            
            # Determine clipboard command
            if command -v xclip >/dev/null 2>&1; then
                CLIPBOARD_CMD="xclip -sel clip"
            elif command -v xsel >/dev/null 2>&1; then
                CLIPBOARD_CMD="xsel --clipboard --input"
            elif command -v wl-copy >/dev/null 2>&1; then
                CLIPBOARD_CMD="wl-copy"  # Wayland
            else
                CLIPBOARD_CMD=""
            fi
            ;;
        macos)
            CONFIG_BASE_DIR="${HOME}/.config"  # We use .config even on macOS for consistency
            FONT_DIR="${HOME}/Library/Fonts"
            CLIPBOARD_CMD="pbcopy"
            ;;
        *)
            CONFIG_BASE_DIR="${HOME}/.config"
            FONT_DIR="${HOME}/.local/share/fonts"
            CLIPBOARD_CMD=""
            ;;
    esac
    
    # Ensure directories exist
    mkdir -p "$CONFIG_BASE_DIR"
    mkdir -p "$FONT_DIR"
    mkdir -p "$(dirname "$SSH_KEY_PATH")"
}

# Shell configuration based on platform
get_shell_config_file() {
    local shell_name="${1:-$SHELL}"
    
    case "$(basename "$shell_name")" in
        zsh)
            if [[ "$PLATFORM_OS" == "macos" ]]; then
                echo "${HOME}/.zshrc"
            else
                echo "${HOME}/.zshrc"
            fi
            ;;
        bash)
            if [[ "$PLATFORM_OS" == "macos" ]]; then
                echo "${HOME}/.bash_profile"
            else
                echo "${HOME}/.bashrc"
            fi
            ;;
        fish)
            echo "${CONFIG_BASE_DIR}/fish/config.fish"
            ;;
        *)
            echo "${HOME}/.profile"
            ;;
    esac
}

# Package manager commands
get_package_install_cmd() {
    case "$PACKAGE_MANAGER" in
        dnf)
            echo "sudo dnf install -y"
            ;;
        yum)
            echo "sudo yum install -y"
            ;;
        apt)
            echo "sudo apt install -y"
            ;;
        pacman)
            echo "sudo pacman -S --noconfirm"
            ;;
        brew)
            echo "brew install"
            ;;
        *)
            echo ""
            ;;
    esac
}

get_package_update_cmd() {
    case "$PACKAGE_MANAGER" in
        dnf)
            echo "sudo dnf check-update"
            ;;
        yum)
            echo "sudo yum check-update"
            ;;
        apt)
            echo "sudo apt update"
            ;;
        pacman)
            echo "sudo pacman -Sy"
            ;;
        brew)
            echo "brew update"
            ;;
        *)
            echo ""
            ;;
    esac
}

# Application paths that differ between platforms
get_app_config_dir() {
    local app_name="$1"
    
    case "$app_name" in
        ghostty)
            echo "${CONFIG_BASE_DIR}/ghostty"
            ;;
        nvim)
            echo "${CONFIG_BASE_DIR}/nvim"
            ;;
        zed)
            if [[ "$PLATFORM_OS" == "macos" ]]; then
                echo "${HOME}/Library/Application Support/Zed"
            else
                echo "${CONFIG_BASE_DIR}/zed"
            fi
            ;;
        vscode)
            if [[ "$PLATFORM_OS" == "macos" ]]; then
                echo "${HOME}/Library/Application Support/Code/User"
            else
                echo "${CONFIG_BASE_DIR}/Code/User"
            fi
            ;;
        *)
            echo "${CONFIG_BASE_DIR}/${app_name}"
            ;;
    esac
}

# Terminal emulator detection and configuration
detect_terminal() {
    local term=""
    
    if [[ -n "$TERM_PROGRAM" ]]; then
        case "$TERM_PROGRAM" in
            "Apple_Terminal") term="terminal" ;;
            "iTerm.app") term="iterm2" ;;
            "ghostty") term="ghostty" ;;
            "Alacritty") term="alacritty" ;;
            "kitty") term="kitty" ;;
            "WezTerm") term="wezterm" ;;
            *) term="unknown" ;;
        esac
    elif [[ -n "$KITTY_WINDOW_ID" ]]; then
        term="kitty"
    elif [[ -n "$ALACRITTY_SOCKET" ]]; then
        term="alacritty"
    elif [[ -n "$WEZTERM_PANE" ]]; then
        term="wezterm"
    else
        term="unknown"
    fi
    
    echo "$term"
}

# Environment variables that need platform-specific handling
set_platform_env_vars() {
    case "$PLATFORM_OS" in
        linux)
            # Linux-specific environment variables
            export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
            export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
            export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
            ;;
        macos)
            # macOS-specific environment variables
            # Homebrew paths
            if [[ "$PLATFORM_ARCH" == "arm64" ]]; then
                export HOMEBREW_PREFIX="/opt/homebrew"
            else
                export HOMEBREW_PREFIX="/usr/local"
            fi
            ;;
    esac
}

# Check for required dependencies
check_dependencies() {
    local missing_deps=()
    local required_deps=("git" "curl")
    
    case "$PLATFORM_OS" in
        linux)
            required_deps+=("unzip")
            ;;
        macos)
            # Most tools are available by default on macOS
            ;;
    esac
    
    for dep in "${required_deps[@]}"; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            missing_deps+=("$dep")
        fi
    done
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        log_error "Missing required dependencies: ${missing_deps[*]}"
        log_info "Please install them first:"
        
        case "$PACKAGE_MANAGER" in
            dnf|yum)
                log_info "  sudo $PACKAGE_MANAGER install ${missing_deps[*]}"
                ;;
            apt)
                log_info "  sudo apt update && sudo apt install ${missing_deps[*]}"
                ;;
            brew)
                log_info "  brew install ${missing_deps[*]}"
                ;;
        esac
        
        return 1
    fi
    
    return 0
}

# GPU detection for Asahi Linux specific optimizations
detect_gpu() {
    local gpu_info=""
    
    if command -v lspci >/dev/null 2>&1; then
        gpu_info=$(lspci | grep -i vga | head -1)
    elif [[ -f /proc/cpuinfo ]] && grep -q "Apple" /proc/cpuinfo; then
        gpu_info="Apple Silicon GPU"
    elif [[ "$PLATFORM_OS" == "macos" ]]; then
        gpu_info=$(system_profiler SPDisplaysDataType 2>/dev/null | grep "Chipset Model" | head -1 | cut -d: -f2 | xargs)
    fi
    
    echo "${gpu_info:-Unknown}"
}

# Check if running in a container or VM
is_container_or_vm() {
    # Check for container
    if [[ -f /.dockerenv ]] || [[ -f /run/.containerenv ]]; then
        return 0
    fi
    
    # Check for common VM indicators
    if command -v systemd-detect-virt >/dev/null 2>&1; then
        local virt_type=$(systemd-detect-virt)
        if [[ "$virt_type" != "none" ]]; then
            return 0
        fi
    fi
    
    # Check DMI for VM indicators
    if [[ -r /sys/class/dmi/id/product_name ]]; then
        local product_name=$(cat /sys/class/dmi/id/product_name 2>/dev/null)
        case "$product_name" in
            *VirtualBox*|*VMware*|*QEMU*|*KVM*)
                return 0
                ;;
        esac
    fi
    
    return 1
}

# Performance tweaks based on platform
apply_platform_optimizations() {
    log_info "Applying platform-specific optimizations..."
    
    case "$PLATFORM_OS" in
        linux)
            if is_asahi_linux; then
                log_info "Detected Asahi Linux - applying Apple Silicon optimizations"
                
                # GPU-specific optimizations for Asahi
                export MESA_LOADER_DRIVER_OVERRIDE=asahi
                
                # Add to shell config
                local shell_config=$(get_shell_config_file)
                if [[ -f "$shell_config" ]]; then
                    if ! grep -q "MESA_LOADER_DRIVER_OVERRIDE" "$shell_config"; then
                        echo "export MESA_LOADER_DRIVER_OVERRIDE=asahi" >> "$shell_config"
                    fi
                fi
            fi
            ;;
        macos)
            # macOS-specific optimizations
            log_info "Applying macOS optimizations"
            ;;
    esac
}