#!/bin/bash

# Dependencies
source ./libcolor.bash

# Make the user confirm an action.
# Custom text can be passed in as the first parameter.
confirm() {
	confirmText="${bold}${cyan}Are you sure? [Y/n]${resetall}"

	# If first parameter contains a non-empty string, use that instead
	if [[ ! -z "$1" ]]
	then
		confirmText=$1
	fi

	read -r -p "$(echo -e "$confirmText") " response
	response=${response,,}    # tolower

	# If response is empty, contais yes or y (case insensitive), well proceed
	if [[ "$response" =~ ^(yes|y)$ ]] || [[ -z "$response" ]]
	then
		echo -e "Then what are we waiting for?! Let's goo!"
	else
		echo -e "Then we'll stop before we do something we'll both regret."
		exit
	fi
}

echo -e "${green}
███    ██ ███████  ██████  ██    ██ ██ ███    ███ 
████   ██ ██      ██    ██ ██    ██ ██ ████  ████ 
██ ██  ██ █████   ██    ██ ██    ██ ██ ██ ████ ██ 
██  ██ ██ ██      ██    ██  ██  ██  ██ ██  ██  ██ 
██   ████ ███████  ██████    ████   ██ ██      ██

A U T O M A T I C    I N S T A L L    S C R I P T

${resetall}"

echo -e "${bold}This script will make the following changes to your system:${resetall}
${darkgrey}
1. apt-get update
2. Install git and build tools needed for compiling Neovim
3. Compile and install the stable version of Neovim
4. Install vim-plug, a plugin manager for Vim/Neovim
5. Download my init.vim file as a template for you.
   - This init.vim file is in it's own git repository which is
     cloned into the auto-installer project. Then the file is
     symlinked into ~/.config/nvim.${resetall}
"
confirm "${bold}Sounds good? [Y/n]${resetall}"

exit

echo ""
echo ""
echo "Installing build tools"
echo "---"
sudo apt-get update -y
sudo apt-get install -y ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip curl git

echo ""
echo ""
echo "Cloning neovim's git repository"
echo "---"
git clone https://github.com/neovim/neovim

cd neovim

echo ""
echo ""
echo "Selecting the stable branch"
echo "---"
git checkout stable

echo ""
echo ""
echo "Compiling the release version of neovim"
echo "---"
# Set the type of build (Release/Debug/RelWIthDebInfo)
# -j flag shouldn't be added if ninja is installed
make CMAKE_BUILD_TYPE=Release

echo ""
echo ""
echo "Installing to /usr/local"
echo "---"
sudo make install

echo ""
echo ""
echo "Configuring Neovim"
echo "---"
git clone https://github.com/etokheim/nvim-config.git
mkdir -p ~/.config/nvim
cp nvim-config/init.vim ~/.config/nvim/

# Install vim-plug (plugin manager for vim/neovim)
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

echo ""
echo ""
echo "Done!"
echo "Successfully installed if build type is printed below:"
./build/bin/nvim --version | grep ^Build
echo ""
echo ""
echo "Things to do:"
echo "1. Re-source your PATH. Ie.: 'source ~/.bashrc'"
echo "2. Open neovim and run ':PlugInstall' to install the plugins"
echo "3. Delete the ./neovim folder if you don't need it"
echo "---"
