import haxe.DynamicAccess;
import haxe.Json;
import org.docopt.Docopt;

using StringTools;

enum Abort {
  Abort;
}

class Main {
  // Configuration
  static inline var TESTCASES:String = "testcases.docopt";
  static inline var START    :Int    = 0;
  
  public static function main():Void {
    // Platform identification
    var sysln =
#if js
      js.Node.console.log;
#else
      Sys.println;
#end
    var sysout =
#if js
      js.Node.console.log;
#else
      Sys.print;
#end
    sysln("Running docopt tests on platform: " +
#if cpp
        "C++"
#elseif js
        "Javascript"
#elseif neko
        "Neko"
#elseif php
        "PHP"
#else
        "Unknown"
#end
      );
    
    // Load testcases
    var tests = sys.io.File.getContent(TESTCASES).split("\n");
    var line  = 0;
    
    // Test results
    var success:Int = 0;
    var fail   :Int = 0;
    var total  :Int = 0;
    
    // Test state
    var usage   :String = null;
    var exitCode:Int    = -1;
    
    // Intercept default exit / print behaviour
    Docopt.exit    = function (code:Int) { exitCode = code; throw Abort; };
    Docopt.println = function (msg:String) { /*Sys.println(msg);*/ };
    
    // JSON object equivalence
    function mapNormalise(map:Map<String, Dynamic>):Dynamic {
      var ret:DynamicAccess<Dynamic> = {};
      for (k in map.keys()) {
        ret.set(k, map[k]);
      }
      return ret;
    }
    
    function equivalent(a:Dynamic, b:Dynamic):Bool {
      var isArr  = Std.is(a, Array ) && Std.is(b, Array );
      var isBool = Std.is(a, Bool  ) && Std.is(b, Bool  );
      var isInt  = Std.is(a, Int   ) && Std.is(b, Int   );
      var isNum  = Std.is(a, Float ) && Std.is(b, Float );
      var isStr  = Std.is(a, String) && Std.is(b, String);
      /*
      trace('isArr: $isArr');
      trace('isBool: $isBool');
      trace('isInt: $isInt');
      trace('isNum: $isNum');
      trace('isStr: $isStr');
      */
      if (isArr) {
        var arrA = (cast a:Array<Dynamic>);
        var arrB = (cast b:Array<Dynamic>);
        if (arrA.length != arrB.length) {
          return false;
        }
        for (i in 0...arrA.length) {
          if (!equivalent(arrA[i], arrB[i])) {
            return false;
          }
        }
      } else if (isBool) {
        return (cast a:Bool) == (cast b:Bool);
      } else if (isInt) {
        return (cast a:Int) == (cast b:Int);
      } else if (isNum) {
        return (cast a:Float) == (cast b:Float);
      } else if (isStr) {
        return (cast a:String) == (cast b:String);
      } else {
        var objA:DynamicAccess<Dynamic> = a;
        var objB:DynamicAccess<Dynamic> = b;
        if (objA.keys().length != objB.keys().length) {
          return false;
        }
        var keys = objA.keys().concat(objB.keys());
        for (k in keys) {
          if (!objA.exists(k) || !objB.exists(k)) {
            return false;
          }
          if (!equivalent(objA.get(k), objB.get(k))) {
            return false;
          }
        }
      }
      return true;
    }
    
    while (line < tests.length && fail == 0) {
      var t = tests[line++];
      
      // Skip empty lines and comments
      if (t == "" || t.charAt(0) == "#") {
        continue;
      }
      
      // Parse usage string
      if (t.startsWith('r"""')) {
        var rawUsage = [t.substr(4)];
        while (!rawUsage[rawUsage.length - 1].endsWith('"""')) {
          rawUsage.push(tests[line++]);
        }
        usage = rawUsage.join("\n").substr(0, -3);
      }
      
      // Run testcase
      if (t.startsWith("$")) {
        total++;
        if (total < START) {
          continue;
        }
        var cline = line - 1;
        var command = t.substr(2);
        var result = [ while (tests[line++] != "") tests[line - 1] ].join("\n");
        var expect = null;
        if (!result.startsWith('"user-error"')) {
          expect = Json.parse(result);
        }
        exitCode = -1;
        function mkFail(msg:String):Bool {
          sysln('\n! (line $cline: $command), $msg');
          return false;
        }
        if (try {
            var args = command.split(" ").slice(1).filter(function(s) return s != "");
            var actual = mapNormalise(Docopt.parse(usage, args));
            if (expect == null) {
              mkFail('expected user-error, got:\n${Std.string(actual)}');
            } else if (!equivalent(actual, expect)) {
              mkFail('expected:\n${Std.string(expect)}\n\ngot:\n${Std.string(actual)}');
            } else {
              true;
            }
          } catch (ex:Abort) {
            if (expect != null) {
              mkFail('unexpected user-error');
            } else {
              true;
            }
          } catch (ex:Dynamic) {
            mkFail('runtime error $ex');
          }) {
          sysout(".");
          success++;
        } else {
          fail++;
        }
      }
    }
    sysln("");
    sysln("---------------");
    sysln('tests run:  $total');
    sysln('successful: $success');
    sysln('failed:     $fail');
  }
}
