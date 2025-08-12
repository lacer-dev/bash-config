#
# ~/.bashrc
#

# if not running interactively, exit
[[ "$-" != *i* ]] && return

export PATH="$PATH:~/bin"
export HISTCONTROL="$HISTCONTROL${HISTCONTROL+:}ignoredups:erasedups"
unset HISTFILE

[[ -f "${HOME}/.bash_aliases" ]] && . "${HOME}/.bash_aliases"
[[ -f "${HOME}/.bash_functions" ]] && . "${HOME}/.bash_functions"
[[ -f "${HOME}/.dircolors" ]] && . "${HOME}/.dircolors"

PS1='\[\e[38;5;3m\]\W\[\e[0m\] $ '
PROMPT_COMMAND='printf "\033]0;%s\007" "${PWD/#${HOME}/\~}"'

set -o ignoreeof # disable ^D for logout
shopt -s nocaseglob # enable case-insensitive filename globbing
