# Cross-Platform Development Environment Setup

A comprehensive system for quickly configuring development environments on both **macOS** and **Asahi Linux + Fedora**. This repository contains dotfiles, configuration scripts, and automation tools to get your development environment up and running with minimal effort across platforms.

## 🚀 Features

- **Cross-Platform Compatibility**: Works seamlessly on macOS and Asahi Linux + Fedora
- **Intelligent Platform Detection**: Automatically adapts to your operating system
- **Dual Package Management**: Uses Homebrew on macOS, DNF on Fedora, with optional Linuxbrew
- **Automated Setup**: Single command to configure your entire system
- **Git Profile Setup**: Automated Git configuration with GitHub credentials
- **Package Mapping**: Translates packages between Homebrew and DNF automatically
- **Dotfiles Management**: Organized configuration files with automatic symlinking
- **Backup System**: Automatic backup of existing configurations before replacement
- **SSH Key Management**: Automated SSH key generation and setup with platform-specific clipboard integration
- **Font Installation**: Cross-platform font management
- **Asahi Linux Optimizations**: Special handling for Apple Silicon Linux
- **Modular Design**: Easy to modify and extend

## 🖥️ Supported Platforms

- **macOS** (Intel and Apple Silicon)
- **Asahi Linux + Fedora** on Apple Silicon Macs
- **Fedora Linux** (other variants with DNF)

## 📁 Directory Structure

```
.
├── setup.sh                 # Main cross-platform setup script
├── configs/                 # Configuration files
│   ├── ghostty/            # Cross-platform Ghostty terminal configs
│   ├── nvim/               # Neovim configs (cross-platform)
│   ├── ohmyposh/           # Oh My Posh configs (cross-platform)
│   ├── zed/                # Zed editor configs
│   ├── .gitconfig          # Git configuration template
│   ├── .gitignore_global   # Global gitignore
│   └── .zshrc              # Cross-platform ZSH configuration
├── scripts/                # Helper scripts
│   ├── config.sh           # Cross-platform configuration variables
│   └── helpers.sh          # Platform detection and utility functions
├── Packages                # Cross-platform package definitions (YAML)
└── README.md               # This file
```

## ⚡ Quick Start

### One-Line Installation

```bash
git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/.dotfiles && cd ~/.dotfiles && ./setup.sh
```

### Manual Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/.dotfiles
   cd ~/.dotfiles
   ```

2. **Run the setup script**:
   ```bash
   ./setup.sh
   ```

3. **Follow the interactive prompts**:
   - Provide GitHub username and email
   - Enter email for SSH key generation
   - Confirm package installations

## 🛠️ Prerequisites

### All Platforms
- Terminal access
- Internet connection
- Git (for cloning this repository)

### macOS
- macOS 10.15+ (Catalina or later)
- Command Line Tools for Xcode (installed automatically)

### Linux/Asahi Linux
- Fedora 35+ or compatible distribution
- DNF package manager
- `curl` and `unzip` packages

## ⚙️ Configuration Options

The setup script accepts several command-line options:

```bash
# Skip backing up existing configurations
./setup.sh --no-backup

# Skip package installation (dotfiles only)
./setup.sh --no-packages

# Skip SSH key generation
./setup.sh --no-ssh

# Skip Git configuration setup
./setup.sh --no-git

# Install Homebrew on Linux for consistency
./setup.sh --brew-linux

# Show help
./setup.sh --help
```

**Example combinations**:
```bash
# Minimal setup (dotfiles only)
./setup.sh --no-packages --no-ssh

# Full setup with Homebrew on Linux
./setup.sh --brew-linux
```

## 📋 Interactive Setup Process

The script guides you through several configuration steps:

### 1. Platform Detection
- Automatically detects macOS vs. Linux
- Identifies Asahi Linux on Apple Silicon
- Determines available package managers

### 2. Git Configuration
- Prompts for GitHub username and email
- Updates template `.gitconfig` with your information
- Sets up global gitignore

### 3. Package Installation
**macOS**: Uses Homebrew for all packages
**Linux**: Uses DNF for system packages, Flatpak for GUI apps

### 4. SSH Key Setup
- Generates ED25519 SSH keys if needed
- Adds keys to SSH agent
- Copies public key to clipboard (platform-specific)
- Shows public key for GitHub/service setup

### 5. Font Installation
- **macOS**: Via Homebrew casks
- **Linux**: System packages or manual download/install

## 📦 Package Management

### Automatic Translation
The setup script automatically translates packages between platforms:

| Category | macOS (Homebrew) | Linux (DNF/Flatpak) |
|----------|------------------|---------------------|
| **Development** | `node` | `nodejs npm` |
| **Editors** | `visual-studio-code` | `flatpak:com.visualstudio.code` |
| **Tools** | `docker` | `docker docker-compose` |
| **Media** | `spotify` | `flatpak:com.spotify.Client` |

### Currently Installed Software

#### CLI Tools
- **Development**: git, neovim, node, vim, lazygit
- **Utilities**: tree, fzf, ripgrep, ffmpeg, yt-dlp
- **Terminal**: oh-my-posh, cmatrix
- **Fonts**: JetBrains Mono

#### GUI Applications
- **Development**: Visual Studio Code, Zed, Figma
- **Productivity**: Obsidian, Raycast (macOS) / Albert (Linux)
- **Media**: Blender, Spotify, Steam
- **Utilities**: Docker, Ghostty*, UTM (macOS) / QEMU (Linux)
- **Communication**: WhatsApp Desktop
- **Browsers**: Chromium

*Note: Ghostty has limited Linux support*

### Platform-Specific Notes

#### macOS
- All packages installed via Homebrew
- Casks used for GUI applications
- Automatic Rosetta 2 installation on Apple Silicon

#### Linux/Fedora
- System packages via DNF
- GUI applications via Flatpak when possible
- RPM Fusion repositories enabled automatically
- Font cache updated automatically

#### Asahi Linux Specific
- GPU acceleration with Mesa drivers
- Apple Silicon optimizations
- PipeWire audio system
- 16K page size compatibility considerations

## 🎨 Customization

### Adding New Packages

1. **Edit the package mapping** in `scripts/helpers.sh`:
   ```bash
   PACKAGE_MAP["new-tool"]="homebrew-name dnf-name"
   GUI_APP_MAP["new-app"]="flatpak:app.id"
   ```

2. **Or modify the YAML** configuration in `Packages` file

### Adding New Dotfiles

1. **Add files** to the `configs/` directory
2. **Update the mapping** in `scripts/helpers.sh`:
   ```bash
   CONFIG_MAPPINGS+=(
       "your_config:.config/target_path"
   )
   ```

### Platform-Specific Configurations

Use platform detection in configuration files:
```bash
# In .zshrc or other configs
case "$PLATFORM" in
    macos)
        # macOS-specific settings
        ;;
    linux)
        # Linux-specific settings
        ;;
esac
```

## 🔐 Security Features

- **SSH Keys**: ED25519 encryption with platform-specific keychain integration
- **Backups**: Existing configurations backed up before replacement
- **Permissions**: Proper Unix permissions set automatically (600 for keys, 644 for configs)
- **Validation**: Input validation for all user-provided data

## 🚨 Troubleshooting

### Common Issues

1. **Permission Denied**
   ```bash
   chmod +x setup.sh
   chmod +x scripts/*.sh
   ```

2. **Package Manager Not Found**
   ```bash
   # Fedora/RHEL
   sudo dnf install dnf-plugins-core
   
   # macOS - install Xcode Command Line Tools
   xcode-select --install
   ```

3. **Git Configuration Issues**
   - Ensure valid GitHub username and email
   - Check template file exists: `configs/.gitconfig`

4. **Font Issues on Linux**
   ```bash
   fc-cache -fv
   ```

5. **Asahi Linux Specific**
   - Ensure you're running latest kernel updates
   - Check GPU acceleration: `glxinfo | grep renderer`

### Platform-Specific Debugging

#### macOS
```bash
# Check Homebrew installation
brew doctor

# Verify package installations
brew list
brew list --cask
```

#### Linux
```bash
# Check DNF configuration
dnf repolist

# Verify Flatpak setup
flatpak list

# Check font installation
fc-list | grep -i jetbrains
```

## 🔄 Maintenance

### Regular Updates

1. **Update packages**:
   ```bash
   # macOS
   brew update && brew upgrade && brew cleanup
   
   # Linux
   sudo dnf upgrade
   flatpak update
   ```

2. **Update dotfiles repository**:
   ```bash
   cd ~/.dotfiles
   git pull
   ./setup.sh --no-backup  # Re-run setup if needed
   ```

3. **Backup current state**:
   ```bash
   # Create new backup before changes
   ./setup.sh --no-packages --no-ssh --no-git
   ```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Test on both macOS and Linux if possible
4. Commit changes: `git commit -m 'Add amazing feature'`
5. Push to branch: `git push origin feature/amazing-feature`
6. Open a Pull Request

### Development Guidelines

- Test changes on both macOS and Linux when possible
- Use platform detection for platform-specific features
- Update documentation for any new features
- Maintain backward compatibility when possible

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

## 🙏 Acknowledgments

This setup draws inspiration from various dotfiles repositories and cross-platform development practices in the community. Special thanks to:

- The Asahi Linux project for making Linux on Apple Silicon possible
- Homebrew team for cross-platform package management
- Oh My Posh for cross-platform shell theming
- The dotfiles community for sharing configuration best practices

## 📞 Support

- **Issues**: Report bugs via GitHub Issues
- **Discussions**: Use GitHub Discussions for questions
- **Platform-specific help**: Tag issues with `macos`, `linux`, or `asahi-linux`

## 🗺️ Roadmap

- [ ] Support for additional Linux distributions (Ubuntu, Arch)
- [ ] Windows Subsystem for Linux (WSL) compatibility
- [ ] Container-based development environment option
- [ ] GUI configuration tool
- [ ] Automated testing on multiple platforms
- [ ] Zsh plugin management improvements
- [ ] Advanced Asahi Linux optimizations