#!/usr/bin/bash
#
# Color
#

BASE16_CONFIG=~/.vim/.base16
BASE16_LAST_SCHEME=~/.local/share/flavours/lastscheme

blk='\033[1;30m'   # Black
red='\033[1;31m'   # Red
grn='\033[1;32m'   # Green
ylw='\033[1;33m'   # Yellow
blu='\033[1;34m'   # Blue
pur='\033[1;35m'   # Purple
cyn='\033[1;36m'   # Cyan
wht='\033[1;37m'   # White
clr='\033[0m'      # Reset

function pause(){
   read -rp "$*"
}

err() {
  echo -e "${red}Error: $*${clr}" >&2
}

bug() {
  echo -e "${ylw}A bug occured. Please copy the following message and report the bug here: https://github.com/shadday007/.dotfiles"
  echo -e "${red}$*${clr}"
}

# Takes a hex color in the form of "RRGGBB" and outputs its luma (0-255, where
# 0 is black and 255 is white).
#
# Based on: https://github.com/lencioni/dotfiles/blob/b1632a04/.shells/colors
luma() {

  local COLOR_HEX=$1

  if [ -z "$COLOR_HEX" ]; then
    err "Missing argument hex color (RRGGBB)"
    return 1
  fi

  # Extract hex channels from background color (RRGGBB).
  local COLOR_HEX_RED
  local COLOR_HEX_GREEN
  local COLOR_HEX_BLUE
  COLOR_HEX_RED=$(echo "$COLOR_HEX" | cut -c 1-2)
  COLOR_HEX_GREEN=$(echo "$COLOR_HEX" | cut -c 3-4)
  COLOR_HEX_BLUE=$(echo "$COLOR_HEX" | cut -c 5-6)

  # Convert hex colors to decimal.
  local COLOR_DEC_RED
  local COLOR_DEC_GREEN
  local COLOR_DEC_BLUE
  COLOR_DEC_RED=$((16#$COLOR_HEX_RED))
  COLOR_DEC_GREEN=$((16#$COLOR_HEX_GREEN))
  COLOR_DEC_BLUE=$((16#$COLOR_HEX_BLUE))

  # Calculate perceived brightness of background per ITU-R BT.709
  # https://en.wikipedia.org/wiki/Rec._709#Luma_coefficients
  # http://stackoverflow.com/a/12043228/18986
  local COLOR_LUMA_RED
  local COLOR_LUMA_GREEN
  local COLOR_LUMA_BLUE
  COLOR_LUMA_RED=$(echo "0.2126 * $COLOR_DEC_RED" | bc )
  COLOR_LUMA_GREEN=$(echo "0.7152 * $COLOR_DEC_GREEN" | bc )
  COLOR_LUMA_BLUE=$(echo "0.0722 * $COLOR_DEC_BLUE" | bc )

  local COLOR_LUMA
  COLOR_LUMA=$(echo "$COLOR_LUMA_RED + $COLOR_LUMA_GREEN + $COLOR_LUMA_BLUE" | bc )

  echo "$COLOR_LUMA"
}

color() {

  local SCHEME="$1"
  local BASE16_DIR=~/.vim/colors
  local BASE16_CONFIG_PREVIOUS="$BASE16_CONFIG.previous"
  local STATUS=0

  __color() {
    SCHEME=$1

    flavours apply $SCHEME
    test $? -eq 0 || bug "There was some error applying scheme:  $SCHEME"
    
    # hooks in flavours config don't work in this env.
    source ~/.config/fzf/fzf.sh
    source ~/.config/bspwm/bspwm_colors.sh
    source ~/.config/bash/scripts/base16_shell_colors.sh

    local SCHEME=$(head -1 "$BASE16_LAST_SCHEME")
    local FILE_BASE="$BASE16_DIR/base16.vim"
    local FILE="$BASE16_DIR/base16-$SCHEME.vim"

    rm $BASE16_DIR/base16-*.vim 2>/dev/null
    mv $FILE_BASE $FILE

    if [[ -e "$FILE" ]]; then
      local BG
      local LUMA
      local BACKGROUND
      BG=$(grep 's:gui00\s*=' "$FILE" | cut -d \" -f2)
      LUMA=$(luma "$BG")

      if [ "$(echo "$LUMA <= 127.5" | bc)" -eq 1 ]; then
        BACKGROUND="dark"
      else
        BACKGROUND="light"
      fi

      if [ -e "$BASE16_CONFIG" ]; then
        # \ here override alias cp
        \cp "$BASE16_CONFIG" "$BASE16_CONFIG_PREVIOUS"
      fi

      echo "$SCHEME" > "$BASE16_CONFIG"
      echo "$BACKGROUND" >> "$BASE16_CONFIG"
      echo "vim9script" > ~/.vim/vimrc-colorscheme.vim
      echo "if !exists('g:colors_name') || g:colors_name != 'base16-$SCHEME'" >> ~/.vim/vimrc-colorscheme.vim
      echo "  colorscheme base16-$SCHEME" >> ~/.vim/vimrc-colorscheme.vim
      echo "  set background=$BACKGROUND" >> ~/.vim/vimrc-colorscheme.vim
      echo "endif" >> ~/.vim/vimrc-colorscheme.vim

      if [ -n "$TMUX" ]; then
        local CC
        CC=$(grep 's:gui01\s*=' "$FILE" | cut -d \" -f2)
        if [ -n "$BG" ] && [ -n "$CC" ]; then
          command tmux set -a window-active-style "bg=#$BG"
          command tmux set -a window-style "bg=#$CC"
          command tmux set -g pane-active-border-style "bg=#$CC"
          command tmux set -g pane-border-style "bg=#$CC"
        fi
      fi
    else
      err "Scheme '$SCHEME' not found in $BASE16_DIR"
      STATUS=1
    fi
  }

  if [ $# -eq 0 ]; then
    if [ -s "$BASE16_CONFIG" ]; then
      echo -e "${grn}";cat "$BASE16_CONFIG";echo -e "${clr}"
      local SCHEME
      SCHEME=$(head -1 "$BASE16_CONFIG")
      __color "$SCHEME"
      return
    else
      SCHEME=help
    fi
  fi

  case "$SCHEME" in
    "-h"|"-?"|"--help")
      echo -e "${wht}Usage: ${pur}color${clr} [${grn}options]${clr} [${grn}scheme]${clr} [${grn}pattern]${clr}"
      echo -e "  The default is to show current scheme.\n"
      echo -e "${wht}Options:"
      echo -e "  ${blu}-h,-?,--help                    ${clr} (show this help)"
      echo -e "  ${blu}-l,--list [pattern]             ${clr} (list available schemes)"
      echo -e "  ${blu}-s,--switch [scheme] | [pattern]${clr} (switch to scheme)"
      echo -e "  ${blu}-                               ${clr} (switch to previous scheme)\n"
      return
      ;;
    "-l"|"--list")
      flavours list $2 |
        xargs -n1 |
        fzf --preview "flavours info {} 2>/dev/null"
        ;;
    -)
      if [[ -s "$BASE16_CONFIG_PREVIOUS" ]]; then
        local PREVIOUS_SCHEME
        PREVIOUS_SCHEME=$(head -1 "$BASE16_CONFIG_PREVIOUS")
        __color "$PREVIOUS_SCHEME"
      else
        echo "${ylw}Warning: no previous config found at $BASE16_CONFIG_PREVIOUS${clr}"
        STATUS=1
      fi
      ;;
    "-s"|"--switch")
      __color $( flavours list $2 |
        xargs -n1 |
        fzf --preview "flavours info {} 2>/dev/null" )
        ;;
    *)
      if  flavours list | grep -wq $SCHEME 2>/dev/null  ; then
        __color "$SCHEME"
      else
        err "Scheme not found"
        STATUS=1
      fi
      ;;
  esac

  unset -f __color
  return $STATUS
}

if [[ -s "$BASE16_CONFIG" ]]; then
  SCHEME=$(head -1 "$BASE16_CONFIG")
  BACKGROUND=$(sed -n -e '2 p' "$BASE16_CONFIG")
  PREVIOUS_SCHEME=$(head -1 "$BASE16_CONFIG.previous")

  if [ "$BACKGROUND" != 'dark' ] && [ "$BACKGROUND" != 'light' ]; then
    echo -e "${ylw}Warning: unknown background type in $BASE16_CONFIG${clr}"
  elif [ "$SCHEME" != "$PREVIOUS_SCHEME" ]; then
    color "$SCHEME"
  fi
else
  # Default.
  color  default-dark
fi
