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
    when String, Fixnum, nil
      # no op
    when Array
      json.each { |element| assert_valid element }
    when Hash
      json.each do |k, v|
        raise unless k.kind_of? String
        assert_valid v
      end
    else
      raise "#{json.inspect} does not appear to be a JSON type"
    end
  end

  example 'true literal' do
    expect(call('true')['type']).to eq 'true'
  end

  example 'false literal' do
    expect(call('false')['type']).to eq 'false'
  end

  example 'nil literal' do
    expect(call('nil')['type']).to eq 'nil'
  end

  describe 'integer literals' do
    def assert_int(code, expected_value)
      result = call code
      expect(result['type']).to eq 'integer'
      expect(result['value']).to eq expected_value
    end

    example('Fixnum')         { assert_int '1', '1' }
    example('Bignum')         { assert_int '111222333444555666777888999', '111222333444555666777888999' }
    example('underscores')    { assert_int '1_2_3', '123' }
    example('binary literal') { assert_int '0b101', '5' }
    example('octal literal')  { assert_int '0101',  '65' }
    example('hex literal')    { assert_int '0x101', '257' }
  end

  describe 'float literals' do
    def assert_float(code, expected_value)
      result = call code
      expect(result['type']).to eq 'float'
      expect(result['value']).to eq expected_value
    end

    example('normal')              { assert_float '1.0',    '1.0' }
    example('negative')            { assert_float '-1.0',   '-1.0' }
    example('scientific notation') { assert_float '1.2e-3', '0.0012' }
  end


  context 'single and multiple expressions' do
    example 'single expression is just the expression type' do
      result = call '1'
      expect(result['type']).to eq 'integer'
      expect(result['value']).to eq '1'
    end

    example 'multiple expressions, no bookends, newline delimited' do
      result = call "9\n8"
      expect(result['type']).to eq 'expressions'

      expr1, expr2, *rest = result['children']
      expect(rest).to be_empty

      expect(expr1['type']).to eq 'integer'
      expect(expr1['value']).to eq '9'

      expect(expr2['type']).to eq 'integer'
      expect(expr2['value']).to eq '8'
    end

    example 'multiple expressions, parentheses bookends, newline delimited' do
      result = call "(9\n8)"
      expect(result['type']).to eq 'expressions'
      expect(result['children'].size).to eq 2
    end

    example 'multiple expressions, begin/end bookends, newline delimited' do
      result = call "begin\n 1\nend"
      expect(result['type']).to eq 'keyword_begin'
      expr, *rest = result['children']
      expect(rest).to be_empty
      expect(expr['type']).to eq 'integer'
      expect(expr['value']).to eq '1'
    end

    example 'semicolon delimited' do
      result = call "1;2"
      expect(result['type']).to eq 'expressions'
      expect(result['children'].size).to eq 2

      result = call "(1;2)"
      expect(result['type']).to eq 'expressions'
      expect(result['children'].size).to eq 2

      result = call "begin;1;end"
      expect(result['type']).to eq 'keyword_begin'
      expect(result['children'].size).to eq 1
    end
  end

  example 'set and get local variable' do
    result = call "a = 1; a"
    set, get = result['children']
    expect(set['type']).to eq 'assign_local_variable'
    expect(set['name']).to eq 'a'

    val = set['value']
    expect(val['type']).to eq 'integer'
    expect(val['value']).to eq '1'

    expect(get['type']).to eq 'lookup_local_variable'
    expect(get['name']).to eq 'a'
  end


  context 'symbol literals' do
    example 'without quotes' do
      result = call ':abc'
      expect(result['type']).to eq 'symbol'
      expect(result['value']).to eq 'abc'
    end

    example 'with quotes' do
      result = call ':"a b\tc"'
      expect(result['type']).to eq 'symbol'
      expect(result['value']).to eq "a b\tc"
    end
  end

  'class definitions'
  'module definitions'
  # idk, look at SiB for a start

  context 'send' do
    example 'with no receiver' do
      result = call 'load'
      expect(result['type']).to eq 'send'
      expect(result['target']).to eq nil
      expect(result['message']).to eq 'load'
      expect(result['args']).to be_empty
    end

    example 'without args' do
      result = call '1.even?'
      expect(result['type']).to eq 'send'

      expect(result['target']['value']).to eq '1'
      expect(result['message']).to eq 'even?'
      expect(result['args']).to be_empty
    end

    example 'with args' do
      result = call '1.a 2, 3'
      expect(result['type']).to eq 'send'

      expect(result['target']['value']).to eq '1'
      expect(result['message']).to eq 'a'
      expect(result['args'].map { |a| a['value'] }).to eq ['2', '3']
    end

    example 'with operator' do
      result = call '1 % 2'
      expect(result['type']).to eq 'send'

      expect(result['target']['value']).to eq '1'
      expect(result['message']).to eq '%'
      expect(result['args'].map { |a| a['value'] }).to eq ['2']
    end
  end
end
