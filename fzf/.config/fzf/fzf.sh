# Key bindings for command-line and Fuzzy finder completion for bash
source /usr/share/fzf/completion.bash
source /usr/share/fzf/key-bindings.bash

# 'fzf' configuration.
export FZF_DEFAULT_OPTS="
--height 75% --multi --reverse --margin=0,1
--bind ctrl-f:page-down,ctrl-b:page-up
--bind pgdn:preview-page-down,pgup:preview-page-up
--prompt=\"❯ \"
--preview '(highlight -O ansi {} || bat --color=always {}) 2> /dev/null | head -500'
"
export FZF_DEFAULT_COMMAND='fd --type f --color=never --hidden --exclude={.git,.idea,.vscode,.sass-cache,node_modules,build}'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS='--multi --preview "bat --color=always --line-range :500 {}"'
export FZF_ALT_C_COMMAND='fd --type d . --color=never --hidden'
export FZF_ALT_C_OPTS='--preview "tree -C {} | head -100"'

source ~/.config/fzf/.fzf-base16.sh
