# Mac Setup Configuration

A streamlined system for quickly reconfiguring a Mac after system resets. This repository contains dotfiles, configuration scripts, and automation tools to get your development environment up and running with minimal effort.

## Features

- **Automated Setup**: Single command to configure your entire system
- **Git Profile Setup**: Automated Git configuration with GitHub credentials
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
│   ├── .gitconfig     # Git configuration (template with placeholders)
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

- Mac running macOS
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

3. Follow the interactive prompts:
   - Provide GitHub username and email
   - Enter email for SSH key generation

## Configuration Options

The setup script accepts several command-line options:

- `--no-backup`: Skip backing up existing configurations
- `--no-brew`: Skip Homebrew installation and updates
- `--no-ssh`: Skip SSH key generation
- `--no-git`: Skip Git configuration setup
- `--help`: Show help message

Example:
```bash
./setup.sh --no-backup --no-ssh
```

## Interactive Setup Process

The script will guide you through several configuration steps:

### 1. Git Configuration
- Prompts for GitHub username and email
- Updates the template .gitconfig file by replacing placeholders:
  - `{{GIT_USERNAME}}` → Your GitHub username
  - `{{GIT_EMAIL}}` → Your GitHub email
- Template includes comprehensive Git settings:
  - User credentials
  - Default editor (nvim)

### 2. SSH Key Setup
- Generates ED25519 SSH keys
- Adds keys to SSH agent
- Copies public key to clipboard
- Displays public key for GitHub/service setup

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

### Customizing Git Configuration

The Git configuration uses a template file at `configs/.gitconfig` with placeholders:
- `{{GIT_USERNAME}}` - Replaced with your GitHub username
- `{{GIT_EMAIL}}` - Replaced with your GitHub email

You can customize the template by editing `configs/.gitconfig` to:
- Change the default editor
- Add/modify aliases
- Adjust color schemes
- Configure merge/diff tools
- Add additional Git settings

The placeholders will be automatically replaced during setup.

## Currently Installed Software

### CLI Tools
- cmatrix
- ffmpeg
- fzf
- lazygit
- neovim
- node
- oh-my-posh
- ripgrep
- tree
- vim
- yt-dlp

### Applications
- Blender
- Docker
- Eloston Chromium
- Figma
- Font-jetbrains-mono
- Ghostty
- Obsidian
- Private Internet Access
- Raycast
- Shottr
- Spotify
- Steam
- UTM
- Visual Studio Code
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

## Git Configuration

The generated `.gitconfig` includes:
- User credentials (name and email)
- Neovim as default editor

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

4. **Git Configuration Issues**
   - Ensure you provide valid GitHub username and email
   - The .gitconfig will be created even if GitHub credentials are invalid

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

3. Update Git configuration:
   ```bash
   # Re-run just the Git setup
   ./setup.sh --no-backup --no-brew --no-ssh --no-hostname
   ```

## Security Considerations

- SSH keys are generated with ED25519 encryption
- Git credentials are stored in macOS Keychain
- Existing configurations are backed up before replacement
- The script requires explicit confirmation for destructive operations

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