# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.

eval "$(/opt/homebrew/bin/brew shellenv)"

export SDKMAN_DIR=$(brew --prefix sdkman-cli)/libexec
  [[ -s "${SDKMAN_DIR}/bin/sdkman-init.sh" ]] && source "${SDKMAN_DIR}/bin/sdkman-init.sh"

export PATH="$PATH:${HOME}/.dotnet:${HOME}/.dotnet/tools"
export NVM_DIR=~/.nvm
source $(brew --prefix nvm)/nvm.sh
export HOMEBREW_BUNDLE_FILE=~/.config/brew/.BrewfileWork
export EDITOR=nvim
export SUDO_EDITOR="$EDITOR"
#export RSYNC_LOGSEQ="$(pass rsync/logseq)"
#export OPENAI_API_KEY="$(pass apikey/openai)"

# Set zinit directory
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit if needed
if [ ! -d "$ZINIT_HOME" ]; then
	mkdir -p "$(dirname $ZINIT_HOME)"
	git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Add powerlevel10k
#zinit ice depth=1; zinit light romkatv/powerlevel10k

# Load starship theme
zinit ice as"command" from"gh-r" \
          atclone"./starship init zsh > init.zsh; ./starship completions zsh > _starship" \
          atpull"%atclone" src"init.zsh"
zinit light starship/starship

# Add zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Add snippets
zinit snippet OMZP::thefuck
zinit snippet OMZP::azure


#Load completions
autoload -U compinit && compinit

zinit cdreplay -q

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
#[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Keybindings
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

# History
HISTSIZE=32768
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
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fxf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup

# Aliases
alias fabric='fabric-ai'
alias ls='eza -lh --group-directories-first --icons=auto --git'
alias lsa='ls -a'
alias lt='eza --tree --level=2 --icons --git'
alias ltree='eza --tree --level=2 --icons --git'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias vim='nvim'
alias cat='bat'
alias '??'='gh copilot suggest -t shell'
alias 'git?'='gh copilot suggest -t git'
alias 'explain'='gh copilot explain'
alias 'gh?'='gh copilot suggest -t gh'
alias bsync="brew update &&\
    brew bundle install --cleanup --verbose &&\
    brew upgrade"

# Shell integrations
eval "$(fzf --zsh)"
eval "$(zoxide init zsh)"
eval "$(gh copilot alias -- zsh)"
eval "$(direnv hook zsh)"
eval "$(starship init zsh)"
eval "$(mise activate zsh --shims)"
# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/ramon/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions
