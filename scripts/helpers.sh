#!/bin/bash

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
)

# Logging functions
log_header() { printf "\n\033[1m%s\033[0m\n" "$@"; }
log_success() { printf "\033[0;32m✓ %s\033[0m\n" "$@"; }
log_error() { printf "\033[0;31m⨯ %s\033[0m\n" >&2 "$@"; }
log_info() { printf "\033[0;34m➜ %s\033[0m\n" "$@"; }

# Homebrew setup
setup_homebrew() {
    log_info "Setting up Homebrew..."

    if ! command -v brew >/dev/null 2>&1; then
        log_info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        if [[ $(uname -m) == "arm64" ]]; then
                    log_info "Adding Homebrew to PATH..."
                    # Add both recommended Homebrew PATH configurations
                    echo >> "/Users/${USER}/.zprofile"
                    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "${HOME}/.zprofile"
                    eval "$(/opt/homebrew/bin/brew shellenv)"
                    # Opt out of Homebrew analytics
                    log_info "Disabling Homebrew analytics..."
                    brew analytics off
        fi
    else
        log_info "Updating Homebrew..."
        brew update
    fi
}

# SSH key management
setup_ssh_keys() {
    if [[ "$ENABLE_SSH" == false ]]; then
        log_info "SSH setup disabled, skipping..."
        return 0
    fi

    log_info "Setting up SSH keys..."

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

    eval "$(ssh-agent -s)"
    ssh-add "${SSH_KEY_PATH}"

    if command -v pbcopy >/dev/null 2>&1; then
        pbcopy < "${SSH_KEY_PATH}.pub"
        log_success "Public key copied to clipboard"
    fi

    log_info "Public key:"
    cat "${SSH_KEY_PATH}.pub"
}

# Package installation
install_packages() {
    log_info "Installing packages from Brewfile..."

    if [[ ! -f "${DOTFILES_DIR}/Brewfile" ]]; then
        log_error "Brewfile not found"
        exit 1
    fi

    # Install all dependencies from Brewfile
    brew bundle --file="${DOTFILES_DIR}/Brewfile"
}

create_symlinks() {
    log_info "Creating symlinks..."

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
    }

    # Get current remote URL
    local current_url=$(git -C "$repo_dir" remote get-url origin)

    # Check if it's already an SSH URL
    if [[ "$current_url" == git@* ]]; then
        log_info "Remote URL is already using SSH"
        return 0
    }

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

show_help() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Options:
    --no-backup    Skip backing up existing configurations
    --no-brew      Skip Homebrew installation and updates
    --no-ssh       Skip SSH key generation
    --help         Show this help message
EOF
}