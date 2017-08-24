package org.docopt;

class LeafPattern extends Pattern {
  public var name:String;
  public var value:Dynamic;
  
  public function new(name:String, ?value:Dynamic) {
    super();
    type = LeafPattern;
    this.name = name;
    this.value = value;
  }
  
  override public function toString():String {
    return '$type($name, $value)';
  }
  
  override public function flat(?types:Array<PatternType>):Array<Pattern> {
    return (types == null || types.indexOf(type) != -1 ? [this] : []);
  }
  
  public function singleMatch(left:Array<LeafPattern>):SingleMatch {
    return null;
  }
  
  override public function match(
    left:Array<LeafPattern>, ?collected:Array<LeafPattern>
  ):Match {
    collected = (collected != null ? collected : []);
    var smatch = singleMatch(left);
    if (smatch == null || smatch.pos == null) {
      return {matched: false, left: left, collected: collected};
    }
    left = left.slice(0, smatch.pos).concat(left.slice(smatch.pos + 1));
    var sameName = [ for (a in collected) if (a.name == name) a ];
    var isInt = Std.is(value, Int);
    var isArr = Std.is(value, Array);
    if (isInt || isArr) {
      var increment:Dynamic = null;
      if (isInt) {
        increment = 1;
      } else {
        increment = (Std.is(smatch.match.value, String) ? [smatch.match.value] : smatch.match.value);
      }
      if (!Docopt.bool(sameName)) {
        smatch.match.value = increment;
        return {
            matched: true, left: left, collected: collected.concat([smatch.match])
          };
      }
      if (Std.is(sameName[0].value, Array) && isArr) {
        sameName[0].value = sameName[0].value.concat(increment);
      } else if (Std.is(sameName[0].value, Array)) {
        sameName[0].value.push(increment);
      } else {
        sameName[0].value += increment;
      }
      return {
          matched: true, left: left, collected: collected
        };
    }
    return {
        matched: true, left: left, collected: collected.concat([smatch.match])
      };
  }
}
