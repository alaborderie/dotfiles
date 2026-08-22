# zsh login shells read ~/.zprofile, not ~/.profile — so with zsh as login
# shell, nothing sourced ~/.profile and brew + ~/.local/bin vanished from PATH.
# GDM also launches the graphical session through the login shell, so this is
# what gives GUI apps (Ghostty, etc.) their PATH too.
[ -f "$HOME/.profile" ] && emulate sh -c 'source "$HOME/.profile"'
