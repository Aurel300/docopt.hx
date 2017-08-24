package org.docopt;

class Argument extends LeafPattern {
  public static function parse(type:PatternType, source:String):Argument {
    var name = Docopt.regAll(~/(<\S*?>)/, source)[0];
    var value = Docopt.regAll(~/\[default: (.*)\]/i, source);
    return (switch (type) {
        case Argument: new Argument(name, value.length > 0 ? value[0] : null);
        case Command: new Command(name, value.length > 0 ? value[0] : null);
        case _: null;
      });
  }
  
  public function new(name:String, ?value:Dynamic) {
    super(name, value);
    type = Argument;
  }
  
  override public function singleMatch(left:Array<LeafPattern>):SingleMatch {
    for (i in 0...left.length) {
      if (left[i].type == Argument) {
        return {pos: i, match: new Argument(name, left[i].value)};
      }
    }
    return {pos: null, match: null};
  }
}
