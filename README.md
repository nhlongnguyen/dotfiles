# Dotfiles

This repository contains my personal dotfiles and setup scripts for macOS. These dotfiles are designed to set up a development environment with Zsh, Oh My Zsh, Oh My Posh, and asdf version manager, along with other essential tools.

## Overview

This dotfiles repository includes configurations for:

- **Zsh** - A powerful shell with features like tab completion, spelling correction, and more
- **Oh My Zsh** - A framework for managing Zsh configuration with themes and plugins
- **Oh My Posh** - A prompt theme engine for any shell
- **asdf** - A version manager for multiple languages and tools
- **Git** - Version control system
- **Homebrew** - Package manager for macOS
- **Claude Code** - AI-powered coding assistant with consistent behavior across projects

## Installation

To install these dotfiles, follow these steps:

1. Clone this repository:

   ```bash
   git clone git@github.com:nhlongnguyen/dotfiles.git ~/dotfiles
   ```

2. Navigate to the dotfiles directory:

   ```bash
   cd ~/dotfiles
   ```

3. Run the installation script:

   ```bash
   chmod +x scripts/install.sh
   ./scripts/install.sh
   ```

4. Restart your terminal or run:
   ```bash
   source ~/.zshrc
   ```

## What's Included

### Zsh Configuration

- `.zshrc` - Main Zsh configuration file
- `.zshenv` - Environment variables
- `.zprofile` - Login shell configuration

### Oh My Zsh

- Theme: `robbyrussell`
- Plugins:
  - git
  - asdf
  - zsh-autosuggestions
  - zsh-syntax-highlighting
  - fast-syntax-highlighting
  - zsh-autocomplete

### Oh My Posh

- Theme: `tokyonight_storm`

### asdf Version Manager

- Configured with:
  - nodejs (version 23.11.0)
  - ruby (version 3.4.3)
  - terraform (version 1.12.1)

### Homebrew

- Formulae:
  - asdf
  - aws-vault
  - oh-my-posh
  - zsh
  - zsh-autocomplete
  - zsh-autosuggestions
  - zsh-syntax-highlighting
- Casks:
  - cursor
  - docker
  - visual-studio-code
  - warp

### Git Configuration

- Template-based Git configuration for machine-specific customization
- Copied from template on first install (not symlinked to avoid conflicts)
- Safe to customize with work vs personal email addresses
- Template includes basic user information setup

### Claude Code Configuration

- **Global configuration**: Manages Claude Code behavior across all projects
- **Coding principles**: Universal and language-specific guidelines
- **Collaboration rules**: Human-AI collaborative problem-solving framework
- **Configuration files**:
  - `config/claude/CLAUDE.md` - Project-specific instructions
  - `config/claude/rules/` - Coding principles and collaboration rules

## Dependencies

- macOS (tested on the latest version)
- Zsh (installed by default on modern macOS)
- Git
- Internet connection (for downloading packages)

## Environment-Specific Configuration

This dotfiles repository supports environment-specific configurations through a local configuration system. This allows you to have different settings on your work laptop vs. personal laptop without committing sensitive or environment-specific information to version control.

### How It Works

- The main `.zshrc` file automatically sources `~/.zshrc.local` if it exists
- `.zshrc.local` is excluded from git tracking (via `.gitignore`)
- The installation script creates this file from a template on first setup
- You can safely add sensitive information like API tokens, work aliases, and machine-specific configurations

### Setting Up Local Configuration

When you run the installation script, it will:

1. Create `~/.zshrc.local` from the template if it doesn't exist
2. Provide a template with examples of common environment-specific settings
3. Allow you to customize this file without affecting the shared dotfiles

### What to Put in .zshrc.local

**Recommended for local configuration:**
- API tokens and authentication keys
- Work-specific SSH aliases and bastion hosts
- Company-specific environment variables
- Machine-specific PATH modifications
- Database connection strings
- Personal shortcuts and aliases

**Example local configuration:**
```bash
# Work-specific environment variables
export COMPANY_API_TOKEN="your-secret-token"
export WORK_DATABASE_URL="postgresql://..."

# Work aliases
alias work-server='ssh user@company-server.com'
alias deploy-staging='kubectl apply -f staging/'

# Custom PATH for work tools
export PATH="/opt/company-tools/bin:$PATH"
```

## Customization

You can customize these dotfiles to suit your needs by:

1. **Shared configurations**: Edit files in the `config/` directory for settings that should be the same across all your machines
2. **Environment-specific settings**: Add your machine-specific configurations to `~/.zshrc.local`
3. **Zsh theme**: Change the Oh My Posh theme by editing the theme reference in `config/zsh/.zshrc`
4. **Package management**: Add or remove Homebrew packages by editing `scripts/install.sh`
5. **Language versions**: Update asdf versions in `config/asdf/.tool-versions`

## Adding Your Own Configurations

### For Shared Configurations

1. Create new configuration files in the appropriate `config/` directories
2. Add symlinks in the `scripts/install.sh` script
3. Update documentation as needed

### For Environment-Specific Configurations

1. Add your settings directly to `~/.zshrc.local`
2. Use the template file as a guide for organization
3. No need to modify the installation script or commit changes

## Maintenance

To keep your environment up to date:

1. Pull the latest changes:

   ```bash
   cd ~/dotfiles
   git pull
   ```

2. Re-run the installation script:
   ```bash
   ./scripts/install.sh
   ```

3. Your local configuration (`~/.zshrc.local`) will be preserved during updates

## License

This project is open source and available under the [MIT License](LICENSE).

## Acknowledgements

- [Oh My Zsh](https://ohmyz.sh/)
- [Oh My Posh](https://ohmyposh.dev/)
- [asdf](https://asdf-vm.com/)
- [Homebrew](https://brew.sh/)
