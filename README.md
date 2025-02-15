# M1 Mac Setup Configuration

A streamlined system for quickly reconfiguring an M1 Mac after system resets. This repository contains dotfiles, configuration scripts, and automation tools to get your development environment up and running with minimal effort.

## Features

- **Automated Setup**: Single command to configure your entire system
- **Homebrew Integration**: Automated package and application installation via Brewfile
- **Dotfiles Management**: Organized configuration files with automatic symlinking
- **Backup System**: Automatic backup of existing configurations before replacement
- **SSH Key Management**: Automated SSH key generation and setup
- **Modular Design**: Easy to modify and extend

## Directory Structure

```
.
├── setup.sh              # Main setup script
├── configs/             # Configuration files
│   ├── ghostty/        # Ghostty terminal configs
│   ├── nvim/          # Neovim configs
│   ├── ohmyposh/      # Oh My Posh configs
│   ├── zed/           # Zed editor configs
│   └── .zshrc         # ZSH configuration
├── scripts/           # Helper scripts
│   ├── config.sh      # Configuration variables
│   └── helpers.sh     # Utility functions
├── Brewfile           # Homebrew packages and apps
└── README.md          # This file
```

## One-Line Installation

```bash
git clone https://github.com/YOUR_USERNAME/setup.sh.git ~/.dotfiles && cd ~/.dotfiles && ./setup.sh
```

## Prerequisites

- M1 Mac running macOS
- Terminal access
- Internet connection
- Git (for cloning this repository)

## Quick Start

1. Clone the repository:
   ```bash
   git clone <repository-url> ~/.dotfiles
   cd ~/.dotfiles
   ```

2. Run the setup script:
   ```bash
   ./setup.sh
   ```

## Configuration Options

The setup script accepts several command-line options:

- `--no-backup`: Skip backing up existing configurations
- `--no-brew`: Skip Homebrew installation and updates
- `--no-ssh`: Skip SSH key generation
- `--help`: Show help message

Example:
```bash
./setup.sh --no-backup --no-ssh
```

## Customization

### Adding New Dotfiles

1. Add your configuration files to the `configs/` directory
2. Update the `CONFIG_MAPPINGS` array in `scripts/helpers.sh`:
   ```bash
   declare -a CONFIG_MAPPINGS=(
       "your_config:target_path"
   )
   ```

### Modifying Homebrew Packages

Edit the `Brewfile` to add or remove packages:
```ruby
# Add a new package
brew "package_name"

# Add a new cask
cask "application_name"
```

## Currently Installed Software

### CLI Tools
- ffmpeg
- fzf
- neovim
- oh-my-posh
- ripgrep
- vim
- yt-dlp

### Applications
- Blender
- Docker
- Eloston Chromium
- Figma
- Ghostty
- Obsidian
- Private Internet Access
- Raycast
- Shottr
- Spotify
- WhatsApp
- Zed

## Backup System

The script automatically creates timestamped backups of existing configurations in:
```
~/.config/.dotfiles_backup/YYYYMMDD_HHMMSS/
```

## SSH Key Management

The script can automatically:
- Generate new ED25519 SSH keys
- Add keys to the SSH agent
- Copy public key to clipboard (on macOS)
- Display the public key for easy access

## Troubleshooting

### Common Issues

1. **Permission Denied**
   ```bash
   chmod +x setup.sh
   chmod +x scripts/*.sh
   ```

2. **Homebrew Installation Fails**
   - Ensure you have internet connectivity
   - Check system requirements at brew.sh

3. **Symlink Errors**
   - Run with `--no-backup` to force override
   - Check file permissions in target directories

## Maintenance

### Regular Updates

1. Update Homebrew packages:
   ```bash
   brew bundle dump --force  # Update Brewfile with current packages
   git commit -am "Update Brewfile packages"
   ```

2. Update configurations:
   ```bash
   # After making changes to any configs
   git add configs/
   git commit -m "Update configurations"
   ```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is open source and available under the MIT License.

## Acknowledgments

This setup is designed for personal use but draws inspiration from various dotfiles repositories and Mac setup scripts in the developer community.