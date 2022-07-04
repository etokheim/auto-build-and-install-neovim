#!/bin/bash

# Exit on error
set -e

# Dependencies
source ./libcolor.bash

# Config
initPath=~/.config/nvim/init.vim
newInitPath=$(pwd)/nvim-config/init.vim

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
		confirmValue=true
	else
		confirmValue=false
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
	echo -e "│${darkgrey}" 	# Sometimes useful to set color here
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

if [ "$confirmValue" = true ]; then
	echo -e "Then what are we waiting for?! Let's goo!"
else
	echo -e "Then we'll stop before we do something we'll both regret."
	exit
fi

if [ "$EUID" -ne 0 ]; then
	echo -e "${green}╭───────────────────────────────────────╮"
	echo -e "│  ⚠️ This script requires sudo to run  │"
	echo -e "├───────────────────────────────────────╯"
	echo -e "│${resetall}"

	sudo echo -e "${green}╰  ✅ Sudo permissions"
fi

section "Update"
sudo apt-get update -y | while read -r line; do formatter "$line"; done
closeSection "Updated"

section "Install build tools"
sudo apt-get install -y ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip curl git | while read -r line; do formatter "$line"; done
closeSection "Installed build tools"

if [ -d ./neovim/.git ]; then
	section "Updating the already downloaded Neovim repository"
	cd neovim
	# TODO: This command leaks a bit for some reason... Can use the | while read trick
	pullOutput=$(git pull origin stable)

	cd ..

	# If the pull output contains: "Already up to date", then we don't have to rebuild
	if [[ "$pullOutput" == *"Already up to date"* ]]; then
		rebuild=false
		closeSection "Already at the latest version!"
	else
		rebuild=true
		closeSection "Update done!"
	fi
else
	section "Cloning neovim's git repository"
	git clone https://github.com/neovim/neovim | while read -r line; do formatter "$line"; done
	closeSection "Cloned Neovim's git repository"

	section "Selecting the stable branch"
	cd neovim
	git checkout -q stable | while read -r line; do formatter "$line"; done
	cd ..
	closeSection "Selected stable branch"
fi

if [ "$rebuild" = true ]; then
	section "Compiling the release version of neovim"
	# Set the type of build (Release/Debug/RelWIthDebInfo)
	# -j flag shouldn't be added if ninja is installed
	make CMAKE_BUILD_TYPE=Release | while read -r line; do formatter "$line"; done
	closeSection "Compile successfull"

	section "Installing to /usr/local"
	sudo make install | while read -r line; do formatter "$line"; done
	closeSection "Installation completed without errors"
fi


section "Configuring Neovim"
if [ -d nvim-config/.git ]; then
	cd nvim-config
	git pull -q | while read -r line; do formatter "$line"; done
	cd ..
else
	git clone -q https://github.com/etokheim/nvim-config.git | while read -r line; do formatter "$line"; done
fi

mkdir -p ~/.config/nvim

# If there's a configuration file already present, ask the user if we should overwrite it
if [ -L "$initPath" ] || [ -f "$initPath" ]; then
	confirm "${resetall}${green}│${resetall}${bold}   There is already an existing config file for Neovim. Do you want to overwrite it? [Y/n]"

	if [ "$confirmValue" = true ]; then
		rm "$initPath"
		ln -s "$newInitPath" "$initPath"
		formatter "Successfully removed the old config"
	else
		formatter "Keeping existing config"
	fi
else
	ln -s "$newInitPath" "$initPath"
fi

# Install vim-plug (plugin manager for vim/neovim)
sh -c 'curl --no-progress-meter -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

closeSection "Configuration done!"

section "Verifying installation"
verifyMessage=$(./neovim/build/bin/nvim --version | grep ^Build)

if [[ "$verifyMessage" == *"Build type: Release"* ]]; then
	closeSection "Successfully installed!"
else
	formatter "Verify message should have contained 'Build type: Release'."
	formatter "Instead it contained:"
	formatter "${verifyMessage}"
	closeSection "${red}Installation was not successfull!${resetall}"
fi

section "Things to do:"
formatter "1. Re-source your PATH. Ie.: 'source ~/.bashrc'"
formatter "2. Open neovim (ie.: nvim [file]) and run ':PlugInstall' to install the plugins"
formatter ""
formatter "${italic}Don't delete this folder, as it now contains the Neovim configuration file (init.vim), which is symlinked to the correct location"
closeSection "Have a nice day!"

