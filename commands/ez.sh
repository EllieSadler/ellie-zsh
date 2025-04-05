#!/usr/bin/env zsh

# @cmd Change directories to a repository
# @arg <repo> Repository to change directories to
function ez() {
  local repo=$1
  local dir="$GIT_DIR/$repo"

  cd $dir
}
