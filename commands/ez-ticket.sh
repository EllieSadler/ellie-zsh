#!/usr/bin/env zsh

# @cmd Command template for switching to the needed environments for a ticket/update
# @arg <commands> The command(s) to run on each repository
function ez-ticket() {
  # start config
  local parent_branch=""
  local branch=""
  local repos=()
  # end config

  _ez_ticket --parent-branch "${parent_branch}" --branch "${branch}" --repos "${repos}" --commands "${*}"
}

# @cmd Loops through repositories, changes to the correct branch, and runs specified commands while passing predefined values like the parent branch
# @option -r|--repos Repositories to loop through
# @option -b|--branch Branch to use for current update
# @option -p|--parent-branch Parent branch for current update
# @option -c|--commands Commands to run for each repository
function _ez_ticket() {
  local repos=()
  local branch=""
  local parent_branch=""
  local commands=""

  while [ $# -gt 0 ]; do
    case $1 in
      -r | --repos) 
        if _has_flag_arg $@; then
          repos=(${(@s: :)$(_get_flag_arg $@)})
          shift
        fi
        ;;
      -b | --branch)
        if _has_flag_arg $@; then
          branch=$(_get_flag_arg $@)
          shift
        fi
        ;;
      -p | --parent-branch)
        if _has_flag_arg $@; then
          parent_branch=$(_get_flag_arg $@)
          shift
        fi
        ;;
      -c | --commands)
        if _has_flag_arg $@; then
          commands=$(_get_flag_arg $@)
          shift
        fi
        ;;
    esac

    shift
  done

  # start error management
  local errors=""

  if [[ -z $repos ]]; then
    errors="\n${INDENT}Repository array cannot be empty."
  fi

  if [[ -z $branch ]]; then
    errors="${errors}\n${INDENT}Branch name cannot be empty."
  fi

  if [[ -z $parent_branch ]]; then
    errors="${errors}\n${INDENT}Parent branch cannot be empty."
  fi

  if [[ -n $errors ]]; then
    _error "Cancelling. Look below for details.\n${RED}${errors}${STOP_COLOR}"
    return
  fi
  # end error management

  if [[ -z $commands ]]; then
    local build_repos=""
    local options=(
      "yarn build"
      "yarn install && yarn build"
      "no"
    )

    _question "Do you want to run any builds?" --options "${(j:,:)options}"
    read response

    case $response in
      [1-2]*) build_repos="${options[$response]}";;
      *) ;;
    esac
  fi

  for repo in $repos; do
    _repo_before $repo
    ez-branch $branch $parent_branch
  
    if [[ -z $commands && -n $build_repos ]]; then
      eval $build_repos
    else
      if [[ $commands = "ez-push" || $commands = "ez-pr" || $commands = "ez-super-duper" ]]; then
        eval $commands --batch --skip-check --parent-branch $parent_branch
      elif [[ $commands = "ez-commit" ]]; then
        eval $commands --batch
      else
        eval $commands
      fi
    fi

    _repo_after
  done

  # reset pull request type selection
  pr_type=""
}
