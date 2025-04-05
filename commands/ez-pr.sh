#!/usr/bin/env zsh

# @cmd Open a link to create a pull request
# @option -p|--parent-branch Parent branch name to use for new pull requests
# @flag -b|--batch Part of a batch of repository commits and skips branch check
function ez-pr() {
  local repo=${PWD##*/}
  local branch=`_get_current_branch`
  local origin=`git config --get remote.origin.url`
  local url="${origin/%'.git'}"
  local parent_branch=""
  local pr_message="view pull requests"
  local batch=false

  while [ $# -gt 0 ]; do
    case $1 in
      -p | --parent-branch) 
        if _has_flag_arg $@; then
          parent_branch=$(_get_flag_arg $@)
          shift
        fi
        ;;
      -b | --batch) 
        batch=true
        ;;
    esac

    shift
  done

  if [[ $batch = false ]]; then
    local pr_type=""
  fi

  if [[ -z $pr_type || $batch = true && -z $pr_type ]]; then
    local options=(
      "new"
      "existing"
      "cancel"
    )

    _question "What type of pull request do you need for ${YELLOW}${repo}${STOP_COLOR}?" --options "${(j:,:)options}"
    read response

    case $response in
      [1-2]*) pr_type="${options[$response]}";;
      *) ;;
    esac
  fi

  if [[ $pr_type = "new" ]]; then
    url="${url}/compare/"

    if [[ -n $parent_branch ]]; then
      url="${url}${parent_branch}..."
    fi

    url="${url}${branch}"
    pr_message="create a pull request"
  elif [[ $pr_type = "existing" ]]; then
    url="${url}/issues?q=is%3Aopen+is%3Apr+author%3A%40me"
  else
    _alert "Cancelling pull request process for ${SKYBLUE}${repo}${STOP_COLOR}..."
    return
  fi

  _alert "The URL below can be used to ${pr_message} for ${SKYBLUE}${repo}${STOP_COLOR}.\n${INDENT}${SKYBLUE}${url}${STOP_COLOR}"
  open $url
}
