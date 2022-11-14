#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc
#[[ -f ~/.profile ]] && . ~/.profile

# make CapsLock behave like Ctrl:
setxkbmap -option ctrl:nocaps

# make short-pressed Ctrl behave like Escape:
xcape -e 'Control_L=Escape'

export GOPATH=~/go
export PATH="$PATH:$GOPATH/bin"

# opam configuration
test -r /home/shadday/.opam/opam-init/init.sh && . /home/shadday/.opam/opam-init/init.sh > /dev/null 2> /dev/null || true
