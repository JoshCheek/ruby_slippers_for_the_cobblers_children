require 'defs/parse_template'

class Defs
  class InstructionDefinitions
    def self.parse(template)
      parsed = ParseTemplate.parse(template)
      parsed.each do |name, attributes|
        attributes[:body] = ExecutionContext.new.eval(
          attributes[:argnames],
          attributes[:body]
        )
      end
    end

    class ExecutionContext
      def eval(argnames, code)
        b = clean_binding
        argnames.each { |name| b.local_variable_set name, name }
        b.eval code
      end

      def clean_binding
        binding
      end
    end
  end
end
