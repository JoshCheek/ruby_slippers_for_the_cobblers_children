require 'defs'

RSpec.describe Defs::Machine do
  it 'parses this thing' do
    root = parse_machine <<-DEFS.gsub(/^    /, "")
    main:
      > The main machine, kicks everything else off
      /ast($ast)
      /ast/nil

    emit: @value
      $currentBinding.returnValue <- @value

    reemit:
      /foundExpression

    twoArgs: @a, @b
      @a <- @b

    ast: @ast
      > Interpreters for language constructs

      self <- /ast/@ast.type

      nil:
        /emit($rNil)

      expressions: @ast
        for @expression in @ast.expressions
          /ast(@expression)
        /reemit
    DEFS

    expect(root.description).to_not be_empty
    assert_machine root, name: :root, namespace: []

    assert_machine root[:main],
      name:           :main,
      namespace:      [],
      description:    "The main machine, kicks everything else off",
      arg_names:      [],
      instructions:   [
        [:globalToRegister, :ast, :@_1],
        [:runMachine, [:ast], [:@_1]],
        [:runMachine, [:ast, :nil], []],
      ],
      children: {}

    assert_machine root[:emit],
      name:         :emit,
      namespace:    [],
      description:  "Machine: /emit",
      arg_names:    [:@value],
      instructions: [
        [:globalToRegister, :currentBinding, :@_1],
        [:setKey, :@_1, :returnValue, :@value],
      ],
      children: {}

    assert_machine root[:reemit],
      name:         :reemit,
      namespace:    [],
      description:  "Machine: /reemit",
      arg_names:    [],
      instructions: [
        [:runMachine, [:foundExpression], []]
      ],
      children: {}

    assert_machine root[:twoArgs], arg_names: [:@a, :@b]

    assert_machine root[:ast],
      name:         :ast,
      namespace:    [],
      description:  "Interpreters for language constructs",
      arg_names:    [:@ast],
      instructions: [
        [:getKey, :@_1, :@ast, :type],
        [:becomeMachine, [:ast, :@_1]],
      ],
      children: {
        nil: {
          name:         :nil,
          namespace:    [:ast],
          description:  "Machine: /ast/nil",
          arg_names:    [],
          instructions: [
            [:globalToRegister, :rNil, :@_1],
            [:runMachine, [:emit], [:@_1]],
          ],
          children: {}
        },
        expressions: {
          name:         :expressions,
          namespace:    [:ast],
          description:  "Machine: /ast/expressions",
          arg_names:    [:@ast],
          instructions: [
            [:setInt, :@_1, 0],
            [:getKey, :@_2, :@ast, :expressions],
            [:getKey, :@_3, :@_2,  :length],

            [:label, :forloop],
              [:eq, :@_4, :@_1, :@_3], # var4 = (index == length)
              [:jumpToIf, :forloop_end, :@_4],
              [:getKey, :@expression, :@_2, :@_1],
              [:runMachine, [:ast], [:@expression]],
              [:add, :@_1, 1],
              [:jumpTo, :forloop],
            [:label, :forloop_end],

            [:runMachine, [:reemit], []],
          ],
          children: {}
        },
      }
  end

  it 'ignores comments: any line beginning with a hash' do
    root = parse_machine <<-DEFS.gsub(/^    /, "")
    # comment
    n:
    # comment
      # comment
        # comment
      > d
      # comment
      /machineName()
      # comment
    # comment
    DEFS

    assert_machine root,
      name: :root,
      children: {
        n: {
          name:           :n,
          description:    "d",
          instructions: [
            [:runMachine, [:machineName], []],
          ],
          children: {}
        }
      }
  end

  def parse_machine(def_string)
    def_hash = Defs::ParseMachine.from_string def_string
    Defs::Machine.new def_hash
  end

  def assert_instructions_equal(expected_instrs, actual_instrs)
    expected_instrs.zip(actual_instrs).each.with_index do |(einstr, ainstr), index|
      next if einstr == ainstr
      dim       = "\e[38;5;243m"
      red       = "\e[31m"
      blue      = "\e[34m"
      matches   = expected_instrs.take(index).map { |instrs| "  #{instrs.inspect},\n" }.join
      missing   = "  " << einstr.inspect << ",\n"
      present   = "  " << ainstr.inspect << ",\n"
      remaining = expected_instrs.drop(index.next).map { |instrs| "  #{instrs.inspect},\n" }.join

      msg = "Expected the instructions to be equal, but they aren't :(\n"
      msg << "#{dim}[#{matches}#{red}#{missing}#{blue}#{present}#{dim}  ...\n#{remaining}#{red}"
      expect(ainstr).to eq(einstr), msg
    end
    expect(actual_instrs.length).to eq expected_instrs.length
  end

  def assert_machine(machine, assertions)
    assertions.each do |attr, expected|
      case attr
      when :name, :namespace, :description, :arg_names, :instructions
        actual = machine.__send__ attr
        msg = "Expected\n#{machine.inspect.gsub(/^/, '  ')}.#{attr}\n"\
              "    to eq   #{expected.inspect}\n"\
              "    but got #{actual.inspect}"
        if attr != :instructions
          expect(actual).to eq(expected), msg
        else
          assert_instructions_equal expected, actual
        end
      when :children
        expected.each do |child_name, child_assertions|
          assert_machine machine[child_name], child_assertions
        end
      else
        raise "No assertion for #{attr.inspect}"
      end
    end
  end

end
