require 'parse_server/raw_ruby_to_jsonable'
require 'json'
module ParseServer
  class App
    def self.call(rack_env)
      new(rack_env).call
    end

    def initialize(rack_env)
      @request = Rack::Request.new(rack_env)
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
      { 'Content-Type' => 'application/json; charset=utf-8',
        'Access-Control-Allow-Origin' => 'null', # allows static files (maybe should only enable in dev mode?)
      }
    end

    def ast
      RawRubyToJsonable.call(@request[:code] || @request.body.read)
    end
  end
end
