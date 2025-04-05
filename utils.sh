#!/usr/bin/env zsh

# @describe Loops through all files inside utils/
for f in `ls utils/`; do
  source ${0:A:h}/utils/$f
done
