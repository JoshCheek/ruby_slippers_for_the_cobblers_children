class Defs
  class ParseInstruction
    def self.call(raw_instructions)
      new(raw_instructions).call
    end

    def initialize(raw_instructions)
      self.implicit_registers = []
      self.instructions       = []
      self.raw_instructions   = raw_instructions.dup
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
      until raw_instructions.empty?
        parse_instruction raw_instructions.shift
      end
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

    def append_value?(instr)
      instr.to_s.include? '<<'
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

    def for_loop?(instr)
      instr.start_with?("for ")
    end

    def new_counter(initial_value)
      raise "handle_this: #{initial_value.inspect}" unless initial_value.kind_of? Fixnum
      register = new_implicit_register
      instructions << [:setInt, register, initial_value]
      register
    end

    def parse_instruction(instr)
      if no_instruction? instr
        # noop
      elsif for_loop? instr
        # for @expression in @ast.expressions
        #   /ast(@expression)
        # [[:setInt, :@_1, 0],
        #  [:getKey, :@_2, :@ast, :expressions],
        #  [:getKey, :@_3, :@_2, :length],
        #  [:label, :forloop],
        #    [:eq, :@_4, :@_1, :@_3],
        #    [:jumpToIf, :forloop_end, :@_4],
        #    [:getKey, :@expression, :@_2, :@_1],
        #    [:runMachine, [:ast], [:@expression]],
        #    [:add, :@_1, 1],
        #    [:jumpTo, :forloop],
        #  [:label, :forloop_end]]
        kw_for, var, kw_in, collection_expr, *rest = instr.split
        raise instr unless kw_for == "for" && kw_in == "in" && rest.empty?
        index_register      = new_counter(0)
        collection_register = value_to_register(collection_expr)
        length_register     = value_to_register "#{collection_register}.length"

        # @_1 = index_register      | i = 0
        # @_2 = collection_register | @ast.expressions
        # @_3 = length_register     | @ast.expressions.length
        instructions << [:label, :forloop]
          eq_register = new_implicit_register
          instructions << [:eq, eq_register, index_register, length_register]
          instructions << [:jumpToIf, :forloop_end, eq_register]
          instructions << [:getKey, var.intern, collection_register, index_register]

          while raw_instructions.any? && raw_instructions.first.start_with?("  ")
            parse_instruction raw_instructions.shift[2..-1]
          end

          instructions << [:add, index_register, 1]
          instructions << [:jumpTo, :forloop]
        instructions << [:label, :forloop_end]

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
      elsif append_value? instr
        parse_append_value instr
      else
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
      elsif value == '{}' && register?(to_set)
        instructions << [:newHash, to_set.intern]
      else
        return instr
        raise "What is this: #{instr.inspect}"
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

    # @names << @name
    def parse_append_value(instr)
      lhs, rhs       = instr.split(/\s*<<\s*/, 2)
      left_register  = value_to_register(lhs)
      right_register = value_to_register(rhs)
      instructions << [:aryAppend, left_register, right_register]
    end
  end
end
