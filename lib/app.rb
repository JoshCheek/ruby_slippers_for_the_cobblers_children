require 'parser/current'
require 'json'

class RawRubyToJsonable
  # receives raw ruby code (a String)
  # return a data structure that can be directly converted into json
  # meaning String, Array, Hash, Fixnum, Float
  def self.call(raw_code)
    new(raw_code).call
  end

  def initialize(raw_code)
    self.raw_code = raw_code
  end

  def call
    ast = parse(raw_code)
    ast.inspect
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
