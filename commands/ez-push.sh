#!/usr/bin/env zsh

# @cmd Push changes to a branch and optionally switch branches
# @flag -s|--skip-check Skip initial check to continue push process
function ez-push() {
  local repo=${PWD##*/}
  local branch=`_get_current_branch`
  local skip_check=false

  while [ $# -gt 0 ]; do
    case $1 in
      -s | --skip-check) 
        skip_check=true
        ;;
    esac
    shift
  done

  if [[ $skip_check = false ]]; then
    _question --yes-no "Move forward with pushing to ${YELLOW}${repo}${STOP_COLOR}?"
    read response

    if [[ $response != "y" ]]; then
      _alert "Skipping push process for ${SKYBLUE}${repo}${STOP_COLOR}..."
      return
    fi

    _question --yes-no "Is ${YELLOW}${branch}${STOP_COLOR} the correct branch?"
    read response

    if [[ $response != "y" ]]; then
      _question "Enter branch name:" -d branch_name

      if [[ -z $branch_name ]]; then
        _error "Response was empty.\n${INDENT}Cancelling push process for ${RED}${repo}${STOP_COLOR}..."
        return
      else
        _add_space
        branch=$branch_name
        ez-branch $branch
      fi
    fi
  fi

  _question --yes-no "Do you want to push to ${YELLOW}${branch}${STOP_COLOR} for ${YELLOW}${repo}${STOP_COLOR}?"
  read response

  if [[ $response = "y" ]]; then
    _msg "${ITALIC}processing push...${STOP_ITALIC}"
    _add_space
    local branch_remote=`_is_branch_remote $branch`

    if [[ -n $branch_remote ]]; then
      git push
    else
      git push --set-upstream origin $branch
    fi
  else
    _alert "Cancelling push process for ${SKYBLUE}${repo}${STOP_COLOR}..."
    return
  fi
}
