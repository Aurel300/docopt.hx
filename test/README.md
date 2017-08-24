# Testing suite #

`docopt` provides a language-agnostic testing suite (`testcases.docopt`). The script in this directory parses this file and attempts to run all the tests contained within (any failure aborts the testing run). To build the testing suite parser, simply make sure this is your working directory and run:

    haxe -lib docopt -main Main -neko test.n

Then to run the script:

    neko test.n
