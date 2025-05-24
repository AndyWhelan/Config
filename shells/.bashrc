# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything (don't need to have in .zshrc)
case $- in
    *i*) ;;
      *) return;;
esac
# Source system-wide bashrc
if [[ "$OSTYPE" != "darwin"* ]]; then  # not on Mac, so ok to source
   if [ -f /etc/bashrc ]; then
           . /etc/bashrc
   fi
fi
# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
# The HISTSIZE is set in .commonrc
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi
# Source bash login-shell configs
if [ -f ~/.bash_profile ]; then
        . $HOME/.bash_profile
fi
# Source common non-login-shell configs
if [ -f ~/.common_rc ]; then
        . $HOME/.common_rc
fi
