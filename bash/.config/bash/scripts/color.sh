#!/usr/bin/bash
#
# Colors
#

BASE16_CONFIG=~/.vim/.base16


function pause(){
   read -rp "$*"
}

# Takes a hex color in the form of "RRGGBB" and outputs its luma (0-255, where
# 0 is black and 255 is white).
#
# Based on: https://github.com/lencioni/dotfiles/blob/b1632a04/.shells/colors
luma() {

  local COLOR_HEX=$1

  if [ -z "$COLOR_HEX" ]; then
    echo "Missing argument hex color (RRGGBB)"
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
  local BASE16_DIR=~/.config/base16-shell/scripts
  local BASE16_CONFIG_PREVIOUS="$BASE16_CONFIG.previous"
  local STATUS=0

  __color() {
    SCHEME=$1
    local FILE="$BASE16_DIR/base16-$SCHEME.sh"
    if [[ -e "$FILE" ]]; then
      local BG
      local LUMA
      local BACKGROUND
      BG=$(grep color_background= "$FILE" | cut -d \" -f2 | sed -e 's#/##g')
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
      sh "$FILE"

      if [ -n "$TMUX" ]; then
        local CC
        CC=$(grep color18= "$FILE" | cut -d \" -f2 | sed -e 's#/##g')
        if [ -n "$BG" ] && [ -n "$CC" ]; then
          command tmux set -a window-active-style "bg=#$BG"
          command tmux set -a window-style "bg=#$CC"
          command tmux set -g pane-active-border-style "bg=#$CC"
          command tmux set -g pane-border-style "bg=#$CC"
        fi
      fi
    else
      echo "Scheme '$SCHEME' not found in $BASE16_DIR"
      STATUS=1
    fi
  }

  if [ $# -eq 0 ]; then
    if [ -s "$BASE16_CONFIG" ]; then
      cat "$BASE16_CONFIG"
      local SCHEME
      SCHEME=$(head -1 "$BASE16_CONFIG")
      __color "$SCHEME"
      return
    else
      SCHEME=help
    fi
  fi

  case "$SCHEME" in
  -help)
    echo 'color                                   (show current scheme)'
    echo 'color -                                 (switch to previous scheme)'
    echo 'color default-dark|grayscale-light|...  (switch to scheme)'
    echo 'color -help                             (show this help)'
    echo 'color -ls [pattern]                     (list available schemes)'
    return
    ;;
  -ls)
    find "$BASE16_DIR" -name 'base16-*.sh' | \
      sed -E 's|.+/base16-||' | \
      sed -E 's/\.sh//' | \
      grep "${2:-.}" | \
      sort | \
      column
      ;;
  -)
    if [[ -s "$BASE16_CONFIG_PREVIOUS" ]]; then
      local PREVIOUS_SCHEME
      PREVIOUS_SCHEME=$(head -1 "$BASE16_CONFIG_PREVIOUS")
      __color "$PREVIOUS_SCHEME"
    else
      echo "warning: no previous config found at $BASE16_CONFIG_PREVIOUS"
      STATUS=1
    fi
    ;;
  *)
    __color "$SCHEME"
    ;;
  esac

  unset -f __color
  return $STATUS
}

if [[ -s "$BASE16_CONFIG" ]]; then
  SCHEME=$(head -1 "$BASE16_CONFIG")
  BACKGROUND=$(sed -n -e '2 p' "$BASE16_CONFIG")
  #echo $SCHEME $BACKGROUND
  if [ "$BACKGROUND" != 'dark' ] && [ "$BACKGROUND" != 'light' ]; then
    echo "warning: unknown background type in $BASE16_CONFIG"
  fi
  color "$SCHEME"
else
  # Default.
  color  default-dark
fi
