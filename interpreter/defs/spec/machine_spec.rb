require 'defs'

RSpec.describe Defs do
  def assert_machine(machine, assertions)
    assertions.each do |attr, expected|
      case attr
      when :name, :namespace, :desc, :arg_names, :register_names
        actual = machine.__send__ attr
        msg = "Expected\n#{machine.inspect.gsub(/^/, '  ')}.#{attr}\n"\
              "    to eq   #{expected.inspect}\n"\
              "    but got #{actual.inspect}"
        expect(actual).to eq(expected), msg
      when :instructions
        # FIXME
      when :children
        expected.each do |child_name, child_assertions|
          assert_machine machine[child_name], child_assertions
        end
      else
        raise "No assertion for #{attr.inspect}"
      end
    end
  end

  it 'parses this thing' do
    root = Defs.from_string <<-DEFS.gsub(/^    /, "")
    main:
      > The main machine, kicks everything else off
      /ast($ast)

    emit: @value
      $currentBinding.returnValue <- @value

    reemit:
      $foundExpression <- $rTrue

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

    assert_machine root, name: :root, desc: "machine: /", namespace: []

    assert_machine root[:main],
      name:         :main,
      namespace:    [],
      desc:         "The main machine, kicks everything else off",
      arg_names:    [],
      register_names:    [],
      # instructions: [
      #   [:globalToRegister, :ast, :@_1],
      #   [:runMachine, [:ast], [:@_1]],
      # ],
      children: {}

    assert_machine root[:emit],
      name:         :emit,
      namespace:    [],
      desc:         "machine: /emit",
      arg_names:    [:@value],
      register_names:    [],
      # instructions: [
      #   [:globalToRegister, :currentBinding, :@_1],
      #   [:setKey, :@_1, :returnValue, :@value],
      # ],
      children: {}

    assert_machine root[:reemit],
      name:         :reemit,
      namespace:    [],
      desc:         "machine: /reemit",
      arg_names:    [],
      register_names:    [],
      # instructions: [
      #   [:globalToRegister, :rTrue, :@_1],
      #   [:registerToGlobal, :@_1, :foundExpression],
      # ],
      children: {}

    assert_machine root[:ast],
      name:         :ast,
      namespace:    [],
      desc:         "Interpreters for language constructs",
      arg_names:    [:@ast],
      register_names:    [],
      # instructions: [
      #   [:getKey, :@_1, :@ast, :type],
      #   [:becomeMachine, [:ast, :@_1], :@_2],
      # ],
      children: {
        nil: {
          name:         :nil,
          namespace:    [:ast],
          desc:         "machine: /ast/nil",
          arg_names:    [],
          register_names:    [],
          # instructions: [
          #   [:globalToRegister, :rNil, :@_1],
          #   [:runMachine, [:emit], [:@_1]],
          # ],
          children: {}
        },
        expressions: {
          name:         :expressions,
          namespace:    [:ast],
          desc:         "machine: /ast/expressions",
          arg_names:    [:@ast],
          # register_names: [:@expression],
          # instructions: [
          #   [:setInt, :@_1, 0],
          #   [:getKey, :@_2, :@ast, :expressions],
          #   [:getKey, :@_3, :@_2,  :length],

          #   [:label, :forloop],
          #     [:eq, :@_4, :@_1, :@_3], # var4 = (index == length)
          #     [:jumpToIf, :forloop_end, :@_4],
          #     [:getKey, :@expression, :@_2, :@_1],
          #     [:runMachine, [:ast], [:@expression]],
          #     [:add, :@_1, 1],
          #     [:jumpTo, :forloop],
          #   [:label, :forloop_end],

          #   [:runMachine, [:reemit], []],
          # ],
          children: {}
        },
      }
  end
end
