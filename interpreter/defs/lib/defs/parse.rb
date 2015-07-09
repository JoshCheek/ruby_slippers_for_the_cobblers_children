class Defs
  class Parse
    def self.root(def_string)
      defn_with_root = "root:\n  > Machine /\n" << def_string.gsub(/^/, '  ')
      call defn_with_root
    end

    def self.call(def_string, namespace=[])
      new(def_string, namespace).call
    end

    def initialize(def_string, namespace)
      self.def_string = def_string
      self.namespace  = namespace
    end

      require 'pp'
    def call
      str                        = remove_comments def_string
      first, *rest               = str.strip.lines.map { |l| l.gsub(/^  /, "").chomp }
      self.name, *self.arg_names = first.split(/\s+|\s*:\s*/).map(&:intern)

      if rest.first.start_with? '>'
        self.description = rest.first[/(?<=> ).*/]
        rest = rest.drop(1)
      end

      raw_instrs = rest.take_while { |line| line !~ /^\w+:/ }
      rest       = rest.drop(raw_instrs.length)
      self.instructions = parse_instrs(raw_instrs)

      self.children = rest.join("\n")
                          .split(/^(?=\w)/)
                          .map { |s| Parse.call s.strip, child_namespace }
                          .map { |c| [c[:name], c] }
                          .to_h

      { name:           name,
        arg_names:      arg_names,
        description:    description,
        register_names: [],
        instructions:   instructions,
        namespace:      namespace,
        children:       children,
      }
    end

    private

    attr_accessor :def_string, :name, :arg_names, :namespace, :description, :instructions, :children

    def description
      @description || "Machine: #{machine_path}"
    end

    def machine_path
      ["", *child_namespace].join("/")
    end

    def child_namespace
      [*namespace, name].tap { |ns| ns.pop if name == :root }
    end

    def remove_comments(string)
      string.gsub(/^\s*#.*\n/, '')
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