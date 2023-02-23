⚠️⚠️ This is a work in progress, and won't work properly at the moment ⚠️⚠️

# Automatically build and install Neovim
This script automatically builds, installs and configures Neovim. It's made for Raspberry Pis, for which there isn't prebuilt images available, but runs perfectly on Ubuntu, and probably other Linux distributions.

## What it does:
 1. Updates repositories (apt update)
 2. Installs the required tools for building Neovim
 3. Downloads and compiles the latest stable version of Neovim
 4. Installs Neovim (Release version)
 5. Installs vim-plug (a plugin manager for vim/neovim)
 6. Configures Neovim (Configuration file: https://github.com/etokheim/nvim-config.git)

## How to run
 1. Clone this repository
 2. Run the install.sh:
    ```sh
    ./install.sh
    ```
## TODO
 1. Move all confirm dialogs to the start, so the install can happen without anyone there
 2. Auto install Node and NPM if they are missing
