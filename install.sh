#!/bin/bash

# Exit on error
set -e

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

section() {
	spacers=""

	for (( i=0; i< ${#1}+4; i++ ))
	do
		spacers="$spacers─"
	done

	echo -e "${resetall}${green}"
	echo -e ""
	echo -e "╭$spacers╮"
	echo -e "│  $1  │"
	echo -e "├$spacers╯"
	echo -e "│"
}

closeSection() {
	echo -e "${green}│"
	echo -e "╰  ✅ $1"
}

formatter() {
	echo -e "${green}│   ${darkgrey}$1"
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

if [ "$EUID" -ne 0 ]
then
	echo -e "${green}╭───────────────────────────────────────╮"
	echo -e "│  ⚠️ This script requires sudo to run  │"
	echo -e "╰───────────────────────────────────────╯${resetall}"

	sudo echo -e "${green}✅ Sudo permissions"
	echo "---"
fi

section "Update"
sudo apt-get update -y | while read -r line; do formatter "$line"; done
closeSection "Updated"

section "Install build tools"
sudo apt-get install -y ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip curl git | while read -r line; do formatter "$line"; done
closeSection "Installed build tools"

section "Cloning neovim's git repository"
git clone https://github.com/neovim/neovim | while read -r line; do formatter "$line"; done
closeSection "Cloned Neovim's git repository"

cd neovim

section "Selecting the stable branch"
git checkout stable | while read -r line; do formatter "$line"; done
closeSection "Selected stable branch"

section "Compiling the release version of neovim"
# Set the type of build (Release/Debug/RelWIthDebInfo)
# -j flag shouldn't be added if ninja is installed
make CMAKE_BUILD_TYPE=Release | while read -r line; do formatter "$line"; done
closeSection "Compile successfull"

section "Installing to /usr/local"
sudo make install | while read -r line; do formatter "$line"; done
closeSection "Installation completed without errors"


section "Configuring Neovim"
git clone https://github.com/etokheim/nvim-config.git | while read -r line; do formatter "$line"; done

mkdir -p ~/.config/nvim
cp nvim-config/init.vim ~/.config/nvim/

# Install vim-plug (plugin manager for vim/neovim)
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
closeSection "Configuration done!"

section "Successfully installed if build type is printed below"
verifyMessage=./build/bin/nvim --version | grep ^Build
closeSection "$verifyMessage"

section "Things to do:"
formatter "1. Re-source your PATH. Ie.: 'source ~/.bashrc'"
formatter "2. Open neovim and run ':PlugInstall' to install the plugins"
formatter ""
formatter "${italic}Don't delete this folder, as it now contains the Neovim configuration file (init.vim), which is symlinked to the correct location"
closeSection "Have a nice day!"
