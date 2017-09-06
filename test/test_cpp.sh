#!/bin/sh

mkdir -p build
haxe -D haxeJSON -lib docopt -main Main -cpp build/test.cpp \
    && build/test.cpp/Main
