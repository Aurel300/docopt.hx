package org.docopt;

using StringTools;
using org.docopt.Docopt;

class Option extends LeafPattern {
  public static function parse(optionDescription:String):Option {
    var short:String = null;
    var long:String = null;
    var argCount = 0;
    var value:Dynamic = false;
    var optSplit = Docopt.partition(optionDescription.trim(), "  ");
    var options = optSplit[0].replace(",", " ").replace("=", " ");
    var description = optSplit[2];
    for (s in options.split(" ")) {
      if (s == "") {
        continue;
      }
      if (s.startsWith("--")) {
        long = s;
      } else if (s.startsWith("-")) {
        short = s;
      } else {
        argCount = 1;
      }
    }
    if (argCount > 0) {
      var matched = ~/\[default: (.*)\]/i.regAllGroups(description, 1);
      value = (matched.length > 0 ? matched[0][0] : null);
    }
    return new Option(short, long, argCount, value);
  }
  
  public var short:String;
  public var long:String;
  public var argCount:Int;
  
  public function new(
    ?short:String, ?long:String, ?argCount:Int = 0, ?value:Dynamic = false
  ) {
    if (argCount != 0 && argCount != 1) {
      throw new DocoptLanguageError("invalid argument count");
    }
    super(
         long != null ? long : short
        ,(value == false && argCount != 0) ? null : value
      );
    type = Option;
    this.short = short;
    this.long = long;
    this.argCount = argCount;
  }
  
  override public function toString():String {
    return '$type($short, $long, $argCount, $value)';
  }
  
  override public function singleMatch(left:Array<LeafPattern>):SingleMatch {
    for (i in 0...left.length) {
      if (left[i].name == name) {
        return {pos: i, match: left[i]};
      }
    }
    return {pos: null, match: null};
  }
}
