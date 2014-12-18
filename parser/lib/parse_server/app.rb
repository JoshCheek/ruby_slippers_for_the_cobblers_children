require 'parse_server/raw_ruby_to_jsonable'
require 'json'
module ParseServer
  class App
    def self.call(rack_env)
      new(rack_env).call
    end

    def initialize(rack_env)
      @request = Rack::Request.new(rack_env)
      @status  = 200
    end

    def call
      [200, headers, [JSON.dump(ast)]]
    rescue Parser::SyntaxError
      [400, headers, [JSON.dump(name:      'SyntaxError',
                                message:   $!.message,
                                backtrace: $!.backtrace)]
      ]
    end

    private

    def headers
      {'Content-Type' => 'application/json; charset=utf-8'}
    end

    def ast
      RawRubyToJsonable.call(@request[:code] || @request.body.read)
    end
  end
end
