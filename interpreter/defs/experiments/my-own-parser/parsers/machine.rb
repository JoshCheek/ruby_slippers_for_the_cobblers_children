require 'defs/machine'

class Defs
  module Parse
    class Machine
      def self.call(string)
        new(string).call
      end

      def initialize(string)
        self.string = string
      end

      def call
        return machine if machine
        state = MachineDefinition.call State.new string
        self.machine = state.machine
      end

      private

      attr_accessor :string, :machine

      class State
        attr_accessor :string, :index, :indentation
        def initialize(string)
          self.string      = string
          self.index       = 0
          self.indentation = [""]
        end
      end

      def self.defstate(name, &definition)
        parse_state = Class.new(ParseState) { self.name, self.definition = name, definition }
        const_set name, parse_state
        define_method name do |*args|
          parse_state.new(*args)
        end
        self
      end

      class ParseState
        class << self
          attr_accessor :name, :definition
          def call(state)
            new.call(state)
          end
        end

        attr_accessor :definition

        def initialize(*args)
          self.definition = self.class.definition.call(*args)
        end

        def call(state)
          definition.call(state)
        end
      end

      defstate :Sequence do |*children|
        children.inject state do |child, state|
          child.call state or return
        end
      end

      defstate :Star do |child|
        state = state()
        loop do
          if (next_state = child.call state)
            state = next_state
          else
            return state
          end
        end
      end

      defstate :BlankLine do
        Star(Sequence(Regex(/[\t\v\f\r ]*/), Char("\n")))
      end

      defstate :CharClass do |chars|
        char_matchers = chars.chars.map { |c| Char c }
        Any(char_matchers).call state
      end

      defstate :Indentation do
        String(state.indentation.last).call state
      end

      defstate :MachineDefinition do
        Sequence( BlankLine,
                  MachineName,
                  Char(":"),
                  MachineArgs,
                  Char("\n"),
                  PushIndentation,
                  MachineBody,
                  PopIndentation,
                  BlankLine,
                )
      end

      defstate :PushIndentation do
        indentation = state.indentation.last + '  '
        state.with_indentation(indentation)
      end

      defstate :PopIndentation do
        state.without_indentation
      end

      defstate :MachineBody do
        Sequence( BlankLine,
                  Star(Sequence(Indentation, Description)),
                  BlankLine,
                  Star(Sequence(Indentation, Instruction)),
                  BlankLine,
                  Star(Sequence(Indentation, MachineDefinition)),
                  BlankLine
                )
      end

      defstate :Identifier do
        Regex(/[a-zA-Z_-]+/)
      end

      defstate :MachineName do
        Identifier.call state
      end

      defstate :RegisterName do
        Sequence(Char("@"), Identifier).call state
      end

      defstate :MachineArgs do
        state # FIXME: placeholder
      end

      defstate :Description do
        Sequence(
          Char(">"),
          Regex(/[ ,A-Za-z]*/),
          Char("\n"),
        ).call(state)
      end

      defstate :Instruction do
        state # FIXME: placeholder
      end

      defstate :Regex do |regex|

      end
    end
  end
end
