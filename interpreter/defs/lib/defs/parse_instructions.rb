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
      raw_instructions.each { |instr| parse_instruction instr }
      instructions
    end

    def run_machine?(instr)
      instr.to_s.start_with? "/"
    end

    def global?(name)
      name.start_with? "$"
    end

    def register?(name)
      name.to_s.start_with? "@"
    end

    def hash_with_key?(expr)
      expr.to_s.include? "."
    end

    def set_value?(instr)
      instr.to_s.include? "<-"
    end

    def no_instruction?(instr)
      instr.strip == ""
    end

    # "self <- /ast/@ast.type"
    def become_machine?(instr)
      instr =~ /^self\s*<-/
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
      if no_instruction? instr
        # noop
      elsif run_machine? instr
        parse_run_machine instr
      elsif become_machine? instr
        # "self <- /ast/@ast.type"
        # [[:getKey, :@_1, :@ast, :type],
        #  [:becomeMachine, [:ast, :@_1]]]
        _, raw_path = split(instr, /\s*<-\s*/)
        path = parse_machine_path(raw_path)
        instructions << [:becomeMachine, path]
      elsif set_value? instr
        parse_set_value instr
      else
        instructions << instr
        return
        raise "What to do with: #{instr.inspect}"
      end
    end

    # $currentBinding.returnValue <- @value
    # $foundExpression <- $rTrue
    def parse_set_value(instr)
      to_set, value  = split instr, /\s*<-\s*/
      if hash_with_key? to_set
        # "$currentBinding.returnValue <- @value"
        # [[:globalToRegister, :currentBinding, :@_1],
        #  [:setKey, :@_1, :returnValue, :@value]]
        hash, key      = split to_set, "."
        hash_register  = value_to_register hash
        value_register = value_to_register value
        instructions << [:setKey, hash_register, key.to_s.intern, value_register]
      elsif global? to_set
        # "$foundExpression <- $rTrue"
        # [[:globalToRegister, :rTrue, :@_1],
        #  [:registerToGlobal, :@_1, :foundExpression]]
        global   = global_name(to_set)
        register = value_to_register(value)
        instructions << [:registerToGlobal, register, global]
      else
        return instr
        raise "What is this: #{to_set.inspect}"
      end
    end

    def split(str, delimiter)
      left, right, *rest = str.to_s.split(delimiter)
      raise "What is this: #{rest.inspect}" if rest.any?
      [left, right]
    end

    def value_to_register(value)
      if hash_with_key? value
        hash, key       = split value, "."
        hash_register   = value_to_register hash
        result_register = new_implicit_register
        instructions << [:getKey, result_register, hash_register, key.intern]
        result_register
      elsif register? value
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

    # /ast/@ast.type/whatever
    def parse_machine_path(raw_path)
      segments = raw_path.split("/").reject(&:empty?).map(&:intern)
      segments.map { |segment|
        if register? segment
          value_to_register(segment)
        else
          segment
        end
      }
    end

    # /ast($ast)
    def parse_run_machine(instr)
      raw_path, *args = instr.chomp(")").split("(")
      path            = parse_machine_path(raw_path)
      args            = args.map { |arg| value_to_register arg }
      instructions << [:runMachine, path, args]
    end
  end
end
