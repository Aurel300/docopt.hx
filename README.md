# `docopt.hx` – Haxe port of docopt #

See [docopt](https://github.com/docopt/docopt/) for the reference Python implementation.

## Installing and using ##

With Haxe installed, simply use `haxelib` to install:

    haxelib git docopt https://github.com/Aurel300/docopt.hx

Then in your compilation arguments, specify:

    -lib docopt

The API only consists of the static method `org.docopt.Docopt.parse`, whose signature is identical to that of the Python reference. See also the example below.

## Example ##

`docopt` helps you create most beautiful command-line interfaces easily:

```haxe
import org.docopt.Docopt;

class Main {
  public static function main():Void {
    var arguments = Docopt.parse("Naval Fate.

Usage:
  naval ship new <name>...
  naval ship <name> move <x> <y> [--speed=<kn>]
  naval ship shoot <x> <y>
  naval mine (set|remove) <x> <y> [--moored | --drifting]
  naval (-h | --help)
  naval --version

Options:
  -h --help     Show this screen.
  --version     Show version.
  --speed=<kn>  Speed in knots [default: 10].
  --moored      Moored (anchored) mine.
  --drifting    Drifting mine.

", Sys.args(), true, "Naval Fate 2.0");
    
    // pretty print arguments
    var keys = [ for (k in arguments.keys()) k ];
    keys.sort(Reflect.compare);
    Sys.println("{"
      + [ for (k in keys) '\'$k\': ${arguments[k]}' ].join(",\n ")
      + "}");
  }
}
```

(The above code is also available in the `example/` directory with build instructions.)

And that's it. Invoking the above code (compiled to a binary, e.g. using the `cpp` target) like so:

    ./naval ship Napoleon move 5 2 --speed=3

Results in:

    {'--drifting': false,
     '--help': false,
     '--moored': false,
     '--speed': 3,
     '--version': false,
     '<name>': [Napoleon],
     '<x>': 5,
     '<y>': 2,
     'mine': false,
     'move': true,
     'new': false,
     'remove': false,
     'set': false,
     'ship': true,
     'shoot': false}

## Differences from the reference implementation ##

 - The main class is located in the package `org.docopt.Docopt`
 - The `docopt` function is renamed to `Docopt.parse`, but its signature remains the same

## Version ##

This is `docopt.hx` version `0.6.3`, based on the reference implementation version `0.6.2`. It passes all the language-agnostic tests as of the time of writing, on the C++, Javascript, Neko, and PHP targets (see the `test/` directory).
