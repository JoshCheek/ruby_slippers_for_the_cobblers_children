// http://www.avrfreaks.net/forum/codec-parsing-strings-flexiblyefficiently-ragel?page=0&file=viewtopic&t=80042
#include <stdint.h>

#define OP_ADD    0
#define OP_SUB    1
#define OP_MUL    2
#define OP_AND    3
#define OP_OR     4
#define OP_XOR    5
#define OP_SHIFTL 6
#define OP_SHIFTR 7

static uint16_t currentNumber;
static uint8_t  currentVariable, assignmentVariable;
static uint8_t  currentPort, outPort;
static uint16_t variableValues[26];
static uint8_t  currentOp;
static uint16_t leftValue;

// faking out the vars that come from libs used in the real one
static uint8_t  PINB = 1;
static uint8_t  PINC = 2;
static uint8_t  PIND = 3;

static uint8_t  PORTB = 11;
static uint8_t  PORTC = 12;
static uint8_t  PORTD = 13;

static uint8_t  DDRB = 21;
static uint8_t  DDRC = 22;
static uint8_t  DDRD = 23;

// for more helpful output
static int commandNumber = 0;

%%{
  machine microscript;

  action ClearNumber {
    currentNumber = 0;
    printf("currentNumber = 0\n");
  }

  action RecordVariable {
    currentVariable = (*p) - 'a';
    printf("currentVariable = \"$%c\"\n", *p);
  }

  action ReadVariable {
    currentNumber = variableValues[currentVariable];
    printf(
      "currentNumber = variableValues[currentVariable # => \"$%c\"] # => %d\n",
      'a'+currentVariable,
      variableValues[currentVariable]
    );
  }

  action SetAssignmentVariable {
    assignmentVariable = currentVariable;
    printf(
      "assignmentVariable = currentVariable # => \"$%c\"\n",
      'a'+assignmentVariable
    );
  }

  action AssignValue {
    variableValues[assignmentVariable] = currentNumber;
    printf(
      "variableValues[assignmentVariable # => \"$%c\"] = currentNumber # => %d\n",
      'a'+assignmentVariable,
      currentNumber
    );
  }

  action RecordPort {
    currentPort = (*p) - 'A';
    printf("currentPort = %c\n", 'A'+currentPort);
  }

  action RecordOutPort {
    outPort = currentPort;
    printf("outPort = currentPort # => %c\n", 'A'+outPort);
  }

  action SaveLeftValue {
    leftValue = currentNumber;
    printf("leftValue = currentNumber # => %d\n", currentNumber);
  }

  action SetPortValue {
    switch(outPort) {
      case 1:
        PORTB = (uint8_t) (currentNumber & 255);
        break;
      case 2:
        PORTC = (uint8_t) (currentNumber & 255);
        break;
      case 3:
        PORTD = (uint8_t) (currentNumber & 255);
        break;
    }
    printf("PORT%c = currentNumber # => %d\n", 'A'+outPort, currentNumber&255);
  }

  action ReadPortValue {
    switch(currentPort) {
      case 1:
        currentNumber = PINB;
        break;
      case 2:
        currentNumber = PINC;
        break;
      case 3:
        currentNumber = PIND;
        break;
    }
    printf("currentNumber = PIN%c # => %d\n", 'A'+currentPort, currentNumber);
  }

  action SetPortDirection {
    switch(outPort) {
      case 1:
        DDRB = (uint8_t) (currentNumber & 255);
        break;
      case 2:
        DDRC = (uint8_t) (currentNumber & 255);
        break;
      case 3:
        DDRD = (uint8_t) (currentNumber & 255);
        break;
    }
    printf("DDR%c = currentNumber # => %d\n", 'A'+outPort, currentNumber);
  }

  action ApplyOperator {
    int initialCurrentNumber = currentNumber;
    switch(currentOp) {
      case OP_ADD:
        currentNumber = leftValue + currentNumber;
        break;
      case OP_SUB:
        currentNumber = leftValue - currentNumber;
        break;
      case OP_MUL:
        currentNumber = leftValue * currentNumber;
        break;
      case OP_AND:
        currentNumber = leftValue & currentNumber;
        break;
      case OP_OR:
        currentNumber = leftValue | currentNumber;
        break;
      case OP_XOR:
        currentNumber = leftValue ^ currentNumber;
        break;
      case OP_SHIFTL:
        currentNumber = leftValue << currentNumber;
        break;
      case OP_SHIFTR:
        currentNumber = leftValue >> currentNumber;
        break;
    }
    printf(
      "currentNumber = (leftValue # => %d) %s (currentNumber # => %d) # => %d\n",
      leftValue,
      ({ char* op = "";
         if(currentOp == OP_ADD   ) op="+" ; else
         if(currentOp == OP_SUB   ) op="-" ; else
         if(currentOp == OP_MUL   ) op="*" ; else
         if(currentOp == OP_AND   ) op="&" ; else
         if(currentOp == OP_OR    ) op="|" ; else
         if(currentOp == OP_XOR   ) op="^" ; else
         if(currentOp == OP_SHIFTL) op="<<"; else
         if(currentOp == OP_SHIFTR) op=">>"; else
                                    op="??wtf!??";
         op;
      }),
      initialCurrentNumber,
      currentNumber
    );
  }

  action AppendDigitToCurrentNumber {
    uint8_t digit = (*p) - '0';
    currentNumber = currentNumber * 10 + digit;
  }

  action DocumentNumber {
    printf("currentNumber = %d\n", currentNumber);
  }

  action NextCommand {
    printf("\n-- Command %d --\n", ++commandNumber);
  }

  var            = ('$' [a-z] @RecordVariable);
  number         = ((digit @AppendDigitToCurrentNumber)+) >ClearNumber %DocumentNumber;
  port_in        = "PIN" [B-D] @RecordPort;
  port_out       = "PORT" [B-D] @RecordPort;
  port_direction = "DDR" [B-D] @RecordPort;

  # A value is a variable or a number. If a variable is given as a value, read the number it represents.
  value = (var @ReadVariable) | number | (port_in @ReadPortValue);

  # An infix operator sits between two values.
  infix_op = (
      '+'  @{currentOp = OP_ADD;}
    | '-'  @{currentOp = OP_SUB;}
    | '*'  @{currentOp = OP_MUL;}
    | '&'  @{currentOp = OP_AND;}
    | '|'  @{currentOp = OP_OR;}
    | '^'  @{currentOp = OP_XOR;}
    | '<<' @{currentOp = OP_SHIFTL;}
    | '>>' @{currentOp = OP_SHIFTR;}
  );


  opExpr    = ( value
                space*
                (infix_op @SaveLeftValue)
                space*
                value
              ) %ApplyOperator;
  valueOrOp = opExpr | value;

  # An assignment looks like "$a = 3" or "$b=$c". Port output looks similar.
  assignment = (var            @SetAssignmentVariable space* '=' space* valueOrOp) %AssignValue;
  set_out    = (port_out       @RecordOutPort         space* '=' space* valueOrOp) %SetPortValue;
  set_ddr    = (port_direction @RecordOutPort         space* '=' space* valueOrOp) %SetPortDirection;

  # We're going to use a semicolon on the end of commands to make the boundaries clear
  command = (space* (assignment | set_out | set_ddr) space* ';') >NextCommand;

  # A program can consist of any number of commands
  main := command* space*;
}%%

%% write data;

static uint8_t cs; /* The current parser state */

void init_microscript( void ) {
  %% write init;
}

const char* parse_microscript(const char* p, uint16_t len, uint8_t is_eof) {
  const char* pe = p + len; /* pe points to 1 byte beyond the end of this block of data */
  char* eof = is_eof ? (char *)pe : ((char*) 0); /* Indicates the end of all data, 0 if not in this block */

  %% write exec;
  return p;
}
