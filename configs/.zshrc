# Cross-Platform ZSH Configuration
# Compatible with macOS and Asahi Linux + Fedora

# Platform detection
if [[ "$OSTYPE" == "darwin"* ]]; then
    export PLATFORM="macos"
elif [[ "$OSTYPE" == "linux"* ]]; then
    export PLATFORM="linux"
    # Check if we're on Asahi Linux
    if [[ -f /proc/cpuinfo ]] && grep -q "Apple" /proc/cpuinfo; then
        export ASAHI_LINUX=true
    fi
else
    export PLATFORM="unknown"
fi

# Platform-specific package manager setup
case "$PLATFORM" in
    macos)
        # Homebrew setup for macOS
        if [[ -f "/opt/homebrew/bin/brew" ]]; then
            # Apple Silicon
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [[ -f "/usr/local/bin/brew" ]]; then
            # Intel Mac
            eval "$(/usr/local/bin/brew shellenv)"
        fi
        ;;
    linux)
        # Homebrew on Linux (if installed)
        if [[ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
            eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        fi
        
        # Add local binaries to PATH
        export PATH="$HOME/.local/bin:$PATH"
        
        # XDG Base Directory Specification
        export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
        export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
        export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
        ;;
esac

# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Add in snippets
zinit snippet OMZP::git
zinit snippet OMZP::sudo

# Platform-specific plugins
case "$PLATFORM" in
    macos)
        zinit snippet OMZP::macos
        zinit snippet OMZP::brew
        ;;
    linux)
        zinit snippet OMZP::systemd
        if command -v dnf >/dev/null 2>&1; then
            zinit snippet OMZP::dnf
        fi
        ;;
esac

# Load completions
autoload -Uz compinit && compinit

zinit cdreplay -q

# Theme setup (Oh My Posh)
# Skip if we're in Apple Terminal (doesn't support advanced features well)
if [ "$TERM_PROGRAM" != "Apple_Terminal" ]; then
    # Check if oh-my-posh is available
    if command -v oh-my-posh >/dev/null 2>&1; then
        eval "$(oh-my-posh init zsh --config $HOME/.config/ohmyposh/zen.toml)"
    else
        # Fallback to a simple prompt
        autoload -U colors && colors
        PS1="%{$fg[cyan]%}%~%{$reset_color%} %{$fg[magenta]%}❯%{$reset_color%} "
    fi
fi

# Keybindings
bindkey '^[[1;2A' history-search-backward  # Shift + Up
bindkey '^[[1;2B' history-search-forward   # Shift + Down

# Vi mode keybindings (optional)
# bindkey -v

# History configuration
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'

# Platform-specific aliases
case "$PLATFORM" in
    macos)
        alias ls='ls -G'  # macOS ls with color
        alias ll='ls -lG'
        alias la='ls -aG'
        alias lla='ls -laG'
        # macOS specific aliases
        alias brewup='brew update && brew upgrade && brew cleanup'
        alias finder='open -a Finder'
        alias chrome='open -a "Google Chrome"'
        ;;
    linux)
        alias ls='ls --color=auto'  # GNU ls with color
        alias ll='ls -l --color=auto'
        alias la='ls -a --color=auto'
        alias lla='ls -la --color=auto'
        # Linux specific aliases
        alias grep='grep --color=auto'
        alias fgrep='fgrep --color=auto'
        alias egrep='egrep --color=auto'
        
        # Package manager aliases based on detected system
        if command -v dnf >/dev/null 2>&1; then
            alias dnfup='sudo dnf upgrade'
            alias dnfin='sudo dnf install'
            alias dnfse='dnf search'
            alias dnfre='sudo dnf remove'
        fi
        
        # Systemd aliases
        alias sc='systemctl'
        alias scu='systemctl --user'
        alias jc='journalctl'
        
        # Clipboard aliases
        if command -v xclip >/dev/null 2>&1; then
            alias pbcopy='xclip -sel clip'
            alias pbpaste='xclip -sel clip -o'
        elif command -v xsel >/dev/null 2>&1; then
            alias pbcopy='xsel --clipboard --input'
            alias pbpaste='xsel --clipboard --output'
        elif command -v wl-copy >/dev/null 2>&1; then
            alias pbcopy='wl-copy'
            alias pbpaste='wl-paste'
        fi
        ;;
esac

# Universal aliases
alias vim='nvim'
alias c='clear'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias mkdir='mkdir -pv'
alias h='history'
alias j='jobs -l'
alias which='type -a'
alias du='du -h'
alias df='df -h'

# Git aliases (enhanced)
alias g='git'
alias ga='git add'
alias gaa='git add --all'
alias gapa='git add --patch'
alias gau='git add --update'
alias gb='git branch'
alias gba='git branch -a'
alias gbd='git branch -d'
alias gbda='git branch --no-color --merged | command grep -vE "^(\*|\s*(master|develop|dev)\s*$)" | command xargs -n 1 git branch -d'
alias gbl='git blame -b -w'
alias gbnm='git branch --no-merged'
alias gbr='git branch --remote'
alias gbs='git bisect'
alias gbsb='git bisect bad'
alias gbsg='git bisect good'
alias gbsr='git bisect reset'
alias gbss='git bisect start'
alias gc='git commit -v'
alias gc!='git commit -v --amend'
alias gca='git commit -v -a'
alias gca!='git commit -v -a --amend'
alias gcam='git commit -a -m'
alias gcan!='git commit -v -a --no-edit --amend'
alias gcans!='git commit -v -a -s --no-edit --amend'
alias gcb='git checkout -b'
alias gcd='git checkout develop'
alias gcf='git config --list'
alias gch='git checkout'
alias gchm='git checkout master'
alias gcl='git clone --recursive'
alias gclean='git clean -fd'
alias gcm='git checkout master'
alias gcmsg='git commit -m'
alias gco='git checkout'
alias gcount='git shortlog -sn'
alias gcp='git cherry-pick'
alias gcpa='git cherry-pick --abort'
alias gcpc='git cherry-pick --continue'
alias gcs='git commit -S'
alias gd='git diff'
alias gdca='git diff --cached'
alias gdct='git describe --tags `git rev-list --tags --max-count=1`'
alias gdt='git diff-tree --no-commit-id --name-only -r'
alias gdw='git diff --word-diff'
alias gf='git fetch'
alias gfa='git fetch --all --prune'
alias gfo='git fetch origin'
alias gg='git gui citool'
alias gga='git gui citool --amend'
alias ggpull='git pull origin $(git_current_branch)'
alias ggpush='git push origin $(git_current_branch)'
alias ggsup='git branch --set-upstream-to=origin/$(git_current_branch)'
alias ghh='git help'
alias gignore='git update-index --assume-unchanged'
alias gignored='git ls-files -v | grep "^[[:lower:]]"'
alias git-svn-dcommit-push='git svn dcommit && git push github master:svntrunk'
alias gk='\gitk --all --branches'
alias gke='\gitk --all $(git log -g --pretty=%h)'
alias gl='git pull'
alias glg='git log --stat'
alias glgg='git log --graph'
alias glgga='git log --graph --decorate --all'
alias glgm='git log --graph --max-count=10'
alias glgp='git log --stat -p'
alias glo='git log --oneline --decorate'
alias glog='git log --oneline --decorate --graph'
alias gloga='git log --oneline --decorate --graph --all'
alias glol='git log --graph --pretty='\''%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'\'' --abbrev-commit'
alias glola='git log --graph --pretty='\''%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'\'' --abbrev-commit --all'
alias glp='_git_log_prettily'
alias gm='git merge'
alias gmom='git merge origin/master'
alias gmt='git mergetool --no-prompt'
alias gmtvim='git mergetool --no-prompt --tool=vimdiff'
alias gmum='git merge upstream/master'
alias gp='git push'
alias gpd='git push --dry-run'
alias gpoat='git push origin --all && git push origin --tags'
alias gpu='git push upstream'
alias gpv='git push -v'
alias gr='git remote'
alias gra='git remote add'
alias grb='git rebase'
alias grba='git rebase --abort'
alias grbc='git rebase --continue'
alias grbi='git rebase -i'
alias grbm='git rebase master'
alias grbs='git rebase --skip'
alias grh='git reset HEAD'
alias grhh='git reset HEAD --hard'
alias grmv='git remote rename'
alias grrm='git remote remove'
alias grset='git remote set-url'
alias grt='cd $(git rev-parse --show-toplevel || echo ".")'
alias gru='git reset --'
alias grup='git remote update'
alias grv='git remote -v'
alias gsb='git status -sb'
alias gsd='git svn dcommit'
alias gsi='git submodule init'
alias gsps='git show --pretty=short --show-signature'
alias gsr='git svn rebase'
alias gss='git status -s'
alias gst='git status'
alias gsta='git stash save'
alias gstaa='git stash apply'
alias gstc='git stash clear'
alias gstd='git stash drop'
alias gstl='git stash list'
alias gstp='git stash pop'
alias gsts='git stash show --text'
alias gsu='git submodule update'
alias gts='git tag -s'
alias gtv='git tag | sort -V'
alias gunignore='git update-index --no-assume-unchanged'
alias gunwip='git log -n 1 | grep -q -c "\-\-wip\-\-" && git reset HEAD~1'
alias gup='git pull --rebase'
alias gupv='git pull --rebase -v'
alias gwch='git whatchanged -p --abbrev-commit --pretty=medium'
alias gwip='git add -A; git rm $(git ls-files --deleted) 2> /dev/null; git commit --no-verify -m "--wip-- [skip ci]"'

# Development environment variables
export EDITOR='nvim'
export VISUAL='nvim'
export PAGER='less'
export LESS='-R'

# Node.js/npm configuration
if command -v node >/dev/null 2>&1; then
    export NODE_OPTIONS="--max-old-space-size=4096"
fi

# Python configuration
if command -v python3 >/dev/null 2>&1; then
    export PYTHONDONTWRITEBYTECODE=1
fi

# Rust configuration
if [[ -d "$HOME/.cargo" ]]; then
    export PATH="$HOME/.cargo/bin:$PATH"
fi

# Go configuration
if command -v go >/dev/null 2>&1; then
    export GOPATH="${HOME}/go"
    export PATH="$GOPATH/bin:$PATH"
fi

# Shell integrations
# FZF (Fuzzy Finder)
if command -v fzf >/dev/null 2>&1; then
    case "$PLATFORM" in
        macos)
            if [[ -f "${HOMEBREW_PREFIX}/opt/fzf/shell/completion.zsh" ]]; then
                source "${HOMEBREW_PREFIX}/opt/fzf/shell/completion.zsh"
            fi
            if [[ -f "${HOMEBREW_PREFIX}/opt/fzf/shell/key-bindings.zsh" ]]; then
                source "${HOMEBREW_PREFIX}/opt/fzf/shell/key-bindings.zsh"
            fi
            ;;
        linux)
            if [[ -f "/usr/share/fzf/shell/key-bindings.zsh" ]]; then
                source "/usr/share/fzf/shell/key-bindings.zsh"
            fi
            if [[ -f "/usr/share/fzf/shell/completion.zsh" ]]; then
                source "/usr/share/fzf/shell/completion.zsh"
            fi
            ;;
    esac
    
    # Custom FZF configuration
    export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
    export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*"'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi

# Platform-specific environment adjustments
case "$PLATFORM" in
    linux)
        # Linux-specific environment variables
        
        # Asahi Linux specific optimizations
        if [[ "$ASAHI_LINUX" == "true" ]]; then
            # GPU driver for Asahi
            export MESA_LOADER_DRIVER_OVERRIDE=asahi
            
            # Enable better font rendering
            export FREETYPE_PROPERTIES="truetype:interpreter-version=38"
        fi
        
        # Wayland support
        if [[ "$XDG_SESSION_TYPE" == "wayland" ]]; then
            export MOZ_ENABLE_WAYLAND=1
            export QT_QPA_PLATFORM=wayland
            export GDK_BACKEND=wayland
        fi
        ;;
    macos)
        # macOS-specific environment variables
        
        # Better Python performance on macOS
        export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES
        ;;
esac

# Functions

# Quick directory navigation
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Extract various archive types
extract() {
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2)   tar xjf $1     ;;
            *.tar.gz)    tar xzf $1     ;;
            *.bz2)       bunzip2 $1     ;;
            *.rar)       unrar e $1     ;;
            *.gz)        gunzip $1      ;;
            *.tar)       tar xf $1      ;;
            *.tbz2)      tar xjf $1     ;;
            *.tgz)       tar xzf $1     ;;
            *.zip)       unzip $1       ;;
            *.Z)         uncompress $1  ;;
            *.7z)        7z x $1        ;;
            *)     echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Get current git branch
git_current_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
}

# Platform info function
sysinfo() {
    echo "System Information:"
    echo "  Platform: $PLATFORM"
    echo "  OS: $(uname -s)"
    echo "  Kernel: $(uname -r)"
    echo "  Architecture: $(uname -m)"
    echo "  Shell: $SHELL"
    echo "  Terminal: ${TERM_PROGRAM:-$TERM}"
    
    if [[ "$ASAHI_LINUX" == "true" ]]; then
        echo "  Asahi Linux: Yes"
    fi
    
    if command -v neofetch >/dev/null 2>&1; then
        echo
        neofetch
    fi
}

# Load local customizations if they exist
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local