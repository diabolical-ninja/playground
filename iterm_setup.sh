# Install Oh-My-Zsh
# https://github.com/ohmyzsh/ohmyzsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"


# Download Colour Theme
# https://cdn.jsdelivr.net/gh/MartinSeeler/iterm2-material-design/material-design-colors.itermcolors  

# Add Syntax highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Update Zsh Profile with old Bash config
# Copy:
code .bash_profile

# Into:
code .zshrc

# Add syntax highlight to list of plugins
plugins=(git zsh-syntax-highlighting)