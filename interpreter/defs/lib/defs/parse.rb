require 'defs/parse_instructions'
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
  end
end
