class Defs
  class ParseInstruction
    def self.call(raw_instructions)
      new(raw_instructions).call
    end

    def initialize(raw_instructions)
      self.implicit_registers = []
      self.instructions       = []
      self.raw_instructions   = raw_instructions
    end

    attr_accessor :raw_instructions, :instructions, :implicit_registers

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
      raw_instructions.each { | instr| parse_instruction instr }
      instructions
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

    def new_implicit_register
      i = implicit_registers.last.to_s[/\d+/].to_i.next
      register = :"@_#{i}"
      implicit_registers << register
      register
    end

    def parse_instruction(instr)
      if run_machine? instr
        parse_run_machine instr
      else
        return instr
        raise "What to do with: #{instr.inspect}"
      end
    end

    # /ast($ast)
    def parse_run_machine(instr)
      raw_path, *args = instr.chomp(")").split("(")
      machine_path = raw_path.split("/").reject(&:empty?).map(&:intern)

      args = args.map do |arg|
        if global? arg
          global   = global_name arg
          register = new_implicit_register
          instructions << [:globalToRegister, global, register]
          register
        else
          raise "What kind of arg is this: #{arg.inspect}"
        end
      end

      instructions << [:runMachine, machine_path, args]
    end
  end
end
