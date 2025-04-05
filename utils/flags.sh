#!/usr/bin/env zsh

# @describe Utility functions related to Zsh command flags

# @func Checks if a flag contains an argument
function _has_flag_arg() {
  [[ ("$1" == *=* && -n ${1#*=}) || ( ! -z "$2" && "$2" != -*)  ]];
}

# @func Returns a flag's argument
function _get_flag_arg() {
  print "${2:-${1#*=}}"
}

