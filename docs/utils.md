# Utility Commands and Configs

This document contains some utility commands and configs that can be helpful for creating and editing your own custom Zsh commands or can be found in the commands listed on Custom Commands to Improve Workflow or this page.

> #### Table of Contents
> 
> - **`.zshrc` functions**
>   - [Open .zshrc in code editor](#open-zshrc-file-in-code-editor--edit-zsh) — `edit-zsh`
>   - [Apply .zshrc changes](#apply-zshrc-changes--ez-reload) — `ez-reload`
> - **Output-related functions**
>   - [Print styles and formatting](#print-styles-and-formatting)
>   - [Add space between outputs](#add-space-between-outputs--_add_space) —` _add_space`
>   - [Add horizontal line that spans entire window](#add-horizontal-line-that-spans-entire-window--_divider) — `_divider`
>   - [Print message](#print-a-message--_msg) — `_msg`
>   - [Print error](#templated-messages--_error-_success-_processing-_warn-_alert) — `_error`
>   - [Print success](#templated-messages--_error-_success-_processing-_warn-_alert) — `_success`
>   - [Print processing](#templated-messages--_error-_success-_processing-_warn-_alert) — `_processing`
>   - [Print warning](#templated-messages--_error-_success-_processing-_warn-_alert) — `_warn`
>   - [Print alert](#templated-messages--_error-_success-_processing-_warn-_alert) — `_alert`
>   - [Ask question](#ask-a-question--_question) — `_question`
> - **Get/check value functions**
>   - [Get current git branch](#get-current-git-branch--_get_current_branch) — `_get_current_branch`
>   - [Check if a branch exists locally](#check-if-a-branch-exists-locally--_is_branch_local) — `_is_branch_local`
>   - [Check if a branch exists remotely](#check-if-a-branch-exists-remotely--_is_branch_remote) — `_is_branch_remote`
>   - [Check if local branch is up-to-date with remote](#check-if-local-branch-is-up-to-date-with-remote--_is_branch_up_to_date) — `_is_branch_up_to_date`
>   - [Check if there are uncommitted changes](#check-if-there-are-uncommitted-changes--_has_uncommitted_changes) — `_has_uncommitted_changes`
>   - [Check if there are unstaged changes](#check-if-there-are-unstaged-changes--_has_unstaged_changes) — `_has_unstaged_changes`
>   - [Check if a flag has an argument](#check-if-a-flag-has-an-argument--_has_flag_arg) — `_has_flag_arg`
>   - [Get an argument for a flag](#get-an-argument-for-a-flag--_get_flag_arg) — `_get_flag_arg`


## Open `.zshrc` file in code editor — `edit-zsh`

If you use VSCode, you can use the `code` command to open files or folders in your editor instead of needing to locate the file and choosing to open it in your editor.

> **Troubleshooting Steps**
> 
> 1. Verify VSCode is in your Applications folder.
> 
> 2. Install `command` function
>   a. Open VSCode
>   b. Open the Command Palette via ⌘⇧P and type `shell command` to find `Shell Command: Install 'code' command in PATH`.

## Apply `.zshrc` changes — `ez-reload`

After you make changes to your `.zshrc` file, you’ll need to `ez-reload` or open a new window. Use the function below to quickly apply changes with a memorable command name.

There's a fun extension of the above command for _Star Wars_ fans: `execute-order-66`.

## Print styles and formatting

These are values for starting and stopping certain text styles or adding an indent inside a print message.

For additional information on adding styles to your print messages, [Common Code Snippets > Modify text styling](./zsh.md#2-modify-text-styling) goes into more detail.

## Add space between outputs — `_add_space`

For legibility in your terminal outputs, you’ll want to add additional space. Use the below codes instead of using `print ""`. Having a named function allows your code to be less cluttered and more legible.

## Add horizontal line that spans entire window — `_divider`

Used to add a visual delineator between sections that is the full width of the terminal.

## Print functions

The following print functions allow you to standardize and simplify printing messages. Additionally; `_msg`, `_error`, `_success`, `_processing`, `_warn`, `_alert` and `_question` are a lot more informative than `print`.

### Print a message — `_msg`

```
_msg [-n|--no-newline] <message>
```

`-n|--no-newline`
Prevents the addition of a newline after printed message. Typically used when waiting for a user’s input to a question.
`_msg -n "Enter branch name:"`

`<message>`
Specifies the text to be printed.
`_msg "Skipping process..."`

### Templated messages — `_error`, `_success`, `_processing`, `_warn`, `_alert`

```
_error <message>
_success <message>
_processing <message>
_warn <message>
_alert <message>
```

`<message>`
Specify the main message to insert into that command's existing message.

`_error "Error preventing completion."`
❌ Error preventing completion.

`_success "Successfully completed!"`
✅ Successfully completed!

`_processing "processing a command"`
🔄 _processing a command..._

`_warn "Pay attention to this."`
🟠 Pay attention to this.

`_alert "Basic alert message."`
🔼 Basic alert message.

### Ask a question — `_question`

```
_question <message> [-y|--yes-no] [-d|--default <default>] [-o|--options <options>]
```

`<message>`
Specify the main message to insert into that command's existing message.
`_question "What is your name?`

`-y|--yes-no`
Append the printed message with help text for yes/no questions.
`_question -y "Continue running command?"`

`-d|--default`
By passing a <default> variable name, this will use the vared command which allows you to set a default value and allows this variable’s value to persist outside of the command it’s used in.
`_question "Branch name:" -d branch_name`
This can be used alongside the `-y|--yes-no` flag.
`_question "Branch name:" -y -d branch_name`

`-o|--options`
`<options>` is a list of options to provide the user — `,` is used as the delimiter.

``` sh
local options="option one,option two,special option,quit"
_question "..." --options "${options}"
read response
# OR
local options=(
  "option one"
  "option two"
  "special option"
  "quit"
)
_question "..." --options "${(j:,:)options}"
read response
```

The use of `_add_space` before and after messages is to allow for proper spacing in the terminal; however, it's not added after printing a question to allow user input to show next to the question instead of below it.

## Get current git branch — `_get_current_branch`

## Check if a branch exists locally — `_is_branch_local`

## Check if a branch exists remotely — `_is_branch_remote`

## Check if local branch is up-to-date with remote — `_is_branch_up_to_date`

## Check if there are uncommitted changes — `_has_uncommitted_changes`

## Check if there are unstaged changes — `_has_unstaged_changes`

## Check if a flag has an argument — `_has_flag_arg`

## Get an argument for a flag — `_get_flag_arg`
