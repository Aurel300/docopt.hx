package org.docopt;

enum PatternType {
  None;
  LeafPattern;
  BranchPattern;
  Argument;
  Command;
  Option;
  Required;
  Optional;
  OptionsShortcut;
  OneOrMore;
  Either;
}
