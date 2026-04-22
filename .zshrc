export DOTFILES=$(dirname $(realpath $0))
source $DOTFILES/.sharedrc

setopt prompt_subst

# Set window title to current directory name
autoload -U add-zsh-hook
_set_window_title() { print -Pn "\e]0;%1~\a" }
add-zsh-hook precmd _set_window_title

export PS1=$'\n%{\e[36;1m%}%n%{\e[0m%}%{\e[36m%}@%m:%{\e[36;1m%}%~%{\e[1;37m%}%{\e[1;37m%}\n\$(__git_ps1 "[%s] ")$ %{\e[0m%}'
