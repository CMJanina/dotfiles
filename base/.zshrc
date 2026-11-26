#!/bin/zsh
source ~/.env

autoload -U compaudit compinit
compinit -u -C -d "$HOME/.cache/zcompdump-$ZSH_VERSION"

zmodload -i zsh/complist
WORDCHARS=''
unsetopt menu_complete
unsetopt flowcontrol
setopt auto_menu
setopt complete_in_word
setopt always_to_end
bindkey -M menuselect '^o' accept-and-infer-next-history
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' special-dirs true
zstyle ':completion:*' list-colors ''
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories
zstyle ':completion::complete:*' use-cache 1
zstyle ':completion::complete:*' cache-path $HOME/.cache/oh-my-zsh-cache

HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=10000

setopt extended_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_verify
setopt inc_append_history
setopt share_history

bindkey -e
# copy and paste previous word (for use in cp/mv)
# (cant use ^M because RET)
bindkey "^[m" copy-prev-shell-word
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word
autoload -U up-line-or-beginning-search
zle -N up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N down-line-or-beginning-search

autoload -Uz is-at-least
autoload -Uz bracketed-paste-magic
zle -N bracketed-paste bracketed-paste-magic
autoload -Uz url-quote-magic
zle -N self-insert url-quote-magic
setopt long_list_jobs
setopt interactivecomments

autoload -U colors && colors
zstyle ':completion:*' list-colors "Gxfxcxdxbxegedabagacad"
setopt auto_cd
setopt multios
setopt prompt_subst

_tldr_get_files() {
        fd . -e md $HOME/.cache/tldr/pages/$1 -X echo {/.} | tr ' ' '\n'
}

_tldr_complete() {
        local word="$1"
        local cmpl=""
        if [[ "$word" == "-"* ]]; then
                cmpl=$(echo $'\n-v\n-h\n-u\n-c\n-p\n-r\n--version\n--help\n--update\n--clear-cache\n--platform\n--render' | sort)
        elif [ -d "$HOME/.cache/tldr/pages" ]; then
                local platform="$(uname)"
                cmpl=$(_tldr_get_files common | sort | uniq)
                if [ "$platform" = "Darwin" ]; then
                        cmpl=${cmpl}$(_tldr_get_files osx | sort | uniq)
                elif [ "$platform" = "Linux" ]; then
                        cmpl=${cmpl}$(_tldr_get_files linux | sort | uniq)
                fi
        fi
        reply=( "${(ps:\n:)cmpl}" )
}

compctl -K _tldr_complete tldr

function colored() {
        # TODO: better colors, consistent with vim/vscopium/...
        env LESS_TERMCAP_mb=$'\e[1;31m' \
            LESS_TERMCAP_md=$'\e[1;31m' \
            LESS_TERMCAP_me=$'\e[0m' \
            LESS_TERMCAP_se=$'\e[0m' \
            LESS_TERMCAP_so=$'\e[1;44;33m' \
            LESS_TERMCAP_ue=$'\e[0m' \
            LESS_TERMCAP_us=$'\e[1;32m' _NROFF_U=1 "$@"
}
function man() { colored man "$@" ; }

source "$HOME/.zshtheme"

alias x=extract

extract() {
        local remove_archive
        local success
        local extract_dir

        if (( $# == 0 )); then
                echo "Usage: $0 [-option] [file ...]

Options:
        -r, --remove    Remove archive after unpacking." >&2
        fi

        remove_archive=1
        [[ "$1" == "-r" || "$1" == "--remove" ]] && { remove_archive=0 ; shift ; }

        while (( $# > 0 )); do
                [ ! -f "$1" ] && { echo "'$1' doesn't exist" >&2 ; shift ; continue ; }

                success=0
                extract_dir="${1:t:r}"
                case "${1:l}" in
                        (*.tar.gz|*.tgz) tar zxvf "$1" ;;
                        (*.tar.bz2|*.tbz|*.tbz2) tar xvjf "$1" ;;
                        (*.tar.xz|*.txz) tar --xz -xvf "$1" ;;
                        (*.tar.zma|*.tlz) tar --lzma -xvf "$1" ;;
                        (*.tar) tar xvf "$1" ;;
                        (*.gz) gunzip -k "$1" ;;
                        (*.bz2) bunzip2 "$1" ;;
                        (*.xz) unxz "$1" ;;
                        (*.lzma) unlzma "$1" ;;
                        (*.z) uncompress "$1" ;;
                        (*.zip|*.war|*.jar|*.sublime-package|*.ipsw|*.xpi|*.apk|*.aar|*.whl) unzip "$1" -d $extract_dir ;;
                        (*.rar) unrar x -ad "$1" ;;
                        (*.rpm) mkdir "$extract_dir" && cd "$extract_dir" && rpm2cpio "../$1" | cpio --quiet -id && cd .. ;;
                        (*.7z) 7za x "$1" ;;
                        (*.deb)
                                mkdir -p "$extract_dir/control"
                                mkdir -p "$extract_dir/data"
                                cd "$extract_dir"; ar vx "../${1}" > /dev/null
                                cd control; tar xzvf ../control.tar.gz
                                cd ../data; extract ../data.tar.*
                                cd ..; rm *.tar.* debian-binary
                                cd .. ;;
                        (*) echo "'$1' cannot be extracted" >&2 ; success=1 ;;
                esac

                (( success = $success > 0 ? $success : $? ))
                (( $success == 0 )) && (( $remove_archive == 0 )) && rm "$1"
                shift
        done
}

zlibd() (printf "\x1f\x8b\x08\x00\x00\x00\x00\x00" | cat - "$@" | gzip -dc)
alias v="$VISUAL"
alias V="sudo $EDITOR"
alias mv="mv -i"
alias b="bat -P --style=plain"

alias m='make -j$(nproc)'
alias mi='make -j$(nproc) install'
alias mt='make -j$(nproc) test'
alias j='just -v'

alias o="`type xdg-open >/dev/null && echo xdg-open || echo open`"
alias -g ...='../..'
alias -g ....='../../..'
alias -g .....='../../../..'
alias -g ......='../../../../..'
alias ll='ls --color=auto -lh'
alias la='ls --color=auto -lAFh'
alias ls='ls --color=auto'

alias grep="grep --color=auto --exclude-dir=.bzr --exclude-dir=CVS --exclude-dir=.git --exclude-dir=.hg --exclude-dir=.svn"
alias gr="grep --color=auto --exclude-dir=.bzr --exclude-dir=CVS --exclude-dir=.git --exclude-dir=.hg --exclude-dir=.svn -R"

alias zshtheme="$VISUAL $HOME/.zshtheme"
alias zshrc="$VISUAL $HOME/.zshrc"

alias -g H='| head'
alias -g T='| tail'
alias -g G='| grep'
alias -g L='| $PAGER'
alias -g S='| sort'
alias -g U='| uniq'
alias -g C='| `type xclip >/dev/null && echo xclip || echo pbcopy`'
alias -g NE='2>/dev/null'
alias -g NUL='>/dev/null'

alias g='git'
alias ga='git add -v'
alias gaa='git add -vA'
alias gap='git add -vp'
alias gc='git commit -v'
alias gca='git commit -va'
alias gcam='git commit -vam'
alias gcl='git clone --recurse-submodules -v'
alias gcm='git commit -vm'
alias gd='git diff'
alias gid='git icdiff'
alias gi='git init'
alias gl='git pull'
alias gp='git push -v'
alias gs='git status'
alias gsh='git show'
alias gst='git stash --'
alias gck='git checkout'
alias gsd='(git -c color.status=always status && echo -e "\n" && git diff --color) | less -R'

alias diff='git diff --no-index'
alias tmp='pushd ; cd $(mktemp -d)'
alias pwn='docker run --rm -v$PWD:/pwd -it chrissx/pwn:latest'

ght() (git tag "$@" && git push origin --tags)
glcp() (git pull && git commit "$@" && git push)
ghcl() (git clone --recurse-submodules -v https://github.com/$1.git $2 $3 $4)

yt-meme() {
        if (( $# < 2 )); then
                echo 'Usage: yt-meme <timestamped-url> <duration>' >&2
                return 1
        fi

        yt-dlp --download-sections '*from-url' --downloader-args "ffmpeg_o:-t ${(q)2}" -f b -- "$1"
}

eval "$(zsh-patina activate)"

! type pfetch >/dev/null || pfetch
