#!/bin/sh

mkdir -p build
haxe -lib docopt -main Main -php build/test.php \
    && php build/test.php/index.php
