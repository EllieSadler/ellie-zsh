# Custom Zsh Commands to Improve Workflow

> #### Table of Contents
> 
> 1. [Run commands on multiple repositories](#1-run-commands-on-multiple-repositories--ez-batch) — `ez-batch`
> 2. [Switch branches (or create new branch)](#2-switch-branches-or-create-new-branch--ez-branch) — `ez-branch`
> 3. [Run through the full merge flow](#3-run-through-the-full-merge-flow--ez-merge) — `ez-merge`
> 4. [Run through commit process](#4-run-through-commit-process--ez-commit) — `ez-commit`
> 5. [Run through push process](#5-run-through-push-process--ez-push) — `ez-push`
> 6. [Open pull request link](#6-open-pull-request-link--ez-pr) — `ez-pr`
> 7. [Run through commit, push, and pull request processes](#7-run-through-commit-push-and-pull-request-processes--ez-super-duper) — `ez-super-duper`
> 8. [Switch between ticket/update workflows](#8-switch-between-ticketupdate-workflows--ez-ticket) — `ez-ticket`

## 1. Run commands on multiple repositories — `ez-batch`

Reference the [Run commands on multiple repositories section](TODO:add-link) for the code and documentation on the `ez-batch` command that allows you to run one or more commands on multiple repositories.

## 2. Switch branches (or create new branch) — `ez-branch`

This command is used to switch to a different branch. It contains logic to silently abort if already on branch, create a new branch, and to switch to a parent branch if specified before creating a new branch.

```
ez-branch <branch> [<parent-branch>]
```

`<branch>`
Use `<branch>` to specify the branch you want to switch to.
`ez-branch feature/XYZ-123-ticket`

`<parent-branch>`
If you provide a parent branch (and the branch you specified does not already exist), it will checkout and pull from that branch before creating your new branch.
`ez-branch feature/XYZ-123-ticket release/1.2.3`

## 3. Run through the full merge flow — `ez-merge`

This command runs through the full flow needed to handle a merge on the current branch and repository you’re on. This includes fetching and merging the remote branch into your local branch, waiting while you resolve any conflicts, allowing you to choose to run `yarn install` and/or `yarn build` if initial commit fails, staging all changes made, committing with a predefined message, and pushing all commits.

```
ez-merge <source-branch>
```

`<source-branch>`
Specifies the branch you plan to merge into your current branch.
`ez-merge master`

### 4. Resolve a pull request’s conflicts — `ez-pr-conflict`

This command is an extension of `ez-merge` primarily meant to be used for pull requests that are blocked because there are conflicts that need resolved. It switches branches if necessary and pulls the remote on the target branch so your local is updated with all auto merges that may have happened from your open pull request.

```
ez-pr-conflict <source-branch> [<target-branch>]
```

`<source-branch>`
Specifies the branch you plan to merge into your current or specified branch.
`ez-pr-conflict master`

`<target-branch>`
If you provide a branch name, it will checkout that branch before pulling from the remote and starting the merge process.
`ez-pr-conflict master feature/XYZ-123-ticket`

## 4. Run through commit process — `ez-commit`

This command is used to go through the commit process. This could include showing you the current git status, staging changes, switching branches, and entering the commit message.

```
ez-commit [-s|--skip-check] [-b|--batch]
```

`-s|--skip-check`
When present, it skips the initial check to see if you want to move forward in the commit process for the current repository. This can be applied by default by updating skip_check on `line 4` to true.
`ez-commit --skip-check`

`-b|--batch`
When present, it skips asking if you are on the correct branch and offering the option to change branches while inside the command. This flag is useful inside other commands like ez-ticket that switches each repository to the specified branch before running any commands.
`ez-commit --batch`

#### Command breakdown, configuration and usage

There are two configuration options inside the function that you can update depending on your needs.

`skip_changelog`
This is currently set to false which includes a step during the commit process to add a changelog file if you forgot to do so. If you would like to disable this step, you can change this to true on `line 4`.

`skip_check`
This determines whether you get asked a yes/no question before continuing with the commit process. The question provides you with the repository name. This step is most helpful when running this command on a list of repositories where you may not want to go through the full process on every repository (`ez-batch` or `ez-ticket` for example).
This variable is set to `false` by default to provide an early out, but you can set this to `true` on `line 5` in order to skip this check.

## 5. Run through push process — `ez-push`

This command is used to go through the push process. This could include switching branches before pushing to a new or existing remote branch.

```
ez-push [-s|--skip-check]
```

`-s|--skip-check`
When present, it skips the initial check to see if you want to move forward in the push process for the current repository and skips the option to verify and switch branches while in the command. This can be applied by default by updating skip_check on line 4 to true.
`ez-push --skip-check`

## 6. Open pull request link — `ez-pr`

This command is used to assemble a pull request URL and open it in your browser. This works for creating a new pull request or viewing existing pull requests for the current repository.

```
ez-pr [-p|--parent-branch <parent-branch>] [-b|--batch]
```

`-p|--parent-branch <parent-branch>`
If you provide a parent branch, it will use this information when assembling the pull request URL for a new pull request.
`ez-pr -p release/1.2.3`

`-b|--batch`
Make `pr_type` initial response available in the future. Useful when performing this function on several repositories at once.
> Warning Note: to reset the value, you need to open a new window/tab or restart your terminal (see [apply .zshrc changes custom command](TODO:add-link)).
`ez-pr -b`

#### Command breakdown, configuration and usage

There is one configuration option inside this function that you can update depending on your needs.

`username`
**location:** `line 8`
**default:** `""`

A string that defines your GitHub username. If present and not empty, this updates the URL when choosing to view existing pull requests; it will result in a URL for all of your open pull requests for that repository.

## 7. Run through commit, push, and pull request processes — `ez-super-duper`

This command is used to run the above commands to commit, push, and open a pull request link. By default, it skips the checks on `ez-push` since you will have previously verified you’re on the correct branch and plan to go through with the push process since you’re running this command. It also passes the parent branch name to the `ez-pr` command if it’s passed to this command.

```
ez-super-duper [-p|--parent-branch <parent-branch>] [-b|--batch]
```

`-p|--parent-branch <parent-branch>`
If you provide a parent branch, it will use this information when assembling the pull request URL for a new pull request.
`ez-super-duper -p release/1.2.3`

`-b|--batch`
When present, it adds the `--batch` flag to `ez-commit`. This flag is useful inside other commands like `ez-ticket` that switches each repository to the specified branch before running any commands.
`ez-super-duper --batch`

## 8. Switch between ticket/update workflows — `ez-ticket`

This command is used to quickly and easily start or switch to working on a different ticket or update.

``` 
ez-ticket [<commands>]
```

`<commands>`
The command or commands to run on each repository. When chaining commands, pass as a string.
`ez-ticket yarn install`
`ez-ticket "yarn install && yarn build"`

#### Command breakdown, configuration and usage

If you need to pass a quoted string as part of a command to run in each of your repositories, you need to wrap it in single quotes (or vice versa) to ensure it stays quoted.

✅ Correct
``` sh
ez-ticket git commit -m '"commit message"'
ez-ticket git commit -m "'commit message'"
```
Would run `git commit -m "commit message"` in each repository.

❌ Incorrect
``` sh
ez-ticket git commit -m "commit message"
ez-ticket git commit -m 'commit message'
```
Would run `git commit -m commit message` in each repository.

There are two commands essential for this to work: `ez-ticket` and `_ez_ticket`.

`_ez_ticket`
You can leave this alone as it only houses the brains for `ez-ticket`.

`ez-ticket`
This is the command that you will copy, paste and modify for each ticket you’re working on. Keep this function as is for quick and easy initialization of a new ticket command.

There are four configuration options inside this function that you can update depending on your needs — three of which are required and stated as such below.

`repos` _*required_
**location:** `line 6`
**default:** `()`
An array of repositories (using their GitHub/folder names) that defines which repositories are included in your current ticket/update and which repositories to run the passed commands on.

`branch` _*required_
**location:** `line 5`
**default:** `""`
Specifies what the branch name will be for the ticket/update you’re working on. When running this command, it will automatically switch each repository in your repositories array to this branch (creating a new branch based on the `parent_branch` values if necessary).

`parent_branch` _*required_
**location:** `line 4`
**default:** `""`
Specifies what the parent branch name is for all repositories for the ticket/update you're working on. When running this command (if branch doesn’t already exist), it will automatically checkout this branch before creating the new one for this ticket/update.

#### New ticket setup steps

1. Duplicate `ez-ticket`

2. Rename this duplicated function
    - I suggest keeping the `ez-` prefix for consistency and making sure you’re not accidentally overriding an existing function.
    - A few recommendations are based on ticket name, branch name, or repo and update: `ez-xyz-123`, `ez-xyz-123-keywords`, `ez-repo-keywords`

3. It can be helpful to add a comment above your ez-ticket commands with useful information like a link to the ticket or a brief description of what this command’s update is for.

4. Add the repositories you’ll be working with for this ticket to the empty `repos` array

5. Add the branch name for this ticket’s update to branch

6. Add the parent branch name to parent_branch

7. Apply your .zshrc changes (options to do so below)
    - open new terminal window
    - `source ~/.zshrc`
    - `exec zsh`
    - `reload` ([see section](TODO:add-link))

You can now use your new `ez-ticket` command!

#### Example Usages

```
ez-ticket
```

After initially setting up your new `ez-ticket` command or when switching back to it after working on a different ticket, I recommend running the command without passing any prompts.

This will provide you with the option to choose between three different types of builds. This can be helpful with dependency changes, but you can choose to not run any builds.

- `yarn build`
- `yarn install && yarn build`

You can pass additional commands to this function similar to `ez-batch`, except with this command, you don’t have to worry about updating or passing an array of repositories because you already specified them for this ticket’s work.

#### Additional example usages:

``` sh
# loops through ticket repositories
# provides option to build in each repository
# switches to specified branch in each repository
ez-ticket

# loops through ticket repositories
# switches to specified branch in each repository
# runs a single command in each repository
ez-ticket ez-build
ez-ticket yarn install
ez-ticket git commit -m '"XYZ-ticket brief description"'

# loops through ticket repositories
# switches to specified branch in each repository
# runs multiple commands in each repository
ez-ticket "yarn install && yarn build"
ez-ticket "ez-build && ez-changelog 'brief description' 'XYZ-test-ticket'"
ez-ticket 'git add . && git commit -m "XYZ-ticket brief description"'
```
