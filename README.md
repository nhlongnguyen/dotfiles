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
  - python (version 3.11.7)
  - ruby (version 3.2.2)

### Homebrew

- Formulae:
  - asdf
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

- Basic Git configuration with user information

## Dependencies

- macOS (tested on the latest version)
- Zsh (installed by default on modern macOS)
- Git
- Internet connection (for downloading packages)

## Customization

You can customize these dotfiles to suit your needs by:

1. Editing the configuration files in the `config/` directory
2. Adding your own aliases to `config/zsh/.zshrc`
3. Changing the Oh My Posh theme by editing the theme reference in `config/zsh/.zshrc`
4. Adding or removing Homebrew packages by editing `scripts/install.sh`
5. Adding or changing asdf versions in `config/asdf/.tool-versions`

## Adding Your Own Configurations

You can add your own configurations by:

1. Creating new files in the appropriate directories
2. Adding symlinks in the `scripts/install.sh` script
3. Optionally adding documentation in the README

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

## License

This project is open source and available under the [MIT License](LICENSE).

## Acknowledgements

- [Oh My Zsh](https://ohmyz.sh/)
- [Oh My Posh](https://ohmyposh.dev/)
- [asdf](https://asdf-vm.com/)
- [Homebrew](https://brew.sh/)
