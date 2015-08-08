#include <stdio.h>
#include <string.h>
#include "microscript.c"

const char* COLOUR_BLUE = "\033[34m";
const char* COLOUR_OFF  = "\033[0m";

int main() {
  char* str = "  $a = PINB;\n  PORTC = $a;\n  $b = $a + 5;\n  $c = 100;\n  PORTD = PINC;";
  printf("%sINIT\n====%s\n\n", COLOUR_BLUE, COLOUR_OFF);
  init_microscript();
  printf("str:\n%s\n\n", str);

  printf("%sPARSING\n=======%s\n", COLOUR_BLUE, COLOUR_OFF);
  const char* p = parse_microscript(str, strlen(str), EOF);

  printf("\n\n%sDONE\n====%s\n\n", COLOUR_BLUE, COLOUR_OFF);
  printf("cs: %s (%d)\n",
    ({ char* cs_name = "";
       if(cs == microscript_start       ) cs_name = "microscript_start";       else
       if(cs == microscript_first_final ) cs_name = "microscript_first_final"; else
       if(cs == microscript_error       ) cs_name = "microscript_error";       else
       if(cs == microscript_en_main     ) cs_name = "microscript_en_main";     else
                                          cs_name = "...IDK! :(...";
       cs_name;
    }),
    cs
  );
  printf("pe: %d\n", strlen(str));
  printf("p: '%c' (offset: %d)\n", *p, (int)(p-str));
  printf("\n\n-------------------\n\n");
}
