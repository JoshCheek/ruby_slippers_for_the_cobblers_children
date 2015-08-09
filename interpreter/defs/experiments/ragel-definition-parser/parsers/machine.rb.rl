%% machine machine_defs;



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

      def log(msgs)
        msgs = msgs.to_a << [:indentations, @indentations]
        pairs = msgs.map { |k,v|
          kv = "\e[41;37m#{k} - #{v}\e[0m"
          if v.kind_of? Fixnum
            kv << " \e[32m#{string[0...v].inspect}\e[0m | \e[33m#{string[v..20].inspect}\e[0m"
          end
          kv
        }.join("\n")
        puts "#{pairs.gsub(/^/, '  ').gsub(/\A */, '')}"
      end

      def parse(machine, data)
        @indentations = []

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
        eof = data.length

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
        %% write init;
        %% write exec;

        puts
        if(cs == machine_defs_error)
          print "\e[31m"
        else
          print "\e[32m"
        end
        require 'pp'
        pp(cs: cs, p: p, consumed: data[0...p], up_next: data[p..p+40], indentations: @indentations)
        print "\e[0m"

        machine
      end
    end
  end
end


%%{
  # Transition actions (https://github.com/calio/ragel-cheat-sheet/#transition-actions)
  #   expr > action Entering Action
  #   expr @ action Finishing Action
  #   expr $ action All Transition Action
  #   expr % action Leaving Actions

  # Some notes that WhiteQuark wrote that sound relevant
  # https://github.com/whitequark/parser/blob/d52492b15f306d18fa52aeab60068114d1da4770/lib/parser/lexer.rl#L16
  #
  #  * The code for extracting matched token is:
  #
  #       @source[@ts...@te]
  #
  #  * If an action emits the token and transitions to another state, use
  #    these Ragel commands:
  #
  #       emit($whatever)
  #       fnext $next_state; fbreak;
  #
  #    If you perform `fgoto` in an action which does not emit a token nor
  #    rewinds the stream pointer, the parser's side-effectful,
  #    context-sensitive lookahead actions will break in a hard to detect
  #    and debug way.
  #
  #  * If an action does not emit a token:
  #
  #       fgoto $next_state;
  #
  #  * If an action features lookbehind, i.e. matches characters with the
  #    intent of passing them to another action:
  #
  #       p = @ts - 1
  #       fgoto $next_state;
  #
  #    or, if the lookbehind consists of a single character:
  #
  #       fhold; fgoto $next_state;
  #
  #  * Ragel merges actions. So, if you have `e_lparen = '(' %act` and
  #    `c_lparen = '('` and a lexer action `e_lparen | c_lparen`, the result
  #    _will_ invoke the action `act`.
  #
  #    e_something stands for "something with **e**mbedded action".
  #
  #  * EOF is explicit and is matched by `c_eof`. If you want to introspect
  #    the state of the lexer, add this rule to the state:
  #
  #       c_eof => do_eof;
  #
  #  * If you proceed past EOF, the lexer will complain:
  #
  #       NoMethodError: undefined method `ord' for nil:NilClass

  # It looks like there are a whole host of methods we can call from within our code (p26)
  #
  #   fpc (p), fc (*p), fcurs (current state), ftargs (target state),
  #   fentry(<label>) (an integer value of label -- this value can refer to multiple labels)
  #   fhold           (do not advance over the current char),
  #   fexec <expr>    (set the next char to process)
  #   fgoto <label>   (Jump to an entry point defined by label),
  #   fgoto *<expr>   (expr must evaluate to an integer value representing a state)
  #   fnext <label>   (set the next state)
  #   fnext *<expr>   (same)
  #   fcall <label>   (Push the target state and jump immediately to the entry point defined by <label>,
  #                    See section 6.1 for more information.)
  #   fcall *<expr>   (same)
  #   fret            (Return to last fcall)
  #   fbreak          (immediately break out of the execute loop -- mostly for use with the nooend write option)

  # -----  Dealing with whitespace sensitivity  -----
  # Here we go, pretty sure this is what I've been looking for! (p46)
  # It declares a scanner named "head_name". Then, after matching "Header:",
  # it calls the scanner. When the scanner completes, it returns.
  # Note that this requires a state stack (ts, te, act)
  #
  #   Scanners can be used to process sub-languages, as well as for tokenizing programming languages.
  #   In the following example a scanner is used to tokenize the contents of a header field.
  #
  #     word = [a-z]+;
  #     head_name = ’Header’;
  #     header := |*
  #       word;
  #       ’ ’;
  #       ’\n’ => { fret; };
  #     *|;
  #     main := ( head_name ’:’ @{ fcall header; } )*;

  # -----  Actions  -----
  # Intent here is to modify a var tracking indented depth when we know it increases or decreases
  # and then offset the data pointer appropriately, if we do not have appropriate indentation.
  action Indent {
    @indentations << [p.next]
    puts "Indenting: #{@indentations.inspect}"
  }

  action Outdent {
    if @indentations.empty?
      raise "indentations: #{@indentations.inspect}" if @indentations.empty?
    end
    @indentations.pop
    puts "Outdenting to #{@indentations.inspect}"
  }

  action SkipIndentation {
    needed = "  " * @indentations.length
    actual = data[fpc, @indentations.length*2]

    puts "NEEDED: #{needed.inspect} ACTUAL: #{actual.inspect}"
    if needed.length.zero?
      puts "p=#{p} SKIPPING b/c NO INDENTATION NEEDED"
    elsif needed == actual
      new_index = needed.length.next
      @indentations.last << p
      puts "p=#{p} THEY ARE EQUAL, CALLING `fexec #{p} + #{new_index}`";
      fexec fpc + new_index;
    else
      puts "p=#{p} NOT EQUAL: needed #{needed.inspect} actual #{actual.inspect}"
    end
  }

  action UnskipIndentation {
    if @indentations.last
      log pre_unskip: p
      new_index = @indentations.last.pop.next
      puts "p=#{p} UNSKIPPING INDENTATION TO #{new_index}"
      fexec new_index;
      log post_unskip: p
    else
      log nothing_to_unskip: p
    end
  }


  action RecordName { }
  action RecordArgs { }

  # -----  State Transitions  -----
  indentation          = "" >SkipIndentation %err(UnskipIndentation);
  blank_line           = ((indentation [\t\v\f\r ] "\n")*)
                           >{ log enter_blank_line: p }
                           %{ log exit_blank_line: p };
  machine_name         = indentation "main";
  machine_args         = "";
  machine_description  = ( indentation >{ log description_indentation: p }
      ">"
      [ ,A-Za-z]*
      "\n"
                         ) >{ log description: p, current: fc.chr.inspect };
  instruction_placeholder = indentation "/ast($ast)\n" indentation "/ast/nil\n"
;

  machine_definition = indentation (machine_name %RecordName ) ":" (machine_args %RecordArgs) "\n"



     # description with optional blank lines
    # (blank_line*)           >{log blank_lines_from_defn: p}
    # machine_description     >{log description_from_defn: p}

    (indentation >{ log pre_description_indentation: p }
"> The main machine, kicks everything else off\n") %{ log desc: fpc, p: p, eof: eof }
    # instructions
    # children
  ;

  main := (blank_line* (machine_definition)*) ${ puts "-- #{p}: #{data[p].inspect} --" };

# -------------------------
  indentation        = ""
  sp                 = [\t\v\f\r ]
  blank_line         = (sp* "\n")*;


  description        = indentation sp ">" sp [^\n]* "\n";
  instruction        = indentation sp ">" sp [^\n]* "\n";

  machine_body := |*
    blank_line*
    (indentation description)*
    blank_line*
    (indentation instruction)*
    blank_line*
    (indentation machine_definition blank_line*)*
  *|;

  machine_args = ""; # placeholder

  machine_definition = machine_name %RecordName ":" machine_args "\n" @{
    push_indentation
    fcall machine_body;
    pop_indentation
  };

  main := blank_line* machine_definition* blank_line*;
}%%


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
