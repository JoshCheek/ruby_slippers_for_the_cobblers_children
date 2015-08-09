
# line 1 "parsers/machine.rb.rl"

# line 2 "parsers/machine.rb.rl"



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
        
# line 46 "lib/defs/parse/machine.rb"
class << self
	attr_accessor :_machine_defs_actions
	private :_machine_defs_actions, :_machine_defs_actions=
end
self._machine_defs_actions = [
	0, 1, 0, 1, 1, 1, 2, 1, 
	3, 2, 0, 2, 2, 1, 2, 2, 
	2, 1, 2, 4, 2
]

class << self
	attr_accessor :_machine_defs_key_offsets
	private :_machine_defs_key_offsets, :_machine_defs_key_offsets=
end
self._machine_defs_key_offsets = [
	0, 0, 4, 5, 6, 7, 8, 9, 
	11, 15, 17, 18, 19, 20, 21, 22, 
	23, 24, 25, 26, 27, 31, 32, 33, 
	34, 35, 36, 37, 38, 39, 40, 41, 
	43, 46, 49
]

class << self
	attr_accessor :_machine_defs_trans_keys
	private :_machine_defs_trans_keys, :_machine_defs_trans_keys=
end
self._machine_defs_trans_keys = [
	9, 32, 11, 13, 97, 105, 110, 58, 
	10, 10, 112, 9, 32, 11, 13, 10, 
	112, 108, 97, 99, 101, 104, 111, 108, 
	100, 101, 114, 9, 32, 11, 13, 108, 
	97, 99, 101, 104, 111, 108, 100, 101, 
	114, 10, 109, 10, 109, 112, 10, 109, 
	112, 10, 109, 0
]

class << self
	attr_accessor :_machine_defs_single_lengths
	private :_machine_defs_single_lengths, :_machine_defs_single_lengths=
end
self._machine_defs_single_lengths = [
	0, 2, 1, 1, 1, 1, 1, 2, 
	2, 2, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 2, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 2, 
	3, 3, 2
]

class << self
	attr_accessor :_machine_defs_range_lengths
	private :_machine_defs_range_lengths, :_machine_defs_range_lengths=
end
self._machine_defs_range_lengths = [
	0, 1, 0, 0, 0, 0, 0, 0, 
	1, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 1, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0
]

class << self
	attr_accessor :_machine_defs_index_offsets
	private :_machine_defs_index_offsets, :_machine_defs_index_offsets=
end
self._machine_defs_index_offsets = [
	0, 0, 4, 6, 8, 10, 12, 14, 
	17, 21, 24, 26, 28, 30, 32, 34, 
	36, 38, 40, 42, 44, 48, 50, 52, 
	54, 56, 58, 60, 62, 64, 66, 68, 
	71, 75, 79
]

class << self
	attr_accessor :_machine_defs_indicies
	private :_machine_defs_indicies, :_machine_defs_indicies=
end
self._machine_defs_indicies = [
	0, 0, 0, 1, 2, 1, 3, 1, 
	4, 1, 5, 1, 6, 1, 7, 8, 
	1, 9, 9, 9, 1, 10, 11, 1, 
	12, 1, 13, 1, 14, 1, 15, 1, 
	16, 1, 17, 1, 18, 1, 19, 1, 
	20, 1, 21, 1, 22, 22, 22, 1, 
	23, 1, 24, 1, 25, 1, 26, 1, 
	27, 1, 28, 1, 29, 1, 30, 1, 
	31, 1, 32, 1, 33, 34, 1, 35, 
	36, 37, 1, 38, 34, 37, 1, 39, 
	36, 1, 0
]

class << self
	attr_accessor :_machine_defs_trans_targs
	private :_machine_defs_trans_targs, :_machine_defs_trans_targs=
end
self._machine_defs_trans_targs = [
	31, 0, 3, 4, 5, 6, 7, 8, 
	10, 9, 8, 10, 11, 12, 13, 14, 
	15, 16, 17, 18, 19, 32, 33, 22, 
	23, 24, 25, 26, 27, 28, 29, 30, 
	34, 1, 2, 20, 2, 21, 20, 1
]

class << self
	attr_accessor :_machine_defs_trans_actions
	private :_machine_defs_trans_actions, :_machine_defs_trans_actions=
end
self._machine_defs_trans_actions = [
	0, 0, 0, 0, 0, 7, 18, 9, 
	1, 0, 5, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 5, 0, 15, 3, 0, 5, 12
]

class << self
	attr_accessor :_machine_defs_eof_actions
	private :_machine_defs_eof_actions, :_machine_defs_eof_actions=
end
self._machine_defs_eof_actions = [
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	3, 0, 3
]

class << self
	attr_accessor :machine_defs_start
end
self.machine_defs_start = 31;
class << self
	attr_accessor :machine_defs_first_final
end
self.machine_defs_first_final = 31;
class << self
	attr_accessor :machine_defs_error
end
self.machine_defs_error = 0;

class << self
	attr_accessor :machine_defs_en_main
end
self.machine_defs_en_main = 31;


# line 42 "parsers/machine.rb.rl"

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
        #   Overriding the code generated when these variables are used (p37)
        #     Example: `access state->;` https://github.com/zedshaw/utu/blob/5eda0d2430f52cb0e42db63f3d268675f10c5901/src/hub/hub.rl#L21
        #
        #     getkey   <code>;             - how to get the char from p
        #     access   <code>;             - how to access the machine data persisted across buffer blocks
        #                                    (if you have to use this, read the paragraph around it)
        #     variable <name> <code>;      - tell it how to access a specific variable (var name is first arg),
        #                                    eg `variable p @current_index`
        #     prepush { <code> };          - use to ensure the stack has room to push onto
        #     postpop { <code> };          - opposite of prepush
        #     write <component> [options]; - Generate parts of the machine (data, start, first_final, error, init, exec, exports)
        #
        # `write exec` will be the implementation.
        #   If it uses `fcall` or `fret` statements, then stack and top variables must be defined.
        #   If a longest-match construction is used, variables for managing backtracking are required
        #   (I think ts, te, act, maybe stack stuff, not sure)
        
# line 244 "lib/defs/parse/machine.rb"
begin
	p ||= 0
	pe ||= data.length
	cs = machine_defs_start
end

# line 93 "parsers/machine.rb.rl"
        
# line 253 "lib/defs/parse/machine.rb"
begin
	_klen, _trans, _keys, _acts, _nacts = nil
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
	_trans = _machine_defs_indicies[_trans]
	cs = _machine_defs_trans_targs[_trans]
	if _machine_defs_trans_actions[_trans] != 0
		_acts = _machine_defs_trans_actions[_trans]
		_nacts = _machine_defs_actions[_acts]
		_acts += 1
		while _nacts > 0
			_nacts -= 1
			_acts += 1
			case _machine_defs_actions[_acts - 1]
when 0 then
# line 113 "parsers/machine.rb.rl"
		begin
 		end
when 1 then
# line 114 "parsers/machine.rb.rl"
		begin
 		end
when 2 then
# line 115 "parsers/machine.rb.rl"
		begin
 		end
when 3 then
# line 117 "parsers/machine.rb.rl"
		begin
 		end
when 4 then
# line 118 "parsers/machine.rb.rl"
		begin
 		end
# line 354 "lib/defs/parse/machine.rb"
			end # action switch
		end
	end
	if _trigger_goto
		next
	end
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
	if p == eof
	__acts = _machine_defs_eof_actions[cs]
	__nacts =  _machine_defs_actions[__acts]
	__acts += 1
	while __nacts > 0
		__nacts -= 1
		__acts += 1
		case _machine_defs_actions[__acts - 1]
when 1 then
# line 114 "parsers/machine.rb.rl"
		begin
 		end
# line 386 "lib/defs/parse/machine.rb"
		end # eof action switch
	end
	if _trigger_goto
		next
	end
end
	end
	if _goto_level <= _out
		break
	end
	end
	end

# line 94 "parsers/machine.rb.rl"

        machine
      end
    end
  end
end



# line 136 "parsers/machine.rb.rl"



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
