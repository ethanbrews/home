# Home

My configuration files for bash, vim, windows terminal and other command line tools.

## Installation

Clone this repo:
```bash
git clone git@github.com:ethanbrews/home.git dotfiles
cd dotfiles
```

Setup local files:
```bash
mkdir ~/local/usr/bin
mkdir ~/local/usr/share
mkdir ~/local/lib
mkdir ~/local/scripts
```

Install apt packages:
```bash
cat packages.txt | xargs sudo apt install -y
```

Now copy config files using `stow [dir]`
```bash
stow bash
stow tmux
stow vim
stow nvim
stow bin
```

Finally, source the .bashrc file
```bash
source ~/.bashrc
```

## Dependencies

### Fuzzy Finder

```bash
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install
```
### Rust + Cargo

```bash
curl https://sh.rustup.rs -sSf | sh
```

### Neovim

```bash
sudo apt-get install ninja-build gettext cmake unzip curl
git clone https://github.com/neovim/neovim
cd neovim
git checkout stable
make CMAKE_BUILD_TYPE=RelWithDebInfo
PREFIX=$HOME/local make install
```

See full steps [here](https://github.com/neovim/neovim/blob/master/BUILD.md)

There is sometimes an issue where treesitter errors are shown on help pages. To fix this run:
```
:TSUninstall vimdoc
(restart neovim)
:TSInstall vimdoc
```

### Cargo Packages
```bash
cat cargo-packages.txt | xargs cargo install -y
```

### Optional Extras:
- [Python](https://devguide.python.org/getting-started/setup-building/)
- [LunarVim](https://www.lunarvim.org/)
- [NerdFonts](https://github.com/ryanoasis/nerd-fonts?tab=readme-ov-file#option-6-install-script)

# Windows

Copy the colours to the windows terminal .json file, accessible via the settings page.

Setup and install apps with:
```powershell
iex "& { $(iwr 'https://raw.githubusercontent.com/ethanbrews/home/main/Windows-Setup.ps1') }"
```
