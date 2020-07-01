# vim:ft=zsh ts=2 sw=2 sts=2
#
# agnoster's Theme - https://gist.github.com/3712874
# A Powerline-inspired theme for ZSH
#
# # README
#
# In order for this theme to render correctly, you will need a
# [Powerline-patched font](https://gist.github.com/1595572).
#
# In addition, I recommend the
# [Solarized theme](https://github.com/altercation/solarized/) and, if you're
# using it on Mac OS X, [iTerm 2](http://www.iterm2.com/) over Terminal.app -
# it has significantly better color fidelity.
#
# # Goals
#
# The aim of this theme is to only show you *relevant* information. Like most
# prompts, it will only show git information when in a git working directory.
# However, it goes a step further: everything from the current user and
# hostname to whether the last call exited with an error to whether background
# jobs are running in this shell will all be displayed automatically when
# appropriate.

### Segment drawing
# A few utility functions to make it easy and re-usable to draw segmented prompts

# Characters
SEGMENT_SEPARATOR="\ue0b0"
SEGMENT_THIN_SEPARATOR="\ue0b1"
AGNOSTER_ICON_PLUSMINUS="\u00b1"
AGNOSTER_ICON_BRANCH="\ue0a0"
AGNOSTER_ICON_DETACHED="\u27a6"
AGNOSTER_ICON_ERROR="\u2718"
AGNOSTER_ICON_ROOT="\u2317"
# AGNOSTER_ICON_BG="\u21BB"
AGNOSTER_ICON_BG="\u22EF "

agnoster_prompt_segment() {
  if [[ "$CURRENT_BG" != "$1" ]]; then
    print -n "%1(l.%{%s%F{$CURRENT_BG}%K{$1}%}$SEGMENT_SEPARATOR.)%{%s%K{$1}%f%}"
    CURRENT_BG=$1
  fi
}

agnoster_prompt_segment_inverted() {
  if [[ "$CURRENT_BG" != "$1" ]]; then
    print -n "%1(l.%{%S%K{$CURRENT_BG}%F{$1}%}$SEGMENT_SEPARATOR.)%{%S%F{$1}%k%}"
    CURRENT_BG=$1
  fi
}

### Prompt components
# Each component will draw itself, and hide itself if no information needs to be shown

typeset -aHg AGNOSTER_PROMPT_SEGMENTS=(
  status
  dir
  git
)

# Status:
# - was there an error
# - am I root
# - are there background jobs?
# - user@hostname (who am I and where am I)
agnoster_prompt_status() {
  agnoster_prompt_segment default
  print -n "%0(?..%{%F{red}%} $AGNOSTER_ICON_ERROR)"
  print -n "%1(j.%{%F{cyan}%} $AGNOSTER_ICON_BG.)"
  print -n "%{%f%}"
  print -n "%1(l. .)"
  local user=""
  if [[ "$UID" == 0 ]]; then
    agnoster_prompt_segment_inverted magenta
    user="$AGNOSTER_ICON_ROOT %n"
  elif [[ "$USER" != "${DEFAULT_USER:-$USER}" || -n "$SSH_CONNECTION" ]]; then
    agnoster_prompt_segment default
    user="%n"
  fi
  local host=""
  if [[ -n "$SSH_CONNECTION" ]]; then
    host="@%m"
  fi
  if [[ -n "$user$host" ]]; then
    print -n " $user$host "
  fi
}

# Dir: current working directory
agnoster_prompt_dir() {
  agnoster_prompt_segment_inverted blue
  print -n ' %~ '
}

# Git: branch/detached head, dirty status
agnoster_prompt_git() {
  local color ref
  is_dirty() {
    test -n "$(git status --porcelain --ignore-submodules -unormal)"
  }
  ref="$vcs_info_msg_0_"
  if [[ -n "$ref" ]]; then
    if is_dirty; then
      color=yellow
      ref="${ref} $AGNOSTER_ICON_PLUSMINUS"
    else
      color=green
      ref="${ref} "
    fi
    if [[ "${ref/.../}" == "$ref" ]]; then
      ref="$AGNOSTER_ICON_BRANCH $ref"
    else
      ref="$AGNOSTER_ICON_DETACHED ${ref/.../}"
    fi
    agnoster_prompt_segment_inverted $color
    print -Pn " $ref"
  fi
}

## Main prompt
prompt_agnoster_main() {
  RETVAL=$?
  CURRENT_BG=''
  for prompt_segment in "${AGNOSTER_PROMPT_SEGMENTS[@]}"; do
    [[ -n $prompt_segment ]] && "agnoster_prompt_$prompt_segment"
  done
  # End the prompt
  agnoster_prompt_segment default
}

prompt_agnoster_precmd() {
  vcs_info
  PROMPT='%{%f%b%k%}$(prompt_agnoster_main)%{%f%b%k%} '
}

prompt_agnoster_setup() {
  autoload -Uz add-zsh-hook
  autoload -Uz vcs_info

  prompt_opts=(cr subst percent)

  add-zsh-hook precmd prompt_agnoster_precmd

  zstyle ':vcs_info:*' enable git
  zstyle ':vcs_info:*' check-for-changes false
  zstyle ':vcs_info:git*' formats '%b'
  zstyle ':vcs_info:git*' actionformats '%b (%a)'
}

prompt_agnoster_setup "$@"
