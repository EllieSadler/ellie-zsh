#!/usr/bin/env zsh

# @cmd Commit changes to a branch and optionally stage changes, switch branches, and/or add a changelog
# @flag -s|--skip-check Skip initial check to continue commit process
# @flag -b|--batch Part of a batch of repository commits and skips branch check
function ez-commit() {
  local repo=${PWD##*/}
  local branch=`_get_current_branch`
  local skip_changelog=false
  local skip_check=false
  local batch=false

  while [ $# -gt 0 ]; do
    case $1 in
      -s | --skip-check) 
        if [[ $skip_check = false ]]; then
          skip_check=true
        fi
        ;;
      -b | --batch)
        batch=true
        ;;
    esac
    shift
  done

  if [[ $skip_check = false ]]; then
    _question --yes-no "Move forward with commiting to ${YELLOW}${repo}${STOP_COLOR}?"
    read response

    if [[ $response != "y" ]]; then
      _alert "Skipping commit process for ${SKYBLUE}${repo}${STOP_COLOR}..."
      return
    fi
  fi

  if [[ $batch = false ]]; then
    _question --yes-no "Is ${YELLOW}${branch}${STOP_COLOR} the correct branch?"
    read response

    if [[ $response != "y" ]]; then
      _question "Enter branch name:" -d branch_name

      if [[ -z $branch_name ]]; then
        _error "Response was empty.\n${INDENT}Cancelling commit process for ${RED}${repo}${STOP_COLOR}..."
        return
      else
        branch=$branch_name
        ez-branch $branch
      fi
    fi
  fi

  if [[ $skip_changelog = false ]]; then
    _question --yes-no "Do you need to add a changelog file?"
    read add_changelog

    if [[ $add_changelog = "y" ]]; then
      _question "Enter changelog message (also used for commit message):" -d commit_message

      if [[ -z $commit_message ]]; then
        _error "Response was empty.\n${INDENT}Cancelling commit process for ${RED}${repo}${STOP_COLOR}..."
        return
      fi

      _add_space
      ez-changelog patch "${commit_message}"
      _add_space _add_space
    fi
  fi
  
  _add_space
  git status

  local options=(
    "stage all changes"
    "wait for you to stage changes elsewhere"
    "do nothing"
  )

  _question "Do you need to update staged changes?" --options "${(j:,:)options}"
  read staged_updated

  case $staged_updated in
    1) staged_updated="y"
      git add .
      ;;
    2) staged_updated="y"
      _question "When finished staging changes, enter ${SKYBLUE}\"y\"${STOP_COLOR} to move forward or ${RED}\"n\"${STOP_COLOR} to cancel.\n${INDENT}Response:"
      read response

      if [[ $response != "y" ]]; then
        _alert "Cancelling commit process for ${SKYBLUE}${repo}${STOP_COLOR}..."
        return
      fi
      ;;
    *) staged_updated="n";;
  esac
  
  if [[ $staged_updated = "y" ]]; then
    _add_space
    git status
  fi

  _question --yes-no "Commit to ${YELLOW}${repo}${STOP_COLOR} on branch ${YELLOW}${branch}${STOP_COLOR} with current git status?"
  read response

  if [[ $response = "y" ]]; then
    if [[ $add_changelog != "y" ]]; then
      _question "Enter commit message:" -d commit_message

      if [[ -z $commit_message ]]; then
        _error "Response was empty.\n${INDENT}Cancelling commit process for ${RED}${repo}${STOP_COLOR}..."
        return
      fi
    fi

    _add_space
    git commit -m "$commit_message"
  else
    _alert "Cancelling commit process for ${SKYBLUE}${repo}${STOP_COLOR}..."
    return
  fi
}
