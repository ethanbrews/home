# Home

My configuration files for bash, vim, windows terminal and other command line tools.

## Installation

Clone this repo:
```bash
git clone git@github.com:ethanbrews/home.git dotfiles
cd dotfiles
```

Install apt packages:
```bash
cat packages.txt | xargs sudo apt install -y
```

Now copy config files using `stow [dir] --dotfiles`
```bash
stow bash --dotfiles
stow tmux --dotfiles
stow vim --dotfiles
```

Finally, source the .bashrc file
```bash
source ~/.bashrc
```

## Dependencies

### Fuzzy Finder

```bash
$ git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
$ ~/.fzf/install
```


### Install manually:
- [Rust + Cargo](https://doc.rust-lang.org/cargo/getting-started/installation.html)
- [Python](https://devguide.python.org/getting-started/setup-building/)
- [NeoVim](https://github.com/neovim/neovim/blob/master/BUILD.md)
- [LunarVim](https://www.lunarvim.org/)
- [NerdFonts](https://github.com/ryanoasis/nerd-fonts?tab=readme-ov-file#option-6-install-script)

### RipGrep
```bash
cargo install ripgrep
```
