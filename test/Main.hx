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
          // To make sure the JSON spacing is consistent:
          expect = Json.stringify(Json.parse(result));
        }
        exitCode = -1;
        function mkFail(msg:String):Bool {
          Sys.println('\n! (line $cline: $command), $msg');
          return false;
        }
        if (try {
            var args = command.split(" ").slice(1).filter(function(s) return s != "");
            var actual = Json.stringify(Docopt.parse(usage, args));
            if (expect == null) {
              mkFail('expected user-error, got:\n$actual');
            } else if (actual != expect) {
              mkFail('expected:\n$expect\n\ngot:\n$actual');
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
          Sys.print(".");
          success++;
        } else {
          fail++;
        }
      }
    }
    Sys.println("");
    Sys.println("---------------");
    Sys.println('tests run:  $total');
    Sys.println('successful: $success');
    Sys.println('failed:     $fail');
  }
}
