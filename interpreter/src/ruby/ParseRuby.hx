package ruby;
import ruby.ds.Interpreter;
import ruby.ds.Objects;

class ParseRuby {
  public static var serverUrl = 'http://localhost:3003';

  public static function fromCode(rawCode:String, ?serverUrl:String):ExecutionState {
    if(serverUrl==null) serverUrl = ParseRuby.serverUrl;
    var rawJson = ruby.Http.post(serverUrl, rawCode);
    return fromJson(haxe.Json.parse(rawJson));
  }

  static function fromJson(ast:Dynamic):ExecutionState {
    if(ast == null) return Default;
    return switch(ast.type) {
      case "nil"                   : Nil;
      case "true"                  : True;
      case "false"                 : False;
      case "self"                  : Self;
      case "integer"               : Integer(ast.value);
      case "float"                 : Float(ast.value);
      case "string"                : String(ast.value);
      case "expressions"           : Exprs(Start(ast.expressions.map(fromJson)));
      case "set_local_variable"    : SetLvar(FindRhs(ast.name, fromJson(ast.value)));
      case "get_local_variable"    : GetLvar(Name(ast.name));
      case "set_instance_variable" : SetIvar(FindRhs(ast.name, fromJson(ast.value)));
      case "get_instance_variable" : GetIvar(Name(ast.name));
      case "send"                  : Send(Start(fromJson(ast.target), ast.message, ast.args.map(fromJson)));
      case "constant"              : Const(GetNs(fromJson(ast.namespace), ast.name));
      case "class"                 : OpenClass(GetNs(fromJson(ast.name_lookup), fromJson(ast.superclass), fromJson(ast.body)));
      case "method_definition"     : Def(Start(ast.name, ast.args.map(toArg), fromJson(ast.body)));
      case _                       : throw("CAN'T PARSE: " + ast);
    }
  }

  private static function toArg(arg:Dynamic):ArgType {
    switch(arg.type) {
      case "required_arg": return Required(arg.name);
      case "rest_arg":     return Rest(arg.name);
      case _: throw("Unknown arg type!: " + arg);
    }
  }
}
