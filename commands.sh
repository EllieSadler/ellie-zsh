#!/usr/bin/env zsh

# @describe Loops through all files inside commands/
for f in `ls commands/`; do
  source ${0:A:h}/commands/$f
done
