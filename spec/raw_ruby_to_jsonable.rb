require 'app'

RSpec.describe RawRubyToJsonable do
  # I don't know what I want yet, just playing to see

  def call(raw_code)
    json = RawRubyToJsonable.call raw_code
    assert_valid json
    json
  end

  def assert_valid(json)
    case json
    when String, Fixnum
      # no op
    when Array
      json.each { |element| assert_valid element }
    when Hash
      json.each do |k, v|
        raise unless k.kind_of? String
        assert_valid v
      end
    else
      raise "Unknown type: #{json.inspect}"
    end
  end

  example 'single expression' do
    result = call '1'
    expect(result['type']).to eq 'integer'
    expect(result['highlightings']).to eq [[0, 1]]
    expect(result['value']).to eq 1
  end

  'multiple expressions'
  'set and get local variable'
  'integer literals'
  'class definitions'
  'module definitions'
  # idk, look at SiB for a start
end
