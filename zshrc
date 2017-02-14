source "$HOME/.zgen/zgen.zsh"
DEFAULT_USER=$(whoami)

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.

plugins ()
# User configuration

alias nvim='nvim --cmd "set bg=$(dark_or_light)"'
alias ipy='ipython --TerminalInteractiveShell.editing_mode=vi'
alias py=python3
alias q='exit'
alias t='tmux'
alias v='nvim'
alias vim='vim --cmd "set bg=$(dark_or_light)"'
alias vrc='nvim ~/.vimrc'
alias zrc='nvim ~/.zshrc'

PROMPT='%F{blue}%T%f %F{yellow}%c%f %# '

export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
export PATH=$PATH:~/.cabal/bin
export MANPATH="/usr/local/man:$MANPATH"
export PATH="$HOME/.linuxbrew/bin:$PATH"
export MANPATH="$HOME/.linuxbrew/share/man:$MANPATH"
export INFOPATH="$HOME/.linuxbrew/share/info:$INFOPATH"

if ! zgen saved; then
    echo "Creating a zgen save"
    zgen oh-my-zsh
    zgen oh-my-zsh plugins/git
    zgen oh-my-zsh plugins/sudo
    zgen oh-my-zsh plugins/docker
    zgen oh-my-zsh plugins/dirhistory
    zgen oh-my-zsh plugins/cabal
    zgen oh-my-zsh plugins/python
    zgen oh-my-zsh plugins/pip
    zgen oh-my-zsh plugins/vi-mode
    zgen oh-my-zsh plugins/taskwarrior
    zgen load zsh-users/zsh-syntax-highlighting
    zgen load zsh-users/zsh-completions src
    zgen load purpleP/autovenv
    zgen save
fi

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=10'

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
    export EDITOR='vim'
else
    export EDITOR='nvim'
fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/dsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
export XDG_CONFIG_HOME=$HOME/.config
LC_CTYPE=en_US.UTF-8
export LC_CTYPE
local platform=$(uname)
if [[ $platform == 'Darwin' ]]; then
    export JAVA_HOME="$(/usr/libexec/java_home -v 1.8)"
    export LIBCLANG_PATH=/Library/Developer/CommandLineTools/usr/lib/libclang.dylib
    export LIBCLANG_HEADER=/Library/Developer/CommandLineTools/usr/lib/clang/8.0.0/include

    bg_luminance() {
        local color=$(osascript -e 'tell app "Iterm2" to get background color of current session of current window')
        local colors=("${(s/, /)color}") 
        local coefficients=(0.2126 0.7152 0.0722)
        local luminance=0
        for i (1 2 3) (( luminance+= coefficients[i] * colors[i] ))
            luminance=$(( luminance / 65535 * 100 ))
            integer luminance
            echo $luminance
    }
else
    export LIBCLANG_PATH=/usr/lib/llvm-3.9/lib/libclang.so
    export LIBCLANG_HEADER=/usr/lib/llvm-3.9/lib/clang/3.9.0/include
    alias pbcopy='xclip -selection clipboard'
    alias pbpaste='xclip -selection clipboard -o'

    bg_luminance() {
        local profile_id=$(dconf list /org/gnome/terminal/legacy/profiles:/ | head -1)
        local color=$(dconf read "/org/gnome/terminal/legacy/profiles:/$profile_id"background-color)
        local luminance=0
        local coefficients=(0.2126 0.7152 0.0722)
        local regex="s/'rgb(\([0-9]\+\),\([0-9]\+\),\([0-9]\+\).*/\1 \2 \3/p"
        local colors=($(echo $color | sed -n $regex))
        for i (1 2 3) (( luminance+= coefficients[i] * colors[i] ))
            luminance=$(( luminance / 255 * 100 ))
            integer luminance
            echo $luminance
    }

fi

dark_or_light() {
    if [[ $(bg_luminance) -ge 50 ]];then
        echo 'light';
    else
        echo 'dark';
    fi
}

setopt autopushd pushdminus pushdsilent pushdtohome
setopt histignorespace extended_glob

export KEYTIMEOUT=1
bindkey -v
vi-append-x-selection () { RBUFFER=$(pbpaste </dev/null)$RBUFFER; }
zle -N vi-append-x-selection
bindkey -M vicmd 'p' vi-append-x-selection

uncommited() {
    find ~/code ~/vimconf ~/configs ~/.vim/plugged -type d -exec test -e '{}/.git' \; -print -prune 2>/dev/null | \
        xargs -I {} $SHELL -c \
        'dir={};cd $dir;uncommited=$(git ls-files --modified --deleted --exclude-standard --others;git log @{push}.. 2>/dev/null);if [ -n "$uncommited" ];then echo $dir;fi'
}

mark_pane() {
    if [ -n "$TMUX_PANE" ]; then
        sed -i "/$TMUX_PANE/d" /tmp/marked_panes 2>/dev/null
        echo ${TMUX_PANE} >> /tmp/marked_panes
    fi
}

alias m="mark_pane"
alias unm="rm /tmp/marked_panes 2>/dev/null"
unalias gcl

gcl() {
    git clone $1 && cd $(echo "$1" | perl -pe 's/.*?(\w+)\.git/\1/g')
}
cd .
