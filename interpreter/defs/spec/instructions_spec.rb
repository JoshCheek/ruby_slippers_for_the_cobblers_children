require 'defs/parse_instructions'

RSpec.describe Defs::ParseInstruction do
  def parses!(instructions, expected)
    lines  = instructions.lines.map(&:chomp)
    actual = Defs::ParseInstruction.call(lines)
    expect(actual).to eq expected
  end

  describe 'running a machine' do
    it 'can be run with no args' do
      parses! '/abc',   [[:runMachine, [:abc], []]]
      parses! '/abc()', [[:runMachine, [:abc], []]]
    end

    it 'can be run with a namespace' do
      parses! '/a/b/c', [[:runMachine, [:a, :b, :c], []]]
    end

    it 'allows include lookups in the namespace'
    # /a/@b
    # /a/@b/c
    # /a/$b
    # /a/@b.c
    # /a/@b.c/d
    # /a/@b.c/$e.f.g/h

    it 'can pass registers as arguments' do
      parses! '/a(@b)',     [[:runMachine, [:a], [:@b]]]
      parses! '/a(@b, @c)', [[:runMachine, [:a], [:@b, :@c]]]
    end

    it 'includes instructions to turn non-register arguments into registers' do
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
    it 'sets lhs and rhs if they are both registers' do
      parses! '@a <- @b',   [[:registerToRegister, :@b, :@a]]
    end

    # a lot of room for optimization in here, but that's not very important at the moment
    it 'expands rhs to a register' do
      parses! '@a <- $b',   [[:globalToRegister, :b, :@_1],
                             [:registerToRegister, :@_1, :@a]]
      parses! '@a <- @b.c', [[:getKey, :@_1, :@b, :c],
                             [:registerToRegister, :@_1, :@a]]
      parses! '@a <- $b.c', [[:globalToRegister, :b, :@_1],
                             [:getKey, :@_2, :@_1, :c],
                             [:registerToRegister, :@_2, :@a]]
    end

    it 'expands lhs to a register' do
      parses! '$a <- @b',   [[:registerToGlobal, :@b, :a]]
      parses! '$a.b <- @c', [[:globalToRegister, :a, :@_1],
                             [:setKey, :@_1, :b, :@c]]
    end

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
        parses! '@a.b <- {}', [[:newHash, :@_1],
                               [:setKey, :@a, :b, :@_1]]
        # parses! '$a <- {}', [[:newHash, :@_1],
                             # [:registerToGlobal, :@_1, :a]]
      end
    end
  end
end
