package ruby;

import ruby.ds.Ast;

class ParseRuby {
  public static function fromCode(rawCode:String):Ast {
    return usingServer(rawCode);
  }

  public static function usingServer(rawCode:String):Ast {
    var port   = "";
    if(Sys.environment().exists("RUBY_PARSER_PORT"))
      port = Sys.environment().get("RUBY_PARSER_PORT");
    else
      port = '3003';
    var parser = new haxe.Http('http://localhost:$port');
    parser.setPostData(rawCode);
    var rawJson = "";
    parser.onData   = function(jsonResult) rawJson += jsonResult;
    parser.onError  = function(message) trace("HTTP ERROR: " + message);
    parser.onStatus = function(status) { };
    parser.request(true);
    return fromRawJson(rawJson);
  }

  // loading the bin for each request was just taking annoyingly long
  public static function usingBinary(rawCode:String):Ast {
    var astFor       = new sys.io.Process('ast_for', [rawCode]);
    var rawJson      = "";
    try { rawJson += astFor.stdout.readLine(); } catch (ex:haxe.io.Eof) { /* no op */ }
    return fromRawJson(rawJson);
  }

  public static function fromRawJson(rawJson:String) {
    return fromJson(haxe.Json.parse(rawJson));
  }

  public static function fromJson(ast:Dynamic):Ast {
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
      case "class"                 : Class(fromJson(ast.name_lookup), fromJson(ast.superclass), fromJson(ast.body));
      case "method_definition"     : MethodDefinition(ast.name, fromJsonArray(ast.args), fromJson(ast.body));
      case "required_arg"          : RequiredArg(ast.name);
      case _                       : Undefined(ast);
    }
    return rubyAst;
  }

  private static function fromJsonArray(array:Array<Dynamic>):Array<Ast> {
    return array.map(fromJson);
  }
}
