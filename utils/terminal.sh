#!/usr/bin/env zsh

# @describe Utility functions for this plugin

# @cmd Opens a folder or file in vscode
# @arg <path> Path of the file or folder to open in VSCode
function ez-edit() {
  # if zsh shortcode
  if [ $1 = "zsh" ]; then
    code ~/.zshrc
  # open from path provided
  elif [[ -z $1 ]]; then
    code $GIT_DIR/$1
  # default to this plugin
  else
    code $GIT_DIR/ellie-zsh/
  fi
}

# @cmd Source ~/.zshrc file to load zsh changes
function ez-reload() {
  source ~/.zshrc
}

# @cmd Outputs a Star Wars quote and reloads terminal (because I'm a nerd and hopefully you are too) 
function execute-order-66() {
  _add_space
  _msg "${GREY}DS: \"Commander Cody, the time has come. Execute Order 66.\"${STOP_COLOR}"
  _msg "${GREY}CC: \"Yes, my Lord.\"${STOP_COLOR}"
  ez-reload
}
