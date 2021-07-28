echo "Installing build tools"
sudo apt-get update -y
sudo apt-get install -y ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip curl git

git clone https://github.com/neovim/neovim

cd neovim

echo "Select the stable version"
git checkout stable

make -j4

echo "Installing to /usr/local"
sudo make install
