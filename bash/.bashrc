
# Make sure the shell is interactive
case $- in
    *i*) ;;
    *) return ;;
esac

#IFS=$'\n'

export HISTIGNORE="history*:[ \t]*:ls:ll:cd:cd -:man:man *:pwd:exit:date:* --help:"
export HISTCONTROL=ignoredups:erasedups
# export HISTTIMEFORMAT="%F %T "

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
export HISTSIZE=5000
HISTFILESIZE=10000
export HSTR_CONFIG=hicolor       # get more colors

debug_handler() {
    LAST_COMMAND=$BASH_COMMAND;
}

exit_handler() {
    for i in $(echo $FAILED_COMMANDS | tr ' ' '\n' | uniq)
    do
        history -d $i
    done
    FAILED_COMMANDS=
    history -n; history -w; history -c; history -r;
}

# trap error_handler ERR
trap debug_handler DEBUG
# If you want to perform work any time bash exits (and whether it’s a login shell or not)
trap exit_handler EXIT

remove_failed_commands_from_history () {
    local exit_status=$?
    # If the exit status was 127, the command was not found. Let's remove it from history
    # local number=$(history 1)
    # number=${number%% *}
    local number=$(history 1 | awk '{print $1}')
    if [ -n "$number" ]; then
        if [ $exit_status -eq 127 ] && ([ -z $HISTLASTENTRY ] || [ $HISTLASTENTRY -lt $number ]); then
            history -d $number
        else
            HISTLASTENTRY=$number
        fi
    fi
}

export PROMPT_COMMAND="remove_failed_commands_from_history;$PROMPT_COMMAND"

#shop
shopt -s autocd # change to named directory
shopt -s cdspell # autocorrects cd misspellings
shopt -s cmdhist # save multi-line commands in history as single line
shopt -s dotglob #include filenames beginning with `.' in results of path	expansion
shopt -s histappend # do not overwrite history
shopt -s expand_aliases # expand aliases
shopt -s direxpand # expand directory names
shopt -s histreedit ## reedit a history substitution line if it failed
shopt -s histverify ## edit a recalled history line before executing

export EDITOR=vim
export VIMCONFIG=~/.vim
export VIMDATA=~/.vim
export MYVIMRC=~/.vim/vimrc

# from vim-unimpaired plugin
stty -ixon  #Note that <C-Q> only works in a terminal if you disable flow control

# Execute Alias definitions. {{{
DISTRO=$(cat /etc/issue  | head -n +1 | awk '{print $1}')
if [[ -f $HOME/.config/bash/aliasses/$DISTRO ]]; then
    . "$HOME"/.config/bash/aliasses/"$DISTRO"
else
    . "$HOME"/.config/bash/aliasses/default
fi
# }}}

# echo $TERM
if [[ $TERM == xterm-termite ]]; then
    . /etc/profile.d/vte*.sh
    __vte_prompt_command
fi

[ -z "$TMUX" ] && export TERM=xterm-256color

# Base16 Shell {{{
BASE16_SHELL="$HOME/.config/base16-shell/"

if [[ ! -f $BASE16_SHELL/profile_helper.sh ]]; then
    git clone https://github.com/chriskempson/base16-shell.git "$BASE16_SHELL"
fi

#The -n returns TRUE if the length of STRING is nonzero.
#has problem with vim terminal
[ -n "$PS1" ] && \
    [ -s "$BASE16_SHELL/profile_helper.sh" ] && \
    eval "$("$BASE16_SHELL/profile_helper.sh")"
# }}}

export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
export PATH="/home/shadday/.local/bin:$PATH"
export PATH="/home/shadday/.config/bash/scripts/:$PATH"
export PATH=".:$PATH"
export PATH="/home/shadday/.gem/ruby/3.0.0/bin:$PATH"

export MANPATH="$(manpath -g):$HOME/.cache/cppman:$HOME/.cache/cppman/manindex"   #no set for now

# install font JetBrains Mono Regular Nerd Font Complete.ttf
FONT_INSTALLED=$(fc-list | grep -i "JetBrainsMono");
if [ -z "$FONT_INSTALLED" ]; then
    FONT_INSTALL_PATH="$HOME/.local/share/fonts"
    FONT_URL="https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/JetBrainsMono/Regular/complete/JetBrains%20Mono%20Regular%20Nerd%20Font%20Complete.ttf"
    FONT_NAME="JetBrains Mono Regular Nerd Font Complete.ttf"
    curl -fLo "$FONT_NAME" "$FONT_URL"
    if [ ! -d "$FONT_INSTALL_PATH" ]; then
        mkdir "$FONT_INSTALL_PATH"
    fi
    mv "$FONT_NAME" "$FONT_INSTALL_PATH"
    fc-cache -f -v
fi

# Key bindings for command-line and Fuzzy finder completion for bash
source /usr/share/fzf/completion.bash
source /usr/share/fzf/key-bindings.bash

# 'fzf' configuration.
export FZF_DEFAULT_OPTS="
--height 75% --multi --reverse --margin=0,1
--bind ctrl-f:page-down,ctrl-b:page-up
--bind pgdn:preview-page-down,pgup:preview-page-up
--prompt=\"❯ \"
--color bg+:#343d46,fg+:#dadada,hl:#0dbc79,hl+:#23d18b
--color border:#303030,info:#0dbc79,header:#80a0ff,spinner:#36c692
--color prompt:#87afff,pointer:#ff3c3c,marker:#f09479,gutter:-1
--preview '(highlight -O ansi {} || bat --color=always {}) 2> /dev/null | head -500'
"
export FZF_DEFAULT_COMMAND='fd --type f --color=never --hidden --exclude={.git,.idea,.vscode,.sass-cache,node_modules,build}'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS='--multi --preview "bat --color=always --line-range :500 {}"'
export FZF_ALT_C_COMMAND='fd --type d . --color=never --hidden'
export FZF_ALT_C_OPTS='--preview "tree -C {} | head -100"'

export BAT_THEME="base16-256"

# Ruby environment manager
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# starship prompt
eval "$(starship init bash)"
source /usr/share/nvm/init-nvm.sh

source "$HOME"/.config/bash/scripts/color.sh

### CREATE CUSTOM PROMPT(S)
# txtblu='\[\033[00;34m\]'
# txtpur='\[\033[00;35m\]'
# txtblu='\[\033[00;36m\]'
# txtwht='\[\033[00;37m\]'
# txtylw='\[\033[00;33m\]'
# txtgrn='\[\033[00;32m\]'
# txtred='\[\033[00;31m\]'
# txtblk='\[\033[00;30m\]'
# blk='\[\033[01;30m\]'   # Black
# red='\[\033[01;31m\]'   # Red
# grn='\[\033[01;32m\]'   # Green
# ylw='\[\033[01;33m\]'   # Yellow
# blu='\[\033[01;34m\]'   # Blue
# pur='\[\033[01;35m\]'   # Purple
# cyn='\[\033[01;36m\]'   # Cyan
# wht='\[\033[01;37m\]'   # White
# clr='\[\033[00m\]'      # Reset

#PS1=$'\n\e[1;36m %@ [%.] %# \e[0m\e[4 q' # for zsh
# \n - new line
# %# - specifies whether the user is root (#) or otherwise (%)
# \e[1;36m - applies bold and cyan color to the following text (list of options in the LS_COLORS file on the www-gem gitlab)
# %@ - time in 12h format
# %. - current directory (not the full path)
# \e[0m - exit color-change
# \e[4 q - show the cursor as underline _
# 0 -> blinking block
# 1 -> blinking block (default)
# 2 -> steady block
# 3 -> blinking underline
# 4 -> steady underline
# 5 -> blinking bar (xterm)
# 6 -> steady bar (xterm)
# Note that zsh also offers a right sided prompt with the RPROMPT variable. It uses the same placeholders as the PS1 prompt.

  ### OTHER ZSH OPTIONS
  # %D - the date in yy-mm-dd format
  # %T - current time of day, in 24-hour format
  # %t or %@ - current time of day, in 12-hour, am/pm format
  # %* - current time of day in 24-hour format, with seconds
  # %w - the date in day-dd format
  # %W - the date in mm/dd/yy format
  # %D{string} - string is formatted using the strftime function. See man page strftime(3) for more details. Various zsh extensions provide numbers with no leading zero or space if the number is a single digit
  # %f - the day of the month
  # %K - the hour of the day on the 24-hour clock
  # %L - the hour of the day on the 12-hour clock
  # %l - the line (tty) the user is logged in on, without ‘/dev/’ prefix. If the name starts with ‘/dev/tty’, that prefix is stripped
  # %M - the full machine hostname
  # %m - the hostname up to the first ‘.’. An integer may follow the ‘%’ to specify how many components of the hostname are desired. With a negative integer, trailing components of the hostname are shown
  # %n - $USERNAME
  # %y - the line (tty) the user is logged in on, without ‘/dev/’ prefix. This does not treat ‘/dev/tty’ names specially
  # %? - the return status of the last command executed just before the prompt
  # %_ - the status of the parser, i.e. the shell constructs (like ‘if’ and ‘for’) that have been started on the command line. If given an integer number that many strings will be printed; zero or negative or no integer means print as many as there are. This is most useful in prompts PS2 for continuation lines and PS4 for debugging with the XTRACE option; in the latter case it will also work non-interactively
  # %^ - the status of the parser in reverse. This is the same as ‘%_’ other than the order of strings. It is often used in RPS2
  # %d or %/ - current working directory. If an integer follows the ‘%’, it specifies a number of trailing components of the current working directory to show; zero means the whole path. A negative integer specifies leading components, i.e. %-1d specifies the first component
  # %~ - as %d and %/, but if the current working directory starts with $HOME, that part is replaced by a ‘~’. Furthermore, if it has a named directory as its prefix, that part is replaced by a ‘~’ followed by the name of the directory, but only if the result is shorter than the full path; Filename Expansion
  # %e - evaluation depth of the current sourced file, shell function, or eval. This is incremented or decremented every time the value of %N is set or reverted to a previous value, respectively. This is most useful for debugging as part of $PS4
  # %h or %! - current history event number
  # %i - the line number currently being executed in the script, sourced file, or shell function given by %N. This is most useful for debugging as part of $PS4
  # %I - the line number currently being executed in the file %x. This is similar to %i, but the line number is always a line number in the file where the code was defined, even if the code is a shell function
  # %j - the number of jobs
  # %L - the current value of $SHLVL
  # %N - the name of the script, sourced file, or shell function that zsh is currently executing, whichever was started most recently. If there is none, this is equivalent to the parameter $0. An integer may follow the ‘%’ to specify a number of trailing path components to show; zero means the full path. A negative integer specifies leading components
  # %x - the name of the file containing the source code currently being executed. This behaves as %N except that function and eval command names are not shown, instead the file where they were defined
  # %c or % or %C - trailing component of the current working directory. An integer may follow the ‘%’ to get more than one component. Unless ‘%C’ is used, tilde contraction is performed first. These are deprecated as %c and %C are equivalent to %1~ and %1/, respectively, while explicit positive integers have the same effect as for the latter two sequences

  ### BASH OPTIONS
  # \$ - specifies whether the user is root (#) or otherwise ($)
  # \d – date (day/month/date)
  # \h – hostname (short)
  # \H – full hostname (domain name)
  # \j – number of jobs being managed by the shell
  # \l – the basename of the shells terminal device
  # \r – carriage return
  # \s – the name of the shell
  # \t – time (hour:minute:second)
  # \A – time, 24-hour, without seconds
  # \u – current username
  # \v – bASH version
  # \V – extra information about the BASH version
  # \w – current working directory ($HOME is represented by ~)
  # \W – the basename of the working directory ($HOME is represented by ~)
  # \[ – start a sequence of non-displayed characters (useful if you want to add a command or instruction set to the prompt)
  # \] – close or end a sequence of non-displayed characters
