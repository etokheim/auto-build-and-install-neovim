# Automatically build and install Neovim
This script automatically builds, installs and configures Neovim. It's made for Raspberry Pis, for which there isn't prebuilt images available, but runs perfectly on Ubuntu, and probably other Linux distributions.

## What it does:
 1. Updates repositories (apt update)
 2. Installs the required tools for building Neovim
 3. Downloads and compiles the latest stable version of Neovim
 4. Installs Neovim (Release version)
 5. Installs vim-plug (a plugin manager for vim/neovim)
 6. Configures Neovim (Configuration file: https://github.com/etokheim/nvim-config.git)

