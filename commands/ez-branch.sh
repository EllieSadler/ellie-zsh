#!/usr/bin/env zsh

# @cmd Switch to a new or existing branch
# @arg <branch> Branch to switch to
# @arg <parent-branch> Parent branch to use for new branch
function ez-branch() {
  local branch=$1
  local parent_branch=$2
  local current_branch=`_get_current_branch`

  if [[ -z $branch ]]; then
    _error "No branch specified. Cancelling..."
    source ~/.zshrc # critical error - prevent possible next commands from running
  fi

  if [[ $branch = $current_branch ]]; then
    return
  fi

  local branch_local=`_is_branch_local $branch`
  local new_flag=""

  if [[ -z $branch_local ]]; then
    _msg "${ITALIC}processing branch change...${STOP_ITALIC}"
    
    new_flag="-b"
    local branch_remote=`_is_branch_remote $branch`

    if [[ -n $branch_remote ]]; then
      branch="${branch} origin/${branch}"
    elif [[ -n $parent_branch ]]; then
      local parent_branch_local=`_is_branch_local $parent_branch`
      local parent_branch_remote=`_is_branch_remote $parent_branch`

      if [[ -n $parent_branch_local ]]; then
        _add_space
        git checkout $parent_branch
        git pull origin $parent_branch
      elif [[ -n $parent_branch_remote ]]; then
        _add_space
        git checkout -b $parent_branch origin/$parent_branch
      else 
        _error "The parent branch ${RED}${parent_branch}${STOP_COLOR} does not exist. Cancelling..."
        # critical error occurred - prevent possible next commands from running
        source ~/.zshrc 
      fi
    fi
  fi

  _add_space
  eval "git checkout ${new_flag} ${branch}"
}
