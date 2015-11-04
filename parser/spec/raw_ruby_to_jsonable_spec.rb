require 'parse_server'

# You can test what Parser returns for some given syntax with:
# $ ruby-parse -e 'def a() 1 end'
# (def :a
#   (args)
#   (int 1))

RSpec.describe ParseServer::RawRubyToJsonable do
  # I don't know what I want yet, just playing to see
  # probably look at SiB for a start

  def call(raw_code, options={})
    json = ParseServer::RawRubyToJsonable.call raw_code, options
    assert_valid json
    json
  end

  def assert_valid(json)
    case json
    when String, Symbol, Fixnum, nil, true, false
      # no op
    when Array
      json.each { |element| assert_valid element }
    when Hash
      json.each do |k, v|
        raise unless k.kind_of?(String) || k.kind_of?(Symbol)
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
    expect(result[:type]).to eq :integer
    expect(result[:value]).to eq expected_value
  end

  def parses_string!(code, expected_value)
    is_string! call(code), expected_value
  end

  def is_string!(result, expected_value)
    expect(result[:type]).to eq :string
    expect(result[:value]).to eq expected_value
  end

  def parses_float!(code, expected_value)
    is_float! call(code), expected_value
  end

  def is_float!(result, expected_value)
    expect(result[:type]).to eq :float
    expect(result[:value]).to eq expected_value
  end

  def parses_symbol!(code, expected_value)
    is_symbol! call(code), expected_value
  end

  def is_symbol!(result, expected_value)
    expect(result[:type]).to eq :symbol
    expect(result[:value]).to eq expected_value
  end

  def has_standard_location!(node, filename, begin_pos, end_pos)
    expect(node[:location][:filename]).to eq filename
    expect(node[:location][:begin]).to eq begin_pos
    expect(node[:location][:end]).to eq end_pos
  end

  def standard_assertions(node, assertions)
    assertions.each do |k, v|
      case k
      when :type
        expect(node[:type]).to eq v
      when :location
        location = node.fetch(:location) { raise KeyError, ":location not in #{node.keys.inspect}" }
        filename, begin_pos, end_pos = v
        expect(location[:filename]).to eq filename
        expect(location[:begin]).to    eq begin_pos
        expect(location[:end]).to      eq end_pos
      end
    end
  end

  example 'true literal' do
    standard_assertions call('true', filename: 'f.rb'),
      type:     :true,
      location: ['f.rb', 0, 4]
  end

  example 'false literal' do
    standard_assertions call('false', filename: 'g.rb'),
      type:     :false,
      location: ['g.rb', 0, 5]
  end

  example 'nil literal' do
    standard_assertions call('nil', filename: 'somefile.rb'),
      type: :nil,
      location: ['somefile.rb', 0, 3]
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
    specify 'have a location' do
      standard_assertions call('123', filename: 'f.rb'), location: ['f.rb', 0, 3]
    end
  end

  describe 'float literals' do
    example('normal')              { parses_float! '1.0',    '1.0' }
    example('negative')            { parses_float! '-1.0',   '-1.0' }
    example('scientific notation') { parses_float! '1.2e-3', '0.0012' }
    specify 'have a location' do
      standard_assertions call('1.23', filename: 'f.rb'), location: ['f.rb', 0, 4]
    end
  end

  describe 'string literals' do
    specify 'have a location' do
      standard_assertions call('"abc"', filename: 'f.rb'), location: ['f.rb', 0, 5]
    end
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
      result = call '"a#{1}b"', filename: 'f.rb'
      standard_assertions result, type: :interpolated_string, location: ['f.rb', 0, 8]
      expect(result[:segments].size).to eq 3

      a, exprs, b = result[:segments]
      is_string! a, 'a'
      is_string! b, 'b'

      expect(exprs[:expressions].size).to eq 1
      is_int! exprs[:expressions][0], '1'
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
      standard_assertions call(':abc', filename: 'f.rb'), location: ['f.rb', 0, 4]
    end
    example 'with quotes' do
      parses_symbol! ':"a b\tc"', "a b\tc"
    end
    example 'interpolation' do
      result = call ':"a#{1}b"', filename: 'f.rb' # (dsym (str "a") (begin (int 1)) (str "b"))
      standard_assertions result, type: :interpolated_symbol, location: ['f.rb', 0, 9]
      expect(result[:segments].size).to eq 3

      a, exprs, b = result[:segments]
      is_string! a, 'a'
      is_string! b, 'b'

      expect(exprs[:expressions].size).to eq 1
      is_int! exprs[:expressions][0], '1'
    end
  end

  context 'executable strings' do
    example 'backticks' do
      result = call '`a`', filename: 'f.rb'
      standard_assertions result, type: :executable_string, location: ['f.rb', 0, 3]
      expect(result[:segments].size).to eq 1
      is_string! result[:segments][0], "a"
    end
    # TODO: What is heredoc with executable string?
  end

  context 'regular expressions' do
    def parses_regex!(code, *args)
      is_regex! call(code), *args
    end

    def is_regex!(result, *expected_values, options: [])
      expect(result[:type]).to eq :regular_expression
      actual_values = result[:segments].map { |s| s[:expressions] || s }.flatten.map { |node| node[:value] }
      expect(actual_values.size).to eq expected_values.size
      [expected_values, actual_values].transpose.each { |expected_value, actual_value|
        expect(actual_value).to eq expected_value
      }

      expect(result[:options][:ignorecase]).to eq options.include?(:ignorecase)
      expect(result[:options][:extended]).to   eq options.include?(:extended)
      expect(result[:options][:multiline]).to  eq options.include?(:multiline)
      # TODO: Figure out how to turn on :FIXEDENCODING, and :NOENCODING
    end

    it 'has a location' do
      standard_assertions call('/a/', filename: 'f.rb'),
        type: :regular_expression, location: ['f.rb', 0, 3]
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
      standard_assertions call('/a#{1}b/i', filename: 'f.rb'), location: ['f.rb', 0, 9]
    end

    example '%r with interpolation' do
      parses_regex! '%r(a#{1}b)',  'a', '1', 'b'
      parses_regex! '%r(a#{1}b)i', 'a', '1', 'b', options: [:ignorecase]
    end
  end

  context 'array literals' do
    example 'empty' do
      result = call '[]', filename: 'f.rb'
      standard_assertions result, type: :array, location: ['f.rb', 0, 2]
      expect(result[:elements]).to be_empty
    end

    example 'not empty' do
      result = call '["a", 1]', filename: 'f.rb'
      standard_assertions result, type: :array, location: ['f.rb', 0, 8]
      a, one = result[:elements]
      is_string! a,   "a"
      is_int!    one, "1"
    end
  end



  context 'single and multiple expressions' do
    example 'single expression is just the expression type' do
      result = call '1'
      expect(result[:type]).to eq :integer
      expect(result[:value]).to eq '1'
    end

    example 'multiple expressions, no bookends, newline delimited' do
      result = call "9\n8", filename: 'f.rb'
      standard_assertions result, type: :expressions, location: ['f.rb', 0, 3]

      expr1, expr2, *rest = result[:expressions]
      expect(rest).to be_empty

      expect(expr1[:type]).to eq :integer
      expect(expr1[:value]).to eq '9'

      expect(expr2[:type]).to eq :integer
      expect(expr2[:value]).to eq '8'
    end

    example 'multiple expressions, parentheses bookends, newline delimited' do
      result = call "(9\n8)", filename: 'f.rb'
      standard_assertions result, type: :expressions, location: ['f.rb', 0, 5]
      expect(result[:expressions].size).to eq 2
    end

    example 'multiple expressions, begin/end bookends, newline delimited' do
      result = call "begin\n 1\nend", filename: 'f.rb'
      standard_assertions result, type: :keyword_begin, location: ['f.rb', 0, 12]
      expr, *rest = result[:expressions]
      expect(rest).to be_empty
      expect(expr[:type]).to eq :integer
      expect(expr[:value]).to eq '1'
    end

    example 'semicolon delimited' do
      result = call "1;2", filename: 'f.rb'
      standard_assertions result, type: :expressions, location: ['f.rb', 0, 3]
      expect(result[:expressions].size).to eq 2

      result = call "(1;2)"
      expect(result[:type]).to eq :expressions
      expect(result[:expressions].size).to eq 2

      result = call "begin;1;end"
      expect(result[:type]).to eq :keyword_begin
      expect(result[:expressions].size).to eq 1
    end
  end

  example 'set and get local variable' do
    result = call "a = 1; a", filename: 'f.rb'
    set, get = result[:expressions]
    standard_assertions set, type: :set_local_variable, location: ['f.rb', 0, 5]
    expect(set[:name]).to eq 'a'

    val = set[:value]
    standard_assertions val, type: :integer, location: ['f.rb', 4, 5]
    expect(val[:value]).to eq '1'

    standard_assertions get, type: :get_local_variable, location: ['f.rb', 7, 8]
    expect(get[:name]).to eq 'a'
  end


  describe 'class definitions' do
    example 'implicit toplevel' do
      result = call 'class A;end', filename: 'f.rb'
      standard_assertions result, type: :class, location: ['f.rb', 0, 11]
      expect(result[:superclass]).to eq nil
      expect(result[:body]).to eq nil

      name_lookup = result[:name_lookup]
      standard_assertions name_lookup, type: :constant, location: ['f.rb', 6, 7]
      expect(name_lookup[:namespace]).to eq nil
      expect(name_lookup[:name]).to eq 'A'
    end

    example 'explicit toplevel' do
      result = call 'class ::A;end', filename: 'f.rb'
      expect(result[:type]).to eq :class
      expect(result[:superclass]).to eq nil
      expect(result[:body]).to eq nil

      name_lookup = result[:name_lookup]
      standard_assertions name_lookup, type: :constant, location: ['f.rb', 6, 9]
      standard_assertions name_lookup[:namespace], type: :toplevel_constant, location: ['f.rb', 6, 8]
      expect(name_lookup[:name]).to eq 'A'
    end

    example 'direct namespacing' do
      result = call 'class String::A;end', filename: 'f.rb'
      standard_assertions result, type: :class, location: ['f.rb', 0, 19]
      expect(result[:superclass]).to eq nil
      expect(result[:body]).to eq nil

      name_lookup = result[:name_lookup]
      standard_assertions name_lookup, type: :constant, location: ['f.rb', 6, 15]
      expect(name_lookup[:name]).to eq 'A'

      namespace = name_lookup[:namespace]
      standard_assertions namespace, type: :constant, location: ['f.rb', 6, 12]
      expect(namespace[:name]).to eq 'String'
      expect(namespace[:namespace]).to eq nil
    end

    example 'inheriting' do
      result = call 'class A < B; end', filename: 'f.rb'
      standard_assertions result, type: :class
      expect(result[:body]).to eq nil

      name_lookup = result[:name_lookup]
      expect(name_lookup[:type]).to eq :constant
      expect(name_lookup[:namespace]).to eq nil
      expect(name_lookup[:name]).to eq 'A'

      superclass = result[:superclass]
      standard_assertions superclass, type: :constant, location: ['f.rb', 10, 11]
      expect(superclass[:namespace]).to eq nil
      expect(superclass[:name]).to eq 'B'
    end

    example 'with a body' do
      result = call 'class A; 1; end', filename: 'f.rb'
      expect(result[:type]).to eq :class
      expect(result[:superclass]).to eq nil

      name_lookup = result[:name_lookup]
      expect(name_lookup[:type]).to eq :constant
      expect(name_lookup[:namespace]).to eq nil
      expect(name_lookup[:name]).to eq 'A'

      standard_assertions result[:body], type: :integer, location: ['f.rb', 9, 10]
      is_int! result[:body], '1'
    end
  end

  context 'instance method definitions' do
    example 'simple definition' do
      # (def :a (args) nil)
      method_definition = call 'def a; end', filename: 'f.rb'
      standard_assertions method_definition, type: :method_definition, location: ['f.rb', 0, 10]
      expect(method_definition[:name]).to eq 'a'
      expect(method_definition[:args]).to eq []
      expect(method_definition[:body]).to eq nil
    end

    context 'with args' do
      def assert_arg(arg_code:, type:)
        code              = "def a(#{arg_code}) end"
        method_definition = call code, filename: 'f.rb'
        standard_assertions method_definition, type: :method_definition, location: ['f.rb', 0, code.length]
        arg, *remaining_args = method_definition[:args]
        expect(remaining_args).to be_empty
        expect(method_definition[:body]).to eq nil
        standard_assertions arg, type: type, location: ['f.rb', 6, 6+arg_code.length]
        arg
      end

      example 'required arg' do
        arg = assert_arg arg_code: 'b', type: :required_arg
        expect(arg[:name]).to eq 'b'
      end

      example 'optional arg' do
        arg = assert_arg arg_code: 'b="a"', type: :optional_arg
        expect(arg[:name]).to eq 'b'
        is_string! arg[:default_value], "a"
      end

      example 'splatted args' do
        arg = assert_arg arg_code: '*b', type: :rest_arg
        expect(arg[:name]).to eq 'b'
      end

      example 'required keyword arg' do
        arg = assert_arg arg_code: 'b:', type: :keyword_arg
        expect(arg[:name]).to eq 'b'
      end

      example 'optional keyword arg' do
        arg = assert_arg arg_code: 'b: "s"', type: :optional_keyword_rest
        expect(arg[:name]).to eq 'b'
        is_string! arg[:default_value], "s"
      end

      example 'remaining keyword args' do
        arg = assert_arg arg_code: '**b', type: :keyword_rest_arg
        expect(arg[:name]).to eq 'b'
      end

      example 'block arg' do
        arg = assert_arg arg_code: '&b', type: :block_arg
        expect(arg[:name]).to eq 'b'
      end

      example 'shadowed arg'
      example 'all together'
    end

    example 'with a body' do
      # (def :a (args) (int 1))
      method_definition = call 'def a() 1 end', filename: 'f.rb'
      expect(method_definition[:type]).to eq :method_definition
      expect(method_definition[:args]).to eq []
      standard_assertions method_definition[:body], type: :integer, location: ['f.rb', 8, 9]
    end
  end

  describe 'module definitions'

  context 'keywords' do
    example 'self' do
      standard_assertions call('self', filename: 'f.rb'), type: :self, location: ['f.rb', 0, 4]
    end
  end

  context 'send' do
    example 'with no receiver' do
      result = call 'load', filename: 'f.rb'
      standard_assertions result, type: :send, location: ['f.rb', 0, 4]
      expect(result[:target]).to eq nil
      expect(result[:message]).to eq 'load'
      expect(result[:args]).to be_empty
    end

    example 'without args' do
      result = call '1.even?', filename: 'f.rb'
      standard_assertions result, type: :send, location: ['f.rb', 0, 7]

      expect(result[:target][:value]).to eq '1'
      expect(result[:message]).to eq 'even?'
      expect(result[:args]).to be_empty
    end

    example 'with args' do
      result = call '1.a 2, 3', filename: 'f.rb'
      standard_assertions result, type: :send, location: ['f.rb', 0, 8]

      expect(result[:target][:value]).to eq '1'
      expect(result[:message]).to eq 'a'
      standard_assertions result[:args][0], type: :integer, location: ['f.rb', 4, 5]
      standard_assertions result[:args][1], type: :integer, location: ['f.rb', 7, 8]
    end

    example 'with operator' do
      result = call '1 % 2', filename: 'f.rb'
      standard_assertions result, type: :send, location: ['f.rb', 0, 5]

      expect(result[:target][:value]).to eq '1'
      expect(result[:message]).to eq '%'
      expect(result[:args].map { |a| a[:value] }).to eq ['2']
    end
  end

  context 'variables' do
    context 'instance variables' do
      example 'getting' do
        result = call '@abc', filename: 'f.rb' # (ivar :@abc)
        standard_assertions result, type: :get_instance_variable, location: ['f.rb', 0, 4]
        expect(result[:name]).to eq '@abc'
      end
      example 'setting' do
        result = call '@abc = 1', filename: 'f.rb' # (ivasgn :@abc (int 1))
        standard_assertions result, type: :set_instance_variable, location: ['f.rb', 0, 8]
        expect(result[:name]).to eq '@abc'
        expect(result[:value][:value]).to eq '1'
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

      expect(result[:type]).to eq :expressions
      expect(result[:expressions].map { |node| node[:type] })
        .to eq [:class, :set_local_variable, :send]
    end
  end
end
