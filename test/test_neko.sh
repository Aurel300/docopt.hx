#!/bin/sh

mkdir -p build
haxe -lib docopt -main Main -neko build/test.n \
    && neko build/test.n
