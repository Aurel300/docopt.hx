package org.docopt;

class Command extends Argument {
  public function new(name:String, ?value:Dynamic = false) {
    super(name, value);
    type = Command;
  }
  
  override public function singleMatch(left:Array<LeafPattern>):SingleMatch {
    for (i in 0...left.length) {
      if (left[i].type == Argument) {
        if (left[i].value == name) {
          return {pos: i, match: new Command(name, true)};
        } else {
          break;
        }
      }
    }
    return {pos: null, match: null};
  }
}
