#!/usr/bin/env bash

if [[ -z $STOW_DIRECTORY ]]; then
	STOW_DIRECTORY=$HOME/.dotfiles
fi

# Navigate to the directory of this script 
pushd $STOW_DIRECTORY

# Sync dotfiles repo and ensure that dotfiles are tangled correctly afterward
GREEN='\033[1;32m'
BLUE='\033[1;34m'
RED='\033[1;30m'
NC='\033[0m'

# Save changes on actual branches
echo -e "${BLUE}Stashing existing changes in dotfiles...${NC}"
git stash push -m "sync-dotfiles: Before syncing dotfiles"
echo -e "${BLUE}Stashing existing changes in submodules...${NC}"
git submodule foreach 'git stash'

# Switch to master branches
echo -e "${BLUE}Switch to master...${NC}"
git checkout master
git submodule foreach 'git checkout master'

# Pulling all changes
echo -e "${BLUE}Pulling updates from dotfiles repo and submodules...${NC}"
git pull origin master
git submodule foreach 'git pull origin master'

# TODO: decide if these variables are fixed or dynamics
if [[ -z $STOW_PACKAGES ]]; then
	readarray -t STOW_PACKAGES < <(for i in $(ls -d [!^.]*/); do echo ${i%%/}; done)
fi

# Run stow to ensure all new dotfiles are linked
echo -e "${GREEN}Run stow to ensure all new dotfiles are linked...${NC}"
for folder in "${STOW_PACKAGES[@]}"
do
	echo "stow $folder"
	stow -D $folder
	stow $folder
done

echo -e "${BLUE}Switch back to old branch...${NC}"
stash_result=$(git checkout -)
stash_result=$(git submodule foreach 'git checkout -')

echo -e "${BLUE}Popping stashed changes...${NC}"
git stash pop
echo -e "${BLUE}Popping stashed changes in submodules...${NC}"
git submodule foreach 'git stash pop || :'

popd
echo -e "${GREEN}Done...${NC}"
