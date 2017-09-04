package org.docopt;

using StringTools;

class Tokens {
  public static function fromPattern(source:String):Tokens {
    source = ~/([\[\]\(\)\|]|\.\.\.)/g.replace(source, " $1 ");
    return new Tokens([ for (s in Docopt.regSplit(~/\s+|(\S*<.*?>)/g, source))
        if (s.length > 0) s
      ], false);
  }
  
  public var list:Array<String>;
  public var exit:Bool;
  
  public function new(source:Array<String>, ?exit:Bool = true) {
    this.list = source;
    this.exit = exit;
  }
  
  public function move():String {
    return list.shift();
  }
  
  public function hasNext():Bool {
    return list.length > 0;
  }
  
  public function current():String {
    return list[0];
  }
  
  public function error(msg:String):DocoptLanguageError {
    return (exit ? new DocoptExit(msg) : new DocoptLanguageError(msg));
  }
  
  public function iterator():Iterator<String> {
    return list.iterator();
  }
  
  public function join(s:String) return list.join(s);
}
