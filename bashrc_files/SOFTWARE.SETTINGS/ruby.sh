#!/usr/bin/env bash

#This suppose ruby has been installed using brew:
#
# ```
# $ brew install chruby ruby-install
# $ ruby-install ruby
# ```

. "$(brew --prefix)/opt/chruby/share/chruby/chruby.sh"
. "$(brew --prefix)/opt/chruby/share/chruby/auto.sh"
chruby ruby-3.4.1
