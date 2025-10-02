# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# -----------------------------------
# Oh My Zsh Core Setup
# -----------------------------------
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# -----------------------------------
# Homebrew Path Fix (for Apple Silicon)
# -----------------------------------
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"

# -----------------------------------
# Aliases
# -----------------------------------
alias ll='ls -lah'
alias gs='git status'
alias gc='git commit'
alias gp='git push'
alias ga='git add'

# -----------------------------------
# Default Editor
# -----------------------------------
export EDITOR="nvim"

# -----------------------------------
# Pyenv Setup
# -----------------------------------
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"

# -----------------------------------
# NVM Setup
# -----------------------------------
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"

# -----------------------------------
# Go Setup
# -----------------------------------
export GOPATH="$HOME/go"
export PATH="$PATH:$GOPATH/bin"

# -----------------------------------
# Java Setup
# -----------------------------------
#export JAVA_HOME=/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home

# -----------------------------------
# Android SDK Setup
# -----------------------------------
export ANDROID_HOME=$HOME/Library/Android/sdk 
export PATH=$PATH:$ANDROID_HOME/emulator 
export PATH=$PATH:$ANDROID_HOME/platform-tools

# -----------------------------------
# pnpm
# -----------------------------------
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# -----------------------------------
# llvm
# -----------------------------------
export PATH="/opt/homebrew/opt/llvm/bin:$PATH"

# -----------------------------------
# AWS CLI
# -----------------------------------
# export AWS_PROFILE=AdministratorAccess-347720567579
# export AWS_ACCOUNT_ID=347720567579
export AWS_REGION=us-east-1
export AWS_PROFILE=localstack

# -----------------------------------
# PostgreSQL
# -----------------------------------
export PATH="$PATH:/Users/neilsmahajan/.local/bin"
export PATH="/opt/homebrew/opt/postgresql@17/bin:$PATH"

# -----------------------------------
# GoLand
# -----------------------------------
alias goland='goland & disown'

# -----------------------------------
# fzf
# -----------------------------------
source <(fzf --zsh)

# -----------------------------------
# zoxide
# -----------------------------------
eval "$(zoxide init zsh)"

# -----------------------------------
# User Local Bin
# -----------------------------------
export PATH="$HOME/.local/bin:$PATH"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

