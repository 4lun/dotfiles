# AIASES
	alias dev="cd ~/Development/"
	alias ..="cd ../"
	alias hosts="subl /private/etc/hosts"

# Show which commands you use the most - Source: http://alias.sh/show-which-commands-you-use-most
	alias freq='cut -f1 -d" " ~/.bash_history | sort | uniq -c | sort -nr | head -n 30'

# Remove ".svn" folders from working copy (recursive) - Source: http://alias.sh/remove-svn-folders-workingcopy-recursive
	alias rm_svn="find . -type d -name .svn -exec rm -rf {} \;"

# Reload DNS on OSX - Source: http://alias.sh/reload-dns-osx
	alias flushdns="dscacheutil -flushcache"

# OS X keeps a log of all downloaded files, commands for listing and removing records
# http://news.ycombinator.com/item?id=5080350 & http://www.macgasm.net/2013/01/18/good-morning-your-mac-keeps-a-log-of-all-your-downloads/
	alias ls_downloads="sqlite3 ~/Library/Preferences/com.apple.LaunchServices.QuarantineEventsV* 'select LSQuarantineDataURLString from LSQuarantineEvent'"
	alias rm_downloads="sqlite3 ~/Library/Preferences/com.apple.LaunchServices.QuarantineEventsV* 'delete from LSQuarantineEvent'; sqlite3 ~/Library/Preferences/com.apple.LaunchServices.QuarantineEventsV* 'vacuum'"

# FUNCTIONS
# Make and cd into directory - Source: http://alias.sh/make-and-cd-directory
	function mcd() {
	  mkdir -p "$1" && cd "$1";
	}

	set_titlebar() {
	    case $TERM in
	        *xterm*|ansi|rxvt)
	            printf "\033]0;%s\007" "$*"
	            ;;
	    esac
	}

# Git related
	get_dir() {
	    printf "%s" $(pwd | sed "s:$HOME:~:")
	}

	get_sha() {
	    git rev-parse --short HEAD 2>/dev/null
	}

# cd and then ls - Source: http://alias.sh/cd-and-then-ls
	function cd () {
		builtin cd "$@" && ls;
	}

# EXPORTS
# Editors
	export EDITOR='subl -w'
	export SVN_MERGE='subl -w'
	export SVN_EDITOR='subl -w'

# Git PS1
	export GIT_PS1_SHOWDIRTYSTATE=1
	export GIT_PS1_SHOWSTASHSTATE=1
	export GIT_PS1_SHOWUNTRACKEDFILES=1
	export GIT_PS1_DESCRIBE_STYLE="branch"
	export GIT_PS1_SHOWUPSTREAM="auto git"

# SOURCES
# Load in the git branch prompt script.
	source ~/Development/4lun/dotfiles/git-prompt.sh

# COLOUR
if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
	export PS1="\[\e[1;35;1m\]\u\[\e[0m\]\[\e[35m\]@\h\[\e[35;1m\]\w\[\e[1;37m\]\$(__git_ps1 \"[%s $(get_sha)] \")\$ \[\e[0m\]"
else
	export PS1="\[\e[36;1m\]\u\[\e[0m\]\[\e[36m\]@\h\[\e[36;1m\]\w\[\e[1;37m\]\n\$(__git_ps1 \"[%s $(get_sha)] \")\$ \[\e[0m\]"
fi

# For reference, white on red, good for use on root user
# export PS1="\[\e[1;41m\]\u\[\e[0m\]\[\e[0;41m\]@\h\[\e[0;41m\]\w \[\e[1;37m\]\$ \[\e[0m\] "