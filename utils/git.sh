#!/usr/bin/env zsh

# @describe Git-related utility functions

# @func Returns current branch name
function _get_current_branch() {
  print `git branch --show-current`
}

# @func Checks if passed branch name exists locally
# @arg <branch> Branch name to check
function _is_branch_local() {
  print `git branch --list $1`
}

# @func Checks if passed branch name exists remotely
# @arg <branch> Branch name to check
function _is_branch_remote() {
  print `git ls-remote --heads origin $1`
}

# @func Checks if there are unstaged changes
function _has_unstaged_changes() {
  [ `git diff --quiet 2>/dev/null; print $?` -eq 0 ] && print "false" || print "true"
}

# @func Checks if there are uncommitted changes
function _has_uncommitted_changes() {
  git diff-index --quiet HEAD -- && print "false" || print "true"
}

# @func Checks if the current branch is up-to-date with its remote
function _is_branch_up_to_date() {
  local branch=`_get_current_branch`
  git fetch origin $branch
  [ "$(git rev-parse HEAD)" = "$(git rev-parse @{u})" ] && print "true" || print "false"
}
