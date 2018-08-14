# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=50
SAVEHIST=500
setopt autocd extendedglob nobadpattern notify menucomplete completeinword nobeep 
bindkey -v
# End of lines configured by zsh-newuser-install

export CONST_USER=aaron
export CONST_HOME=~$CONST_USER

# Use vi if vim isn't available
if whence vim &> /dev/null
then
    alias vim="vim -u $CONST_HOME/.vimrc"
    alias vi=vim
    export EDITOR==vim
    export VISUAL==vim
else
    export EDITOR==vi
    export VISUAL==vi
fi

# use more if less isn't available
if whence less &> /dev/null
then
    # use colored grep output
    # 'always' uses colors even when piping out.  LESS is fine with it
    alias grep="grep --color=always"

    # LESS options
    # --no-init - leaves LESS output in terminal when execution finishes
    # -R properly processes color escape sequences
    export LESS='--no-init -R'
    export PAGER='less'
else
    # use colored grep output
    # 'auto' uses colors only when outputting to an interactive terminal
    alias grep="grep --color=always"
    export PAGER='more'
fi


# set term title to user@server
case $TERM in
    *xterm*|rxvt|(a|dt|k|E)term)
    #precmd () {print -Pn "\e]0;%n@%m: %~\a"}
    ;;
esac

#show cwd in term title bar
chpwd() {
    [[ -t 1 ]] || return
    case $TERM in
        *xterm*|rxvt|(a|dt|k|E)term) print -Pn "\e]2;%~\a"
        ;;
    esac
}

# This causes this config to source when ksuing to root (k alias below)
export ZDOTDIR=$CONST_HOME

# Store the shortened hostname
export SHORTHOST=`hostname | sed -E 's/(\.pair\.com)|(\.pair\.net)|(\.pairserver\.com)|(\.pairnic\.net)|(\.aaronash\.net)|(\.sleepless\.us)//'`

# Bash style ls colors
if [[ -x "`whence -p dircolors`"  ]]; then
    eval `dircolors`
    if [[ `uname` == 'FreeBSD' ]]; then
        alias ls='ls -G'
    else
        alias ls='ls -F --color=auto'
    fi
else
    alias ls='ls -F'
fi

# Prepare terminal colors
if [[ "$terminfo[colors]" -gt 7 ]]; then
    autoload -U colors
    colors
fi

#Allows prompt profiles
autoload -U promptinit
promptinit

# When we KSU to root the SHELL variable represents the root user's login shell,
# and not our login shell
SHELL=`which zsh`

#pimp prompt
#TODO: Fix this when freeBSD 4
PROMPT="%B%F{green}%n%b%f@%B%F{cyan}$SHORTHOST%f%b:%B%F{yellow}%~%f%b> "

path=(/sbin /bin /usr/sbin /usr/bin /usr/games /usr/local/sbin /usr/local/bin $HOME/bin $CONST_HOME/bin /usr/krb5/bin /usr/pair/bin /usr/pair/perl/bin /drive1/pgsql/bin)
# Set path to only the directories above that actually exist
path=($^path(N))

fpath=($CONST_HOME/.zshfuncs $fpath)
fpath=($^fpath(N))
export PERL5LIB=/usr/pair/perl/lib

autoload dmesg_time

# Load up generic aliases everywhere
autoload hosts delay

alias r="rlogin -F"
alias go="ssh -oStrictHostKeyChecking=no -Y -A"
alias k="sudo -s"
alias ki="kinit -f -l 365d"
alias x="exit"
alias clr="clear"

# See if we have a config specific to this host
if [[ -s $ZDOTDIR/.zshrc_$HOST ]]; then
    source $ZDOTDIR/.zshrc_$HOST
    echo "$HOST specific shell configuration loaded."
fi

# if using GNU screen, let the zsh tell screen what the title and hardstatus
# of the tab window should be.
if [[ "$TERM" == screen* ]]; then
  function screen_tabset() {
      # use the current user as the prefix of the current tab title 
      TAB_TITLE_PREFIX='"$SHORTHOST"'
      # when at the shell prompt, show a truncated version of the current path (with
      # standard ~ replacement) as the rest of the title.
      TAB_TITLE_PROMPT='$SHELL:t'
      # when running a command, show the title of the command as the rest of the
      # title (truncate to drop the path to the command)
      TAB_TITLE_EXEC='$cmd[1]:t'

      # use the current path (with standard ~ replacement) in square brackets as the
      # prefix of the tab window hardstatus.
      TAB_HARDSTATUS_PREFIX='"[`'$_GET_PATH'`] "'
      # when at the shell prompt, use the shell name (truncated to remove the path to
      # the shell) as the rest of the title
      TAB_HARDSTATUS_PROMPT='$SHELL:t'
      # when running a command, show the command name and arguments as the rest of
      # the title
      TAB_HARDSTATUS_EXEC='$cmd'
  }

  # tell GNU screen what the tab window title ($1) and the hardstatus($2) should be
  function screen_set()
  {
    # set the tab window title (%t) for screen
    print -nR $'\033k'$1$'\033'\\\

    # set hardstatus of tab window (%h) for screen
    print -nR $'\033]0;'$2$'\a'
  }
  # called by zsh before executing a command
  function preexec()
  {
    local -a cmd; cmd=(${(z)1}) # the command string
    screen_tabset
    eval "tab_title=$TAB_TITLE_PREFIX:$TAB_TITLE_EXEC"
    eval "tab_hardstatus=$TAB_HARDSTATUS_PREFIX:$TAB_HARDSTATUS_EXEC"
    screen_set $tab_title $tab_hardstatus
  }
  # called by zsh before showing the prompt
  function precmd()
  {
    screen_tabset
    eval "tab_title=$TAB_TITLE_PREFIX:$TAB_TITLE_PROMPT"
    eval "tab_hardstatus=$TAB_HARDSTATUS_PREFIX:$TAB_HARDSTATUS_PROMPT"
    screen_set $tab_title $tab_hardstatus
  }
fi

alias tmux="tmux -2"

if [[ `uname -s` == "FreeBSD" && `uname -r` == 4* ]]; then
    echo "FreeBSD 4 detected. (I'm so, so sorry)"
    unset GREP_OPTIONS
else
    # Setup command keys
    # This doesn't work on freebsd 4 

    # Many keys don't work by default.
    # create a zkbd compatible hash;
    # to add other keys to this hash, see: man 5 terminfo
    typeset -A key

    key[Home]=${terminfo[khome]}

    key[End]=${terminfo[kend]}
    key[Insert]=${terminfo[kich1]}
    key[Delete]=${terminfo[kdch1]}
    key[Up]=${terminfo[kcuu1]}
    key[Down]=${terminfo[kcud1]}
    key[Left]=${terminfo[kcub1]}
    key[Right]=${terminfo[kcuf1]}
    key[PageUp]=${terminfo[kpp]}
    key[PageDown]=${terminfo[knp]}

    # setup key accordingly
    [[ -n "${key[Home]}"     ]]  && bindkey  "${key[Home]}"     beginning-of-line
    [[ -n "${key[End]}"      ]]  && bindkey  "${key[End]}"      end-of-line
    [[ -n "${key[Insert]}"   ]]  && bindkey  "${key[Insert]}"   overwrite-mode
    [[ -n "${key[Delete]}"   ]]  && bindkey  "${key[Delete]}"   delete-char
    [[ -n "${key[Up]}"       ]]  && bindkey  "${key[Up]}"       up-line-or-history
    [[ -n "${key[Down]}"     ]]  && bindkey  "${key[Down]}"     down-line-or-history
    [[ -n "${key[Left]}"     ]]  && bindkey  "${key[Left]}"     backward-char
    [[ -n "${key[Right]}"    ]]  && bindkey  "${key[Right]}"    forward-char
    [[ -n "${key[PageUp]}"   ]]  && bindkey  "${key[PageUp]}"   beginning-of-buffer-or-history
    [[ -n "${key[PageDown]}" ]]  && bindkey  "${key[PageDown]}" end-of-buffer-or-history

    # Finally, make sure the terminal is in application mode, when zle is
    # active. Only then are the values from $terminfo valid.
    if (( ${+terminfo[smkx]} )) && (( ${+terminfo[rmkx]} )); then
        function zle-line-init () {
            printf '%s' "${terminfo[smkx]}"
        }
        function zle-line-finish () {
            printf '%s' "${terminfo[rmkx]}"
        }
        zle -N zle-line-init
        zle -N zle-line-finish
    fi
fi
