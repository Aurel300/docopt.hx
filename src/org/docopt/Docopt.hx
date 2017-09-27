package org.docopt;

using StringTools;
using org.docopt.Docopt;

@:allow(org.docopt)
class Docopt {
  public static dynamic function exit(code:Int):Void {
    Sys.exit(code);
  }
  
  public static dynamic function println(msg:String):Void {
    Sys.println(msg);
  }
  
  /**
   * Python-like utility functions.
   */
  
  private static function regAll(re:EReg, source:String):Array<String> {
    return [ while (re.match(source)) {
        source = re.matchedRight();
        re.matched(0);
      } ];
  }
  
  private static function regAllGroups(
    re:EReg, source:String, groups:Int
  ):Array<Array<String>> {
    return [ while (source != null && re.match(source)) {
        source = re.matchedRight();
        [ for (i in 1...groups + 1) re.matched(i) ];
      } ];
  }
  
  private static function regSplit(re:EReg, source:String):Array<String> {
    var ret = [];
    while (re.match(source)) {
      ret.push(re.matchedLeft());
      if (re.matched(1) != null) {
        ret.push(re.matched(1));
      }
      source = re.matchedRight();
    }
    ret.push(source);
    return ret;
  }
  
  private static function isUpper(s:String):Bool {
    return s.toUpperCase() == s && s.toLowerCase() != s.toUpperCase();
  }
  
  private static function lstrip(s:String, c:String):String {
    for (i in 0...s.length) {
      if (s.charAt(i) != c) {
        return s.substr(i);
      }
    }
    return "";
  }
  
  private static function split(s:String):Array<String> {
    return ~/\s+/g.split(s.trim());
  }
  
  private static function listSet<T>(arr:Array<T>, ?eq:T->T->Bool):Array<T> {
    if (eq == null) {
      eq = function(a, b) return a == b;
    }
    var ret = [];
    for (el in arr) {
      if (listIn(ret, el, eq) == null) {
        ret.unshift(el);
      }
    }
    return ret;
  }
  
  private static function listIn<T>(arr:Array<T>, s:T, ?eq:T->T->Bool):T {
    if (eq == null) {
      eq = function(a, b) return a == b;
    }
    for (el in arr) {
      if (eq(el, s)) {
        return el;
      }
    }
    return null;
  }
  
  private static function count<T>(arr:Array<T>, s:T, ?eq:T->T->Bool):Int {
    if (eq == null) {
      eq = function(a, b) return a == b;
    }
    var ret = 0;
    for (el in arr) {
      if (eq(el, s)) {
        ret++;
      }
    }
    return ret;
  }
  
  private static function bool(value:Dynamic):Bool {
    if (value == null) {
      return false;
    }
    if (Std.is(value, Bool)) {
      return (cast value:Bool);
    }
    if (Std.is(value, Float)) {
      return (cast value:Float) == 0;
    }
    if (Std.is(value, String)) {
      return (cast value:String) != "";
    }
    if (Std.is(value, Array)) {
      return value.length != 0;
    }
    return true;
  }
  
  private static function partition(s:String, c:String):Array<String> {
    var split = s.split(c);
    if (split.length > 1) {
      return [split[0], c, split.slice(1).join(c)];
    }
    return [split[0], null, null];
  }
  
  /**
   * Docopt functions.
   */
  
  /**
   * """Parse `argv` based on command-line interface described in `doc`.
   * 
   * `docopt` creates your command-line interface based on its
   * description that you pass as `doc`. Such description can contain
   * --options, <positional-argument>, commands, which could be
   * [optional], (required), (mutually | exclusive) or repeated...
   * 
   * Parameters
   * ----------
   * doc : str
   *     Description of your command-line interface.
   * argv : list of str, optional
   *     Argument vector to be parsed. sys.argv[1:] is used if not
   *     provided.
   * help : bool (default: True)
   *     Set to False to disable automatic help on -h or --help
   *     options.
   * version : any object
   *     If passed, the object will be printed if --version is in
   *     `argv`.
   * options_first : bool (default: False)
   *     Set to True to require options precede positional arguments,
   *     i.e. to forbid options and positional arguments intermix.
   * 
   * Returns
   * -------
   * args : dict
   *     A dictionary, where keys are names of command-line elements
   *     such as e.g. "--verbose" and "<path>", and values are the
   *     parsed values of those elements.
   * 
   * Example
   * -------
   * >>> from docopt import docopt
   * >>> doc = '''
   * ... Usage:
   * ...     my_program tcp <host> <port> [--timeout=<seconds>]
   * ...     my_program serial <port> [--baud=<n>] [--timeout=<seconds>]
   * ...     my_program (-h | --help | --version)
   * ...
   * ... Options:
   * ...     -h, --help  Show this screen and exit.
   * ...     --baud=<n>  Baudrate [default: 9600]
   * ... '''
   * >>> argv = ['tcp', '127.0.0.1', '80', '--timeout', '30']
   * >>> docopt(doc, argv)
   * {'--baud': '9600',
   *  '--help': False,
   *  '--timeout': '30',
   *  '--version': False,
   *  '<host>': '127.0.0.1',
   *  '<port>': '80',
   *  'serial': False,
   *  'tcp': True}
   * 
   * See also
   * --------
   * * For video introduction see http://docopt.org
   * * Full documentation is available in README.rst as well as online
   *   at https://github.com/docopt/docopt#readme
   */
  public static function parse(
     doc:String, ?argv:Array<String>, ?help:Bool = true, ?version:Dynamic
    ,?optionsFirst:Bool = false
  ):Map<String, Dynamic> {
    if (argv == null) {
      argv = Sys.args();
    }
    var usageSections = parseSection("usage:", doc);
    if (usageSections.length == 0) {
      throw new DocoptLanguageError('"usage:" (case-insensitive) not found.');
    } else if (usageSections.length > 1) {
      throw new DocoptLanguageError('More than one "usage:" (case-insensitive).');
    }
    DocoptExit.usage = usageSections[0];
    var options = parseDefaults(doc);
    var pattern = parsePattern(formalUsage(DocoptExit.usage), options);
    var parsedArgv = parseArgv(new Tokens(argv), options, optionsFirst);
    var patternOptions = listSet(pattern.flat([Option]));
    for (optionsShortcut in pattern.flat([OptionsShortcut])) {
      var docOptions = parseDefaults(doc);
      optionsShortcut.children = [ for (o in docOptions)
          if (patternOptions.listIn(o, Pattern.equal) == null) o
        ];
    }
    extras(help, version, (cast parsedArgv:Array<Option>), doc);
    var match = pattern.fix().match(parsedArgv);
    if (match.matched && match.left.length == 0) {
      var ret = new Map<String, Dynamic>();
      for (a in pattern.flat().concat((cast match.collected:Array<Pattern>))) {
        var aa = (cast a:LeafPattern);
        ret.set(aa.name, aa.value);
      }
      return ret;
    }
    throw new DocoptExit();
  }
  
  /**
   * long ::= '--' chars [ ( ' ' | '=' ) chars ] ;
   */
  private static function parseLong(
    tokens:Tokens, options:Array<Option>
  ):Array<Option> {
    var tokSplit = tokens.move().partition("=");
    var long = tokSplit[0];
    if (!long.startsWith("--")) {
      throw tokens.error("long doesn't start with --");
    }
    var value = tokSplit[2];
    var similar = [ for (o in options) if (o.long == long) o ];
    if (tokens.exit && similar.length == 0) {
      similar = [ for (o in options)
          if (o.long != null && o.long.startsWith(long)) o
        ];
    }
    var o = null;
    if (similar.length > 1) {
      throw tokens.error('$long is not a unique prefix: '
        + [ for (o in similar) o.long ].join(", "));
    } else if (similar.length < 1) {
      var argCount = (tokSplit[1] == "=" ? 1 : 0);
      o = new Option(null, long, argCount);
      options.push(o);
      if (tokens.exit) {
        o = new Option(null, long, argCount, argCount > 0 ? value : true);
      }
    } else {
      o = new Option(
           similar[0].short, similar[0].long
          ,similar[0].argCount, similar[0].value
        );
      if (o.argCount == 0) {
        if (value != null) {
          throw tokens.error('${o.long} must not have an argument');
        }
      } else {
        if (value == null) {
          if (tokens.current() == null || tokens.current() == "--") {
            throw tokens.error('${o.long} requires argument');
          }
          value = tokens.move();
        }
      }
      if (tokens.exit) {
        o.value = (value != null ? value : true);
      }
    }
    return [o];
  }
  
  /**
   * shorts ::= '-' ( chars )* [ [ ' ' ] chars ] ;
   */
  private static function parseShorts(
    tokens:Tokens, options:Array<Option>
  ):Array<Option> {
    var token = tokens.move();
    if (!token.startsWith("-") || token.startsWith("--")) {
      throw tokens.error("invalid short token");
    }
    var left = lstrip(token, "-");
    var parsed = [];
    while (left != "") {
      var short = "-" + left.charAt(0);
      left = left.substr(1);
      var similar = [ for (o in options) if (o.short == short) o ];
      var o = null;
      if (similar.length > 1) {
        throw tokens.error(
            '$short is specified ambiguously %{similar.length} times'
          );
      } else if (similar.length < 1) {
        o = new Option(short, null, 0, null);
        options.push(o);
        if (tokens.exit) {
          o = new Option(short, null, 0, true);
        }
      } else {
        o = new Option(
             short, similar[0].long
            ,similar[0].argCount, similar[0].value
          );
        var value = null;
        if (o.argCount != 0) {
          if (left == "") {
            if (tokens.current() == null || tokens.current() == "--") {
              throw tokens.error('$short requires argument');
            }
            value = tokens.move();
          } else {
            value = left;
            left = "";
          }
        }
        if (tokens.exit) {
          o.value = (value != null ? value : true);
        }
      }
      parsed.push(o);
    }
    return parsed;
  }
  
  private static function parsePattern(
    source:String, options:Array<Option>
  ):Required {
    var tokens = Tokens.fromPattern(source);
    var result = parseExpr(tokens, options);
    if (tokens.current() != null) {
      throw tokens.error("unexpected ending: " + tokens.join(" "));
    }
    return new Required(result);
  }
  
  /**
   * expr ::= seq ( '|' seq )* ;
   */
  private static function parseExpr(
    tokens:Tokens, options:Array<Option>
  ):Array<Pattern> {
    var seq = parseSeq(tokens, options);
    if (tokens.current() != "|") {
      return seq;
    }
    var result:Array<Pattern> = (seq.length > 1 ? [new Required(seq)] : seq);
    while (tokens.current() == "|") {
      tokens.move();
      seq = parseSeq(tokens, options);
      result = result.concat(seq.length > 1 ? [new Required(seq)] : seq);
    }
    return (result.length > 1 ? [new Either(result)] : result);
  }
  
  /**
   * seq ::= ( atom [ '...' ] )* ;
   */
  private static function parseSeq(
    tokens:Tokens, options:Array<Option>
  ):Array<Pattern> {
    var result = [];
    while (tokens.hasNext() && ["]", ")", "|"].indexOf(tokens.current()) == -1) {
      var atom = parseAtom(tokens, options);
      if (tokens.current() == "...") {
        atom = [new OneOrMore(atom)];
        tokens.move();
      }
      result = result.concat(atom);
    }
    return result;
  }
  
  /**
   * atom ::= '(' expr ')' | '[' expr ']' | 'options'
   *       | long | shorts | argument | command ;
   */
  private static function parseAtom(
    tokens:Tokens, options:Array<Option>
  ):Array<Pattern> {
    var token = tokens.current();
    return (switch (token) {
        case "(" | "[":
        tokens.move();
        var matching = ")";
        var result = (if (token == "(") {
            new Required(parseExpr(tokens, options));
          } else {
            matching = "]";
            new Optional(parseExpr(tokens, options));
          });
        if (tokens.move() != matching) {
          throw tokens.error('unmatched \'$token\'');
        }
        [result];
        
        case "options":
        tokens.move();
        [new OptionsShortcut()];
        
        case (_.startsWith("--") => true) if (token != "--"):
        (cast parseLong(tokens, options):Array<Pattern>);
        
        case (_.startsWith("-") => true) if (token != "-" && token != "--"):
        (cast parseShorts(tokens, options):Array<Pattern>);
        
        case [_.startsWith("<"), _.endsWith(">")] => [true, true]:
        [new Argument(tokens.move())];
        
        case _.isUpper() => true:
        [new Argument(tokens.move())];
        
        case _:
        [new Command(tokens.move())];
      });
  }
  
  /**
   * Parse command-line argument vector.
   * 
   * If options_first:
   *     argv ::= [ long | shorts ]* [ argument ]* [ '--' [ argument ]* ] ;
   * else:
   *     argv ::= [ long | shorts | argument ]* [ '--' [ argument ]* ] ;
   */
  private static function parseArgv(
    tokens:Tokens, options:Array<Option>, ?optionsFirst:Bool = false
  ):Array<LeafPattern> {
    var parsed:Array<LeafPattern> = [];
    while (tokens.current() != null) {
      switch (tokens.current()) {
        case "--":
        return parsed.concat([ for (v in tokens) new Argument(null, v) ]);
        
        case (_.startsWith("--") => true):
        parsed = parsed.concat(
            (cast parseLong(tokens, options):Array<LeafPattern>)
          );
        
        case (_.startsWith("-") => true) if (tokens.current() != "-"):
        parsed = parsed.concat(
            (cast parseShorts(tokens, options):Array<LeafPattern>)
          );
        
        case _ if (optionsFirst):
        return parsed.concat([ for (v in tokens) new Argument(null, v) ]);
        
        case _:
        parsed.push(new Argument(null, tokens.move()));
      }
    }
    return parsed;
  }
  
  private static function parseDefaults(doc:String):Array<Option> {
    var defaults = [];
    for (s in parseSection("options:", doc)) {
      s = s.split(":").slice(1).join(":");
      var split = regSplit(~/\n[ \t]*(-\S+?)/, "\n" + s).slice(1);
      split = [ for (i in 0...Std.int(split.length / 2))
          split[i * 2] + split[i * 2 + 1]
        ];
      var options = [ for (s in split) if (s.startsWith("-")) Option.parse(s) ];
      defaults = defaults.concat(options);
    }
    return defaults;
  }
  
  private static function parseSection(
    name:String, source:String
  ):Array<String> {
    var pattern = new EReg(
        "^([^\\r\\n]*" + name + "[^\\r\\n]*\\r?\\n?(?:[ \\t].*?(?:\\r?\\n|$))*)", "im"
      );
    return [ for (s in regAll(pattern, source)) s.trim() ];
  }
  
  private static function formalUsage(section:String):String {
    section = section.split(":").slice(1).join(":");
    var pu = split(section);
    return "( " + ([ for (s in pu.slice(1))
        (s == pu[0] ? ") | (" : s)
      ].join(" ")) + " )";
  }
  
  private static function extras(
    help:Bool, version:Dynamic, options:Array<Option>, doc:String
  ):Void {
    if (help) {
      for (o in options) {
        if (o.name == "-h" || o.name == "--help") {
          if (Docopt.bool(o.value)) {
            Docopt.println(~/^\\n+|\\n+$/.replace(doc, ""));
            Docopt.exit(0);
          }
        }
      }
    }
    if (version != null) {
      for (o in options) {
        if (o.name == "--version") {
          Docopt.println(version);
          Docopt.exit(0);
        }
      }
    }
  }
}
