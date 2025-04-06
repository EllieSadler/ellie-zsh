#!/usr/bin/env zsh

# @describe Utility functions and consts related to printing messages or asking questions

# Color variables
GREY=%4F{000}
RED=%4F{009}
ORANGE=%4F{208}
YELLOW=%4F{011}
GREEN=%4F{010}
BLUE=%4F{012}
SKYBLUE=%4F{117}
PURPLE=%4F{013}
STOP_COLOR=%4f

# Text style variables
BOLD=%B
STOP_BOLD=%b
UNDERLINE=%U
STOP_UNDERLINE=%u
ITALIC="%{\e[3m%}"
STOP_ITALIC="%{\e[23m%}"

# Enough spaces to indicate an indent
INDENT="   "

# @func Prints an empty line
function _add_space() {
  print ""
}

# @func Prints a divider that spans entire terminal width
function _divider() {
  printf '%.s─' $(seq 1 $(tput cols))
}

# @func Prints the passed text
# @arg <message> Text to print
# @flag -n|--no-newline Print without a new line
function _msg() {
  local no_newline=""
  local message=""

  # check for flag and arg and update local variables
  while [ $# -gt 0 ]; do
    case $1 in
      -n | --no-newline) 
        no_newline="-n"
        ;;
      *) message=$1;;
    esac
    shift
  done

  # print message
  print $no_newline -P "${message}"
}

# @func Prints the passed error message prepended by an error icon and empty lines before and after
# @arg <message> Error message to print
function _error() {
  _add_space
  _msg "❌ $1"
  _add_space
}

# @func Prints the passed success message prepended by a success icon and empty lines before and after
# @arg <message> Success message to print
function _success() {
  _add_space
  _msg "✅  $1"
  _add_space
}

# @func Prints the passed processing message in italics, prepended by a processing icon, appended by ellipses, and empty lines before and after
# @arg <message> Processing message to print
function _processing() {
  _add_space
  _msg "🔄 ${ITALIC}$1...${STOP_ITALIC}"
  _add_space
}

# @func Prints the passed warning message prepended by a warning icon and empty lines before and after
# @arg <message> Warning message to print
function _warn() {
  _add_space
  _msg "🟠  $1"
  _add_space
}

# @func Prints the passed alert message prepended by an alert icon and empty lines before and after
# @arg <message> Alert message to print
function _alert() {
  _add_space
  _msg "🔼 $1"
  _add_space
}

# @func Prints the passed question message with a question icon, empty lines before and after, and passed settings
# @arg <message> Question message to print
# @flag -y|--yes-no Include yes/no text in the message
# @option -d|--default <default-response> Default value that allows the user's submitted value to persist outside this instance
# @option -o|--options <output_file> An array of answers the user can select
function _question() {
  local message=""
  local yes_no=""
  local default=""
  local options=()

  # check for flags and args and update local variables
  while [ $# -gt 0 ]; do
    case $1 in
      -y | --yes-no) 
        yes_no="${GREY}[y/n]${STOP_COLOR} "
        ;;
      -d | --default) 
        if _has_flag_arg $@; then
          default=$(_get_flag_arg $@)
          shift
        fi
        ;;
      -o | --options) 
        if _has_flag_arg $@; then
          options=(${(@s:,:)"$(_get_flag_arg $@)"})
          shift
        fi
        ;;
      *) message=$1;;
    esac
    shift
  done

  # set message text w/ or w/o yes/no text
  message="🟡 ${message} ${yes_no}"
  _add_space

  # options exist
  if [[ -n $options ]]; then
    # print question
    _msg "${message}"
    _add_space

    # print each option
    for option in $options; do
      _msg "${INDENT}${INDENT}${options[(Ie)$option]}) ${option}"
    done

    _add_space

    # print user response prompt w/ or w/o a default value
    if [[ -n $default ]]; then
      vared -p "${INDENT}Response: " -c $default
    else
      _msg -n "${INDENT}Response: "
    fi
  # a default exists but not options
  elif [[ -n $default ]]; then
    # print question w/ default value
    vared -p $message -c $default
  # no options or default exists
  else
    # print question
    _msg -n $message
  fi
}
