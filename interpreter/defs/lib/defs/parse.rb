class Defs
  class Parse
    def initialize(def_string)
      @def_string = def_string
    end

    def call
      defn = remove_comments(@def_string)
      parse_body defn
    end

    private

    def remove_comments(string)
      string.gsub(/^\s*#.*\n/, '')
    end

    def parse_body(str, name: :root, args: [], ns: [], desc: "Machine: /", instrs: [])
      child_ns = [*ns, name].tap { |ns| ns.pop if name == :root }
      { name:           name,
        description:    desc || "Machine: #{["", *ns, name].join '/'}",
        arg_names:      args,
        register_names: [],
        instructions:   instrs,
        namespace:      ns,
        children:       str.split(/^(?=\w)/)
                           .map { |s| parse_defn s.strip, child_ns }
                           .map { |c| [c[:name], c] }
                           .to_h
      }
    end

    def parse_defn(str, ns)
      first, *rest = str.strip.lines.map { |l| l.gsub /^  /, "" }
      name,  *args = first.split(/\s+|\s*:\s*/).map(&:intern)

      if rest.first.start_with? '>'
        desc = rest.first[/(?<=> ).*/]
        rest = rest.drop(1)
      end

      instrs = rest.take_while { |line| line !~ /^\w+:/ }
      body   = rest.drop(instrs.length).join("\n")

      parse_body body, name: name, desc: desc, args: args, ns: ns, instrs: parse_instrs(instrs)
    end

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
    def parse_instrs(raw_instructions)
      implicit_vars = []
      instructions  = []

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
