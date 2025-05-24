echo "zp" #DEBUG, remove later
# Source common login-shell configs
if [ -f $HOME/.common_profile ]; then
	. $HOME/.common_profile
fi
# Source the zsh non-login-shell configs, but make sure we're not sourcing multiple
# times (comment out if you want different behaviour for shell type)
if [[ -z "$ZSH_PROFILE_SOURCED" ]]; then
   export ZSH_PROFILE_SOURCED=1
   # Source non-login shell configs
   if [ -f $HOME/.zshrc ]; then
           . $HOME/.zshrc
   fi
fi
