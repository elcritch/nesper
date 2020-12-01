#!/bin/sh

ruby -i -pe '$_.gsub!(/((?:uint|int))(\d+)_t/, "\\1\\2")' $*
