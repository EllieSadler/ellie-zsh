# ellie-zsh

A collection of Zsh commands to help engineers.

## Naming Conventions

### Common Names for Args, Flags, and Options

- repo(s)
    - `$repo`
    - `$repos`
    - `r|--repo`
    - `r|--repos`
- branch
    - `$branch`
    - `-b|--branch`
- parent branch
    - `$parent_branch`
    - `-p|--parent-branch`
- source branch
    - `$source_branch`
    - `-s|--source-branch`
- target branch
    - `$target_branch`
    - `-t|--target-branch`
- skip check (maybe remove entirely or rename)
- batch (maybe rename to group)
- command(s)
    - `$commands`
    - `-c|--commands`

``` sh
GLOBAL_VARIABLE=""
local local_variable=""

alias alias-command=""
function _utility_function() {}
function command-line-function() {}
```

## Documentation Standards

``` sh
# @describe Describes a file's purpose
# @func Describes a utility function
# @cmd Describes a command line function

# @option -o|--option-arg <option-arg> Describes an flagged argument
# @flag -f|--flag Describes a flag
# @arg <argument> Describes an argument
```

## Installation
TBD

## Usage
TBD

## Documentation

Simple documentation for everything included in this plugin can be found above the code you're looking at. 

More verbose documentation and usage instructions can be found in the following docs:

- [Utility Commands and Configs](./docs/utils.md)
- [Commands to Improve Workflow](./docs/commands.md)

If you're interested in writing your own custom commands and want an easy reference for common code snippets, you can reference the [Common Zsh Code Snippets](./docs/zsh.md) doc.

## Future Updates

[ ] create a new init command that creates a new file that's in the `.gitignore` that will include the personal consts from `./consts.sh`

[ ] investigate `verify` variable from `./commands/ez-batch.sh` to see if you want to do something different with it

[ ] in `./commands/ez-changelog.sh`
1. add a question for waiting while the user updates the `package.json` file, then run `git add package.json`
2. see if you can automate version change in `package.json` file

[ ] create command to create a new ticket command and file in `./commands/ez-new-ticket.sh`

[ ] fill in "Installation" section of `README.md`

[ ] fill in "Usage" section of `README.md`

[ ] expand on "Common Names for Args, Flags, and Options" section of `README.md` for common args and options
