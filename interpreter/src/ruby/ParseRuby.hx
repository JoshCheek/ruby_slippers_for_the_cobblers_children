package ruby;

class ParseRuby {
  public static function fromCode(rawCode:String):RubyAst {
    var astFor       = new sys.io.Process('ast_for', [rawCode]);
    var rawJson      = "";
    try { rawJson += astFor.stdout.readLine(); } catch (ex:haxe.io.Eof) { /* no op */ }
    return fromRawJson(rawJson);
  }

  public static function fromRawJson(rawJson:String) {
    return fromJson(haxe.Json.parse(rawJson));
  }

  public static function fromJson(ast:Dynamic):RubyAst {
    if(ast == null) return Nil;
    var rubyAst = switch(ast.type) {
      case "nil"                   : Nil;
      case "true"                  : True;
      case "false"                 : False;
      case "self"                  : Self;
      case "integer"               : Integer(ast.value);
      case "float"                 : Float(ast.value);
      case "string"                : String(ast.value);
      case "expressions"           : Expressions(fromJsonArray(ast.expressions));
      case "set_local_variable"    : SetLocalVariable(ast.name, fromJson(ast.value));
      case "get_local_variable"    : GetLocalVariable(ast.name);
      case "set_instance_variable" : SetInstanceVariable(ast.name, fromJson(ast.value));
      case "get_instance_variable" : GetInstanceVariable(ast.name);
      case "send"                  : Send(fromJson(ast.target), ast.message, fromJsonArray(ast.args));
      case "constant"              : Constant(fromJson(ast.namespace), ast.name);
      case "class"                 : RClass(fromJson(ast.name_lookup), fromJson(ast.superclass), fromJson(ast.body));
      case "method_definition"     : MethodDefinition(ast.name, fromJsonArray(ast.args), fromJson(ast.body));
      case "required_arg"          : RequiredArg(ast.name);
      case _                       : Undefined(ast);
    }
    return rubyAst;
  }

  private static function fromJsonArray(array:Array<Dynamic>):Array<RubyAst> {
    return array.map(fromJson);
  }
}
