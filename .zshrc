fpath+=~/.zfunc

# zmodload zsh/zprof

export XDG_CONFIG_HOME="$HOME/.config"

export LSCOLORS=gxfxcxdxbxegedabagacad

export HISTFILE=${HOME}/.zsh_history
# メモリに保存される履歴の件数
export HISTSIZE=10000
# 履歴ファイルに保存される履歴の件数
export SAVEHIST=1000000
# 重複を記録しない
setopt hist_ignore_dups
setopt hist_ignore_all_dups
# コマンドがスペースで始まる場合、コマンド履歴に追加しない
setopt hist_ignore_space
# 開始と終了を記録
setopt extended_history
setopt share_history

# Emacs ライクな操作を有効にする（文字入力中に Ctrl-F,B でカーソル移動など）
# Vi ライクな操作が好みであれば `bindkey -v` とする
bindkey -e

# 自動補完を有効にする
# コマンドの引数やパス名を途中まで入力して <Tab> を押すといい感じに補完してくれる
# 例： `cd path/to/<Tab>`, `ls -<Tab>`
autoload -U compinit; compinit

# 入力したコマンドが存在せず、かつディレクトリ名と一致するなら、ディレクトリに cd する
# 例： /usr/bin と入力すると /usr/bin ディレクトリに移動
setopt auto_cd

# "~hoge" が特定のパス名に展開されるようにする（ブックマークのようなもの）
# 例： cd ~hoge と入力すると /long/path/to/hogehoge ディレクトリに移動
# hash -d hoge=/long/path/to/hogehoge

# cd した先のディレクトリをディレクトリスタックに追加する
# ディレクトリスタックとは今までに行ったディレクトリの履歴のこと
# `cd +<Tab>` でディレクトリの履歴が表示され、そこに移動できる
setopt auto_pushd

# pushd したとき、ディレクトリがすでにスタックに含まれていればスタックに追加しない
setopt pushd_ignore_dups

# 拡張 glob を有効にする
# glob とはパス名にマッチするワイルドカードパターンのこと
# （たとえば `mv hoge.* ~/dir` における "*"）
# 拡張 glob を有効にすると # ~ ^ もパターンとして扱われる
# どういう意味を持つかは `man zshexpn` の FILENAME GENERATION を参照
setopt extended_glob

# <Tab> でパス名の補完候補を表示したあと、
# 続けて <Tab> を押すと候補からパス名を選択できるようになる
# 候補を選ぶには <Tab> か Ctrl-N,B,F,P
zstyle ':completion:*:default' menu select=1

# 単語の一部として扱われる文字のセットを指定する
# ここではデフォルトのセットから / を抜いたものとする
# こうすると、 Ctrl-W でカーソル前の1単語を削除したとき、 / までで削除が止まる
WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'

# 大文字は大文字、無かった場合は小文字のも
zstyle ':completion:*' matcher-list 'm:{[:lower:]}={[:upper:]}' '+m:{[:upper:]}={[:lower:]}'

peco-select-history() {
    # BUFFER=`history -n 1 | tail -r  | awk '!a[$0]++' | peco`
    BUFFER=`history -n 1 | tac  | awk '!a[$0]++' | peco`
    CURSOR=$#BUFFER
    zle reset-prompt
}
zle -N peco-select-history
bindkey '^r' peco-select-history

# 特定コマンドをhistoryに残さない
zshaddhistory() {
    local line=${1%%$'\n'}
    local cmd=${line%% *}
    [[  ${cmd} != (rm)
        && ${cmd} != (history)
        && ${line} != "git push -f"*
    ]]
}

git-root() {
    # if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    #     cd `pwd`/`git rev-parse --show-cdup`
    # fi
    git rev-parse --show-superproject-working-tree --show-toplevel | head -1
}

export PATH=$HOME/.local/bin:$PATH

# llvm
export PATH="/usr/loca/opt/llvm/bin:$PATH"
export LDFLAGS="-L/usr/local/opt/llvm/lib"
export CPPFLAGS="-L/usr/local/opt/llvm/include"

alias ls='ls -G'
alias la='ls -A'
alias ll='ls -Al'
alias lf='ls -AlF'

alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

alias -g ranking='sort | uniq -c | sort -nr'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

alias repos='ghq list -p | peco'
function repo {
    repo=$(repos)
    if [ "${repo}" != "" ]; then
        cd "${repo}"
    fi
}
function openrepo {
    repo=$(repos)
    if [ "${repo}" != "" ]; then
        code "${repo}"
    fi
}

# ローカル固有の設定を読み込む
[ -f ~/.zshrc.local ] && source ~/.zshrc.local

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

autoload -U +X bashcompinit && bashcompinit

eval "$(starship init zsh)"

eval "$(mise activate zsh)"

eval "$(uv generate-shell-completion zsh)"

_uv_run_mod() {
    if [[ "$words[2]" == "run" && "$words[CURRENT]" != -* ]]; then
        _arguments '*:filename:_files'
    else
        _uv "$@"
    fi
}
compdef _uv_run_mod uv

### Added by Zinit's installer
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

### End of Zinit's installer chunk
