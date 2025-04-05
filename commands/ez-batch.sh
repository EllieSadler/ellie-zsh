#!/usr/bin/env zsh

# @cmd Cycle through repositories and run passed commands
# @arg <commands> The command(s) to run on each repository
# @option -r|--repos <repos> Array of repositories to cycle through
function ez-batch() {
  local repos=$DEFAULT_REPOS
  local commands=""
  local verify=true # TODO: do we want to do something different for this?

  while [ $# -gt 0 ]; do
    case $1 in
      -b | --batch)
        if ! _has_flag_arg $@; then
          _error "${RED}Repository array${STOP_COLOR} must be specified when using the ${RED}--repos${STOP_COLOR} flag."
          return
        fi

        repos=$(_get_flag_arg $@)
        shift
        ;;
      *)
        commands="${commands} ${1}"
        ;;
    esac

    shift
  done

  if [[ -z $repos ]]; then
    _error "${RED}Repostiory list${STOP_COLOR} cannot be empty."
    return
  fi

  if [[ $verify = true ]]; then
    _question "Run${YELLOW}${commands}${STOP_COLOR} for ${YELLOW}${repos}${STOP_COLOR}?" --yes-no
    read response

    if [[ $response != "y" ]]; then
      _alert "Cancelling..."
      return
    fi
  fi

  repos=(${(@s: :)repos})

  for repo in $repos; do
    _repo_before "${repo}"
    eval $commands
    _repo_after
  done
}

# @describe Changes directories and outputs spacing and messaging for switching to a looped repository
# @arg <repo> Repository to switch to
function _repo_before() {
  local repo=$1
  ez $repo
  _add_space _add_space
  _msg "${BLUE}${BOLD}Switched to ${UNDERLINE}${repo}${STOP_UNDERLINE}${STOP_BOLD}${STOP_COLOR}"
  _add_space
}

# @describe Outputs spacing and divider after running commands for a looped repository
function _repo_after() {
  _add_space
  _divider
}
