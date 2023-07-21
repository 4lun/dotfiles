export DOTFILES=$(dirname $BASH_SOURCE)
source $DOTFILES/.sharedrc

# Colour (includes git status if available, requires git-prompt.sh)
if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
	export PS1="\n\[\e[1;35;1m\]\u\[\e[0m\]\[\e[35m\]@\h:\[\e[35;1m\]\w\n\[\e[1;37m\]"'$(
    if [[ $(__git_ps1) == *"master"* ]]
	then echo "\[\e[1;41m\]"
	fi)'"\$(__git_ps1 \"[%s$(get_sha)]\[\e[0m\] \")\[\e[1;37m\]\$ \[\e[0m\]"
else
	export PS1="\n\[\e[36;1m\]\u\[\e[0m\]\[\e[36m\]@\h:\[\e[36;1m\]\w\n\[\e[1;37m\]"'$(
    if [[ $(__git_ps1) == *"master"* ]]
	then echo "\[\e[1;41m\]"
	fi)'"\$(__git_ps1 \"[%s$(get_sha)]\[\e[0m\] \")\[\e[1;37m\]\$ \[\e[0m\]"
fi

# For reference, white on red, good for use on root user
# export PS1="\[\e[1;41m\]\u\[\e[0m\]\[\e[0;41m\]@\h\[\e[0;41m\]\w\n\[\e[1;37m\]\[\e[0m\]\$ "
# For reference, purple ssh style, without git status
# export PS1="\n\[\e[1;35;1m\]\u\[\e[0m\]\[\e[35m\]@\h:\[\e[35;1m\]\w\n\[\e[1;37m\]\$ \[\e[0m\]"
