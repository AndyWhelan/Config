#!/bin/bash

DOTFILES_DIR="./.config"
BACKUP_DIR="./.config-backup"

# List of files to manage (without leading dot)
files=(bashrc bash_profile common_profile common_rc inputrc screenrc tmux.conf vimrc zprofile zshrc )

for file in "${files[@]}"; do
    src="$DOTFILES_DIR/.$file"
    dest=".$file"

    if [ -L "$dest" ]; then
        echo "$dest is already a symlink"
        read -p "Do you want to replace it? [y/N]: " confirm
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
           rm "$dest"
           ln -s "$src" "$dest"
           echo "Re-linked $dest -> $src"
        else
           echo "Skipped $dest"
        fi
    elif [ -f "$dest" ] || [ -d "$dest" ]; then
        echo "Backing up $dest to $BACKUP_DIR"
        mv "$dest" "$BACKUP_DIR/"
        ln -s "$src" "$dest"
        echo "Linked $dest -> $src"
    else
        ln -s "$src" "$dest"
        echo "Linked $dest -> $src"
    fi
done
