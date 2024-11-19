#*─── Settings ───*#
setopt autocd              # change directory just by typing its name
setopt correct            # auto correct mistakes
setopt interactivecomments # allow comments in interactive mode
setopt magicequalsubst     # enable filename expansion for arguments of the form ‘anything=expression’
setopt notify              # report the status of background jobs immediately
setopt promptsubst         # enable command substitution in prompt
setopt nonomatch           # hide error message if there is no match for the pattern
# setopt numericglobsort     # sort filenames numerically when it makes sense

#*─── Bindings ───*#
bindkey "^H" backward-kill-word
bindkey "^[[1;5D" backward-word
bindkey "^[[1;5C" forward-word
bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line

#*─── Change EOL Prompt ───*#
export PROMPT_EOL_MARK=""

#*─── Aliases ───*#
alias c="codium ."
alias ls="eza -1 --icons=always --colour=always -a --group-directories-first --sort=size -l --header --total-size --no-permissions --no-user"
alias ss="cmatrix -C cyan -s -b -a"
alias re="systemctl reboot -i"
alias off="systemctl poweroff -i"

#*─── Completion ───*#
autoload -Uz compinit
compinit -d ~/.cache/zcompdump
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' rehash true
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

#*─── History ───*#
HISTFILE=~/.zsh_history
HISTSIZE=1000
SAVEHIST=2000
setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_dups       # ignore duplicated commands history list
setopt hist_ignore_space      # ignore commands that start with space
setopt hist_verify            # show command with history expansion to user before running it
#setopt share_history         # share command history data

# force zsh to show the complete history
alias history="history 0"

#*─── Functions ───*#
function cpprun() {
    g++ $1.cpp -o $1 && ./$1
}

function crun() {
    g++ $1.c -o $1 && ./$1
}

function colours() {
    for x in {0..8}; do for i in {30..37}; do for a in {40..47}; do echo -ne "\e[$x;$i;$a""m\\\e[$x;$i;$a""m\e[0;37;40m "; done; echo; done; done; echo ""
}

#*─── Exports ───*#
export PATH=$PATH:/home/rquarx/.spicetify
export PATH=$PATH:/home/rquarx/.local/bin/

#*─── Sources ───*#
source <(fzf --zsh)
source /home/rquarx/.config/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /opt/miniconda3/etc/profile.d/conda.sh

#*─── Conda ───*#
[ -f /opt/miniconda3/etc/profile.d/conda.sh ]

#*─── Prompt ───*#
eval "$(starship init zsh)"


