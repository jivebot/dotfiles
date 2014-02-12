# Much of this is from:
# https://github.com/mikemcquaid/dotfiles

# Save more history
export HISTSIZE=100000
export SAVEHIST=100000

# OS variables
[ $(uname -s) = "Darwin" ] && export OSX=1 && export UNIX=1
[ $(uname -s) = "Linux" ] && export LINUX=1 && export UNIX=1
uname -s | grep -q "_NT-" && export WINDOWS=1

# Fix systems missing $USER
[ -z "$USER" ] && export USER=$(whoami)

# Colourful manpages
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'

# Set to avoid `env` output from changing console colour
export LESS_TERMEND=$'\E[0m'

# Count CPUs for Make jobs
if [ $OSX ]
then
  export CPUCOUNT=$(sysctl -n hw.ncpu)
elif [ $LINUX ]
then
  export CPUCOUNT=$(getconf _NPROCESSORS_ONLN)
else
  export CPUCOUNT="1"
fi

if [ "$CPUCOUNT" -gt 1 ]
then
  export MAKEFLAGS="-j$CPUCOUNT"
fi

# Setup paths
remove_from_path() {
  [ -d $1 ] || return
  # Doesn't work for first item in the PATH but don't care.
  export PATH=$(echo $PATH | sed -e "s|:$1||") 2>/dev/null
}

add_to_path_start() {
  [ -d $1 ] || return
  remove_from_path "$1"
  export PATH="$1:$PATH"
}

add_to_path_end() {
  [ -d "$1" ] || return
  remove_from_path "$1"
  export PATH="$PATH:$1"
}

force_add_to_path_start() {
  remove_from_path "$1"
  export PATH="$1:$PATH"
}

quiet_which() {
  which $1 1>/dev/null 2>/dev/null
}

export GOPATH=$HOME/go

add_to_path_end "/Applications/GitX.app/Contents/Resources"
add_to_path_end "$GOPATH/bin"
add_to_path_start "/usr/local/bin"
add_to_path_start "/usr/local/sbin"
force_add_to_path_start "bin"

export PS1='\[\033[0;32m\][\[\033[1;32m\]\A\[\033[0;32m\]] \w$(__git_ps1 " (%s)")\[\033[0m\]> '

# Git bash completion flags.
export GIT_PS1_SHOWDIRTYSTATE=1
export GIT_PS1_SHOWUNTRACKEDFILES=1

# Aliases
alias ll='ls -al'
alias tl='ls -ltr'

alias rdm="bundle exec rake db:migrate"
alias rdr="bundle exec rake db:rollback"
alias be="bundle exec"
alias ber="bundle exec rake"
alias sp="bundle exec rspec"

alias gs="git status"
alias gl="git log --stat"
alias gbr="git br | grep"

# Functions
function sk() { bundle exec sidekiq -C 'config/sidekiq.yml' -i 1 -q $1 -e $2 ;}
function skdev() { bundle exec sidekiq -C 'config/sidekiq.yml' -i 1 -q $1 -e development ;}
function skstag() { bundle exec sidekiq -C 'config/sidekiq.yml' -i 1 -q $1 -e staging ;}

function browserstack() { java -jar ~/bin/BrowserStackTunnel.jar yTR8s8xe6bwy8AqgUyUA $1,80,0 ;}

# Platform-specific stuff
if [ $OSX ]
then
  function open_latest() { ls -dtr1 "$@" | tail -1 | xargs -n1 open -a Preview ;}

  export GREP_OPTIONS="--color=auto"
  export CLICOLOR=1
fi

# Set up editor
if quiet_which subl || quiet_which sublime_text
then
  quiet_which subl && export EDITOR="subl"
  quiet_which sublime_text && export EDITOR="sublime_text" \
    && alias subl="sublime_text"

  export GIT_EDITOR="$EDITOR -w"
elif quiet_which vim
then
  export EDITOR="vim"
elif quiet_which vi
then
  export EDITOR="vi"
fi

# Source external scripts
source ~/bin/git-completion.bash
source "$HOME/.homesick/repos/homeshick/homeshick.sh"
source "$HOME/.homesick/repos/homeshick/completions/homeshick-completion.bash"
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"
