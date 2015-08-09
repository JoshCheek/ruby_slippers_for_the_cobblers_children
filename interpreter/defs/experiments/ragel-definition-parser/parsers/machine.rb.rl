%%{
  machine machine_defs;

  # placeholder
  main := "x";
}%%



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
        self.attributes ||= parse Defs::Machine.new, string
      end

      private

      attr_accessor :string, :attributes

      def parse(machine, data)
        # Machine attributes that we need to parse and set:
        #   name          String
        #   namespace     Array
        #   arg_names     Array
        #   description   String
        #   labels        Array
        #   instructions  Array
        #   children      Array


        # Emit the constant static data needed by the machine.
        # placing it here is a stopgap until I make a bit more progress
        # (it defines this data as attr_accessors on the singleton class,
        # but I think I'd like it to be private constants)
        %% write data;

        # Ragel user guide:
        #   http://www.colm.net/files/ragel/ragel-guide-6.9.pdf
        #
        # `write init` sets variable values
        #   Ragel variables (p36)
        #     cs    - Current state
        #               one of:
        #                 <machine_name>_error       = 0
        #                 <machine_name>_start       = 1
        #                 <machine_name>_first_final = 2
        #               So, if our parser is named "machine_defs",
        #                 Then we would have a local variable `machine_defs_error` with a value of 0.
        #                 Presumably if it's higher than 2, it's the 2nd or 3rd or nth final state.
        #     p     - Data pointer, an index into the data string
        #     pe    - Data end pointer, (data.length)
        #     eof   - End of file pointer. Set to -1, but then to pe on the last buffer block
        #             (we aren't currently buffering)
        #     data  - Something indexable (ie Array or String) containting the data to process.
        #     stack - An array of integers representing states (If the stack must resize dynamically,
        #             the Pre-push and Post-Pop statements can be used to do this)
        #     top   - Integer offset to the next available spot on the top of the stack
        #
        #   Scanners vars (p46)
        #     > We have to manage these if we process using multiple calls... currently, we don't
        #     > But may still be able to use them to find matches instead of building up tokens
        #     > a character at a time like they did in the C example.
        #
        #     ts    - Token start, integer offset to input data.
        #             It is used for recording where the current token match begins.
        #     te    - Token end, Integer offset to input data.
        #             Records where a match ends and scanning of the next token will begin.
        #     act   - Integer sometimes used by scanner code to track the most recent successful match.
        #
        # `write exec` will be the implementation.
        #   If it uses `fcall` or `fret` statements, then stack and top variables must be defined.
        #   If a longest-match construction is used, variables for managing backtracking are required
        #   (I think ts, te, act, maybe stack stuff, not sure)
        %% write init;
        %% write exec;

        machine
      end
    end
  end
end

# %%{
#   machine microscript;

#   action ClearNumber {
#     currentNumber = 0;
#     printf("currentNumber = 0\n");
#   }

#   action RecordVariable {
#     currentVariable = (*p) - 'a';
#     printf("currentVariable = \"$%c\"\n", *p);
#   }

#   action ReadVariable {
#     currentNumber = variableValues[currentVariable];
#     printf(
#       "currentNumber = variableValues[currentVariable # => \"$%c\"] # => %d\n",
#       'a'+currentVariable,
#       variableValues[currentVariable]
#     );
#   }

#   action SetAssignmentVariable {
#     assignmentVariable = currentVariable;
#     printf(
#       "assignmentVariable = currentVariable # => \"$%c\"\n",
#       'a'+assignmentVariable
#     );
#   }

#   action AssignValue {
#     variableValues[assignmentVariable] = currentNumber;
#     printf(
#       "variableValues[assignmentVariable # => \"$%c\"] = currentNumber # => %d\n",
#       'a'+assignmentVariable,
#       currentNumber
#     );
#   }

#   action RecordPort {
#     currentPort = (*p) - 'A';
#     printf("currentPort = %c\n", 'A'+currentPort);
#   }

#   action RecordOutPort {
#     outPort = currentPort;
#     printf("outPort = currentPort # => %c\n", 'A'+outPort);
#   }

#   action SaveLeftValue {
#     leftValue = currentNumber;
#     printf("leftValue = currentNumber # => %d\n", currentNumber);
#   }

#   action SetPortValue {
#     switch(outPort) {
#       case 1:
#         PORTB = (uint8_t) (currentNumber & 255);
#         break;
#       case 2:
#         PORTC = (uint8_t) (currentNumber & 255);
#         break;
#       case 3:
#         PORTD = (uint8_t) (currentNumber & 255);
#         break;
#     }
#     printf("PORT%c = currentNumber # => %d\n", 'A'+outPort, currentNumber&255);
#   }

#   action ReadPortValue {
#     switch(currentPort) {
#       case 1:
#         currentNumber = PINB;
#         break;
#       case 2:
#         currentNumber = PINC;
#         break;
#       case 3:
#         currentNumber = PIND;
#         break;
#     }
#     printf("currentNumber = PIN%c # => %d\n", 'A'+currentPort, currentNumber);
#   }

#   action SetPortDirection {
#     switch(outPort) {
#       case 1:
#         DDRB = (uint8_t) (currentNumber & 255);
#         break;
#       case 2:
#         DDRC = (uint8_t) (currentNumber & 255);
#         break;
#       case 3:
#         DDRD = (uint8_t) (currentNumber & 255);
#         break;
#     }
#     printf("DDR%c = currentNumber # => %d\n", 'A'+outPort, currentNumber);
#   }

#   action ApplyOperator {
#     int initialCurrentNumber = currentNumber;
#     switch(currentOp) {
#       case OP_ADD:
#         currentNumber = leftValue + currentNumber;
#         break;
#       case OP_SUB:
#         currentNumber = leftValue - currentNumber;
#         break;
#       case OP_MUL:
#         currentNumber = leftValue * currentNumber;
#         break;
#       case OP_AND:
#         currentNumber = leftValue & currentNumber;
#         break;
#       case OP_OR:
#         currentNumber = leftValue | currentNumber;
#         break;
#       case OP_XOR:
#         currentNumber = leftValue ^ currentNumber;
#         break;
#       case OP_SHIFTL:
#         currentNumber = leftValue << currentNumber;
#         break;
#       case OP_SHIFTR:
#         currentNumber = leftValue >> currentNumber;
#         break;
#     }
#     printf(
#       "currentNumber = (leftValue # => %d) %s (currentNumber # => %d) # => %d\n",
#       leftValue,
#       ({ char* op = "";
#          if(currentOp == OP_ADD   ) op="+" ; else
#          if(currentOp == OP_SUB   ) op="-" ; else
#          if(currentOp == OP_MUL   ) op="*" ; else
#          if(currentOp == OP_AND   ) op="&" ; else
#          if(currentOp == OP_OR    ) op="|" ; else
#          if(currentOp == OP_XOR   ) op="^" ; else
#          if(currentOp == OP_SHIFTL) op="<<"; else
#          if(currentOp == OP_SHIFTR) op=">>"; else
#                                     op="??wtf!??";
#          op;
#       }),
#       initialCurrentNumber,
#       currentNumber
#     );
#   }

#   action AppendDigitToCurrentNumber {
#     uint8_t digit = (*p) - '0';
#     currentNumber = currentNumber * 10 + digit;
#   }

#   action DocumentNumber {
#     printf("currentNumber = %d\n", currentNumber);
#   }

#   action NextCommand {
#     printf("\n-- Command %d --\n", ++commandNumber);
#   }

#   var            = ('$' [a-z] @RecordVariable);
#   number         = ((digit @AppendDigitToCurrentNumber)+) >ClearNumber %DocumentNumber;
#   port_in        = "PIN" [B-D] @RecordPort;
#   port_out       = "PORT" [B-D] @RecordPort;
#   port_direction = "DDR" [B-D] @RecordPort;

#   # A value is a variable or a number. If a variable is given as a value, read the number it represents.
#   value = (var @ReadVariable) | number | (port_in @ReadPortValue);

#   # An infix operator sits between two values.
#   infix_op = (
#       '+'  @{currentOp = OP_ADD;}
#     | '-'  @{currentOp = OP_SUB;}
#     | '*'  @{currentOp = OP_MUL;}
#     | '&'  @{currentOp = OP_AND;}
#     | '|'  @{currentOp = OP_OR;}
#     | '^'  @{currentOp = OP_XOR;}
#     | '<<' @{currentOp = OP_SHIFTL;}
#     | '>>' @{currentOp = OP_SHIFTR;}
#   );


#   opExpr    = ( value
#                 space*
#                 (infix_op @SaveLeftValue)
#                 space*
#                 value
#               ) %ApplyOperator;
#   valueOrOp = opExpr | value;

#   # An assignment looks like "$a = 3" or "$b=$c". Port output looks similar.
#   assignment = (var            @SetAssignmentVariable space* '=' space* valueOrOp) %AssignValue;
#   set_out    = (port_out       @RecordOutPort         space* '=' space* valueOrOp) %SetPortValue;
#   set_ddr    = (port_direction @RecordOutPort         space* '=' space* valueOrOp) %SetPortDirection;

#   # We're going to use a semicolon on the end of commands to make the boundaries clear
#   command = (space* (assignment | set_out | set_ddr) space* ';') >NextCommand;

#   # A program can consist of any number of commands
#   main := command* space*;
# }%%
