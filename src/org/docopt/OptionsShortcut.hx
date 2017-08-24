package org.docopt;

class OptionsShortcut extends Optional {
  public function new(?children:Array<Pattern>) {
    super(children);
    type = OptionsShortcut;
  }
}
