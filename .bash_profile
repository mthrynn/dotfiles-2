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

GREP_OPTIONS="--color=always" # Colorize grep

# LS Colors
CLICOLOR=1
LSCOLORS=GxFxCxDxBxegedabagaced

complete -W "NSGlobalDomain" defaults # Add tab completion for `defaults read|write NSGlobalDomain`
shopt -s nocaseglob; # Case-insensitive globbing (used in pathname expansion)
shopt -s cdspell; # Correct spelling errors in arguments supplied to cd
shopt -s dirspell 2> /dev/null # Autocorrect on directory names to match a glob.
shopt -s globstar 2> /dev/null # Turn on recursive globbing (enables ** to recurse all directories)
shopt -s cdable_vars # use variables with the cd command
shopt -s cmdhist # save multi-line commands as one history entry
shopt -s checkwinsize # check window size, update LINES and COLUMNS as appropriate
shopt -s dirspell # spelling correction on directory word completion
shopt -s extglob # Necessary for programmable completion.
shopt -s histappend # append to history file rather than overwrite
shopt -s histreedit # allow re-edit of failed history substitutions
shopt -s histverify # history entry passed to readline buffer, not auto-executed
shopt -s sourcepath # source builtin uses PATH to find the supplied file
shopt -s cmdhist # Save multi-line commands as one command
HISTFILESIZE=-1
HISTSIZE=-1
HISTFILE=~/.bash_eternal_history

# Colorize less with pygments
LESS='-R'
LESSOPEN='|~/.lessfilter %s'


for file in ~/.{alias,bash_prompt,exports,aliases,functions}; do
    [ -r "$file" ] && source "$file"
done
unset file

# generic colouriser
GRC=`which grc`
if [ "$TERM" != dumb ] && [ -n "$GRC" ]
    then
        alias colourify="$GRC -es --colour=auto"
        alias configure='colourify ./configure'
        for app in {diff,make,gcc,g++,ping,traceroute}; do
            alias "$app"='colourify '$app
    done
fi

# highlighting inside manpages and elsewhere
export LESS_TERMCAP_mb=$'\E[01;31m'       # begin blinking
export LESS_TERMCAP_md=$'\E[01;38;5;74m'  # begin bold
export LESS_TERMCAP_me=$'\E[0m'           # end mode
export LESS_TERMCAP_se=$'\E[0m'           # end standout-mode
export LESS_TERMCAP_so=$'\E[38;5;246m'    # begin standout-mode - info box
export LESS_TERMCAP_ue=$'\E[0m'           # end underline
export LESS_TERMCAP_us=$'\E[04;38;5;146m' # begin underline
bind Space:magic-space
export HISTTIMEFORMAT='%F %T '
export HISTCONTROL="erasedups:ignoreboth"       # no duplicate entries
type shopt &> /dev/null && shopt -s histappend  # append to history, don't overwrite it
export HISTIGNORE="&:[ ]*:exit:ls:bg:fg:history:clear" # Don't record some commands
export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND" # Save and reload the history after each command finishes
# Homebrew binaries take precedence
pathmunge /usr/local/bin
pathmunge /usr/local/sbin
pathmunge ${HOME}/bin after
# Add terraform pwsh scripts to path
pathmunge ~/PycharmProjects/infrastructure/tf/bin after
# Load Liquidprompt
if [[ $- = *i* && -f /usr/local/share/liquidprompt ]]; then
    . /usr/local/share/liquidprompt
fi
# cp replacement: `brew install z`
zpath="$(brew --prefix)/etc/profile.d/z.sh"
[ -s $zpath ] && source $zpath
