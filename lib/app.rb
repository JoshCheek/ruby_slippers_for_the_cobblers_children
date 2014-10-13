require 'parser/current'
require 'json'

class RawRubyToJsonable
  # receives raw ruby code (a String)
  # return a data structure that can be directly converted into json
  # meaning String, Array, Hash, Fixnum, Float, nil
  def self.call(raw_code)
    new(raw_code).call
  end

  def initialize(raw_code)
    self.raw_code = raw_code
  end

  def call
    translate parse raw_code
  end

  private

  attr_accessor :raw_code

  def parse(raw_code)
    buffer                             = Parser::Source::Buffer.new('something')
    buffer.source                      = raw_code
    builder                            = Parser::Builders::Default.new
    builder.emit_file_line_as_literals = false
    parser                             = Parser::CurrentRuby.new builder
    parser.parse buffer
  end

  def translate(ast)
    return nil if ast.nil?

    case ast.type
    # eg "1"
    when :int
      raise if ast.children.size > 1
      expr = ast.loc.expression
      {'type'          => 'integer',
       'value'         => ast.children.first
      }
    # eg "1;2" and "(1;2)"
    when :begin
      expr = ast.loc.expression
      {'type'          => 'expressions',
       'children'      => ast.children.map { |child| translate child }
      }
    # eg "begin;1;2;end"
    when :kwbegin
      kwbegin = ast.loc.begin
      kwend = ast.loc.end
      {'type'          => 'keyword_begin',
       'children'      => ast.children.map { |child| translate child }
      }
    when :send
      target, message, *args = ast.children
      {'type'          => 'send',
       'target'        => translate(target),
       'message'       => message.to_s,
       'args'          => args.map { |arg| translate arg },
      }
    when :lvasgn
      { 'type'         => 'assign_local_variable',
        'name'         => ast.children[0].to_s,
        'value'        => translate(ast.children[1]),
      }
    when :lvar
      { 'type'         => 'lookup_local_variable',
        'name'         => ast.children[0].to_s,
      }
    else
      raise "No case for #{ast.inspect}"
    end
  end
end

class App
  def self.call(rack_env)
    new.call(rack_env)
  end

  def call(rack_env)
    body   = rack_env['rack.input'].read
    status = 200
    begin
      json   = RawRubyToJsonable.call(body)
    rescue Parser::SyntaxError
      status = 400
      json   = {name: 'SyntaxError', message: $!.message, backtrace: $!.backtrace}
    end
    [status, {'Content-Type' => 'application/json; charset=utf-8'}, [JSON.dump(json)]]
  end
end
