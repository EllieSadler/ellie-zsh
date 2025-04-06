# Common Zsh Code Snippets

The code examples in this document are to help empower you to modify and create your own commands that fit you and your workflow.

For additional resources, you can check out this [Zsh cheatsheet](https://gist.github.com/ClementNerma/1dd94cb0f1884b9c20d1ba0037bdcde2) or this [Bash cheatsheet](https://devhints.io/bash) (Zsh is compatible with Bash for the most part).

> #### **Table of Contents**
> 
> 1. [Open a URL in a browser](#open-a-url-in-a-browser)
> 2. [Modify text styling](#modify-text-styling)
> 3. [Make text bold](#make-text-bold)
> 4. [Underline text](#underline-text)
> 5. [Add color to text](#add-color-to-text)
> 6. [Create local variable and update](#create-local-variable-and-update)
> 7. [Get input value](#get-input-value)
> 8. [Get input value (alt)](#get-input-value-alt)
> 9. [Get input value (alt) 2](#get-input-value-alt-2)
> 10. [Get y/n response](#get-y-n-response)
> 11. [Get y/n response as part of if statement](#get-y-n-response-as-part-of-if-statement)
> 12. [Check for y/n response with colored text](#check-for-y-n-response-with-colored-text)
> 13. [Check if value is defined and not empty](#check-if-value-is-defined-and-not-empty)
> 14. [Check if value is not defined or empty](#check-if-value-is-not-defined-or-empty)
> 15. [Create a select menu](#create-a-select-menu)
> 16. [Pass and receive flagged arguments](#pass-and-receive-flagged-arguments)

## 1. Open a URL in a browser

``` sh
open "https://google.com"
```

## 2. Modify text styling

When adding styles, think of it the same you would an HTML style tag: it needs an opening and closing tag. In this case, the opening tag is uppercase and the closing tag is lowercase. The following style options work with `vared` as well as `print -P`.

## 3. Make text bold

``` sh
print -P "This text is bland, %Bbut this text is bold!%b"
```

## 4. Underline text

``` sh
print -P "This text is bland, %Ubut this text is underlined!%u"
```

## 5. Add color to text

If you use this but don’t specify a color, it defaults to blue.

If you have Oh My Zsh installed, you can run the command `spectrum_ls` to output a list of all the color codes with an example of text in that color.

``` sh
print -P "not colored - %4F{002}colored%4f - not colored"
# OR
print -P "not colored - %4Fcolored%4f - not colored"
```

## 6. Create local variable and update

Variable values set this way will not persist outside of the command it’s used in because of the use of `local` on `line 1`. Removing the use of `local` on this or any of the following examples will allow the value/response to persist outside of the command.

``` sh
local branchName="test"
branchName="new-test"
print "branchName: $branchName"
```

## 7. Get input value

``` sh
local branchName
read "branchName?Enter branch name: "
print "branchName: $branchName"
```

## 8. Get input value (alt)

``` sh
local branchName
print -n "Enter branch name: "
read branchName
print "branchName: $branchName"
```

## 9. Get input value (alt) 2

``` sh
local branchName
vared -p "Enter branch name: " -c branchName
print "branchName: $branchName"
```

## 10. Get y/n response

``` sh
local choice
read -q "choice?Y/N question? "
print "user's response: $choice"
```

## 11. Get y/n response as part of if statement

``` sh
if read -q "?Y/N: "; then
  print "user responded with \"y\""
else
  print "user responded with \"n\""
fi
```

## 12. Check for y/n response with colored text

``` sh
local answer
print -n -P "Commit to %4F{green}projectname%4f and push? y/n: "
read answer
if [ $answer = "y" ]; then
  print "user responded with \"y\""
fi
```

## 13. Check if value is defined and not empty

``` sh
if [[ -n $branchName ]]; then
  print "branchName is defined and not empty"
fi
```

## 14. Check if value is not defined or empty

``` sh
if [[ -z $branchName ]]; then
  print "branchName is not defined or is empty"
fi
```

## 15. Create a select menu

[This article](TODO:add-link) has a helpful breakdown on how to create a select menu and the different options available, but below is an example of what you will likely use the most.

An additional way to accomplish this can be found in the select-option utility function ([see section](TODO:add-link)).  

``` sh
local items=(
  "option one"
  "option two"
  "option three"
)
print "Which option works best?"
PS3="Response: "
select item in "${items[@]}"; do
  case $REPLY in
    1)
      print "You chose: $item" # prints "You chose: option one"
      break;;
    [2-3]*)
      print "You chose: $REPLY" # prints "You chose: 2" or "You chose: 3"
      break;;
    *) break;; # only exits question
  esac
done
```

## 16. Pass and receive flagged arguments

Below is an example of how to pass and receive flags and flag arguments.

> **Note:** Arguments are received as a single item. This is why you need to pass arrays as strings and convert after receiving the passed array.

For additional information, you can review this [Master Flag Handling in Bash Scripts article](https://medium.com/@wujido20/handling-flags-in-bash-scripts-4b06b4d0ed04).

``` sh
receive-arguments() {
  local repos=()
  local branch=""
  local run_builds=false
  # add ":" after any flag that will receive an argument (seen in "a" and "b")
  while getopts 'a:b:c' flag; do
    case $flag in
      a) repos=(${(@s: :)OPTARG});; # convert to array from string
      b) branch="${OPTARG}";;
      c) run_builds=true;;
    esac
  done
}
pass-arguments() {
  local repos=(
    "allrecipes"
    "eatingwell"
    "bhg"
  )
  receive-arguments -c -a "${repos}" -b "feature/XYZ-ticket"
}
```

Another method to receive flagged arguments is the `while [ $# -gt 0 ]` loop that utilizes `shift` to shift the positional arguments.

This example doesn’t include full error handling for instances where a flag that is expecting an argument doesn’t receive one.

Additionally, depending on your usage, the order in which you pass commands matters.

For a more robust example that covers the two above scenarios, see [Run commands on multiple repos](TODO:add-link).

``` sh
receive-arguments() {
  local repos=()
  local branch=""
  local run_builds=false
  while [ $# -gt 0 ]; do
    case $1 in
      -r | --repos)
        repos=$2
        shift
        ;;
      -g | --git-branch)
        branch=$2
        shift
        ;;
      -r | --run-builds)
        run_builds=true
        ;;
      *)
        print "Invalid option: $1"
        return
        ;;
    esac
    shift
  done
}
pass-arguments() {
  local repos=(
    "allrecipes"
    "eatingwell"
    "bhg"
  )
  receive-arguments -r -b "${repos}" -g "feature/XYZ-ticket"
}
```
