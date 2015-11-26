module Token
  Text = Struct.new :raw_token, :index do
    def to_s
      raw_token.inspect
    end
  end
  EOS = Class.new Text do
    def initialize(index)
      super "", index
    end
    def to_s
      "EOS"
    end
  end
  Indent = Class.new Text do
    def to_s
      "Indent"
    end
  end
  Outdent = Class.new do
    def to_s
      "Outdent"
    end
  end
end

def tokenize(raw_code)
  tokens  = []
  token   = ""
  consume_if = lambda do |bool|
    return unless bool
    tokens << token unless token.empty?
    token = ""
  end
  raw_code.each_char do |char|
    case char
    when /\w/, /\d/, '.'
      consume_if[token !~ /\A[\w\d.]*\z/]
      token << char
    when /\s/
      consume_if[token !~ /\A *\z/]
      token << char
      consume_if[token == "  "]
    when '(', ')', "\n"
      consume_if[true]
      tokens << char
    else raise "WHAT IS THIS: #{char.inspect}"
    end
  end
  tokens
end

def lex(raw_tokens)
  tokens      = []
  index       = 0
  indentation = 0
  until raw_tokens.empty?
    raw_token = raw_tokens.shift
    if raw_token == "\n"
      tokens << Token::Text.new("\n", index)
      index += 1
      new_indentation = 0
      while raw_tokens[0] == "  "
        raw_token = raw_tokens.shift
        new_indentation += 1
        if indentation < new_indentation
          tokens << Token::Indent.new(raw_token, index)
          indentation += 1
        end
        index += raw_token.length
      end
      while new_indentation < indentation
        tokens << Token::Outdent.new
        indentation -= 1
      end
    else
      tokens << Token::Text.new(raw_token, index)
      index += raw_token.length
    end
  end
  until indentation.zero?
    tokens << Token::Outdent.new
    indentation -= 1
  end
  tokens << Token::EOS.new(index)
  tokens
end


require 'io/console'
require 'coderay'
class Debugger
  def initialize(outstream:, instream:, code:, tokens:, enabled:)
    @outstream, @instream, @code, @tokens, @enabled, @stack = outstream, instream, code, tokens, enabled, []
  end

  def disable()  @enabled = false end
  def enable()   @enabled = true  end
  def enabled?() @enabled         end

  def leave
    stack.pop
  end

  def visit(parser, token_index)
    stack.push [parser, token_index]
    return unless enabled?
    height, width        = outstream.winsize
    lengths, token_lines = highlighted_token_lines(token_index, height).transpose
    needed_width         = lengths.max

    outstream.print clear_screen
    outstream.puts title('TOKENS'), "", *token_lines

    [ title('CODE'),
      "",
      *highlighted_code_lines_for(tokens[token_index]),
      "",
      "",
      title('PARSERS'),
      "",
      *highlighted_parser_lines
    ].each.with_index 1 do |line, index|
      outstream.print "\e[#{index};#{needed_width+1}H   #{line}"
    end
    outstream.print reset_formatting
    instream.noecho { instream.gets }
  end

  def highlight_ruby(ruby)
    CodeRay.encode ruby, :ruby, :terminal
  end

  def clear_screen
    "\e[H\e[2J"
  end

  def reset_formatting
    "\e[0m"
  end

  def title(title, body="")
    indentation = title.length + 3
    "#{reset_formatting}\e[44m #{title} \e[49m #{body.gsub(/^/, ' '*indentation)[indentation..-1]}"
  end

  private

  attr_reader :outstream, :instream, :code, :tokens, :stack

  def highlighted_code_lines_for(token)
    return code().lines.map(&:chomp) unless range = code_range_for(token)
    code = code().dup
    if code[range] == "\n"
      code[range] = "\e[45m\\n\e[0m\n"
    else
      code[range] = "\e[45m#{code[range]}\e[0m"
    end
    code.lines.map(&:chomp)
  end

  def code_range_for(token)
    return unless token.respond_to?(:index)
    token.index...(token.index + token.raw_token.length)
  end

  def highlighted_token_lines(token_index, available)
    tokens.map.with_index do |token, i|
      string = "%3d. %s" % [i, token]
      length = string.length
      string = highlight_ruby(string)
      if i == token_index
        bgcolor = "\e[48;5;#{16+1*6+1}m"
        string.gsub! "\e[0m", "\e[0m#{bgcolor}"
        string = "#{bgcolor}#{string}\e[0m"
      end
      [length, string]
    end
  end

  def highlighted_parser_lines
    rows, i = [], -1
    while (i+=1) < stack.length
      parser, token_index = stack[i]
      next if parser[:type] == :delegate
      current_token = tokens[token_index]
      rows << [ [ current_token.to_s.length+1,
                  "\e[33m#{current_token}\e[39m ",
                ],
                parser.length_highlight( successor: stack[i+1].to_a.first,
                                         token:     current_token,
                                         raw_token: raw_token_for(current_token),
                                         depth:     0,
                                       ),
              ]
    end
    widths    = rows.transpose.map { |col| col.map { |width,text| width }.max }
    widths[0] = tokens.map { |t| t.to_s.length }.max + 1 # use largest token for width, even if it's not in current output. This keeps it from jumping around
    rows.map { |row|
      widths.zip(row).map { |target_width, (actual_with, text)|
        text+" "*(target_width-actual_with)
      }.join(" ")
    }
  end

  def raw_token_for(token)
    return token.raw_token if token.kind_of? Token::Text
    token.class.name[/[^:]+$/]
  end
end

class ParseTree
  class ParserDefinition < Hash
    def self.with_attrs(*attrs, &length_highlight)
      Class.new self do
        attrs.each { |attr| define_method(attr) { fetch attr } }
        define_method(:length_highlight, &length_highlight) if length_highlight
      end
    end

    def initialize(**options)
      replace options
    end

    def type
      fetch :type
    end

    def leaf?
      false
    end

    def to_s(depth=0)
      type.to_s
    end

    def length_highlight(successor:nil, depth:0, color:true, **)
      if color
        len_highlight_helper type, successor, type.to_s
      else
        [type.to_s.length, type.to_s]
      end
    end

    def len_highlight_helper(*args)
      self.class.len_highlight_helper(*args)
    end
    def self.len_highlight_helper(child, successor, child_highlighted, length=child_highlighted.length)
      if successor == child
        [length, "\e[32m#{child_highlighted}\e[39m"]
      else
        [length, child_highlighted]
      end
    end

    Leaf = Class.new(self) { def leaf?() true end }

    group = -> collection, delimiter, successor, depth do
      lengths, strings = collection.map { |e|
        child_width, child_highlighted = e.length_highlight(depth: depth+1, color: false)
        len_highlight_helper e, successor, child_highlighted, child_width
      }.transpose
      grouped = strings.join(delimiter)
      lengths << (strings.length-1)*delimiter.length
      unless collection.length < 2 || depth.zero?
        grouped = "(#{grouped})"
        lengths << 2
      end
      [lengths.inject(0, :+), grouped]
    end

    Sequence   = with_attrs(:children)   { |successor:nil, depth:0,**| group[children, " ",   successor, depth] }
    FirstMatch = with_attrs(:from)       { |successor:nil, depth:0,**| group[from,     " | ", successor, depth] }
    Zom        = with_attrs(:of)         { |successor:nil, depth:0,**|
                                           child_length, child_hi = of.length_highlight(depth: depth+1)
                                           _, highlighted = len_highlight_helper of, successor, "#{child_hi}*"
                                           [child_length+1, highlighted]
                                         }
    Opt        = with_attrs(:parser)     { |successor:nil, depth:,**| len_highlight_helper parser, successor, "#{parser.length_highlight(depth: depth+1, color: false).last}?"     }
    Text       = Leaf.with_attrs(:text)  { |color:true, token:nil, raw_token:"",**|
                                           [text.inspect.length,  (color ? "\e[3#{text==raw_token  ? 2 : 1}m#{text.inspect}\e[39m"  : text.inspect)]
                                         }
    Regex      = Leaf.with_attrs(:regex) { |color:true, token:nil, raw_token:"",**|
                                           [regex.inspect.length, (color ? "\e[3#{regex=~raw_token ? 2 : 1}m#{regex.inspect}\e[39m" : regex.inspect)]
                                         }
    Indent     = Leaf.with_attrs(:regex) { |color:true, token:nil, raw_token:"",**|
                                           name="Indent"
                                           [name.length, (color ? "\e[3#{token.kind_of?(Token::Indent) ? 2 : 1}m#{name}\e[39m" : name)]
                                         }
    Outdent    = Leaf.with_attrs(:regex) { |color:true, token:nil, raw_token:"",**|
                                           name="Outdent"
                                           [name.length, (color ? "\e[3#{token.kind_of?(Token::Outdent) ? 2 : 1}m#{name}\e[39m" : name)]
                                         }
    EOS        = Leaf.with_attrs(:regex) { |color:true, token:nil, raw_token:"",**|
                                           name="EOS"
                                           [name.length, (color ? "\e[3#{token.kind_of?(Token::EOS) ? 2 : 1}m#{name}\e[39m" : name)]
                                         }
    Delegate   = with_attrs(:to)         { |successor:nil,**|         len_highlight_helper to, successor, to.to_s }
    class Delegate
      def to_s(depth=0)
        to.to_s
      end
    end
  end
  Defn = ParserDefinition

  def self.call(tokens, debugger, &define_parsers)
    parsers = instance_eval &define_parsers
    new(tokens, parsers, debugger).call
  end

  [ def self.delegate(name)        Defn::Delegate.new   type: :delegate, to: name           end,
    def self.sequence(*children)   Defn::Sequence.new   type: :sequence, children: children end,
    def self.zero_or_more(parser)  Defn::Zom.new        type: :zero_or_more, of: parser     end,
    def self.optional(parser)      Defn::Opt.new        type: :optional, parser: parser     end,
    def self.first_match(*options) Defn::FirstMatch.new type: :first_match, from: options   end,
    def self.text(text)            Defn::Text.new       type: :text, text: text             end,
    def self.regex(regex)          Defn::Regex.new      type: :regex, regex: regex          end,
    def self.eos()                 Defn::EOS.new        type: :eos                          end,
    def self.indent()              Defn::Indent.new     type: :indent                       end,
    def self.outdent()             Defn::Outdent.new    type: :outdent                      end,
  ].each do |method_name|
    m = method(method_name)
    define_singleton_method method_name do |*args, &to_ast|
      parser = m.call(*args)
      parser[:to_ast] = to_ast
      parser
    end
  end

  class TreeHash < Hash
    def self.with_getters(*getters, &default_to_ast)
      Class.new self do
        define_method :to_ast do
          ast = (self[:to_ast]||default_to_ast).call(self)
        end
        getters.each do |getter|
          define_method(getter) { fetch getter }
        end
      end
    end
    def initialize(**options) replace options           end
    def type()                fetch :type               end
    def start_token()         fetch :start_token        end
    def end_token()           fetch :end_token          end
    def tokens()              fetch :tokens             end
    def to_ast()              fetch(:to_ast).call(self) end
    Sequence = with_getters :children
    Delegate = with_getters(:to, :child) { |del| del.child.to_ast }
    Optional = with_getters(:child)      { |opt| opt.child && opt.child.to_ast }
  end

  def initialize(tokens, parsers, debugger)
    self.tokens, self.parsers, self.debugger = tokens, parsers, debugger
  end

  def call
    parse self.class.delegate(:root), 0
  end

  private
  attr_accessor :tokens, :parsers, :debugger

  def parse(parser, start_token)
    debugger.visit parser, start_token
    case parser.fetch(:type)
    when :sequence
      child_index = start_token
      children = parser.fetch(:children).each_with_object([]) do |parser, children|
        break nil unless child = parse(parser, child_index)
        children << child
        child_index = child.fetch(:end_token)
      end
      children and TreeHash::Sequence.new type:        :sequence,
                                          children:    children,
                                          to_ast:      parser[:to_ast],
                                          tokens:      tokens,
                                          start_token: start_token,
                                          end_token:   children.last[:end_token]
    when :delegate
      if child = parse(parsers[parser[:to]], start_token)
        TreeHash::Delegate.new type:        :delegate,
                               to:          parser[:to],
                               child:       child,
                               to_ast:      parser[:to_ast],
                               tokens:      tokens,
                               start_token: start_token,
                               end_token:   child[:end_token]
      end
    when :zero_or_more
      children = []
      end_token = start_token
      loop do
        child = parse parser.fetch(:of), end_token
        break unless child
        children << child
        end_token = child.fetch(:end_token)
      end
      TreeHash::Sequence.new type:        :sequence,
                             children:    children,
                             to_ast:      parser[:to_ast],
                             tokens:      tokens,
                             start_token: start_token,
                             end_token:   end_token
    when :first_match
      parser.fetch(:from).each do |child|
        result = parse child, start_token
        return result if result
      end
      nil
    when :optional
      if child = parse(parser.fetch(:parser), start_token)
        TreeHash::Optional.new type:        :optional,
                               child:       child,
                               to_ast:      parser[:to_ast],
                               tokens:      tokens,
                               start_token: start_token,
                               end_token:   child[:end_token]
      else
        TreeHash::Optional.new type:        :optional,
                               child:       nil,
                               to_ast:      parser[:to_ast],
                               tokens:      tokens,
                               start_token: start_token,
                               end_token:   start_token
      end
    when :text
      if tokens[start_token].kind_of?(Token::Text) && tokens[start_token].raw_token == parser.fetch(:text)
        TreeHash.new type:        :text,
                     tokens:      tokens,
                     to_ast:      parser[:to_ast],
                     start_token: start_token,
                     end_token:   start_token+1
      end
    when :regex
      if tokens[start_token].kind_of?(Token::Text) && tokens[start_token].raw_token =~ parser.fetch(:regex)
        TreeHash.new type:        :regex,
                     tokens:      tokens,
                     to_ast:      parser[:to_ast],
                     start_token: start_token,
                     end_token:   start_token+1
      end
    when :eos
      if tokens[start_token].kind_of?(Token::EOS)
        TreeHash.new type:        :eos,
                     tokens:      tokens,
                     to_ast:      parser[:to_ast],
                     start_token: start_token,
                     end_token:   start_token
      end
    when :indent
      if tokens[start_token].kind_of?(Token::Indent)
        TreeHash.new type:        :indent,
                     tokens:      tokens,
                     to_ast:      parser[:to_ast],
                     start_token: start_token,
                     end_token:   start_token+1
      end
    when :outdent
      if tokens[start_token].kind_of?(Token::Outdent)
        TreeHash.new type:        :outdent,
                     tokens:      tokens,
                     to_ast:      parser[:to_ast],
                     start_token: start_token,
                     end_token:   start_token+1
      end
    else raise "WHAT PARSER IS THIS? #{parser.inspect}"
    end
  ensure
    debugger.leave
  end
end


def parse_tree_for(code, tokens, debugger)
  code_for = -> tree do
    start_token = tree.fetch :start_token
    end_token   = tree.fetch :end_token
    start_token += 1 while start_token < end_token && !tokens[start_token].kind_of?(Token::Text)
    end_token   -= 1 while start_token < end_token && !tokens[end_token].kind_of?(Token::Text)
    start_index, end_index = [ tokens[start_token],
                               tokens[end_token],
                             ].select { |tok| tok.respond_to? :index }
                              .map(&:index)
    if start_index && end_index
      code[start_index...end_index]
    else
      ""
    end
  end

  ParseTree.call tokens, debugger do
    { # root:       statements eos
      root: sequence(delegate(:statements), eos) { |seq|
        seq.children.first.to_ast
      },

      # statements: statement*
      statements: zero_or_more(delegate :statement) { |zom|
        if zom.children.length == 1
          zom.children.first.to_ast
        else
          {type: :statements, children: zom.children.map(&:to_ast)}
        end
      },

      # statement:  (function | nested_line | line) "\n"?
      statement: sequence(
        first_match(delegate(:function), delegate(:nested_line), delegate(:line)),
        optional(text("\n"))
      ) { |seq| seq.children.first.to_ast },

      # function:   identifier argument_list "\n" indent statements outdent
      function: sequence(
        delegate(:identifier), delegate(:argument_list),
        text("\n"), indent, delegate(:statements), outdent
      ) { |seq|
        name, args, _newline, _indent, body, * = seq.children
        {type: :function, name: name.to_ast, parameters: args.to_ast, body: body.to_ast}
      },

      # argument_list: '(' identifier ')'
      argument_list: sequence(text('('), delegate(:identifier), text(')')) { |seq|
        seq.children[1].to_ast
      },

      # identifier: /[\w\d.]+/
      identifier: regex(/[\w\d.]+/) { |reg| {type: :identifier, value: code_for[reg]} },

      # nested_line: line "\n" indent statements outdent
      nested_line: sequence(
        delegate(:line), text("\n"),
        indent, delegate(:statements), outdent
      ) { |seq|
        parent, _newline, _indent, statements, outdent = seq.children.to_a
        {type: :nested, parent: parent.to_ast, children: statements.to_ast}
      },

      # line:        identifier
      line: delegate(:identifier) { |del| del.child.to_ast },
    }
  end
end

code = <<LANG
fn(arg)
  a0
    a0.0
      a0.0.0
  b0
    b0.0
    b0.1
      b0.1.0
    b0.2
LANG

debug    = ARGV.any?
tokens   = lex tokenize code
debugger = Debugger.new outstream: $stdout,
                        instream:  $stdin,
                        code:      code,
                        tokens:    tokens,
                        enabled:   debug
parse_tree = parse_tree_for(code, tokens, debugger)

# -----  Display the results  -----
require 'pp'

just_essentials = -> tree do
  case tree
  when Hash
    tree.reject { |k, v| [:to_ast, :tokens, :start_token, :end_token].include?(k) }
        .map    { |k, v| [k, just_essentials[v]] }
        .to_h
  when Array
    tree.map { |e| just_essentials[e] }
  else
    tree
  end
end

puts debugger.title("CODE", code),
     "",
     debugger.title("ABSTRACT SYNTAX TREE",
                    debugger.highlight_ruby(parse_tree.to_ast.pretty_inspect)),
     "",
     debugger.title("PARSE TREE",
                    debugger.highlight_ruby(just_essentials[parse_tree].inspect)),
     "",
     "\e[41m PRESS RETURN TO WATCH INTERACTIVE PARSING (press return after each pause) \e[0m"
gets

debugger.enable
parse_tree_for code, tokens, debugger
print "\e[41m FINISHED \e[0m"
gets
puts "", "\e[H\e[2J#{debugger.highlight_ruby parse_tree.to_ast.pretty_inspect}"
