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
echo "1. Re-source your PATH. Ie.: `source ~/.bashrc`"
echo "2. Open neovim and run `:PlugInstall` to install the plugins"
echo "3. Delete the ./neovim folder if you don't need it"
echo "---"
