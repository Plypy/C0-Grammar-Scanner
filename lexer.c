#include <stdio.h>
#include <stdlib.h>
#include <jansson.h>

json_t *array, *obj;

extern int yylex(void);
int main(void)
{
    array = json_array();
    while (0 != yylex()) {
        continue;
    }
    obj = json_object();
    json_object_set(obj, "tokens", array);
    json_decref(array);
    json_dump_file(obj, "lexer.json", JSON_INDENT(4));
}
