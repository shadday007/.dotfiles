#!/usr/bin/env bash

if [[ -z $STOW_DIRECTORY ]]; then
	STOW_DIRECTORY=$HOME/.dotfiles
fi

# Navigate to the directory of this script 
pushd $STOW_DIRECTORY

if [[ -z $STOW_PACKAGES ]]; then
	readarray -t STOW_PACKAGES < <(for i in $(ls -d [!^.]*/); do echo ${i%%/}; done)
fi

# Sync dotfiles repo and ensure that dotfiles are tangled correctly afterward
GREEN='\033[1;32m'
BLUE='\033[1;34m'
RED='\033[1;30m'
NC='\033[0m'

echo -e "${BLUE}Stashing existing changes in dotfiles...${NC}"
stash_result=$(git checkout master;git stash push -m "sync-dotfiles: Before syncing dotfiles")
echo -e "${BLUE}Stashing existing changes in submodules...${NC}"
stash_result=$(git submodule foreach 'git checkout master; git stash')

echo -e "${BLUE}Pulling updates from dotfiles repo...${NC}"
git pull origin master
echo -e "${BLUE}Pulling updates from submodules...${NC}"
git submodule foreach 'git pull origin master'

echo -e "${BLUE}Popping stashed changes...${NC}"
git stash pop
echo -e "${BLUE}Popping stashed changes in submodules...${NC}"
git submodule foreach 'git stash pop || :'

echo -e "${BLUE}finding unmerged files in dotfiles repo...${NC}"
unmerged_files=$(git diff --name-only --diff-filter=U)
echo -e "${BLUE}finding unmerged files in submodules...${NC}"
git submodule foreach 'unmerged_files+=$(git diff --name-only --diff-filter=U)'

if [[ ! -z $unmerged_files ]]; then
	echo -e "${RED}The following files have merge conflicts after popping the stash:${NC}"
	echo
	printf %"s\n" $unmerged_files  # Ensure newlines are printed
else
	# Run stow to ensure all new dotfiles are linked
	echo -e "${GREEN}Run stow to ensure all new dotfiles are linked...${NC}"
	for folder in "${STOW_PACKAGES[@]}"
	do
		echo "stow $folder"
		stow -D $folder
		stow $folder
	done
fi

popd

