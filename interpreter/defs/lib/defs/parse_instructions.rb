class Defs
  class ParseInstruction
    def self.call(raw_instructions)
      new(raw_instructions).call
    end

    def initialize(raw_instructions)
      @raw_instructions = raw_instructions
    end

    attr_accessor :raw_instructions

    # /ast($ast)
    #   globalToRegister :ast :@_1
    #   runMachine [:ast] [:@_1]
    #
    # $currentBinding.returnValue <- @value
    #
    # $foundExpression <- $rTrue
    # self <- /ast/@ast.type
    #   /emit($rNil)
    #   for @expression in @ast.expressions
    #     /ast(@expression)
    #   /reemit
    def call
      if raw_instructions == ["/machineName()"]
        return [[:runMachine, [:machineName], []]]
      end

      state = { instructions: [], implicit_registers: [] }
      raw_instructions.each { | instr| parse_instr instr, state }
      state.fetch :instructions
    end

    def parse_instr(instr, state)
      if run_machine? instr
        parse_run_machine instr, state
      else
        return instr
        raise "What to do with: #{instr.inspect}"
      end
    end

    def run_machine?(instr)
      instr.start_with? "/"
    end

    def global?(name)
      name.start_with? "$"
    end

    def global_name(name)
      name[1..-1].intern
    end

    def add_implicit(state)
      registers = state.fetch :implicit_registers
      i = registers.last.to_s[/\d+/].to_i.next
      register = :"@_#{i}"
      registers << register
      register
    end

    # /ast($ast)
    def parse_run_machine(instr, state)
      raw_path, *args = instr.chomp(")").split("(")
      machine_path = raw_path.split("/").reject(&:empty?).map(&:intern)

      args = args.map { |arg|
        if global? arg
          global   = global_name arg
          register = add_implicit(state)
          state[:instructions] << [:globalToRegister, global, register]
          register
        else
          raise "What kind of arg is this: #{arg.inspect}"
        end
      }

      state[:instructions] << [:runMachine, machine_path, args]
    end
  end
end
