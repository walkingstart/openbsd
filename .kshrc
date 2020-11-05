#export PS1='[\u@\h \W]\$ '
#export PS1='\u@\h[\[\e[01;$(($??31:39))m\]$?\[\e[0m]\]:\W\]$ '
if [ -f ~/.aliasrc ]; then
    . ~/.aliasrc
fi

if [ -e ~/.ksh_completions ]; then
        # shellcheck source=/home/qbit/.ksh_completions
            . ~/.ksh_completions
        fi

HISTFILE="$HOME/.ksh_history"
HISTSIZE=20000

set -o emacs
#set -o vi
#export VISUAL="emacs"
bind "^i=complete-list"
#bind "^i=complete"
#export EDITOR="$VISUAL"
alias weather='curl http://wttr.in/JianHu'
alias __A=$(print '\0020') # ^P = up = previous command
alias __B=$(print '\0016') # ^N = down = next command
alias __C=$(print '\0006') # ^F = right = forward a character
alias __D=$(print '\0002') # ^B = left = back a character
alias __H=$(print '\0001') # ^A = home = beginning of line
bold="\\033[01;39m"
white="\\033[0m"
# nice colored prompt
_XTERM_TITLE='\[\033]0;\u@\h:\w\007\]'
_PS1_CLEAR='\033[0m\]'
_PS1_BLUE='\033[34m\]'
case "$(id -u)" in
      0) _PS1_COLOR='\033[1;31m' ;;
      *) _PS1_COLOR='\033[32m\]' ;;
    esac
PS1='[\u@\h$_PS1_CLEAR:$_PS1_BLUE\w]$_PS1_COLOR\$$_PS1_CLEAR '

