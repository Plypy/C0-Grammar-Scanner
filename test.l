%{
#include <stdio.h>
#include <stdlib.h>
#include <jansson.h>

#include "test.tab.h"
extern YYSTYPE yylval;
extern json_t *array;
// count the line number
int line_number = 1;

int yywrap();

void output(const char *str)
{
    printf("Line#%d, %s\n", line_number, str);
}

void build(const char *type, const char *value)
{
    json_t *obj = json_object();
    json_object_set_new(obj, "line_number", json_integer(line_number));
    json_object_set_new(obj, "type", json_string(type));
    json_object_set_new(obj, "value", json_string(value));
    json_array_append(array, obj);
    json_decref(obj);
}


%}

    /* Universal Character Name: the naming conventions for UCS defined by International Standard ISO/IEC 10646 */
UCN             (\\u[0-9a-fA-F]{4}|\\U[0-9a-fA-F]{8})

    /* DIGIT: any number from 0 to 9 */
DIGIT           [0-9]

    /* LETTER: any uppercase or lowercase letter */
LETTER          [A-Za-z]

    /* DELIMITER: any occurence of 'space', 'tab'*/
DELIMITER       [ \t]

NEWLINE         \n

    /* IDENTIFIER: starting with a letter; following by any occurence of letter, digit or underscore */
IDENTIFIER      ([_a-zA-Z]|{UCN})([_a-zA-Z0-9]|{UCN})*

    /* INTEGER: 0 or more occurence of consecutive digits */
INTEGER         0|([1-9][0-9]*)

    /* STRING: anything between double quote; just considers \" and \\ characters */
STRING          L?\"([^"\\]|\\['"?\\abfnrtv]|\\[0-7]{1,3}|\\[Xx][0-9a-fA-F]+|{UCN})*\"

    /* COMMENT: any c style comment */
COMMENT         ("/*"([^*]|[\r\n]|(\*+([^*/]|[\r\n])))*"*"+"/")|("//".*)



%%
    /* ----- RULES PART ----- */
    /* ====================== */

    /* RULES FOR OPERATORS AND PUNCTUATIONS */
    /* ------------------------------------ */
"+"         { output("+");build("operator", "+"); return '+'; }
"-"         { output("-");build("operator", "-"); return '-';}
"*"         { output("*");build("operator", "*"); return '*';}
"/"         { output("/");build("operator", "/"); return '/';}
"("         { output("(");build("operator", "("); return '(';}
")"         { output(")");build("operator", ")"); return ')';}
"{"         { output("{");build("operator", "{"); return '{';}
"}"         { output("}");build("operator", "}"); return '}';}
","         { output(",");build("operator", ","); return ',';}
";"         { output(";");build("operator", ";"); return ';';}
"="         { output("=");build("operator", "="); return '=';}
"<"         { output("<");build("operator", "<"); return LS;}
"<="        { output("<=");build("operator", "<="); return LEQ;}
">"         { output(">");build("operator", ">"); return GT;}
">="        { output(">=");build("operator", ">="); return GEQ;}
"=="        { output("==");build("operator", "=="); return EQ;}
"!="        { output("!=");build("operator", "!="); return NEQ;}


    /* RULES FOR KEYWORDS */
    /* ------------------ */
"int"           { output("int");build("reserverd", "int"); return INT;}
"void"          { output("void");build("reserverd", "void"); return VOID;}
"if"            { output("if");build("reserverd", "if"); return IF;}
"else"          { output("else");build("reserverd", "else"); return ELSE;}
"while"         { output("while");build("reserverd", "while"); return WHILE;}
"return"        { output("return");build("reserverd", "return"); return RETURN;}


    /* RULES FOR IDENTIFIIERS */
    /* ---------------------- */
{IDENTIFIER}    {
    yylval.ptr = json_string(yytext);
    build("IDENTIFIER", yytext);
    output(yytext);
    return ID;
}

    /* RULES FOR LITERALS */
    /* ------------------ */
{INTEGER}       {
    yylval.ptr = json_integer(atoi(yytext));
    build("INTEGER", yytext);
    output(yytext);
    return NUM; }

    /* ignore any kind of white space; i.e. no 'action'! */
{DELIMITER}+

    /* ignore any kind of comments; i.e. no 'action'! */
{COMMENT}

{NEWLINE}       {line_number++;}

. { puts("fucked");}

%%
    /* ----- USER CODE PART ----- */
    /* ========================== */

int yywrap()
{
    return 1;
}
