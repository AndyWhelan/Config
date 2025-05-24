echo "zr" #DEBUG, remove later
# zsh non-login-shell setup. NO 'heavyweight', or common stuff here, i.e.
# 1. No environment variables,
# 2. No resource-intensive commands,
# 3. No time-intensive scripts, and 
# 4. No background services/processes
# 5. Nothing that isn't unique to zsh (source from common file below)

# Source global definitions#
if [ -f /etc/zshrc ]; then
	. /etc/zshrc
fi
# Source zsh login-shell configs
if [ -f $HOME/.zprofile ]; then
	. $HOME/.zprofile
fi
# Source common non-login-shell configs
if [ -f $HOME/.common_rc ]; then
	. $HOME/.common_rc
fi
# Optional settings BEFORE sourcing the plugin
ZVM_CURSOR_STYLE_ENABLED=true
ZVM_LINE_INIT_MODE=viins
ZVM_VI_INSERT_ESCAPE_BINDKEY=jk

# Source the plugin
source ~/.zsh/zsh-vi-mode/zsh-vi-mode.plugin.zsh
## Enable zsh-vi-mode
#source ~/.zsh/zsh-vi-mode/zsh-vi-mode.zsh
## # Force Insert Mode on startup (this ensures we're in Insert mode)
#autoload -U add-zsh-hook
#add-zsh-hook -Uz precmd vi-insert  # Switch to Insert mode immediately
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
autoload -Uz vcs_info
precmd() { vcs_info }

setopt prompt_subst
PROMPT='%F{green}%n@%m%f %F{blue}%~%f %F{yellow}${vcs_info_msg_0_}%f %# '
#echo "Zsh-vi-mode is enabled. Current mode: $ZVM_LINE_INIT_MODE"

# Environment variables autocomplete
autoload -Uz compinit
compinit
