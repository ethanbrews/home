SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
WORKING_DIR=$(pwd -P)

if [ "$SCRIPT_DIR" != "$WORKING_DIR" ]; then
  echo "Run the script from .dotfiles"
  exit 1
fi


echo "Create .local directories"
mkdir -p $HOME/.local/{lib,scripts,bin,share} ~/.config

echo "Install apt packages"
cat linux/packages/apt-packages.txt | xargs sudo apt install -y


if which cargo >/dev/null; then
    echo "Rust is already installed"
else
    echo "Install rust (cargo)"
    curl https://sh.rustup.rs -sSf | sh -s -- -y
    echo $(cargo --version)
fi

if which go >/dev/null; then
    echo "Go is already installed"
else
    echo "Install go"
    sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.24.0.linux-amd64.tar.gz
    export PATH=$PATH:/usr/local/go/bin
    echo $(go version)
fi

echo "Install crates"
cat linux/packages/rust-crates.txt | xargs cargo install

export GOBIN="$HOME/.local/bin"
echo "Install go packages"
cat linux/packages/go-packages.txt | xargs go install

echo "Create config symlinks"
find linux/config -maxdepth 1 -mindepth 1 -type d -printf "%f\n" | xargs -n1 stow --target=$HOME --dir "linux/config"
stow --target="$HOME/.local" --dir "linux" bin

if which fzf >/dev/null; then
    echo "Fuzzy Finder is already installed"
else
    echo "Installing fuzzy finder"
    git clone --depth 1 https://github.com/junegunn/fzf.git $HOME/.fzf
    $HOME/.fzf/install --key-bindings --completion --no-update-rc
    echo "fzf $(fzf --version)"
fi
