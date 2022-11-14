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

echo -e "${BLUE}Cleaning dotfiles links...${NC}"
for folder in "${STOW_PACKAGES[@]}"
do
	echo "stow -D $folder"
	stow -D $folder
done

echo -e "${GREEN}Done...${NC}"
popd

