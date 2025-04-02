#!/usr/bin/env zsh

# @describe: used to store utility variables and functions

# print styles
GREY=%4F{000}
RED=%4F{009}
ORANGE=%4F{208}
YELLOW=%4F{011}
GREEN=%4F{010}
BLUE=%4F{012}
SKYBLUE=%4F{117}
PURPLE=%4F{013}
STOP_COLOR=%4f

BOLD=%B
STOP_BOLD=%b

UNDERLINE=%U
STOP_UNDERLINE=%u

ITALIC="%{\e[3m%}"
STOP_ITALIC="%{\e[23m%}"

INDENT="   "

# open .zshrc file in vscode
edit-zsh() {
  code ~/.zshrc
}

# open this folder in vscode
edit-ellie-zsh() {
  code $GIT_DIR/ellie-zsh/
}

# load zsh changes
reload() {
  source ~/.zshrc
}

# load zsh changes
execute-order-66() {
  add-space
  msg "${GREY}DS: \"Commander Cody, the time has come. Execute Order 66.\"${STOP_COLOR}"
  msg "${GREY}CC: \"Yes, my Lord.\"${STOP_COLOR}"
  reload
}

# flag args
has-flag-arg() {
  [[ ("$1" == *=* && -n ${1#*=}) || ( ! -z "$2" && "$2" != -*)  ]];
}
get-flag-arg() {
  print "${2:-${1#*=}}"
}

# get current branch
get-current-branch() {
  print `git branch --show-current`
}

# check if branch exists locally
is-branch-local() {
  print `git branch --list $1`
}

# check if branch exists remotely
is-branch-remote() {
  print `git ls-remote --heads origin $1`
}

# check if there are unstaged changes
has-unstaged-changes() {
  if [ `git diff --quiet 2>/dev/null; print $?` -eq 0 ]; then
    print "false"
  else
    print "true"
  fi
}

# check if there are uncommitted changes
has-uncommitted-changes() {
  if git diff-index --quiet HEAD --; then
    print "false"
  else
    print "true"
  fi
}

# check if local branch is up-to-date with remote
is-branch-up-to-date() {
  local branch=`get-current-branch`
  git fetch origin $branch
  if [ "$(git rev-parse HEAD)" = "$(git rev-parse @{u})" ]; then
    print "true"
  else
    print "false"
  fi
}

# add extra space
add-space() {
  print ""
}
add-more-space() {
  add-space
  add-space
}

# message utility functions
msg() {
  local no_newline=""
  local message=""

  while [ $# -gt 0 ]; do
    case $1 in
      -n | --no-newline) 
        no_newline="-n"
        ;;
      *) message=$1;;
    esac
    shift
  done

  print $no_newline -P "${message}"
}
error() {
  add-space
  msg "❌ $1"
  add-space
}
alert() {
  add-space
  msg "🔼 $1"
  add-space
}
question() {
  local message=""
  local yes_no=""
  local default=""
  local options=()

  while [ $# -gt 0 ]; do
    case $1 in
      -y | --yes-no) 
        yes_no="${GREY}[y/n]${STOP_COLOR} "
        ;;
      -d | --default) 
        if has-flag-arg $@; then
          default=$(get-flag-arg $@)
          shift
        fi
        ;;
      -o | --options) 
        if has-flag-arg $@; then
          options=(${(@s:,:)"$(get-flag-arg $@)"})
          shift
        fi
        ;;
      *) message=$1;;
    esac
    shift
  done

  message="🟡 ${message} ${yes_no}"
  add-space

  if [[ -n $options ]]; then
    msg "${message}"
    add-space

    for option in $options; do
      msg "${INDENT}${INDENT}${options[(Ie)$option]}) ${option}"
    done

    add-space

    if [[ -n $default ]]; then
      vared -p "${INDENT}Response: " -c $default
    else
      msg -n "${INDENT}Response: "
    fi
  elif [[ -n $default ]]; then
    vared -p $message -c $default
  else
    msg -n $message
  fi
}
divider(){
  printf '%.s─' $(seq 1 $(tput cols))
}
