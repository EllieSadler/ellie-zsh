#!/usr/bin/env zsh

# @cmd Merge a branch into another, handle merge conflicts, and optionally push changes to remote
# @arg source_branch Branch to merge into the target branch
# @arg target_branch Branch to merge the source branch into
# @flag -s|--skip-push Skip pushing changes to remote
function ez-merge() {
  # set default values
  local skip_push=false
  local source_branch=""
  # get the current branch you're on
  local target_branch=`_get_current_branch`
  # get the repository you ran this command from
  local repo=${PWD##*/}

  # get/set variables from args
  while [ $# -gt 0 ]; do
    case $1 in
      -s | --skip-push) 
        # set skip_push to true
        if [[ $skip_push = false ]]; then
          skip_push=true
        fi
        ;;
      *)
        # set source_branch (will always be first)
        if [[ -z $source_branch ]]; then
          source_branch=$1
         # set target_branch (will always be second)
        elif [[ -z $target_branch ]]; then
          target_branch=$1
        fi
        ;;
    esac

    # remove arg after it's processed
    shift
  done
  
  # cancel if the source branch was not provided
  if [[ -z $source_branch ]]; then
    _error "${RED}Source branch${STOP_COLOR} must be specified."
    return
  fi
  
  # gut check for correct source branch, feature branch, and repository
  _question --yes-no "Merge ${YELLOW}origin/${source_branch}${STOP_COLOR} into ${YELLOW}${target_branch}${STOP_COLOR} for ${YELLOW}${repo}${STOP_COLOR}?"
  read response

  # stop command if the above info was incorrect
  if [[ $response != "y" ]]; then
    _alert "Skipping merge process for ${SKYBLUE}${repo}${STOP_COLOR}..."
    return
  fi

  # fetch the origin of the source branch
  processing "fetching source branch origin"
  git fetch origin $source_branch

  # get info to check for merge requirement
  source_commit=`git rev-parse origin/$source_branch` # latest commit on source_branch
  target_commit=`git rev-parse HEAD` # latest commit on target_branch
  merge_base=`git merge-base HEAD origin/$source_branch` # latest commit of common ancestor

  # stop command if there's no need to merge
  if [[ $merge_base == $source_commit || $source_commit == $target_commit ]]; then
    _alert "There are no changes that need merged."
    return
  fi

  # merge source branch into target branch
  _add_space
  processing "merging"
  git merge origin/$source_branch

  # merge conflicts exist
  if [[ $? -ne 0 ]]; then
    # offer to wait while you handle merge conflicts
    _question "Once all merge conflicts have been resolved, enter ${SKYBLUE}\"y\"${STOP_COLOR} to stage all changes and move forward or ${RED}\"n\"${STOP_COLOR} to cancel.\n${INDENT}Response:"
    read response

    # stop command if you didn't enter "y"
    if [[ $response != "y" ]]; then
      _alert "Cancelling commit and push process for merge..."
      return
    else 
      # stage all changes and attempt to commit
      processing "staging all changes and committing"
      _add_space
      git add .
      git commit -m "Merged '$source_branch' into '$target_branch'"

      # commit failed (most likely due to pre-commit checks)
      if [[ $? -ne 0 ]]; then
        local options=(
          "'yarn build' and commit"
          "'yarn install && yarn build' and commit"
          "do nothing"
        )

        # offer to install and/or build and attempt to commit again
        _question "Do you want to run 'yarn install' and/or 'yarn build' and try to commit again?" --options "${(j:,:)options}"
        read response

        case $response in
          1)
            yarn build
            ;;
          2)
            yarn install
            yarn build
            ;;
          # stop command if you didn't enter "1" or "2"
          *) 
            _alert "Cancelling commit and push process for merge..."
            return
            ;;
        esac

        # stage all changes and attempt to commit
        processing "staging all changes and committing"
        git add .
        git commit -m "Merged '$source_branch' into '$target_branch'"

        # stop command if commit failed again
        if [[ $? -ne 0 ]]; then
          _error "Commit attempt failed again. Please look at logs for further details."
        fi
      fi
    fi
  fi

  # push changes to remote if not skipped
  if [[ $skip_push = false ]]; then
    _add_space
    processing "pushing merge commits"
    git push

    # display final success/failure messages
    if [[ $? -ne 0 ]]; then
      _error "Push attempt failed. Please look at logs for further details."
    fi
  fi

  # display final success message
  _success "Merge complete."
}
