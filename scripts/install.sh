#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print section header
print_section() {
  echo -e "\n${BLUE}==>${NC} ${GREEN}$1${NC}"
}

# Print status message
print_status() {
  echo -e "${YELLOW}-->${NC} $1"
}

# Print error message
print_error() {
  echo -e "${RED}Error:${NC} $1"
}

# Print success message
print_success() {
  echo -e "${GREEN}Success:${NC} $1"
}

# Check if command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Get the directory of the script
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

# Create symlink
create_symlink() {
  local source_file="$1"
  local target_file="$2"
  
  # If target already exists and is a symlink pointing to the same source, skip
  if [ -L "$target_file" ] && [ "$(readlink "$target_file")" = "$source_file" ]; then
    print_status "Symlink already exists: $target_file -> $source_file"
    return 0
  fi
  
  # Backup existing file if it's not a symlink
  if [ -f "$target_file" ] && [ ! -L "$target_file" ]; then
    print_status "Backing up $target_file to ${target_file}.backup"
    mv "$target_file" "${target_file}.backup"
  fi
  
  # Backup existing directory if it's not a symlink
  if [ -d "$target_file" ] && [ ! -L "$target_file" ]; then
    print_status "Backing up directory $target_file to ${target_file}.backup"
    mv "$target_file" "${target_file}.backup"
  fi
  
  # Remove existing symlink if it exists (even if pointing to different location)
  if [ -L "$target_file" ]; then
    rm "$target_file"
  fi
  
  # Create symlink
  ln -sf "$source_file" "$target_file"
  print_status "Created symlink: $target_file -> $source_file"
}

# Install Homebrew
install_homebrew() {
  print_section "Installing Homebrew"
  
  if command_exists brew; then
    print_status "Homebrew is already installed"
  else
    print_status "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for the current session
    if [[ $(uname -m) == "arm64" ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    else
      eval "$(/usr/local/bin/brew shellenv)"
    fi
    
    print_success "Homebrew installed successfully"
  fi
}

# Install Homebrew packages
install_brew_packages() {
  print_section "Installing Homebrew packages"
  
  # Formulae to install
  brew_formulae=(
    asdf
    aws-vault
    oh-my-posh
    zsh
    zsh-autocomplete
    zsh-autosuggestions
    zsh-syntax-highlighting
  )
  
  # Casks to install
  brew_casks=(
    cursor
    docker
    visual-studio-code
    warp
  )
  
  # Update Homebrew
  print_status "Updating Homebrew..."
  brew update
  
  # Install formulae
  print_status "Installing Homebrew formulae..."
  for formula in "${brew_formulae[@]}"; do
    if brew list "$formula" &>/dev/null; then
      print_status "$formula is already installed"
    else
      print_status "Installing $formula..."
      brew install "$formula"
    fi
  done
  
  # Install casks
  print_status "Installing Homebrew casks..."
  for cask in "${brew_casks[@]}"; do
    if brew list --cask "$cask" &>/dev/null; then
      print_status "$cask is already installed"
    else
      print_status "Installing $cask..."
      brew install --cask "$cask"
    fi
  done
  
  print_success "Homebrew packages installed successfully"
}

# Install Oh My Zsh
install_oh_my_zsh() {
  print_section "Installing Oh My Zsh"
  
  if [ -d "$HOME/.oh-my-zsh" ]; then
    print_status "Oh My Zsh is already installed"
  else
    print_status "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    print_success "Oh My Zsh installed successfully"
  fi
  
  # Install custom plugins if they don't exist
  print_status "Installing Oh My Zsh plugins..."
  
  ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
  
  # Install zsh-autosuggestions
  if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
  fi
  
  # Install zsh-syntax-highlighting
  if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
  fi
  
  # Install fast-syntax-highlighting
  if [ ! -d "$ZSH_CUSTOM/plugins/fast-syntax-highlighting" ]; then
    git clone https://github.com/zdharma-continuum/fast-syntax-highlighting "$ZSH_CUSTOM/plugins/fast-syntax-highlighting"
  fi
  
  # Install zsh-autocomplete
  if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autocomplete" ]; then
    git clone https://github.com/marlonrichert/zsh-autocomplete "$ZSH_CUSTOM/plugins/zsh-autocomplete"
  fi
  
  print_success "Oh My Zsh plugins installed successfully"
}

# Configure Oh My Posh
configure_oh_my_posh() {
  print_section "Configuring Oh My Posh"
  
  if command_exists oh-my-posh; then
    print_status "Oh My Posh is already installed"
  else
    print_error "Oh My Posh is not installed. Please run the Homebrew installation first."
    return 1
  fi
  
  # Create Oh My Posh config directory if it doesn't exist
  mkdir -p "$HOME/.config/oh-my-posh"
  
  # Copy the tokyonight_storm theme to the config directory
  if [ -f "$(brew --prefix oh-my-posh)/themes/tokyonight_storm.omp.json" ]; then
    cp "$(brew --prefix oh-my-posh)/themes/tokyonight_storm.omp.json" "$HOME/.config/oh-my-posh/"
    print_status "Copied tokyonight_storm theme to $HOME/.config/oh-my-posh/"
  else
    print_error "Could not find tokyonight_storm theme. Using default theme instead."
  fi
  
  print_success "Oh My Posh configured successfully"
}

# Install asdf and plugins
install_asdf() {
  print_section "Installing asdf and plugins"
  
  if command_exists asdf; then
    print_status "asdf is already installed"
  else
    print_error "asdf is not installed. Please run the Homebrew installation first."
    return 1
  fi
  
  # Add asdf plugins
  print_status "Installing asdf plugins..."
  
  # NodeJS
  if ! asdf plugin list | grep -q "nodejs"; then
    print_status "Adding nodejs plugin..."
    asdf plugin add nodejs
  fi
  
  # Python
  if ! asdf plugin list | grep -q "python"; then
    print_status "Adding python plugin..."
    asdf plugin add python
  fi
  
  # Ruby
  if ! asdf plugin list | grep -q "ruby"; then
    print_status "Adding ruby plugin..."
    asdf plugin add ruby
  fi
  
  # Install versions from .tool-versions
  print_status "Installing versions from .tool-versions..."
  asdf install
  
  print_success "asdf configured successfully"
}

# Copy template file to target location
copy_template() {
  local template_file="$1"
  local target_file="$2"
  local description="$3"
  
  if [ -f "$target_file" ]; then
    print_status "$description already exists at $target_file"
  else
    if [ -f "$template_file" ]; then
      print_status "Creating $description from template..."
      cp "$template_file" "$target_file"
      print_status "Created $target_file from template"
      print_status "You can now customize $target_file with environment-specific settings"
    else
      print_error "Template file not found: $template_file"
      return 1
    fi
  fi
}

# Setup local configuration
setup_local_config() {
  print_section "Setting up local configuration"
  
  local local_config_file="$HOME/.zshrc.local"
  local template_file="$DOTFILES_DIR/config/zsh/.zshrc.local.template"
  
  if [ -f "$local_config_file" ]; then
    print_status "Local configuration file already exists at $local_config_file"
  else
    if [ -f "$template_file" ]; then
      print_status "Creating local configuration file from template..."
      cp "$template_file" "$local_config_file"
      print_status "Created $local_config_file from template"
      print_status "You can now customize $local_config_file with environment-specific settings"
    else
      print_status "Creating empty local configuration file..."
      touch "$local_config_file"
      echo "# Environment-specific Zsh configuration" > "$local_config_file"
      echo "# Add your custom settings here" >> "$local_config_file"
      print_status "Created empty $local_config_file"
    fi
  fi
  
  print_success "Local configuration setup complete"
}

# Setup machine-specific configuration files
setup_machine_config() {
  print_section "Setting up machine-specific configuration"
  
  # Git configuration
  copy_template "$DOTFILES_DIR/config/git/.gitconfig.template" "$HOME/.gitconfig" "Git configuration"
  
  print_success "Machine-specific configuration setup complete"
}

# Setup Claude configuration
setup_claude_config() {
  print_section "Setting up Claude configuration"
  
  # Create .claude directory if it doesn't exist
  mkdir -p "$HOME/.claude"
  
  # Create symlinks for Claude configuration
  create_symlink "$DOTFILES_DIR/config/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
  create_symlink "$DOTFILES_DIR/config/claude/rules" "$HOME/.claude/rules"
  create_symlink "$DOTFILES_DIR/config/claude/agents" "$HOME/.claude/agents"
  
  print_success "Claude configuration setup complete"
}

# Create symlinks for dotfiles
create_symlinks() {
  print_section "Creating symlinks for dotfiles"
  
  # Zsh files (symlinked - should be identical across machines)
  create_symlink "$DOTFILES_DIR/config/zsh/.zshrc" "$HOME/.zshrc"
  create_symlink "$DOTFILES_DIR/config/zsh/.zshenv" "$HOME/.zshenv"
  create_symlink "$DOTFILES_DIR/config/zsh/.zprofile" "$HOME/.zprofile"
  
  # asdf config (symlinked - development tool versions should be consistent)
  create_symlink "$DOTFILES_DIR/config/asdf/.tool-versions" "$HOME/.tool-versions"
  
  print_success "Symlinks created successfully"
}

# Main function
main() {
  print_section "Starting installation of dotfiles"
  
  # Install Homebrew
  install_homebrew
  
  # Install Homebrew packages
  install_brew_packages
  
  # Install Oh My Zsh
  install_oh_my_zsh
  
  # Configure Oh My Posh
  configure_oh_my_posh
  
  # Install asdf and plugins
  install_asdf
  
  # Create symlinks
  create_symlinks
  
  # Setup local configuration
  setup_local_config
  
  # Setup machine-specific configuration
  setup_machine_config
  
  # Setup Claude configuration
  setup_claude_config
  
  print_section "Installation complete!"
  print_status "Please restart your terminal or run 'source ~/.zshrc' to apply changes."
  print_status "Customize ~/.zshrc.local with environment-specific settings as needed."
  print_status "Customize ~/.gitconfig with your personal/work git settings as needed."
}

# Run the main function
main

