#!/usr/bin/env bash

if [[ -z $STOW_PACKAGES ]]; then
    STOW_PACKAGES="mpv"
fi

if [[ -z $STOW_DIRECTORY ]]; then
    STOW_DIRECTORY=$HOME/.dotfiles
fi

# Sync dotfiles repo and ensure that dotfiles are tangled correctly afterward
GREEN='\033[1;32m'
BLUE='\033[1;34m'
RED='\033[1;30m'
NC='\033[0m'

# Navigate to the directory of this script 
pushd $STOW_DIRECTORY

echo -e "${BLUE}Stashing existing changes...${NC}"
stash_result=$(git checkout master;git stash push -m "sync-dotfiles: Before syncing dotfiles")
stash_result=$(git submodule foreach 'git checkout master; git stash')

echo -e "${BLUE}Pulling updates from dotfiles repo...${NC}"
echo
git checkout master; git pull --recurse-submodules origin master
echo

echo -e "${BLUE}Popping stashed changes...${NC}"
echo
git stash pop; git submodule foreach 'git stash pop'

unmerged_files=$(git diff --name-only --diff-filter=U)
unmerged_files+=$(git submodule foreach 'git diff --name-only --diff-filter=U')

if [[ ! -z $unmerged_files ]]; then
   echo -e "${RED}The following files have merge conflicts after popping the stash:${NC}"
   echo
   printf %"s\n" $unmerged_files  # Ensure newlines are printed
else
   # Run stow to ensure all new dotfiles are linked
   for folder in $(echo $STOW_PACKAGES)
   do
	   echo "stow $folder"
	   stow -D $folder
	   stow $folder
   done
fi

popd

