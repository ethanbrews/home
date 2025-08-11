#!/bin/bash

LINE='[[ -f "${HOME}/.zshrcd/zshrc.sh" ]] && builtin source "${HOME}/.zshrcd/zshrc.sh"'

if ! grep -Fxq "$LINE" ~/.zshrc; then
    echo "$LINE" >> ~/.zshrc
    echo "Update ~/.zshrc"
fi