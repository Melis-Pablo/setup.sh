# Cross-Platform Brewfile for macOS
# This file is used on macOS, while Linux uses the equivalent packages via DNF/Flatpak
# The setup script handles cross-platform translation automatically

# Taps (package repositories)
tap "homebrew/bundle"
tap "homebrew/cask"
tap "homebrew/cask-fonts"

# Development Tools
brew "git"
brew "neovim"
brew "vim"
brew "node"
brew "tree"
brew "fzf"
brew "ripgrep"
brew "lazygit"
brew "oh-my-posh"

# Media and Utilities
brew "ffmpeg"
brew "yt-dlp"
brew "cmatrix"

# Fonts
cask "font-jetbrains-mono"

# GUI Applications - Development
cask "visual-studio-code"
cask "zed"
cask "figma"
cask "docker"

# GUI Applications - Productivity
cask "obsidian"
cask "raycast"

# GUI Applications - Media
cask "blender"
cask "spotify"
cask "steam"

# GUI Applications - Utilities
cask "ghostty"           # May not be available yet
cask "utm"
cask "shottr"
cask "private-internet-access"

# GUI Applications - Communication
cask "whatsapp"

# GUI Applications - Browsers
cask "eloston-chromium"

# VSCode Extensions (optional, handled by setup script)
vscode "chadbaileyvh.oled-pure-black---vscode"

# macOS-specific packages that don't have Linux equivalents
# These will be skipped on Linux by the setup script
brew "mas"               # Mac App Store command line
cask "sf-symbols"        # Apple's SF Symbols app (macOS only)

# Optional development tools (commented out by default)
# Uncomment these if you need them
# brew "python@3.11"
# brew "rust"
# brew "go"
# brew "docker-compose"    # Standalone Docker Compose
# brew "kubernetes-cli"
# brew "helm"
# brew "terraform"
# brew "aws-cli"
# brew "gcloud"

# Optional GUI applications (commented out by default)
# cask "1password"
# cask "iterm2"           # Alternative terminal
# cask "kitty"            # Alternative terminal
# cask "alacritty"        # Alternative terminal
# cask "sublime-text"
# cask "postman"
# cask "slack"
# cask "discord"
# cask "zoom"
# cask "vlc"
# cask "handbrake"
# cask "gimp"
# cask "inkscape"
# cask "android-studio"
# cask "xcode"            # macOS only

# Development databases (commented out)
# brew "postgresql"
# brew "mysql"
# brew "redis"
# brew "mongodb/brew/mongodb-community"

# Additional fonts (commented out)
# cask "font-fira-code"
# cask "font-source-code-pro"
# cask "font-hack"
# cask "font-cascadia-code"

# Note: This Brewfile is designed to work with the cross-platform setup script
# The script will automatically:
# 1. Use this file on macOS
# 2. Translate packages to DNF/Flatpak equivalents on Linux
# 3. Handle platform-specific packages appropriately
# 4. Skip unavailable packages gracefully