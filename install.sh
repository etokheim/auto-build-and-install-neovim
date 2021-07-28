echo ""
echo ""
echo "Installing build tools"
echo "---"
sudo apt-get update -y
sudo apt-get install -y ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip curl git

git clone https://github.com/neovim/neovim

cd neovim

echo ""
echo ""
echo "Select the stable version"
echo "---"
git checkout stable

make -j4

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
echo "Run :PlugInstall when opening Neovim to install the plugins"
echo "---"
