#!/usr/bin/env zsh

# @describe: used to store custom ez-ticket-templates

# EXAMPLE
# bug fix - xxx
function ez-xxx() {
  # start config
  local mantle_parent_branch="feature/xxx"
  local parent_branch="feature/xxx"
  local branch="bugfix/xxx"
  local repos=(
    "xxx"
  )
  # end config

  _ez_ticket --mantle-parent-branch "${mantle_parent_branch}" --parent-branch "${parent_branch}" --branch "${branch}" --brands "${repos}" --commands "${*}"
}
