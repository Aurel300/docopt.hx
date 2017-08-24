package org.docopt;

class OneOrMore extends BranchPattern {
  public function new(?children:Array<Pattern>) {
    super(children);
    type = OneOrMore;
  }
  
  override public function match(
    left:Array<LeafPattern>, ?collected:Array<LeafPattern>
  ):Match {
    if (children.length != 1) {
      throw new DocoptLanguageError('OneOrMore with incorrect child count');
    }
    collected = (collected != null ? collected : []);
    var l = left;
    var c = collected;
    var l_ = null;
    var matched = true;
    var times = 0;
    while (matched) {
      var match = children[0].match(l, c);
      matched = match.matched;
      l = match.left;
      c = match.collected;
      if (matched) {
        times++;
      }
      if (l_ == l) {
        break;
      }
      l_ = l;
    }
    if (times >= 1) {
      return {matched: true, left: l, collected: c};
    }
    return {matched: false, left: left, collected: collected};
  }
}
