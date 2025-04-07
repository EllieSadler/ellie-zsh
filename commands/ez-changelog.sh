#!/usr/bin/env zsh

# @cmd Create a changelog
# @arg <type> Type of version upgrade
# @arg <message> Message to add to changelog
function ez-changelog() {
  local date=${(%):-%D{%Y-%d-%m}}
  local type=$1
  local message=$2
  local has_error=false
  
  if [[ $type = "patch" ]]; then
    local version=`node -p "(() => { let [major, minor, patch] = require('./package.json').version.split('.').map(Number); return [major, minor, patch + 1].join('.'); })()"`
  elif [[ $type = "minor" ]]; then
    # reset patch to 0
    local version=`node -p "(() => { let [major, minor, patch] = require('./package.json').version.split('.').map(Number); return [major, minor + 1, 0].join('.'); })()"`
  elif [[ $type = "major" ]]; then
    # reset minor and patch to 0
    local version=`node -p "(() => { let [major, minor, patch] = require('./package.json').version.split('.').map(Number); return [major + 1, 0, 0].join('.'); })()"`
  else
    has_error=true
    error_message="A version ${RED}type${STOP_COLOR} must be specified: patch, minor, major."
  fi

  if [[ -z $message ]]; then
    has_error=true
    error_message="${error_message} A version ${RED}message${STOP_COLOR} must be provided."
  fi

  if [[ $has_error = true ]]; then
    error $error_message
    _msg "Example: ez-changelog patch \"added new xyz command\""
    return
  fi

  # add version and date to changelog
  sed -i '' "5i\\
## [$version] - $date
  " CHANGELOG.md

  # add version message to changelog
  sed -i '' "6i\\
$message
  " CHANGELOG.md

  # add an empty line to changelog
  sed -i '' "7i\\

  " CHANGELOG.md

  git add CHANGELOG.md

  _warn "Update the version number in ${ORANGE}package.json${STOP_COLOR} to ${ORANGE}$version${STOP_COLOR}."
  code package.json
}
