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
