require 'defs/parse_instructions'

RSpec.describe Defs::ParseInstruction do
  def parses!(instructions, expected)
    lines  = instructions.lines.map(&:chomp)
    actual = Defs::ParseInstruction.call(lines)
    expect(actual).to eq expected
  end

  describe 'running a machine' do
    xit 'can be run with no args' do
      parses! '/abc',   [[:runMachine, [:ast], []]]
      parses! '/abc()', [[:runMachine, [:ast], []]]
    end

    xit 'can be run with a namespace' do
      parses! '/a/b/c', [[:runMachine, [:a, :b, :c], []]]
    end

    it 'allows include lookups in the namespace'
    # /a/@b
    # /a/@b/c
    # /a/$b
    # /a/@b.c
    # /a/@b.c/d
    # /a/@b.c/$e.f.g/h

    xit 'can pass registers as arguments' do
      parses! '/a(@b)',     [[:runMachine, [:a], [:@b]]]
      parses! '/a(@b, @c)', [[:runMachine, [:a], [:@b, :@c]]]
    end

    xit 'includes instructions to turn non-register arguments into registers' do
      parses! '/a($b)', [
        [:globalToRegister, :b, :@_1],
        [:runMachine, [:a], [:@_1]],
      ]
      parses! '/a($b, @c, $d)', [
        [:globalToRegister, :b, :@_1],
        [:globalToRegister, :d, :@_2],
        [:runMachine, [:a], [:@_1, :@c, :@_2]],
      ]
    end
  end

  describe 'expanding ivars' do
    # @a
    # @a.b
    # @a.b.c
    # $a
    # $a.b
    # {}
  end

  describe 'setting values' do
    it 'sets lhs / rhs if they are both ivars'
    it 'expands rhs to an ivar'
    it 'expands lhs to an ivar'
    # $currentBinding.returnValue <- @value
    #     [:globalToRegister, :currentBinding, :@_1],
    #     [:setKey, :@_1, :returnValue, :@value],

    it 'allows `self` on lhs, with a machine to become, on rhs'
    # self <- /ast/@ast.type
    #   [:getKey, :@_1, :@ast, :type],
    #   [:becomeMachine, [:ast, :@_1]],

    it 'is an error to have any code after setting self'
  end

  describe 'working with arrays' do
    describe 'append' do
      it 'expands lhs and rhs to ivars' do
        parses! '@a << @b',   [[:aryAppend, :@a, :@b]]
        parses! '$a << $b',   [[:globalToRegister, :a, :@_1],
                               [:globalToRegister, :b, :@_2],
                               [:aryAppend, :@_1, :@_2]]
      end
    end


    describe 'for loop' do
      # "for @expression in @ast.expressions"
      # "  /ast(@expression)"
      # "/reemit"
      #         [:setInt, :@_1, 0],
      #         [:getKey, :@_2, :@ast, :expressions],
      #         [:getKey, :@_3, :@_2,  :length],

      #         [:label, :forloop],
      #           [:eq, :@_4, :@_1, :@_3], # var4 = (index == length)
      #           [:jumpToIf, :forloop_end, :@_4],
      #           [:getKey, :@expression, :@_2, :@_1],
      #           [:runMachine, [:ast], [:@expression]],
      #           [:add, :@_1, 1],
      #           [:jumpTo, :forloop],
      #         [:label, :forloop_end],

      #         [:runMachine, [:reemit], []],
    end
  end

  describe 'working with hashes' do
    describe 'literal' do
      it 'creates an empty hash literal' do
        parses! '@a <- {}', [[:newHash, :@a]]
        # parses! '$a <- {}', [[:newHash, :@_1],
                             # [:registerToGlobal, :@_1, :a]]
      end
    end
  end
end
