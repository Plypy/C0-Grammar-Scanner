#include <stdio.h>
#include <jansson.h>
#include "test.tab.h"


json_t *array, *json_obj;

int main(void)
{
    json_obj = json_object();
    array = json_array();
    yyparse();
    json_dump_file(json_obj, "parser.json", JSON_INDENT(4));
    json_dump_file(array, "parser-lexer.json", JSON_INDENT(4));
}
