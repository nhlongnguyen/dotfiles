# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is a personal dotfiles repository that sets up a complete macOS development environment with Zsh, Oh My Zsh, Oh My Posh, and asdf version manager. It uses a symlink-based approach to manage configuration files.

## Installation and Setup

### First-time Setup
```bash
# Make the installation script executable and run it
chmod +x scripts/install.sh
./scripts/install.sh
```

### Updating Environment
After making changes to configuration files:
```bash
# Re-run the installation to update symlinks
./scripts/install.sh

# Apply Zsh changes immediately
source ~/.zshrc
```

## Architecture Overview

### Core Components

**Installation System (`scripts/install.sh`)**
- Modular bash script with colored output functions
- Installs and configures: Homebrew, Oh My Zsh, Oh My Posh, asdf, Claude Code
- Uses hybrid approach: symlinks for universal configs, templates for machine-specific configs
- Handles backups of existing files automatically
- Idempotent - safe to run multiple times

**Configuration Structure**
```
config/
├── zsh/                    # Zsh shell configuration
│   ├── .zshrc              # Main shell config with plugins
│   ├── .zshenv             # Environment variables (minimal)
│   ├── .zprofile           # Login shell configuration
│   └── .zshrc.local.template # Template for local configurations
├── git/                    # Git configuration
│   └── .gitconfig.template # Template for user info and GPG signing setup
├── asdf/                   # Version manager
│   └── .tool-versions      # Language runtime versions
└── claude/                 # Claude Code configuration
    ├── CLAUDE.md           # Project-specific Claude instructions
    ├── rules/              # Coding principles and collaboration rules
    │   ├── collaboration.md
    │   ├── general-coding-principles.md
    │   ├── go-coding-principles.md
    │   ├── python-coding-principles.md
    │   └── ruby-coding-principles.md
    └── agents/             # Specialized coding expert agents
        ├── golang-coding-expert.md
        └── ruby-coding-expert.md
```

**Key Design Patterns**
- Hybrid configuration management: symlinks for universal configs, templates for machine-specific configs
- Modular installation functions with status reporting
- Separation of shared vs environment-specific configurations
- Local configuration system for sensitive/machine-specific settings
- Template-based approach for files that need customization per machine
- Version pinning for reproducible environments

### Language Runtime Management

Uses asdf with these versions (config/asdf/.tool-versions:1-3):
- Node.js 23.11.0
- Ruby 3.4.3  
- Terraform 1.12.1

### Shell Environment

**Oh My Zsh Setup**
- Theme: `robbyrussell`
- Plugins: git, asdf, zsh-autosuggestions, zsh-syntax-highlighting, fast-syntax-highlighting, zsh-autocomplete

**Oh My Posh Integration**
- Uses `tokyonight_storm` theme
- Configured in .zshrc

**Environment-Specific Configuration System**
- `.zshrc.local` for machine-specific settings (not tracked by git)
- Template file provides guidance for common configurations
- Automatic sourcing from main .zshrc if local file exists
- Installation script creates local config from template

## Common Development Tasks

### Adding New Configuration Files

**For Shared Configurations:**
1. Add the configuration file to appropriate `config/` subdirectory
2. Update `create_symlinks()` function in `scripts/install.sh` to include the new symlink
3. Test by running the installation script

**For Environment-Specific Configurations:**
1. Add settings directly to `~/.zshrc.local` (created by installation script)
2. Use template file as organization guide
3. No changes to installation script needed

### Modifying Zsh Configuration

**For Shared Settings (all environments):**
- Edit `config/zsh/.zshrc` for plugins, themes, or universal shell behavior
- Changes take effect after `source ~/.zshrc` or new shell session

**For Environment-Specific Settings:**
- Edit `~/.zshrc.local` for machine-specific aliases, environment variables, or sensitive information
- Changes take effect immediately after `source ~/.zshrc`

### Managing Language Versions
- Update `config/asdf/.tool-versions` with desired versions
- Run `asdf install` to install new versions
- Use `asdf global <tool> <version>` for system-wide defaults

### Adding Homebrew Packages
- Edit the `brew_formulae` or `brew_casks` arrays in `scripts/install.sh`
- Re-run the installation script to install new packages

## File Modification Guidelines

### Local Configuration System

**Purpose**: Separate sensitive and environment-specific settings from version-controlled files.

**Key Files:**
- `~/.zshrc.local`: Machine-specific configurations (not tracked by git)
- `config/zsh/.zshrc.local.template`: Template with examples and documentation
- `.gitignore`: Excludes `.zshrc.local` from version control

**Typical Local Configuration Contents:**
- API tokens and authentication keys
- Work-specific SSH aliases and bastion configurations
- Company-specific environment variables
- Machine-specific PATH modifications
- Database connection strings

**Environment Variables**
Work-specific environment variables are now in `.zshrc.local`:
- `FASTMCP_LOG_LEVEL`, `MCP_LOG_LEVEL`, `LOG_LEVEL` for airchat compatibility
- `ASANA_ACCESS_TOKEN` for API access
- `TF_PLUGIN_CACHE_DIR` for Terraform performance
- Custom PATH additions for work tools

### Git Configuration
GPG signing is enabled by default with signing key E1A8FD17008F1BAB. Verify GPG setup is working before making signed commits.

### Claude Code Configuration

**Purpose**: Provides consistent Claude Code behavior across different projects by managing global configuration files.

**Key Files:**
- `config/claude/CLAUDE.md`: Project-specific instructions for Claude Code
- `config/claude/rules/`: Directory containing coding principles and collaboration rules
  - `collaboration.md`: Human-AI collaborative problem-solving framework
  - `general-coding-principles.md`: Universal coding standards and best practices
  - `python-coding-principles.md`: Python-specific coding guidelines following PEP 8 and best practices
  - `ruby-coding-principles.md`: Ruby-specific coding guidelines following Sandi Metz rules
  - `go-coding-principles.md`: Go-specific coding guidelines following Uber Go Style Guide
- `config/claude/agents/`: Directory containing specialized coding expert agents
  - `golang-coding-expert.md`: Go language specialist for focused Go development assistance
  - `ruby-coding-expert.md`: Ruby language specialist for focused Ruby development assistance

**Setup Process:**
- Creates symlinks from `config/claude/` to `~/.claude/` directory
- Preserves existing Claude configuration by creating backups
- Enables consistent Claude Code behavior across all projects
- Provides access to specialized coding agents for language-specific expertise

### Installation Script Functions
- `setup_local_config()`: Creates `~/.zshrc.local` from template on first install
- `create_symlinks()`: Links universal configuration files from `config/` to home directory
- `setup_machine_config()`: Copies machine-specific template files (like git config) for local customization
- `setup_claude_config()`: Creates symlinks for Claude Code configuration including agents
- `copy_template()`: Utility function to copy template files only if they don't exist
- Preserves existing local configuration during updates