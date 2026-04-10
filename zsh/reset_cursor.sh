precmd() {
  if [ -n "$TMUX" ]; then
    # The 'tmux' wrap ensures the code hits iTerm2 directly
    printf '\ePtmux;\e\e]1337;CursorShape=1\a\e\\'
    printf '\ePtmux;\e\e[5 q\e\\'
  else
    # Direct iTerm2 codes
    printf '\e]1337;CursorShape=1\a'
    printf '\e[5 q'
  fi
}
