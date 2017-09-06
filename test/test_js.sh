#!/bin/sh

mkdir -p build
haxe -lib hxnodejs -lib docopt -main Main -js build/test.js \
    && node build/test.js
