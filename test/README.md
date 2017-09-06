# Testing suite #

`docopt` provides a language-agnostic testing suite (`testcases.docopt`). The script in this directory parses this file and attempts to run all the tests contained within (any failure aborts the testing run). The `.sh` files in this directory build the testing suite for various compilation targets and run them.

Platforms included:

 - `test_cpp.sh` - C++
 - `test_js.sh` - Javascript (requires `nodejs` and `hxnodejs` to run)
 - `test_neko.sh` - Neko VM
 - `test_php.sh` - PHP
