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

    def call
      lines = remove_comments(def_string).lines.map { |line| outdent(line).chomp }

      self.name, self.arg_names  = parse_declaration lines.shift

      self.description = lines.shift[/(?<=> ).*/] if lines.first.start_with? '>'

      raw_instrs        = lines.take_while { |l| l !~ /^\w+:/ }

      self.instructions = ParseInstruction.call raw_instrs
      self.children     = parse_children lines.drop(raw_instrs.length).join("\n")

      to_h
    end

    def to_h
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

    def parse_children(children_str)
      children_str.split(/^(?=\w)/)
                  .map { |s| Parse.call s.strip, child_namespace }
                  .map { |c| [c[:name], c] }
                  .to_h
    end

    def parse_declaration(line)
      tokens = line.split(/\s+|\s*:\s*/).map(&:intern)
      [tokens.shift, tokens]
    end

    def outdent(line)
      line.sub /^  /, ""
    end

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
end
