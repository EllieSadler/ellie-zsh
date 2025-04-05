#!/usr/bin/env zsh

# @describe Custom ez-ticket commands

# EXAMPLE
# bug fix - xxx
function ez-ticket-xxx() {
  # start config
  local parent_branch="feature/xxx"
  local branch="bugfix/xxx"
  local repos=(
    "xxx"
  )
  # end config

  _ez_ticket --parent-branch "${parent_branch}" --branch "${branch}" --repos "${repos}" --commands "${*}"
}
