
# line 1 "parsers/machine.rb.rl"
# Note: The "# %" are fake comments to fix vim's highlighting


# line 8 "parsers/machine.rb.rl"
 # %



require 'defs/machine'

class Defs
  class ParseMachine

    
# line 18 "lib/defs/parse/machine.rb"
class << self
	attr_accessor :_machine_defs_key_offsets
	private :_machine_defs_key_offsets, :_machine_defs_key_offsets=
end
self._machine_defs_key_offsets = [
	0, 0, 1
]

class << self
	attr_accessor :_machine_defs_trans_keys
	private :_machine_defs_trans_keys, :_machine_defs_trans_keys=
end
self._machine_defs_trans_keys = [
	120, 0
]

class << self
	attr_accessor :_machine_defs_single_lengths
	private :_machine_defs_single_lengths, :_machine_defs_single_lengths=
end
self._machine_defs_single_lengths = [
	0, 1, 0
]

class << self
	attr_accessor :_machine_defs_range_lengths
	private :_machine_defs_range_lengths, :_machine_defs_range_lengths=
end
self._machine_defs_range_lengths = [
	0, 0, 0
]

class << self
	attr_accessor :_machine_defs_index_offsets
	private :_machine_defs_index_offsets, :_machine_defs_index_offsets=
end
self._machine_defs_index_offsets = [
	0, 0, 2
]

class << self
	attr_accessor :_machine_defs_trans_targs
	private :_machine_defs_trans_targs, :_machine_defs_trans_targs=
end
self._machine_defs_trans_targs = [
	2, 0, 0, 0
]

class << self
	attr_accessor :machine_defs_start
end
self.machine_defs_start = 1;
class << self
	attr_accessor :machine_defs_first_final
end
self.machine_defs_first_final = 2;
class << self
	attr_accessor :machine_defs_error
end
self.machine_defs_error = 0;

class << self
	attr_accessor :machine_defs_en_main
end
self.machine_defs_en_main = 1;


# line 18 "parsers/machine.rb.rl"
    # % comment to fix highlighting

    def self.call(string)
      new(string).call
    end

    def initialize(string)
      self.string = string
    end

    def call
      self.attributes ||= parse Machine.new, string
    end

    private


    def parse(machine, data)
      # Machine attributes that we need to parse and set:
      #   name          String
      #   namespace     Array
      #   arg_names     Array
      #   description   String
      #   labels        Array
      #   instructions  Array
      #   children      Array

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
      
# line 152 "lib/defs/parse/machine.rb"
begin
	p ||= 0
	pe ||= data.length
	cs = machine_defs_start
end

# line 83 "parsers/machine.rb.rl"
      
# line 161 "lib/defs/parse/machine.rb"
begin
	_klen, _trans, _keys = nil
	_goto_level = 0
	_resume = 10
	_eof_trans = 15
	_again = 20
	_test_eof = 30
	_out = 40
	while true
	_trigger_goto = false
	if _goto_level <= 0
	if p == pe
		_goto_level = _test_eof
		next
	end
	if cs == 0
		_goto_level = _out
		next
	end
	end
	if _goto_level <= _resume
	_keys = _machine_defs_key_offsets[cs]
	_trans = _machine_defs_index_offsets[cs]
	_klen = _machine_defs_single_lengths[cs]
	_break_match = false
	
	begin
	  if _klen > 0
	     _lower = _keys
	     _upper = _keys + _klen - 1

	     loop do
	        break if _upper < _lower
	        _mid = _lower + ( (_upper - _lower) >> 1 )

	        if data[p].ord < _machine_defs_trans_keys[_mid]
	           _upper = _mid - 1
	        elsif data[p].ord > _machine_defs_trans_keys[_mid]
	           _lower = _mid + 1
	        else
	           _trans += (_mid - _keys)
	           _break_match = true
	           break
	        end
	     end # loop
	     break if _break_match
	     _keys += _klen
	     _trans += _klen
	  end
	  _klen = _machine_defs_range_lengths[cs]
	  if _klen > 0
	     _lower = _keys
	     _upper = _keys + (_klen << 1) - 2
	     loop do
	        break if _upper < _lower
	        _mid = _lower + (((_upper-_lower) >> 1) & ~1)
	        if data[p].ord < _machine_defs_trans_keys[_mid]
	          _upper = _mid - 2
	        elsif data[p].ord > _machine_defs_trans_keys[_mid+1]
	          _lower = _mid + 2
	        else
	          _trans += ((_mid - _keys) >> 1)
	          _break_match = true
	          break
	        end
	     end # loop
	     break if _break_match
	     _trans += _klen
	  end
	end while false
	cs = _machine_defs_trans_targs[_trans]
	end
	if _goto_level <= _again
	if cs == 0
		_goto_level = _out
		next
	end
	p += 1
	if p != pe
		_goto_level = _resume
		next
	end
	end
	if _goto_level <= _test_eof
	end
	if _goto_level <= _out
		break
	end
	end
	end

# line 84 "parsers/machine.rb.rl"
    end

    private

    attr_accessor :string, :attributes
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
