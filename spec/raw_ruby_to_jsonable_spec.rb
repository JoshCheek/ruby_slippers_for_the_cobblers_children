require 'app'

# You can test what Parser returns for some given syntax with:
# $ ruby-parse -e 'def a() 1 end'
# (def :a
#   (args)
#   (int 1))

# TODO:
#   lookup_x_variable / assign_x_variable should instead be get_x_variable / set_x_variable

RSpec.describe RawRubyToJsonable do
  # I don't know what I want yet, just playing to see
  # probably look at SiB for a start

  def call(raw_code)
    json = RawRubyToJsonable.call raw_code
    assert_valid json
    json
  end

  def assert_valid(json)
    case json
    when String, Fixnum, nil, true, false
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

  def parses_int!(code, expected_value)
    is_int! call(code), expected_value
  end

  def is_int!(result, expected_value)
    expect(result['type']).to eq 'integer'
    expect(result['value']).to eq expected_value
  end

  def parses_string!(code, expected_value)
    is_string! call(code), expected_value
  end

  def is_string!(result, expected_value)
    expect(result['type']).to eq 'string'
    expect(result['value']).to eq expected_value
  end

  def parses_float!(code, expected_value)
    is_float! call(code), expected_value
  end

  def is_float!(result, expected_value)
    expect(result['type']).to eq 'float'
    expect(result['value']).to eq expected_value
  end

  def parses_symbol!(code, expected_value)
    is_symbol! call(code), expected_value
  end

  def is_symbol!(result, expected_value)
    expect(result['type']).to eq 'symbol'
    expect(result['value']).to eq expected_value
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
    example('Fixnum')          { parses_int! '1',      '1' }
    example('-Fixnum')         { parses_int! '-1',     '-1' }
    example('Bignum')          { parses_int! '111222333444555666777888999', '111222333444555666777888999' }
    example('underscores')     { parses_int! '1_2_3',  '123' }
    example('binary literal')  { parses_int! '0b101',  '5' }
    example('-binary literal') { parses_int! '-0b101', '-5' }
    example('octal literal')   { parses_int! '0101',   '65' }
    example('-octal literal')  { parses_int! '-0101',  '-65' }
    example('hex literal')     { parses_int! '0x101',  '257' }
    example('-hex literal')    { parses_int! '-0x101', '-257' }
  end

  describe 'float literals' do
    example('normal')              { parses_float! '1.0',    '1.0' }
    example('negative')            { parses_float! '-1.0',   '-1.0' }
    example('scientific notation') { parses_float! '1.2e-3', '0.0012' }
  end

  describe 'string literals' do
    example('single quoted')         { parses_string! "'a'",    'a' }
    example('double quoted')         { parses_string! '"a"',    'a' }

    example('% paired delimiter')    { parses_string! '%(a)',   'a' }
    example('%q paired delimiter')   { parses_string! '%q(a)',  'a' }
    example('%Q paired delimiter')   { parses_string! '%Q(a)',  'a' }

    example('% unpaired delimiter')  { parses_string! '%_a_',   'a' }
    example('%q unpaired delimiter') { parses_string! '%q_a_',  'a' }
    example('%Q unpaired delimiter') { parses_string! '%Q_a_',  'a' }

    example('single quoted newline') { parses_string! '\'\n\'',  "\\n" }
    example('double quoted newline') { parses_string! '"\n"',    "\n"  }
    example('% newline')             { parses_string! '%(\n)',   "\n"  }
    example('%q newline')            { parses_string! '%q(\n)',  "\\n" }
    example('%Q newline')            { parses_string! '%Q(\n)',  "\n"  }

    example 'interpolation' do
      result = call '"a#{1}b"'
      expect(result['type']).to eq 'interpolated_string'
      expect(result['segments'].size).to eq 3

      a, exprs, b = result['segments']
      is_string! a, 'a'
      is_string! b, 'b'

      expect(exprs['expressions'].size).to eq 1
      is_int! exprs['expressions'][0], '1'
    end

    example 'heredoc' do
      parses_string! "<<abc\nd\nabc", "d\n"
      # for w/e reason, when you put a newline in a heredoc, it parses it as a dstr instead of a str
      # parses_string! "<<abc\nd\ne\nabc",  "def"
      # parses_string! "<<-abc\nd\ne\nabc", "def"
    end
  end

  context 'symbol literals' do
    example 'without quotes' do
      parses_symbol! ':abc', 'abc'
    end
    example 'with quotes' do
      parses_symbol! ':"a b\tc"', "a b\tc"
    end
    example 'interpolation' do
      result = call ':"a#{1}b"' # (dsym (str "a") (begin (int 1)) (str "b"))
      expect(result['type']).to eq 'interpolated_symbol'
      expect(result['segments'].size).to eq 3

      a, exprs, b = result['segments']
      is_string! a, 'a'
      is_string! b, 'b'

      expect(exprs['expressions'].size).to eq 1
      is_int! exprs['expressions'][0], '1'
    end
  end

  context 'executable strings' do
    example 'backticks' do
      result = call '`a`'
      expect(result['type']).to eq 'executable_string'
      expect(result['segments'].size).to eq 1
      is_string! result['segments'][0], "a"
    end
    # TODO: What is heredoc with executable string?
  end

  context 'regular expressions' do
    def parses_regex!(code, *args)
      is_regex! call(code), *args
    end

    def is_regex!(result, *expected_values, options: [])
      expect(result['type']).to eq 'regular_expression'
      actual_values = result['segments'].map { |s| s['expressions'] || s }.flatten.map { |node| node['value'] }
      expect(actual_values.size).to eq expected_values.size
      [expected_values, actual_values].transpose.each { |expected_value, actual_value|
        expect(actual_value).to eq expected_value
      }

      expect(result['options']['ignorecase']).to eq options.include?(:ignorecase)
      expect(result['options']['extended']).to   eq options.include?(:extended)
      expect(result['options']['multiline']).to  eq options.include?(:multiline)
      # TODO: Figure out how to turn on :FIXEDENCODING, and :NOENCODING
    end

    example('slashes')                     { parses_regex! '/a/',    'a' }
    example('%r with paired delimiters')   { parses_regex! '%r(a)',  'a' }
    example('%r with unpaired delimiters') { parses_regex! '%r.a.',  'a' }
    example('slashes with options')        { parses_regex! '/a/i',   'a', options: [:ignorecase] }
    example('%r with options')             { parses_regex! '/a/i',   'a', options: [:ignorecase] }
    example('all options')                 { parses_regex! '/a/ixm', 'a', options: [:ignorecase, :extended, :multiline] }

    example 'slashes with interpolation' do
      parses_regex! '/a#{1}b/',  'a', '1', 'b'
      parses_regex! '/a#{1}b/i', 'a', '1', 'b', options: [:ignorecase]
    end

    example '%r with interpolation' do
      parses_regex! '%r(a#{1}b)',  'a', '1', 'b'
      parses_regex! '%r(a#{1}b)i', 'a', '1', 'b', options: [:ignorecase]
    end
  end

  context 'array literals' do
    example 'empty' do
      result = call '[]'
      expect(result['type']).to eq 'array'
      expect(result['elements']).to be_empty
    end

    example 'not empty' do
      result = call '["a", 1]'
      expect(result['type']).to eq 'array'
      a, one = result['elements']
      is_string! a,   "a"
      is_int!    one, "1"
    end
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

      expr1, expr2, *rest = result['expressions']
      expect(rest).to be_empty

      expect(expr1['type']).to eq 'integer'
      expect(expr1['value']).to eq '9'

      expect(expr2['type']).to eq 'integer'
      expect(expr2['value']).to eq '8'
    end

    example 'multiple expressions, parentheses bookends, newline delimited' do
      result = call "(9\n8)"
      expect(result['type']).to eq 'expressions'
      expect(result['expressions'].size).to eq 2
    end

    example 'multiple expressions, begin/end bookends, newline delimited' do
      result = call "begin\n 1\nend"
      pp result
      expect(result['type']).to eq 'keyword_begin'
      expr, *rest = result['expressions']
      expect(rest).to be_empty
      expect(expr['type']).to eq 'integer'
      expect(expr['value']).to eq '1'
    end

    example 'semicolon delimited' do
      result = call "1;2"
      expect(result['type']).to eq 'expressions'
      expect(result['expressions'].size).to eq 2

      result = call "(1;2)"
      expect(result['type']).to eq 'expressions'
      expect(result['expressions'].size).to eq 2

      result = call "begin;1;end"
      expect(result['type']).to eq 'keyword_begin'
      expect(result['expressions'].size).to eq 1
    end
  end

  example 'set and get local variable' do
    result = call "a = 1; a"
    set, get = result['expressions']
    expect(set['type']).to eq 'assign_local_variable'
    expect(set['name']).to eq 'a'

    val = set['value']
    expect(val['type']).to eq 'integer'
    expect(val['value']).to eq '1'

    expect(get['type']).to eq 'lookup_local_variable'
    expect(get['name']).to eq 'a'
  end


  describe 'class definitions', t:true do
    example 'implicit toplevel' do
      result = call 'class A;end'
      expect(result['type']).to eq 'class'
      expect(result['superclass']).to eq nil
      expect(result['body']).to eq nil

      name_lookup = result['name_lookup']
      expect(name_lookup['type']).to eq 'constant'
      expect(name_lookup['namespace']).to eq nil
      expect(name_lookup['name']).to eq 'A'
    end

    example 'explicit toplevel' do
      result = call 'class ::A;end'
      expect(result['type']).to eq 'class'
      expect(result['superclass']).to eq nil
      expect(result['body']).to eq nil

      name_lookup = result['name_lookup']
      expect(name_lookup['type']).to eq 'constant'
      expect(name_lookup['namespace']).to eq 'type' => 'toplevel_constant'
      expect(name_lookup['name']).to eq 'A'
    end

    example 'direct namespacing' do
      result = call 'class String::A;end'
      expect(result['type']).to eq 'class'
      expect(result['superclass']).to eq nil
      expect(result['body']).to eq nil

      name_lookup = result['name_lookup']
      expect(name_lookup['type']).to eq 'constant'
      expect(name_lookup['name']).to eq 'A'

      namespace = name_lookup['namespace']
      expect(namespace['type']).to eq 'constant'
      expect(namespace['name']).to eq 'String'
      expect(namespace['namespace']).to eq nil
    end

    example 'inheriting' do
      result = call 'class A < B; end'
      expect(result['type']).to eq 'class'
      expect(result['body']).to eq nil

      name_lookup = result['name_lookup']
      expect(name_lookup['type']).to eq 'constant'
      expect(name_lookup['namespace']).to eq nil
      expect(name_lookup['name']).to eq 'A'

      superclass = result['superclass']
      expect(superclass['type']).to eq 'constant'
      expect(superclass['namespace']).to eq nil
      expect(superclass['name']).to eq 'B'
    end

    example 'with a body' do
      result = call 'class A; 1; end'
      expect(result['type']).to eq 'class'
      expect(result['superclass']).to eq nil

      name_lookup = result['name_lookup']
      expect(name_lookup['type']).to eq 'constant'
      expect(name_lookup['namespace']).to eq nil
      expect(name_lookup['name']).to eq 'A'

      is_int! result['body'], '1'
    end
  end

  context 'instance method definitions' do
    example 'simple definition' do
      # (def :a (args) nil)
      method_definition = call 'def a; end'
      expect(method_definition['type']).to eq 'method_definition'
      expect(method_definition['args']).to eq []
      expect(method_definition['body']).to eq nil
    end

    context 'with args' do
      example 'required arg' do
        # (def :a (args (arg :b)) nil)
        method_definition = call 'def a(b) end'
        expect(method_definition['type']).to eq 'method_definition'
        arg, *rest = method_definition['args']
        expect(rest).to be_empty

        expect(arg['type']).to eq 'required_arg'
        expect(arg['name']).to eq 'b'

        expect(method_definition['body']).to eq nil
      end

      example 'optional arg'
      example 'splatted args'
      example 'required keyword arg'
      example 'optional keyword arg'
      example 'remaining keyword args'
      example 'block arg'
      example 'all together'
    end

    example 'with a body' do
      # (def :a (args) (int 1))
      method_definition = call 'def a() 1 end'
      expect(method_definition['type']).to eq 'method_definition'
      expect(method_definition['args']).to eq []
      expect(method_definition['body']['type']).to eq 'integer'
    end
  end

  describe 'module definitions'

  context 'keywords' do
    example 'self' do
      expect(call('self')['type']).to eq 'self'
    end
  end

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

  context 'variables' do
    context 'instance variables' do
      example 'getting' do
        result = call '@abc' # (ivar :@abc)
        expect(result['type']).to eq 'lookup_instance_variable'
        expect(result['name']).to eq '@abc'
      end
      example 'setting' do
        result = call '@abc = 1' # (ivasgn :@abc (int 1))
        expect(result['type']).to eq 'assign_instance_variable'
        expect(result['name']).to eq '@abc'
        expect(result['value']['value']).to eq '1'
      end
    end
  end

  context 'Acceptance tests' do
    example 'Simple example' do
      result = call <<-CODE
        class User
          def initialize(name)
            self.name = name
          end

          def name
            @name
          end

          def name=(name)
            @name = name
          end
        end

        user = User.new("Josh")
        puts user.name
      CODE

      expect(result['type']).to eq 'expressions'
      expect(result['expressions'].map { |node| node['type'] })
        .to eq %w[class assign_local_variable send]
    end
  end
end
