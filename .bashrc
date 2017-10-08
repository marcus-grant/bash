########
#
# MyBash .bashrc file
#
# written by Marcus Grant (2016) of thepatternbuffer.com
#
########

########
#
# Table of Contents
# 1. Prompt Configuration
# 2. Environmental Variables & Paths
# 3. Helper Functions
# 4. Aliases
# 5. Final Configurations & Plugins
#
########

########
#
# 1. Prompt Configuration
#
########

# get absolute path to prompt link
source-prompt-link(){
  # foolproof way to figure out where this script is placed
  local source="${BASH_SOURCE[0]}"
  while [ -h "$source" ]; do # resolve $source until the file is no longer a symlink
    local dir="$( cd -P "$( dirname "$source" )" && pwd )"
    local source="$(readlink "$source")"
    # if $source was a relative symlink, we need to resolve it relative
    # to the path where the symlink file was located
    [[ $source != /* ]] && local source="$dir/$source"
  done
  local dir="$( cd -P "$( dirname "$source" )" && pwd )" #dir now has the script locat'n
  source "$dir/prompt-link"
}
source-prompt-link

########
#
# 2. Environmental Variables & Paths
#
########

# Terminal environment: Termite invokes its own, use xterm-256color instead
export TERM=xterm-256color

# Editors
# Here you define default editors to be used by the OS whenever you ask to open a file
# The -w flag tells your shell to wait until sublime exits
export VISUAL="gedit"
#export SVN_EDITOR="subl -w"
export GIT_EDITOR="vim"
export EDITOR="vim"

# Paths

    # The USR_PATHS variable will just store all relevant /usr paths for easier usage
    # Each path is seperate via a : and we always use absolute paths.

    # TODO: This needs to be checked for compatibility with linux, this came originally from my macOS bash
    # A bit about the /usr directory
    # The /usr directory is a convention from linux that creates a common place to put
    # files and executables that the entire system needs access too. It tries to be user
    # independent, so whichever user is logged in should have permissions to the /usr directory.
    # We call that /usr/local. Within /usr/local, there is a bin directory for actually
    # storing the binaries (programs) that our system would want.
    # Also, Homebrew adopts this convetion so things installed via Homebrew
    # get symlinked into /usr/local
    #export USR_PATHS="/usr/local:/usr/local/bin:/usr/local/sbin:/usr/bin"

    # Hint: You can interpolate a variable into a string by using the $VARIABLE notation as below.

    # We build our final PATH by combining the variables defined above
    # along with any previous values in the PATH variable.

    # Our PATH variable is special and very important. Whenever we type a command into our shell,
    # it will try to find that command within a directory that is defined in our PATH.
    # Read http://blog.seldomatt.com/blog/2012/10/08/bash-and-the-one-true-path/ for more on that.
    #export PATH="$USR_PATHS:$PATH"

    # If you go into your shell and type: echo $PATH you will see the output of your current path.
    # For example, mine is:
    # /Users/avi/.rvm/gems/ruby-1.9.3-p392/bin:/Users/avi/.rvm/gems/ruby-1.9.3-p392@global/bin:/Users/avi/.rvm/rubies/ruby-1.9.3-p392/bin:/Users/avi/.rvm/bin:/usr/local:/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/local/mysql/bin:/usr/local/share/python:/bin:/usr/sbin:/sbin:
   # home bin path
   #TODO: Remove these entries if keeping them in profile is satisfactory
   #export PATH="$HOME/bin:$PATH"

   #TODO: Validate this for functionality and remove if needed
   # add Soundcloud2000 variable for API Key

    # Anaconda (change for OS)
    # TODO: Moving to profile, remove if satisfactory
    #export PATH="$HOME/.local/share/anaconda3/bin:$PATH"

    # eval keychain to update ssh-agent with private keys
    unameOut="$(uname -s)"
    case "${unameOut}" in
        Linux*)     
            machine=Linux
            if [ -f $HOME/.ssh/git.key ]; then
                eval $(keychain --eval --quiet $HOME/.ssh/git.key )
	        else
		        echo "Attempted to add git keychain, but no keyfile exists, ignoring..."
	        fi
        ;;
        Darwin*)    machine=Mac;;
        CYGWIN*)    machine=Cygwin;;
        MINGW*)     machine=MinGw;;
        *)          machine="UNKNOWN:${unameOut}"
    esac


    # Add $HOME/.dotfiles/sysadmin-scripts to PATH for helper scripts
    # Only do it if that directory is present
    if [ -d $HOME/.dotfiles/sysadmin-scripts ]; then
        PATH=$PATH:$HOME/.dotfiles/sysadmin-scripts
    fi



########
#
# 3. Helper Functions
#
########

# A function to CD into the desktop from anywhere
# so you just type desktop.
# HINT: It uses the built in USER variable to know your OS X username

# USE: desktop
#      desktop subfolder
function desktop {
  cd /Users/$USER/Desktop/$@
}

# A function to easily grep for a matching process
# USE: psg postgres
function psg {
  FIRST=`echo $1 | sed -e 's/^\(.\).*/\1/'`
  REST=`echo $1 | sed -e 's/^.\(.*\)/\1/'`
  ps aux | grep "[$FIRST]$REST"
}

# A function to extract correctly any archive based on extension
# I ALWAYS forget how to properly extract all the different kinds of archives
# that exist from the command line, so this is a nice helper to have.
# USE: extract imazip.zip
#      extract imatar.tar
function extract () {
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2)  tar xjf $1      ;;
            *.tar.gz)   tar xzf $1      ;;
            *.bz2)      bunzip2 $1      ;;
            *.rar)      rar x $1        ;;
            *.gz)       gunzip $1       ;;
            *.tar)      tar xf $1       ;;
            *.tbz2)     tar xjf $1      ;;
            *.tgz)      tar xzf $1      ;;
            *.zip)      unzip $1        ;;
            *.Z)        uncompress $1   ;;
	    *.7zip)	7z x $1		;;
            *)          echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Because I always forget the address format for git clones using SSH -
# here is a function that takes a string USER/REPOSITORY as only argument
function gcs () {
  local GIT_ROOT="git@github.com:marcus-grant"
  local GIT_URL="$GIT_ROOT/$1.git"
  echo
  echo "Cloning from $GIT_URL ......."
  echo
  git clone $GIT_URL
  echo
  echo "Done cloning!"
}

# Easier way to clone a personal repository ussing https
# Only argument is the repository name from my personal github acct. marcus-grant
function gch () {
  local GIT_ROOT="https://github.com/marcus-grant"
  local GIT_URL="$GIT_ROOT/$1"
  echo "Cloning from $GIT_URL ......."
  git clone $GIT_URL
  echo
  echo "Done cloning!"
}

# Git Pull All - gpa - pulls all branches to local from remote
function gpa () {
  git branch -r | grep -v '\->' | while read remote;
    do git branch --track "${remote#origin/}" "$remote";
    done
  git fetch --all
  git pull --all
}

# A helper to pipe commands into python for immediate interpretation
# TODO: figure out proper way to handle newlines, quotes, and spaces
function pypipe()
{

  python_statements="$1"
  echo "$python_statements" | python
  # for statement in "$@"; do
  #   python_statements="$python_statements$statement\n"
  # done
  # echo "$python_statements" | python
}


function caps-as-esc()
{
    xmodmap -e 'clear Lock' -e 'keycode 0x42 = Escape'
}


keyboard-default ()
{
    setxkbmap us
}	# ----------  end of function keyboard-default  ----------



# ssh-agent startup script that checks for a previous running one
#if ! pgrep -u "$USER" ssh-agent > /dev/null; then
#    ssh-agent > $HOME/.ssh-agent-thing
#fi
#if [[ "$SSH_AGENT_PID" == "" ]]; then
#    eval "$(<$HOME/.ssh-agent-thing)"
#fi


#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  toggle-touchpad
#   DESCRIPTION:  From http://bit.ly/2tUl5QN & http://bit.ly/1lsLa2r
#				Toggles touchpad on & off to the system with prompts if desired
#    PARAMETERS:  -q or --quiet if no prompts are wanted, otherwise it will
#       RETURNS:  Nothin but an echo and notify-osd even by default
#-------------------------------------------------------------------------------
toggle-touchpad ()
{	
	IS_QUIET=0
	if (( $# > 0 )); then
		if [[ "$1" == "-q" ]] || [[ "$1" == "--quiet" ]]; then
			IS_QUIET=1
		else
			echo ""
			echo "[ERROR] bashrc:toggle-touchpad(): wrong argument given, only -q or --quiet or nothing permitted"
			echo "By default the toggle invokes bash echo outs and notify osd prompts"
			echo ""
		fi
	fi 
    declare -i ID
    ID=`xinput list | grep -Eio '(touchpad|glidepoint)\s*id\=[0-9]{1,2}' | grep -Eo '[0-9]{1,2}'`
    declare -i STATE
    STATE=`xinput list-props $ID|grep 'Device Enabled'|awk '{print $4}'`
    if [ $STATE -eq 1 ]; then
    	xinput disable $ID
		if (( IS_QUIET == 0 )); then
    		echo "Touchpad disabled." 
			notify-send 'Touchpad' 'Disabled' -i /usr/share/icons/Adwaita/48x48/devices/input-touchpad.png
		fi
	else
    	xinput enable $ID
		if (( IS_QUIET == 0 )); then
    		echo "Touchpad enabled." 
			notify-send 'Touchpad' 'Enabled' -i /usr/share/icons/Adwaita/48x48/devices/input-touchpad.png
		fi
    # echo "Touchpad enabled."
    # notify-send 'Touchpad' 'Enabled' -i /usr/share/icons/Adwaita/48x48/devices/input-touchpad.png
	fi

}	# ----------  end of function toggle-touchpad  ----------

#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  view-markup
#   DESCRIPTION:  From https://unix.stackexchange.com/questions/4140/markdown-viewer#120519
#   -- Views any marked up document like *.md as a styled page inside lynx
#   -- Requires pandoc & lynx, potentially python later
#    PARAMETERS: None (for now) | TODO: output options 
#       RETURNS: Opens lynx after piping with pandoc
#-------------------------------------------------------------------------------
view-markup ()
{
    pandoc $1 | lynx -stdin
}	# ----------  end of function view-markup  ----------

########
#
# 4. Aliases
#
########

  #CD - UPDATE THIS
#  alias ios='cd $HOME/Dropbox/Dev/iOS'
  alias dev='cd $HOME/code'
  alias pydev='cd $HOME/code/python'
  alias webdev='cd $HOME/code/web'
  alias aidev='cd $HOME/code/ai'
  alias dev-notes='cd $HOME/documents/dev-notes'
  alias dotfiles='cd $HOME/.dotfiles'
  alias ..='cd ..'
  alias ...='cd ../..'
  alias ....='cd ../../..'

# different aliases based on if it's a mac
  if [ $machine == 'mac' ]; then
    alias dev-notes='cd $HOME/Documents/dev-notes'
  fi

  #Application Starters
  alias oxw='open *.xcw*'
  alias oxp='open *.xcod*'

  # LS
  # Set all common options desired on ls first by replacing the default ls command, here, I want to force color always on ls
  alias ls='ls --color=always'
  alias l='ls -lahG'
  alias ll='ls -FGLAhp' # my preffered ls call, but I'm calling it ll instead of replacing
  alias lt='ls -laHGt'

  # Grep
  alias grep='grep --color=auto'
  alias igrep='grep -i' # a grep alias for case insensitive searches

  # Xresources
  alias xup='xrdb $HOME/.Xresources'

  # Git
  alias gcl="git clone"
  alias gst="git status"
  alias gl="git pull"
  alias gp="git push"
  alias gd="git diff | mate"
  alias gc="git commit -v"
  alias gca="git commit -v -a"
  alias gb="git branch"
  alias gba="git branch -a"
  alias gcam="git commit -am"

  # TODO: Doesn't work -- Worth the effort????
  #function gacm() {
  #    local num_additions=$(($#-1))
  #    local additions=${@:1:$num_additions}
  #    local commit_message=${!#}
#
#      echo 
#      echo "Adding, then committing staged changes using git:"
#      echo "================================================="
#      echo "message: $message"
#      echo "files: $additions"
#      echo 
#      echo "Are these files & message correct?"
#      echo "Hit [Enter] to confirm, or any other key to discard!: "
#
#      read -s -n 1 key
#      if [[ $key = "" ]]; then
#          echo
#          echo "Adding, and committing!"
#          echo
#      else
#          exit 1
#      fi
#
#      git add $additions && git commit -m $commit_message
#  }


  # QEMU-KVM virtual machine launch aliases
  alias loki="sudo $HOME/VMs/Loki/loki-start"
  alias loki-headless="sudo $HOME/VMs/Loki/loki-start-headless"

  # tmux
  # NOTE: Updated to include '-2' option to force the screen-256color option
  function tma()    { tmux -2 attach -t $1; }
  function tml()    { tmux list-sessions; }
  function tmn()    { tmux -2 new -s $1; }
  function tms()    { tmux -2 switch -t $1; }
  function tmk()    { tmux kill-session -t $1; }
  function tmr()    { tmux rename-session -t $1 $2; }
  function tmlk()   { tmux list-keys; }


  #-----------------------------------------------------------------------
  # Vim aliases
  #-----------------------------------------------------------------------
  alias viml='vim "+set background=light"' #runs vim in a light colorscheme

  # system sysctl service etc.
  alias sctl="systemctl"

  # launch steam on arch

function steam-arch {
	LD_PRELOAD='/usr/$LIB/libstdc++.so.6 /usr/$LIB/libgcc_s.so.1 /usr/$LIB/libxcb.so.1 /usr/$LIB/libgpg-error.so' steam
}
# Case-Insensitive Auto Completion
  bind "set completion-ignore-case on"

########
#
# 5. Final Configurations & Plugins
#
########
  # Git Bash Completion
  # Will activate bash git completion if installed
  # via homebrew on macOS, or whatever linux package manager you use
  # NEEDS UPDATING TO WORK ON BOTH macOS & various Linux carnations
  #if [ -f `brew --prefix`/etc/bash_completion ]; then
  #  . `brew --prefix`/etc/bash_completion
  #fi

  # RVM - NEEDS AUDITING
  # Mandatory loading of RVM into the shell
  # This must be the last line of your bash_profile always
  #[[ -s "/Users/$USER/.rvm/scripts/rvm" ]] && source "/Users/$USER/.rvm/scripts/rvm"  # This loads RVM into a shell session.

  # Setup paths for virtualenv
  if [ -d $HOME/.virtualenvs ]; then
	  export WORKON_HOME=$HOME/.virtualenvs
	  source /usr/local/bin/virtualenvwrapper.sh
	  export PIP_VIRTUALENV_BASE=$WORKON_HOME
  fi

