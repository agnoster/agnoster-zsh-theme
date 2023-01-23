# vim:ft=zsh ts=2 sw=2 sts=2
#
# agnoster's Theme - https://gist.github.com/3712874
# A Powerline-inspired theme for ZSH
#
# # README
#
# In order for this theme to render correctly, you will need a
# [Powerline-patched font](https://github.com/Lokaltog/powerline-fonts).
# Make sure you have a recent version: the code points that Powerline
# uses changed in 2012, and older versions will display incorrectly,
# in confusing ways.
#
# In addition, I recommend the
# [Solarized theme](https://github.com/altercation/solarized/) and, if you're
# using it on Mac OS X, [iTerm 2](https://iterm2.com/) over Terminal.app -
# it has significantly better color fidelity.
#
# If using with "light" variant of the Solarized color schema, set
# SOLARIZED_THEME variable to "light". If you don't specify, we'll assume
# you're using the "dark" variant.
#
# # Goals
#
# The aim of this theme is to only show you *relevant* information. Like most
# prompts, it will only show git information when in a git working directory.
# However, it goes a step further: everything from the current user and
# hostname to whether the last call exited with an error to whether background
# jobs are running in this shell will all be displayed automatically when
# appropriate.

### Segments of the prompt, default order declaration

typeset -aHg AGNOSTER_PROMPT_SEGMENTS=(
    prompt_status
    prompt_context
    prompt_virtualenv
    prompt_dir
    prompt_git
    prompt_end
)

### Segment drawing
# A few utility functions to make it easy and re-usable to draw segmented prompts

CURRENT_BG='NONE'

case ${SOLARIZED_THEME:-dark} in
    light) CURRENT_FG='white';;
    *)     CURRENT_FG='black';;
esac

# Special Powerline characters

() {
  local LC_ALL="" LC_CTYPE="en_US.UTF-8"
  # NOTE: This segment separator character is correct.  In 2012, Powerline changed
  # the code points they use for their special characters. This is the new code point.
  # If this is not working for you, you probably have an old version of the
  # Powerline-patched fonts installed. Download and install the new version.
  # Do not submit PRs to change this unless you have reviewed the Powerline code point
  # history and have new information.
  # This is defined using a Unicode escape sequence so it is unambiguously readable, regardless of
  # what font the user is viewing this source code in. Do not replace the
  # escape sequence with a single literal character.
  # Do not change this! Do not make it '\u2b80'; that is the old, wrong code point.
  SEGMENT_SEPARATOR=$'\ue0b0'
}

# Begin a segment
# Takes two arguments, background and foreground. Both can be omitted,
# rendering default background/foreground.
prompt_segment() {
  local bg fg
  [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
  [[ -n $2 ]] && fg="%F{$2}" || fg="%f"
  if [[ $CURRENT_BG != 'NONE' && $1 != $CURRENT_BG ]]; then
    echo -n " %{$bg%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR%{$fg%} "
  else
    echo -n "%{$bg%}%{$fg%} "
  fi
  CURRENT_BG=$1
  [[ -n $3 ]] && echo -n $3
}

# End the prompt, closing any open segments
prompt_end() {
  if [[ -n $CURRENT_BG ]]; then
    echo -n " %{%k%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR"
  else
    echo -n "%{%k%}"
  fi
  echo -n "%{%f%}"
  CURRENT_BG=''
}

### Prompt components
# Each component will draw itself, and hide itself if no information needs to be shown

# Context: user@hostname (who am I and where am I)
prompt_context() {
  if [[ "$USER" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
    prompt_segment black default "%(!.%{%F{yellow}%}.)%n"
  fi
}

# Git: branch/detached head, dirty status
prompt_git() {
  (( $+commands[git] )) || return
  if [[ "$(git config --get oh-my-zsh.hide-status 2>/dev/null)" = 1 ]]; then
    return
  fi
  local PL_BRANCH_CHAR
  () {
    local LC_ALL="" LC_CTYPE="en_US.UTF-8"
    PL_BRANCH_CHAR=$'\ue0a0'         # 
  }
  local ref dirty mode repo_path

  if $(git rev-parse --is-inside-work-tree >/dev/null 2>&1); then
    repo_path=$(git rev-parse --git-dir 2>/dev/null)
    dirty=$(parse_git_dirty)
    ref=$(git symbolic-ref HEAD 2> /dev/null) || ref="➦ $(git rev-parse --short HEAD 2> /dev/null)"
    if [[ -n $dirty ]]; then
      prompt_segment yellow black
    else
      prompt_segment green $CURRENT_FG
    fi

    if [[ -e "${repo_path}/BISECT_LOG" ]]; then
      mode=" <B>"
    elif [[ -e "${repo_path}/MERGE_HEAD" ]]; then
      mode=" >M<"
    elif [[ -e "${repo_path}/rebase" || -e "${repo_path}/rebase-apply" || -e "${repo_path}/rebase-merge" || -e "${repo_path}/../.dotest" ]]; then
      mode=" >R>"
    fi

    setopt promptsubst
    autoload -Uz vcs_info

    zstyle ':vcs_info:*' enable git
    zstyle ':vcs_info:*' get-revision true
    zstyle ':vcs_info:*' check-for-changes true
    zstyle ':vcs_info:*' stagedstr '✚'
    zstyle ':vcs_info:*' unstagedstr '●'
    zstyle ':vcs_info:*' formats ' %u%c'
    zstyle ':vcs_info:*' actionformats ' %u%c'
    vcs_info

    if [[ -n $AGNOSTER_THEME_TINY ]] ; then
      trimed_ref=$(echo ${ref/refs\/heads\//$PL_BRANCH_CHAR } | sed -E -e "s#([^a-zA-Z_]*[a-zA-Z_])[^/]*/#\1/#g")
      echo -n "$trimed_ref${vcs_info_msg_0_%% }${mode}"
    else
      echo -n "${ref/refs\/heads\//$PL_BRANCH_CHAR }${vcs_info_msg_0_%% }${mode}"
    fi
  fi
}

prompt_bzr() {
    (( $+commands[bzr] )) || return
    if (bzr status >/dev/null 2>&1); then
        status_mod=`bzr status | head -n1 | grep "modified" | wc -m`
        status_all=`bzr status | head -n1 | wc -m`
        revision=`bzr log | head -n2 | tail -n1 | sed 's/^revno: //'`
        if [[ $status_mod -gt 0 ]] ; then
            prompt_segment yellow black
            echo -n "bzr@"$revision "✚ "
        else
            if [[ $status_all -gt 0 ]] ; then
                prompt_segment yellow black
                echo -n "bzr@"$revision
            else
                prompt_segment green black
                echo -n "bzr@"$revision
            fi
        fi
    fi
}

prompt_hg() {
  (( $+commands[hg] )) || return
  local rev st branch
  if $(hg id >/dev/null 2>&1); then
    if $(hg prompt >/dev/null 2>&1); then
      if [[ $(hg prompt "{status|unknown}") = "?" ]]; then
        # if files are not added
        prompt_segment red white
        st='±'
      elif [[ -n $(hg prompt "{status|modified}") ]]; then
        # if any modification
        prompt_segment yellow black
        st='±'
      else
        # if working copy is clean
        prompt_segment green $CURRENT_FG
      fi
      echo -n $(hg prompt "☿ {rev}@{branch}") $st
    else
      st=""
      rev=$(hg id -n 2>/dev/null | sed 's/[^-0-9]//g')
      branch=$(hg id -b 2>/dev/null)
      if `hg st | grep -q "^\?"`; then
        prompt_segment red black
        st='±'
      elif `hg st | grep -q "^[MA]"`; then
        prompt_segment yellow black
        st='±'
      else
        prompt_segment green $CURRENT_FG
      fi
      echo -n "☿ $rev@$branch" $st
    fi
  fi
}

# Node env
prompt_nodenv() {
  local nodenv_version="$NODENV_VERSION"
  if [[ -n $nodenv_version ]] && [[ $nodenv_version != "system" ]]; then
    nodenv_version=$([[ $1 == 1 ]] && echo "" || echo " $nodenv_version")
    prompt_segment black green  "`basename ''$nodenv_version`"
  fi
}

# Ruby env
prompt_rbenv() {
  local rbenv_version="$RBENV_VERSION"
  if [[ -n $rbenv_version ]] && [[ $rbenv_version != "system" ]]; then
    rbenv_version=$([[ $1 == 1 ]] && echo "" || echo " $rbenv_version")
    prompt_segment black red "`basename ''$rbenv_version`"
  fi
}

# Conda env
prompt_condaenv() {
  local condaenv_path="$CONDA_DEFAULT_ENV"
  if [[ -n $condaenv_path ]] && [[ $condaenv_path != "base" ]]; then
    condaenv_path=$([[ $1 == 1 ]] && echo "" || echo " $condaenv_path")
    prompt_segment black blue "`basename ''$condaenv_path`"
  fi
}

check_envs() {
  [[ -n "$CONDA_DEFAULT_ENV" && "$CONDA_DEFAULT_ENV" != "base" ]] && local cnd=1 || local cnd=0
  [[ -n "$RBENV_VERSION" && "$RBENV_VERSION" != "system" ]] && local rby=1 || local rby=0
  [[ -n "$NODENV_VERSION" && "$NODENV_VERSION" != "system" ]] && local nde=1 || local nde=0

  [[ $rby == 1 ]] && [[ $nde == 1 ]] && return 1
  [[ $nde == 1 ]] && [[ $cnd == 1 ]] && return 1
  [[ $cnd == 1 ]] && [[ $rby == 1 ]] && return 1

  return 0
}

# When found an all package manager, use `prompt_segment cyan $CURRENT_FG "`basename ' '$upm_env_path`"`
# If more then one env is active, print only the icon as a short version.
promtpt_all_virtual_env() {
  check_envs
  local multiple_envs=$?
  local upm_path="$UPM_DEFAULT_ENV"
  if [[ -n $upm_path ]] && [[ $upm_path != "base" ]]; then
    prompt_segment cyan $CURRENT_FG "`basename ' '$condaenv_path`"
  elif [[ -n $AGNOSTER_THEME_TINY ]] && [[ $multiple_envs == 1 ]]; then
    prompt_nodenv 1
    prompt_rbenv 1
    prompt_condaenv 1
    prompt_virtualenv
  else
    prompt_nodenv
    prompt_rbenv
    prompt_condaenv
    prompt_virtualenv
  fi
}

# Dir: current working directory
prompt_dir() {
  if [[ -n $AGNOSTER_THEME_TINY ]] ; then
    local trim_path=$(print -P ' %~ ' | sed -E -e "s#([^a-zA-Z_]*[a-zA-Z_])[^/]*/#\1/#g")
    prompt_segment blue black $trim_path
  else
    prompt_segment blue $CURRENT_FG '%~'
  fi
}

# Virtualenv: current working virtualenv
prompt_virtualenv() {
  local virtualenv_path="$VIRTUAL_ENV"
  if [[ -n $virtualenv_path && -n $VIRTUAL_ENV_DISABLE_PROMPT ]]; then
    prompt_segment blue black "(`basename $virtualenv_path`)"
  fi
}

# Status:
# - was there an error
# - am I root
# - are there background jobs?
prompt_status() {
  local -a symbols

  [[ $RETVAL -ne 0 ]] && symbols+="%{%F{red}%}✘"
  [[ $UID -eq 0 ]] && symbols+="%{%F{yellow}%}⚡"
  [[ $(jobs -l | wc -l) -gt 0 ]] && symbols+="%{%F{cyan}%}⚙"

  [[ -n "$symbols" ]] && prompt_segment black default "$symbols"
}

#AWS Profile:
# - display current AWS_PROFILE name
# - displays yellow on red if profile name contains 'production' or
#   ends in '-prod'
# - displays black on green otherwise
prompt_aws() {
  [[ -z "$AWS_PROFILE" ]] && return
  case "$AWS_PROFILE" in
    *-prod|*production*) prompt_segment red yellow  "AWS: $AWS_PROFILE" ;;
    *) prompt_segment green black "AWS: $AWS_PROFILE" ;;
  esac
}

## Main prompt
build_prompt() {
  RETVAL=$?
  prompt_status
  promtpt_all_virtual_env
  prompt_aws
  prompt_context
  prompt_dir
  prompt_git
  prompt_bzr
  prompt_hg
  prompt_end

  CURRENT_BG='NONE'
}

PROMPT='%{%f%b%k%}$(build_prompt) '
