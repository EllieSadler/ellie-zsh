#!/usr/bin/env zsh

# @describe: Used to store custom functions

# TODO: should all instances of brand and/or project be switched to something more general?

# TODO: create a list of common args and options to standardize things
#   - brand(s)/project(s)
#   - branch
#   - parent branch
#   - source branch
#   - target branch
#   - skip check
#   - batch
#   - command(s)



alias ez-sync="yarn sync"
alias ez-build="yarn build"
alias ez-fresh-build="yarn install && yarn build"
alias ez-super-build="yarn install && yarn build && gradle build publishToMavenLocal"
alias ez-clean-build="gradle clean build --refresh-dependencies"
alias ez-link="gradle linkMantle"
alias ez-unlink="gradle unlinkMantle && git checkout -- settings.gradle"
alias ez-xmllint="gradle xmllint"

# @cmd Run an application
# @arg <offset> Port offset
function ez-run() {
  if [[ $# = 1 ]]; then
    gradle bootRun -Pport.offset=${1}
  else
    gradle bootRun
  fi
}

# @cmd Create a changelog
# @arg <message> Message to add to changelog
# @arg <ticket> Ticket number for changelog
function ez-changelog() {
  local message=$1
  local ticket=$2

  if [[ -n $ticket ]]; then
    gradle addChangelog -Pchange="${message}" -Pticket="${ticket}"
  else
    gradle addChangelog -Pchange="${message}"
  fi
}

# @cmd Change directories to a brand/project
# @arg <brand> Brand/Project to change directories to
function ez() {
  local brand=$1
  local dir="$GIT_DIR/$brand"

  cd $dir
}

# @cmd Cycle through brands/projects and run passed commands
# @arg <commands> The command(s) to run on each brand/project
# @option -b|--brands <brands> Array of brands/projects to cycle through
function ez-batch() {
  local brands=$DD_DEFAULT_BRANDS
  local commands=""
  local verify=true # TODO: do we want to do something different for this?

  while [ $# -gt 0 ]; do
    case $1 in
      -b | --batch)
        if ! has-flag-arg $@; then
          error "${RED}Brands array${STOP_COLOR} must be specified when using the ${RED}--brands${STOP_COLOR} flag."
          return
        fi

        brands=$(get-flag-arg $@)
        shift
        ;;
      *)
        commands="${commands} ${1}"
        ;;
    esac

    shift
  done

  if [[ -z $brands ]]; then
    error "${RED}Brands${STOP_COLOR} cannot be empty."
    return
  fi

  if [[ $verify = true ]]; then
    question "Run${YELLOW}${commands}${STOP_COLOR} for ${YELLOW}${brands}${STOP_COLOR}?" --yes-no
    read response

    if [[ $response != "y" ]]; then
      alert "Cancelling..."
      return
    fi
  fi

  brands=(${(@s: :)brands})

  for brand in $brands; do
    _brand_before "${brand}"
    eval $commands
    _brand_after
  done
}

# @describe Changes directories and outputs spacing and messaging for switching to a looped brand/project
# @arg <brand> Brand/Project to switch to
function _brand_before() {
  local brand=$1
  ez $brand
  add-more-space
  msg "${BLUE}${BOLD}Switched to ${underline}${brand}${STOP_UNDERLINE}${STOP_BOLD}${STOP_COLOR}"
  add-space
}

# @describe Outputs spacing and divider after running commands for a looped brand/project
function _brand_after() {
  add-space
  divider
}

# @cmd Switch to a new or existing branch
# @arg <branch> Branch to switch to
# @arg <parent-branch> Parent branch to use for new branch
function ez-branch() {
  local branch=$1
  local parent_branch=$2
  local current_branch=`get-current-branch`

  if [[ -z $branch ]]; then
    error "No branch specified. Cancelling..."
    source ~/.zshrc # critical error - prevent possible next commands from running
  fi

  if [[ $branch = $current_branch ]]; then
    return
  fi

  local branch_local=`is-branch-local $branch`
  local new_flag=""

  if [[ -z $branch_local ]]; then
    msg "${italic}processing branch change...${STOP_ITALIC}"
    
    new_flag="-b"
    local branch_remote=`is-branch-remote $branch`

    if [[ -n $branch_remote ]]; then
      branch="${branch} origin/${branch}"
    elif [[ -n $parent_branch ]]; then
      local parent_branch_local=`is-branch-local $parent_branch`
      local parent_branch_remote=`is-branch-remote $parent_branch`

      if [[ -n $parent_branch_local ]]; then
        add-space
        git checkout $parent_branch
        git pull origin $parent_branch
      elif [[ -n $parent_branch_remote ]]; then
        add-space
        git checkout -b $parent_branch origin/$parent_branch
      else 
        error "The parent branch ${RED}${parent_branch}${STOP_COLOR} does not exist. Cancelling..."
        source ~/.zshrc # critical error - prevent possible next commands from running
      fi
    fi
  fi

  add-space
  eval "git checkout ${new_flag} ${branch}"
}

# @cmd Commit changes to a branch and optionally stage changes, switch branches, and/or add a changelog
# @flag -s|--skip-check Skip initial check to continue commit process
# @flag -b|--batch Part of a batch of brand/project commits and skips branch check
function ez-super-commit() {
  local brand=${PWD##*/}
  local branch=`get-current-branch`
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
    question --yes-no "Move forward with commiting to ${YELLOW}${brand}${STOP_COLOR}?"
    read response

    if [[ $response != "y" ]]; then
      alert "Skipping commit process for ${SKYBLUE}${brand}${STOP_COLOR}..."
      return
    fi
  fi

  if [[ $batch = false ]]; then
    question --yes-no "Is ${YELLOW}${branch}${STOP_COLOR} the correct branch?"
    read response

    if [[ $response != "y" ]]; then
      question "Enter branch name:" -d branch_name

      if [[ -z $branch_name ]]; then
        error "Response was empty.\n${INDENT}Cancelling commit process for ${RED}${brand}${STOP_COLOR}..."
        return
      else
        branch=$branch_name
        ez-branch $branch
      fi
    fi
  fi

  if [[ $skip_changelog = false ]]; then
    question --yes-no "Do you need to add a changelog file?"
    read add_changelog

    if [[ $add_changelog = "y" ]]; then
      question "Enter changelog message (also used for commit message):" -d commit_message

      if [[ -z $commit_message ]]; then
        error "Response was empty.\n${INDENT}Cancelling commit process for ${RED}${brand}${STOP_COLOR}..."
        return
      fi

      add-space
      ez-changelog "${commit_message}"
      add-more-space
      git add changelog/
    fi
  fi
  
  add-space
  git status

  local options=(
    "stage all changes"
    "wait for you to stage changes elsewhere"
    "do nothing"
  )

  question "Do you need to update staged changes?" --options "${(j:,:)options}"
  read staged_updated

  case $staged_updated in
    1) staged_updated="y"
      git add .
      ;;
    2) staged_updated="y"
      question "When finished staging changes, enter ${SKYBLUE}\"y\"${STOP_COLOR} to move forward or ${RED}\"n\"${STOP_COLOR} to cancel.\n${INDENT}Response:"
      read response

      if [[ $response != "y" ]]; then
        alert "Cancelling commit process for ${SKYBLUE}${brand}${STOP_COLOR}..."
        return
      fi
      ;;
    *) staged_updated="n";;
  esac
  
  if [[ $staged_updated = "y" ]]; then
    add-space
    git status
  fi

  question --yes-no "Commit to ${YELLOW}${brand}${STOP_COLOR} on branch ${YELLOW}${branch}${STOP_COLOR} with current git status?"
  read response

  if [[ $response = "y" ]]; then
    if [[ $add_changelog != "y" ]]; then
      question "Enter commit message:" -d commit_message

      if [[ -z $commit_message ]]; then
        error "Response was empty.\n${INDENT}Cancelling commit process for ${RED}${brand}${STOP_COLOR}..."
        return
      fi
    fi

    add-space
    git commit -m "$commit_message"
  else
    alert "Cancelling commit process for ${SKYBLUE}${brand}${STOP_COLOR}..."
    return
  fi
}

# @cmd Push changes to a branch and optionally switch branches
# @flag -s|--skip-check Skip initial check to continue push process
function ez-super-push() {
  local brand=${PWD##*/}
  local branch=`get-current-branch`
  local skip_check=false

  while [ $# -gt 0 ]; do
    case $1 in
      -s | --skip-check) 
        skip_check=true
        ;;
    esac
    shift
  done

  if [[ $skip_check = false ]]; then
    question --yes-no "Move forward with pushing to ${YELLOW}${brand}${STOP_COLOR}?"
    read response

    if [[ $response != "y" ]]; then
      alert "Skipping push process for ${SKYBLUE}${brand}${STOP_COLOR}..."
      return
    fi

    question --yes-no "Is ${YELLOW}${branch}${STOP_COLOR} the correct branch?"
    read response

    if [[ $response != "y" ]]; then
      question "Enter branch name:" -d branch_name

      if [[ -z $branch_name ]]; then
        error "Response was empty.\n${INDENT}Cancelling push process for ${RED}${brand}${STOP_COLOR}..."
        return
      else
        add-space
        branch=$branch_name
        ez-branch $branch
      fi
    fi
  fi

  question --yes-no "Do you want to push to ${YELLOW}${branch}${STOP_COLOR} for ${YELLOW}${brand}${STOP_COLOR}?"
  read response

  if [[ $response = "y" ]]; then
    msg "${italic}processing push...${STOP_ITALIC}"
    add-space
    local branch_remote=`is-branch-remote $branch`

    if [[ -n $branch_remote ]]; then
      git push
    else
      git push --set-upstream origin $branch
    fi
  else
    alert "Cancelling push process for ${SKYBLUE}${brand}${STOP_COLOR}..."
    return
  fi
}

# @cmd Open a link to create a pull request
# @option -p|--parent-branch Parent branch name to use for new pull requests
# @flag -b|--batch Part of a batch of brand/project commits and skips branch check
function ez-super-pr() {
  local brand=${PWD##*/}
  local branch=`get-current-branch`
  local origin=`git config --get remote.origin.url`
  local url="${origin/%'.git'}"
  local parent_branch=""
  local pr_message="view pull requests"
  local batch=false

  while [ $# -gt 0 ]; do
    case $1 in
      -p | --parent-branch) 
        if has-flag-arg $@; then
          parent_branch=$(get-flag-arg $@)
          shift
        fi
        ;;
      -b | --batch) 
        batch=true
        ;;
    esac

    shift
  done

  if [[ $batch = false ]]; then
    local pr_type=""
  fi

  if [[ -z $pr_type || $batch = true && -z $pr_type ]]; then
    local options=(
      "new"
      "existing"
      "cancel"
    )

    question "What type of pull request do you need for ${YELLOW}${brand}${STOP_COLOR}?" --options "${(j:,:)options}"
    read response

    case $response in
      [1-2]*) pr_type="${options[$response]}";;
      *) ;;
    esac
  fi

  if [[ $pr_type = "new" ]]; then
    url="${url}/compare/"

    if [[ -n $parent_branch ]]; then
      url="${url}${parent_branch}..."
    fi

    url="${url}${branch}"
    pr_message="create a pull request"
  elif [[ $pr_type = "existing" ]]; then
    url="${url}/issues?q=is%3Aopen+is%3Apr+author%3A%40me"
  else
    alert "Cancelling pull request process for ${SKYBLUE}${brand}${STOP_COLOR}..."
    return
  fi

  alert "The URL below can be used to ${pr_message} for ${SKYBLUE}${brand}${STOP_COLOR}.\n${INDENT}${SKYBLUE}${url}${STOP_COLOR}"
  open $url
}

# @cmd Run the commit, push, and pull request commands
# @option -p|--parent-branch Parent branch name to use for new pull requests (passed to ez-super-commit)
# @flag -b|--batch Part of a batch of brand/project commits and skips branch check (passed to ez-super-pr)
function ez-super-duper() {
  local brand=${PWD##*/}
  local parent_branch=""
  local batch_flag=""

  while [ $# -gt 0 ]; do
    case $1 in
      -p | --parent-branch) 
        if has-flag-arg $@; then
          parent_branch=$(get-flag-arg $@)
          shift
        fi
        ;;
      -b | --batch) 
        batch_flag="--batch"
        ;;
    esac

    shift
  done

  ez-super-commit $batch_flag
  ez-super-push --skip-check
  ez-super-pr --parent-branch $parent_branch
}

# @cmd Merge a branch into another, handle merge conflicts, and optionally push changes to remote
# @arg source_branch Branch to merge into the target branch
# @arg target_branch Branch to merge the source branch into
# @flag -s|--skip-push Skip pushing changes to remote
function ez-merge() {
  # set default values
  local skip_push=false
  local source_branch=""
  # get the current branch you're on
  local target_branch=`get-current-branch`
  # get the brand you ran this command from
  local brand=${PWD##*/}

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
    error "${RED}Source branch${STOP_COLOR} must be specified."
    return
  fi
  
  # gut check for correct source branch, feature branch, and brand
  question --yes-no "Merge ${YELLOW}origin/${source_branch}${STOP_COLOR} into ${YELLOW}${target_branch}${STOP_COLOR} for ${YELLOW}${brand}${STOP_COLOR}?"
  read response

  # stop command if the above info was incorrect
  if [[ $response != "y" ]]; then
    alert "Skipping merge process for ${SKYBLUE}${brand}${STOP_COLOR}..."
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
    alert "There are no changes that need merged."
    return
  fi

  # merge source branch into target branch
  add-space
  processing "merging"
  git merge origin/$source_branch

  # merge conflicts exist
  if [[ $? -ne 0 ]]; then
    # offer to wait while you handle merge conflicts
    question "Once all merge conflicts have been resolved, enter ${SKYBLUE}\"y\"${STOP_COLOR} to stage all changes and move forward or ${RED}\"n\"${STOP_COLOR} to cancel.\n${INDENT}Response:"
    read response

    # stop command if you didn't enter "y"
    if [[ $response != "y" ]]; then
      alert "Cancelling commit and push process for merge..."
      return
    else 
      # stage all changes and attempt to commit
      processing "staging all changes and committing"
      add-space
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
        question "Do you want to run 'yarn install' and/or 'yarn build' and try to commit again?" --options "${(j:,:)options}"
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
            alert "Cancelling commit and push process for merge..."
            return
            ;;
        esac

        # stage all changes and attempt to commit
        processing "staging all changes and committing"
        git add .
        git commit -m "Merged '$source_branch' into '$target_branch'"

        # stop command if commit failed again
        if [[ $? -ne 0 ]]; then
          error "Commit attempt failed again. Please look at logs for further details."
        fi
      fi
    fi
  fi

  # push changes to remote if not skipped
  if [[ $skip_push = false ]]; then
    add-space
    processing "pushing merge commits"
    git push

    # display final success/failure messages
    if [[ $? -ne 0 ]]; then
      error "Push attempt failed. Please look at logs for further details."
    fi
  fi

  # display final success message
  success "Merge complete."
}

# @cmd Loops through brands, changes to the correct branch, and runs specified commands while passing predefined values like the parent branch
# @option -bs|--brands Brands to loop through
# @option -b|--branch Branch to use for current update
# @option -pb|--parent-branch Parent branch for current update
# @option -mpb|--mantle-parent-branch Parent branch for mantle
# @option -c|--commands Commands to run for each brand
function _ez_ticket() {
  local brands=()
  local branch=""
  local parent_branch=""
  local mantle_parent_branch=""
  local commands=""

  while [ $# -gt 0 ]; do
    case $1 in
      -bs | --brands) 
        if has-flag-arg $@; then
          brands=(${(@s: :)$(get-flag-arg $@)})
          shift
        fi
        ;;
      -b | --branch)
        if has-flag-arg $@; then
          branch=$(get-flag-arg $@)
          shift
        fi
        ;;
      -pb | --parent-branch)
        if has-flag-arg $@; then
          parent_branch=$(get-flag-arg $@)
          shift
        fi
        ;;
      -mpb | --mantle-parent-branch)
        if has-flag-arg $@; then
          mantle_parent_branch=$(get-flag-arg $@)
          shift
        fi
        ;;
      -c | --commands)
        if has-flag-arg $@; then
          commands=$(get-flag-arg $@)
          shift
        fi
        ;;
    esac

    shift
  done

  # start error management
  local errors=""

  if [[ -z $brands ]]; then
    errors="\n${INDENT}Brands array cannot be empty."
  fi

  if [[ -z $branch ]]; then
    errors="${errors}\n${INDENT}Branch name cannot be empty."
  fi

  if [[ -z $parent_branch ]]; then
    errors="${errors}\n${INDENT}Parent branch cannot be empty."
  fi

  if [[ -n $errors ]]; then
    error "Cancelling. Look below for details.\n${RED}${errors}${STOP_COLOR}"
    return
  fi
  # end error management

  if [[ -z $commands ]]; then
    local build_brands=""
    local options=(
      "yarn build"
      "yarn install && yarn build"
      "gradle clean build --refresh-dependencies"
      "yarn install && yarn build && gradle build publishToMavenLocal"
      "yarn install && yarn build && gradle clean build --refresh-dependencies"
      "no"
    )

    question "Do you want to run any builds?" --options "${(j:,:)options}"
    read response

    case $response in
      [1-5]*) build_brands="${options[$response]}";;
      *) ;;
    esac
  fi

  for brand in $brands; do
    local brand_parent_branch=$parent_branch
    if [[ $brand = "mantle" && -n $mantle_parent_branch ]]; then
      brand_parent_branch=$mantle_parent_branch
    fi

    _brand_before $brand
    ez-branch $branch $brand_parent_branch
  
    if [[ -z $commands && -n $build_brands ]]; then
      eval $build_brands
    else
      if [[ $commands = "ez-super-push" || $commands = "ez-super-pr" || $commands = "ez-super-duper" ]]; then
        eval $commands --batch --skip-check --parent-branch $brand_parent_branch
      elif [[ $commands = "ez-super-commit" ]]; then
        eval $commands --batch
      else
        eval $commands
      fi
    fi

    _brand_after
  done

  # reset pull request type selection
  pr_type=""
}

# @cmd Command template for switching to the needed environments for a ticket/update
# @arg <commands> The command(s) to run on each brand/project
function ez-ticket-template() {
  # start config
  local mantle_parent_branch=""
  local parent_branch=""
  local branch=""
  local brands=()
  # end config

  _ez_ticket --mantle-parent-branch "${mantle_parent_branch}" --parent-branch "${parent_branch}" --branch "${branch}" --brands "${brands}" --commands "${*}"
}
