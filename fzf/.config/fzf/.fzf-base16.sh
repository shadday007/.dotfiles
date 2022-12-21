# Base16 Horizon Dark
# Scheme author: Michaël Ball (http://github.com/michael-ball/)
# Template author: Tinted Theming (https://github.com/tinted-theming)

_gen_fzf_default_opts() {

local color00='#1C1E26'
local color01='#232530'
local color02='#2E303E'
local color03='#6F6F70'
local color04='#9DA0A2'
local color05='#CBCED0'
local color06='#DCDFE4'
local color07='#E3E6EE'
local color08='#E95678'
local color09='#FAB795'
local color0A='#FAC29A'
local color0B='#29D398'
local color0C='#59E1E3'
local color0D='#26BBD9'
local color0E='#EE64AC'
local color0F='#F09383'

export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS"\
" --color=bg+:$color01,bg:$color00,spinner:$color0C,hl:$color0D"\
" --color=fg:$color04,header:$color0D,info:$color0A,pointer:$color0C"\
" --color=marker:$color0C,fg+:$color06,prompt:$color0A,hl+:$color0D"

}

_gen_fzf_default_opts
