# Editors
	export EDITOR='nano'

# Aliases
	alias dev="cd ~/Development/"
	alias ..="cd ../"
	alias hosts="$EDITOR /private/etc/hosts"
	alias vhosts="$EDITOR /etc/apache2/extra/httpd-vhosts.conf"

# Local phpunit
	phpunit() {
            if [ -f "./vendor/bin/phpunit" ]; then
		php ./vendor/bin/phpunit "$@";
	    else
		 echo "Unable to locate phpunit in ./vendor/bin";
	    fi
	}

# Simple server
	alias server='python -m SimpleHTTPServer'

# Vagrant homestead
	alias vmh="ssh vagrant@127.0.0.1 -p 2222"

# Show which commands you use the most - Source: http://alias.sh/show-which-commands-you-use-most
	alias freq='cut -f1 -d" " ~/.bash_history | sort | uniq -c | sort -nr | head -n 30'

# Remove ".svn" folders from working copy (recursive) - Source: http://alias.sh/remove-svn-folders-workingcopy-recursive
	alias rm_svn="find . -type d -name .svn -exec rm -rf {} \;"

# Reload DNS on OSX - Source: http://alias.sh/reload-dns-osx
	alias flushdns="dscacheutil -flushcache"

# OS X keeps a log of all downloaded files, commands for listing and removing records
# http://news.ycombinator.com/item?id=5080350 & http://www.macgasm.net/2013/01/18/good-morning-your-mac-keeps-a-log-of-all-your-downloads/
	alias ls_dl_log="sqlite3 ~/Library/Preferences/com.apple.LaunchServices.QuarantineEventsV* 'select LSQuarantineDataURLString from LSQuarantineEvent'"
	alias rm_dl_log="sqlite3 ~/Library/Preferences/com.apple.LaunchServices.QuarantineEventsV* 'delete from LSQuarantineEvent'; sqlite3 ~/Library/Preferences/com.apple.LaunchServices.QuarantineEventsV* 'vacuum'"

# Make and cd into directory - Source: http://alias.sh/make-and-cd-directory
	mcd() {
	  mkdir -p "$1" && cd "$1";
	}

# Git related
	get_dir() {
	    printf "%s" $(pwd | sed "s:$HOME:~:")
	}

	get_sha() {
	    git rev-parse --short HEAD 2>/dev/null
	}

	git_track_all_remote() { # Track all remote branches against local branches
		git branch -a | grep -v HEAD | perl -ne 'chomp($_); s|^\*?\s*||; if (m|(.+)/(.+)| && not $d{$2}) {print qq(git branch --track $2 $1/$2\n)} else {$d{$_}=1}' | csh -xfs
	}

# Git PS1
	export GIT_PS1_SHOWDIRTYSTATE=1
	export GIT_PS1_SHOWSTASHSTATE=1
	export GIT_PS1_SHOWUNTRACKEDFILES=1
	export GIT_PS1_DESCRIBE_STYLE="branch"
	export GIT_PS1_SHOWUPSTREAM="auto git"

# Git global .gitignore
	git config --global core.excludesfile $DOTFILES/global.gitignore

# Load in the git branch prompt script.
	source $DOTFILES/git-prompt.sh

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
