# =========================
# PATH
# =========================

typeset -U path PATH

path=(
  "$HOME/.local/bin"
  "/opt/homebrew/bin"
  "/opt/homebrew/sbin"
  "/usr/local/opt/inetutils/libexec/gnubin"
  "/Applications/Ghostty.app/Contents/MacOS"
  $path
)

export PATH


# =========================
# Environment
# =========================

export ZSH="$HOME/.oh-my-zsh"
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES
export DEFAULT_USER="dima"

# =========================
# Editor
# =========================

export EDITOR="nvim"
export VISUAL="nvim"
export GIT_EDITOR="nvim"
export BAT_THEME="Dracula"
export EZA_CONFIG_DIR="$HOME/.config/eza"

[[ -f "$HOME/.config/private/fritzbox.env" ]] && source "$HOME/.config/private/fritzbox.env"


# =========================
# Aliases / small functions
# =========================

# Remove old aliases before defining functions.
# This makes repeated `source ~/.zshrc` safe.
unalias flushdns icloud dotfiles kuber kstage kprod tmp officereboot gartenreboot wzreboot flurreboot fritzreboot k9s k9 ls ll la lla 2>/dev/null
unfunction flushdns icloud dotfiles kuber kstage kprod tmp officereboot gartenreboot wzreboot flurreboot fritzreboot k9s k9 2>/dev/null

flushdns() {
  sudo killall -HUP mDNSResponder 2>/dev/null
  sudo killall mDNSResponderHelper 2>/dev/null
  sudo dscacheutil -flushcache
  echo "DNS cache flushed"
}

alias cat='bat'
alias cd='z'
alias tmux='tmux -u'
alias vim='/opt/homebrew/bin/nvim'
alias vi='/opt/homebrew/bin/nvim'

alias digs='dig +short @1.1.1.1'
alias digg='dig @1.1.1.1'
alias dig8='dig +short @8.8.8.8'
alias diglocal='dig +short @192.168.178.1'

alias brewup='brew update && brew upgrade'

# -------------------------------------------
# Suffix Aliases - Open Files by Extension
# -------------------------------------------
# Just type the filename to open it with the associated program
alias -s json=jless
alias -s py='$EDITOR'
alias -s yaml='$EDITOR'
alias -s yml='$EDITOR'
alias -s txt='bat'

# -------------------------------------------
# Global Aliases - Use Anywhere in Commands
# -------------------------------------------
# Redirect stderr to /dev/null
alias -g NE='2>/dev/null'

# Redirect stdout to /dev/null
alias -g NO='>/dev/null'

# Redirect both stdout and stderr to /dev/null
alias -g NUL='>/dev/null 2>&1'

# Pipe to jq
alias -g JQ='| jq'

# Pipe to less
alias -g L='| less'

# Copy output to clipboard (macOS)
alias -g C='| pbcopy'

# -------------------------------------------
# zmv - Advanced Batch Rename/Move
# -------------------------------------------
# Enable zmv
autoload -Uz zmv

# Usage examples:
# zmv '(*).log' '$1.txt'           # Rename .log to .txt
# zmv -w '*.log' '*.txt'           # Same thing, simpler syntax
# zmv -n '(*).log' '$1.txt'        # Dry run (preview changes)
# zmv -i '(*).log' '$1.txt'        # Interactive mode (confirm each)

# Helpful aliases for zmv
alias zcp='zmv -C'  # Copy with patterns
alias zln='zmv -L'  # Link with patterns

# -------------------------------------------
# Named Directories - Bookmark Folders
# -------------------------------------------
# Access with ~name syntax, e.g., cd ~yt or ls ~yt
hash -d dl=~/Downloads
# Add your own commonly used directories here

icloud() {
  cd "$HOME/Library/Mobile Documents/com~apple~CloudDocs/MyFiles/" || return 1
}

dotfiles() {
  cd "$HOME/Library/Mobile Documents/com~apple~CloudDocs/MyFiles/CONFIGS/dima/dotfiles" || return 1
}

kuber() {
    cd "$HOME/nmedia/kubernetes" || return 1 
}

kstage() {
  cd "$HOME/nmedia/kubernetes/stage" || return 1
}

kprod() {
  cd "$HOME/nmedia/kubernetes/prod" || return 1
}

tmp() {
  local dir
  dir="$(mktemp -d /tmp/tmp.XXXXXX)" || return 1
  cd "$dir" || return 1
}

mysocks() {
  ssh -N -D 127.0.0.1:1080 my-hetzner-vpn
}

# -------------------------------------------
# Custom Widgets
# -------------------------------------------
# Clear screen but keep current command buffer
function clear-screen-and-scrollback() {
  echoti civis >"$TTY"
  printf '%b' '\e[H\e[2J\e[3J' >"$TTY"
  echoti cnorm >"$TTY"
  zle redisplay
}
zle -N clear-screen-and-scrollback
bindkey '^xl' clear-screen-and-scrollback

# Copy current command buffer to clipboard (macOS)
function copy-buffer-to-clipboard() {
  echo -n "$BUFFER" | pbcopy
  zle -M "Copied to clipboard"
}
zle -N copy-buffer-to-clipboard
bindkey '^xc' copy-buffer-to-clipboard

# For Linux with wl-copy:
# function copy-buffer-to-clipboard() {
#   echo -n "$BUFFER" | wl-copy
#   zle -M "Copied to clipboard"
# }

# -------------------------------------------
# Hotkey Insertions - Text Snippets
# -------------------------------------------
# Insert git commit template (Ctrl+X, G, C)
# \C-b moves cursor back one position
bindkey -s '^xgc' 'git commit -m ""\C-b'

# More examples:
bindkey -s '^xgp' 'git push origin '
bindkey -s '^xgs' 'git status\n'
bindkey -s '^xgl' 'git log --oneline -n 10\n'


# =========================
# FritzBox helpers
# =========================

FRITZBOX_SHELL="$HOME/Library/Mobile Documents/com~apple~CloudDocs/MyFiles/BACKUP/FritzBoxShell/fritzBoxShell.sh"

_require_fritz_env() {
  if [[ ! -x "$FRITZBOX_SHELL" ]]; then
    echo "FritzBoxShell not found or not executable:"
    echo "$FRITZBOX_SHELL"
    return 1
  fi

  if [[ -z "$FRITZ_USER" || -z "$FRITZ_PASS" ]]; then
    echo "FRITZ_USER or FRITZ_PASS is not set."
    echo "Check: ~/.config/private/fritzbox.env"
    return 1
  fi
}

_reboot_repeater() {
  local ip="$1"

  _require_fritz_env || return 1

  "$FRITZBOX_SHELL" \
    --repeaterip "$ip" \
    --repeateruser "$FRITZ_USER" \
    --repeaterpw "$FRITZ_PASS" \
    REBOOT Repeater
}

officereboot() {
  _reboot_repeater 192.168.178.5
}

gartenreboot() {
  _reboot_repeater 192.168.178.4
}

wzreboot() {
  _reboot_repeater 192.168.178.3
}

flurreboot() {
  _reboot_repeater 192.168.178.2
}

fritzreboot() {
  _require_fritz_env || return 1

  "$FRITZBOX_SHELL" \
    --boxip 192.168.178.1 \
    --boxuser "$FRITZ_USER" \
    --boxpw "$FRITZ_PASS" \
    REBOOT Box
}


# =========================
# Kubernetes / OpenShift
# =========================

_use_kubeconfig() {
  local alias_name="$1"
  local kubeconfig_path="$2"

  if [[ ! -f "$kubeconfig_path" ]]; then
    echo "Kubeconfig not found: $kubeconfig_path"
    return 1
  fi

  export KUBECONFIG="$kubeconfig_path"
  export ACTIVE_KUBE_ALIAS="$alias_name"

  echo "Active kube: $ACTIVE_KUBE_ALIAS"
  echo "KUBECONFIG: $KUBECONFIG"

  if command -v kubectl >/dev/null 2>&1; then
    kubectl config current-context 2>/dev/null
  fi
}

use-stage() {
  _use_kubeconfig "stage" "$HOME/.kube/nxt-stage.yaml"
}

use-prod() {
  _use_kubeconfig "prod" "$HOME/.kube/nxt-prod.yaml"
}

use-local() {
  _use_kubeconfig "local" "$HOME/.kube/nmedia-local-cluster.yaml"
}

use-crc() {
  _use_kubeconfig "crc" "$HOME/.crc/machines/crc/kubeconfig"

  if [[ $? -eq 0 ]] && command -v oc >/dev/null 2>&1; then
    oc whoami --show-server 2>/dev/null
  fi
}

kubeoff() {
  unset KUBECONFIG
  unset ACTIVE_KUBE_ALIAS
  echo "Kube context disabled"
}

kc() {
  if [[ -z "$KUBECONFIG" ]]; then
    echo "No active kube context."
    return 1
  fi

  echo "ACTIVE_KUBE_ALIAS: $ACTIVE_KUBE_ALIAS"
  echo "KUBECONFIG: $KUBECONFIG"

  if command -v kubectl >/dev/null 2>&1; then
    kubectl config current-context 2>/dev/null
  fi
}

k() {
  if [[ -z "$KUBECONFIG" ]]; then
    echo "No active kube context."
    echo "Use: use-stage, use-prod, use-local, use-crc"
    return 1
  fi

  command -v kubectl >/dev/null 2>&1 || {
    echo "kubectl not found"
    return 1
  }

  command kubectl "$@"
}

o() {
  if [[ -z "$KUBECONFIG" ]]; then
    echo "No active OpenShift context."
    echo "Use: use-stage, use-prod, use-local, use-crc"
    return 1
  fi

  command -v oc >/dev/null 2>&1 || {
    echo "oc not found"
    return 1
  }

  command oc "$@"
}

k9() {
  if [[ -z "$KUBECONFIG" ]]; then
    echo "No active kube context."
    echo "Use: use-stage, use-prod, use-local, use-crc"
    return 1
  fi

  local k9s_bin
  k9s_bin="$(whence -p k9s)" || {
    echo "k9s not found"
    return 1
  }

  "$k9s_bin" --kubeconfig "$KUBECONFIG" -r 2 "$@"
}


# =========================
# ZSH tricks
# =========================

# -------------------------------------------
# Edit Command Buffer
# -------------------------------------------
# Open the current command in your $EDITOR (e.g., neovim)
# Press Ctrl+X followed by Ctrl+E to trigger
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^x^e' edit-command-line

# -------------------------------------------
# chpwd Hook - Run Commands on Directory Change
# -------------------------------------------
# NOTE: Only one chpwd hook can be defined at once
# To merge them, use add-zsh-hook which is mentioned below

# Example: List directory contents on cd

chpwd() {
  #ls
  eza --icons --color=always --long --git
}


# -------------------------------------------
# Yazi 
# -------------------------------------------
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
	command rm -f -- "$tmp"
}

# =========================
# Powerlevel9k
# =========================

ZSH_THEME="powerlevel9k/powerlevel9k"

export POWERLEVEL9K_MODE='nerdfont-complete'
export POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(os_icon context dir vcs custom_activekube)
#export POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(rbenv history)
export POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(rbenv)

export POWERLEVEL9K_CUSTOM_ACTIVEKUBE='[[ -n "$ACTIVE_KUBE_ALIAS" ]] && echo -n "$ACTIVE_KUBE_ALIAS"'
export POWERLEVEL9K_CUSTOM_ACTIVEKUBE_BACKGROUND="024"
export POWERLEVEL9K_CUSTOM_ACTIVEKUBE_FOREGROUND="255"

export POWERLEVEL9K_PROMPT_ON_NEWLINE=true
export POWERLEVEL9K_RPROMPT_ON_NEWLINE=true
export POWERLEVEL9K_PROMPT_ADD_NEWLINE=true

export POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX='%F{195}\u250c\u2574%F{252}'
export POWERLEVEL9K_MULTILINE_SECOND_PROMPT_PREFIX='%F{195}\u2514\u25b8%F{252} '

export POWERLEVEL9K_OS_ICON_BACKGROUND="247"
export POWERLEVEL9K_OS_ICON_FOREGROUND="255"

export POWERLEVEL9K_CONTEXT_TEMPLATE='%n'
export POWERLEVEL9K_CONTEXT_ROOT_BACKGROUND="196"
export POWERLEVEL9K_CONTEXT_ROOT_FOREGROUND="255"
export POWERLEVEL9K_CONTEXT_DEFAULT_BACKGROUND="090"
export POWERLEVEL9K_CONTEXT_DEFAULT_FOREGROUND="253"

export POWERLEVEL9K_ALWAYS_SHOW_CONTEXT=true
export POWERLEVEL9K_ALWAYS_SHOW_USER=false

export POWERLEVEL9K_DIR_DEFAULT_BACKGROUND="136"
export POWERLEVEL9K_DIR_DEFAULT_FOREGROUND="233"
export POWERLEVEL9K_DIR_HOME_BACKGROUND="178"
export POWERLEVEL9K_DIR_HOME_FOREGROUND="233"
export POWERLEVEL9K_DIR_HOME_SUBFOLDER_BACKGROUND="178"
export POWERLEVEL9K_DIR_HOME_SUBFOLDER_FOREGROUND="233"
export POWERLEVEL9K_SHORTEN_DIR_LENGTH=2
export POWERLEVEL9K_SHORTEN_STRATEGY="truncate_folders"

export POWERLEVEL9K_STATUS_VERBOSE=false
export POWERLEVEL9K_STATUS_OK_IN_NON_VERBOSE=true
export POWERLEVEL9K_FAIL_ICON="\uf165"
export POWERLEVEL9K_OK_ICON="\uf164"
export POWERLEVEL9K_VCS_FOREGROUND='051'

# =========================
# Homebrew completions
# Must be before Oh My Zsh / compinit
# =========================
if command -v brew >/dev/null 2>&1; then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
fi

# =========================
# Oh My Zsh
# =========================

plugins=(git)

if [[ -f "$ZSH/oh-my-zsh.sh" ]]; then
  source "$ZSH/oh-my-zsh.sh"
else
  echo "oh-my-zsh not found: $ZSH/oh-my-zsh.sh"
fi

# =========================
# envman / nvm
# =========================

[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"

# =========================
# Completions
# =========================

if command -v carapace >/dev/null 2>&1; then
  export CARAPACE_BRIDGES='zsh,fish,bash'
  zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'
  source <(carapace _carapace)
fi

if command -v fzf >/dev/null 2>&1; then
  export FZF_CTRL_T_OPTS='--preview "bat --style=numbers --color=always --line-range :500 {}"'
  export FZF_ALT_C_OPTS='--preview "eza --tree --color=always {} | head -200"'
  source <(fzf --zsh)
fi

# ---- Zoxide (better cd)----
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh)"
fi

_fzf_comprun() {
  local command="$1"
  shift

  case "$command" in
    cd)             fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
    export|unset)   fzf --preview "eval 'echo \$' {}" "$@" ;;
    ssh)            fzf --preview 'dig {}' "$@" ;;
    *)              fzf --preview 'bat -n --color=always --line-range :500 {}' "$@" ;;
  esac
}

if command -v kubectl >/dev/null 2>&1; then
  source <(kubectl completion zsh)
fi

if command -v oc >/dev/null 2>&1; then
  source <(oc completion zsh)
fi

# =========================
# Syntax highlighting
# Must be close to the end
# =========================

if [[ -f "/opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
  source "/opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
elif [[ -f "/usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
  source "/usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

# =========================
# eza aliases
# Must be after Oh My Zsh
# =========================

if command -v eza >/dev/null 2>&1; then
  unalias ls ll la lla 2>/dev/null

  alias ls='eza --icons --color=always --long --git'
  alias ll='eza --icons --color=always --long --git'
  alias la='eza --icons --color=always --long --git --all'
  alias lla='eza --icons --color=always --long --git --all'
fi
