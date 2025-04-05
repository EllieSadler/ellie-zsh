#!/usr/bin/env zsh

# @cmd Run the commit, push, and pull request commands
# @option -p|--parent-branch Parent branch name to use for new pull requests (passed to ez-commit)
# @flag -b|--batch Part of a batch of repository commits and skips branch check (passed to ez-pr)
function ez-super-duper() {
  local repo=${PWD##*/}
  local parent_branch=""
  local batch_flag=""

  while [ $# -gt 0 ]; do
    case $1 in
      -p | --parent-branch) 
        if _has_flag_arg $@; then
          parent_branch=$(_get_flag_arg $@)
          shift
        fi
        ;;
      -b | --batch) 
        batch_flag="--batch"
        ;;
    esac

    shift
  done

  ez-commit $batch_flag
  ez-push --skip-check
  ez-pr --parent-branch $parent_branch
}
