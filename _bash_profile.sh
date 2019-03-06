# .bash_profile

# set -x

# Source global definitions
[[ -f /etc/bashrc ]] && . /etc/bashrc


# Adapted from pathmunge in /etc/profile
function pathmunge {
    [[ ! -d "$1" ]] && return 1

    if ! echo $PATH | egrep -q "(^|:)$1($|:)" ; then
        if [ "$2" = "after" ] ; then
            PATH=$PATH:$1
        else
            PATH=$1:$PATH
        fi
    fi
}


# Shell options - see man shopt for details!
shopt -s cdable_vars # use variables with the cd command
shopt -s cmdhist # save multi-line commands as one history entry
shopt -s cdspell # correct minor spelling errors
shopt -s checkwinsize # check window size, update LINES and COLUMNS as appropriate
if [[ $(uname -s) != "Darwin" ]]; then
    shopt -s dirspell # spelling correction on directory word completion
fi
shopt -s extglob # Necessary for programmable completion.
shopt -s histappend # append to history file rather than overwrite
shopt -s histreedit # allow re-edit of failed history substitutions
shopt -s histverify # history entry passed to readline buffer, not auto-executed
shopt -s sourcepath # source builtin uses PATH to find the supplied file


# auto-export all variables
set +o allexport

GREP_OPTIONS="--color=always" # Colorize grep

# OS X settings
if [[ $(uname -s) == "Darwin" ]]; then
	echo "Loading $(uname -s)-specific settings"

	# Source Python virtualenvwrapper helpers
	WORKON_HOME=${HOME}/.virtualenvs
	VIRTUALENVWRAPPER_PYTHON=/usr/local/bin/python3
	. /usr/local/bin/virtualenvwrapper.sh
	# TODO: Choose a default virtualenv
	# [[ -z ${VIRTUAL_ENV} ]] && workon proxy

	# LS Colors
	CLICOLOR=1
	LSCOLORS=GxFxCxDxBxegedabagaced

	# Add terraform pwsh scripts to path
	pathmunge ~/PycharmProjects/infrastructure/tf/bin after

	# Homebrew binaries take precedence
	pathmunge /usr/local/bin
	pathmunge /usr/local/sbin
fi

# Include executables from user's bin directory
pathmunge ${HOME}/bin after

# Load Liquidprompt
if [[ $- = *i* && -f /usr/local/share/liquidprompt ]]; then
    . /usr/local/share/liquidprompt
fi

# Eternal bash history.
# ---------------------
# Undocumented feature which sets history size to "unlimited".
# http://stackoverflow.com/questions/9457233/unlimited-bash-history
HISTFILESIZE=
HISTSIZE=
# Change the file location because certain bash sessions truncate .bash_history file upon close.
# http://superuser.com/questions/575479/bash-history-truncated-to-500-lines-on-each-login
HISTFILE=~/.bash_eternal_history
# Force prompt to write history after every command.
# http://superuser.com/questions/20900/bash-history-loss
PROMPT_COMMAND="history -a; $PROMPT_COMMAND"
# collapse duplicate history entries
HISTCONTROL=ignorespace:ignoredups
# Add timestamp to history
HISTTIMEFORMAT="%F %T > "
# Ignore clutterful entries
HISTIGNORE="[ ]*:hgrep*:history*:hd*:man*:h:x:exit:reload:reset:l:lt:d:tldr*:c:w:path:t"

# Colorize less with pygments
LESS='-R'
LESSOPEN='|~/.lessfilter %s'

set -o allexport


# Enable additional features
features=()
# Git auto-completion
features+=(${HOME}/bin/git-completion.sh)
# Autojump
features+=(/usr/local/etc/autojump.sh)
# tldr
features+=(/opt/local/share/tldr-cpp-client/autocomplete/complete.bash)

for feature in "${features[@]}"; do
	[[ -f ${feature} ]] && . ${feature}
done

# TODO: loading all completions in the below loop causes issues :/
# LOAD ALL AUTOCOMPLETIONS IF ANY ARE INSTALLED
#if [ -d /usr/local/etc/bash_completion.d ]; then
#    for F in "/usr/local/etc/bash_completion.d/"*; do
#       if [ -f "${F}" ]; then
#		echo "Loading ${F}"
#		source "${F}";
#       fi
#    done
#fi

# Load bash completion libraries
. /usr/local/etc/bash_completion.d/git-extras
. /usr/local/etc/bash_completion.d/git-completion.bash
. /usr/local/etc/bash_completion.d/vagrant

# Consul autocompletion
[[ -f /usr/bin/consul ]] && complete -C /usr/bin/consul consul

# Vault autocompletion
[[ -f /usr/bin/vault ]] && complete -C /usr/bin/vault vault


# Load supplemental files - Separated by area of concern:
## .bash_profile{_local} - Shell settings, history settings, environment variables
## .bash_aliases{_local} - Shell aliases
## .bash_functions{_local} - Shell functions
# NOTE: All "_local" files are executed last, and are in place so that distributed versions
# (.e.g. without "_local" suffix) do not overwrite items setup for an individual environment / server.
profiles=( ".bash_aliases" ".bash_functions" ".bash_profile_local" ".bash_aliases_local" ".bash_functions_local" )
for filename in "${profiles[@]}"; do
	[[ -f ${HOME}/${filename} ]] && . ${HOME}/${filename} && echo "Loading ${filename}"
done