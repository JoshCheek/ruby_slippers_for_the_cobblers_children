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

    def register?(name)
      name.start_with? "@"
    end

    def hash_with_key?(expr)
      expr.include? "."
    end

    def set_value?(instr)
      instr.include? "<-"
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
      elsif set_value? instr
        parse_set_value instr
      else
        instructions << instr
        return
        raise "What to do with: #{instr.inspect}"
      end
    end

          # -[[:globalToRegister, :currentBinding, :@_1],
          #     - [:setKey, :@_1, :returnValue, :@value]]
          #   +["$currentBinding.returnValue <- @value"]
    def parse_set_value(instr)
      to_set, value  = split instr, /\s*<-\s*/
      if hash_with_key? to_set
        hash, key      = split to_set, "."
        hash_register  = value_to_register hash
        value_register = value_to_register value
        instructions << [:setKey, hash_register, key.to_s.intern, value_register]
      elsif global? to_set
        global   = global_name(to_set)
        register = value_to_register(value)
        instructions << [:registerToGlobal, register, global]
      else
        return instr
        raise "What is this: #{to_set.inspect}"
      end
    end

    def split(str, delimiter)
      left, right, *rest = str.split(delimiter)
      raise "What is this: #{rest.inspect}" if rest.any?
      [left, right]
    end

    def value_to_register(value)
      if register? value
        value.intern
      elsif global? value
        global   = global_name value
        register = new_implicit_register
        instructions << [:globalToRegister, global, register]
        register
      else
        return value
        raise "What kind of arg is this: #{value.inspect}"
      end
    end

    # /ast($ast)
    def parse_run_machine(instr)
      raw_path, *args = instr.chomp(")").split("(")
      machine_path = raw_path.split("/").reject(&:empty?).map(&:intern)
      args         = args.map { |arg| value_to_register arg }
      instructions << [:runMachine, machine_path, args]
    end
  end
end
