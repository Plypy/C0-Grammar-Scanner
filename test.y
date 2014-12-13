%{

#include <jansson.h>
#include <stdio.h>
extern json_t * json_obj;

json_t *add_to_array(json_t *a, json_t *b)
{
    json_t *ret = 0;
    if (json_is_array(a)) {
        ret = a;
    } else {
        ret = json_array();
        json_array_append(ret, a);
        json_decref(a);
    }
    json_array_append(ret, b);
    json_decref(b);
    return ret;
}

json_t *create_and_add(const char *type, json_t *obj)
{
    json_t *ret = json_object();
    json_object_set(ret, type, obj);
    json_decref(obj);
    return ret;
}

%}
%token LS LEQ GT GEQ EQ NEQ
%token IF ELSE WHILE RETURN
%token INT VOID

%union {
    json_t *ptr;
}

%token <ptr>  ID;
%token <ptr> NUM;
%type <ptr>
    program mixed_declaration var_declaration IDENTIFIER_LIST
    fun_declaration params param_list compound_stmt stmt_list
    mixed_stmt statement expression_stmt if_else_stmt if_stmt
    while_stmt return_stmt expression simple_expression relop
    additive_expression term factor call arg_list RETURN_TYPE
    param

%%

top
    : program
    {
        json_object_set(json_obj, "C program", $1);
    }

program
    : mixed_declaration { $$ = $1;}
    | program mixed_declaration { $$ = add_to_array($1, $2);}
    ;

mixed_declaration
    : var_declaration {$$ = create_and_add("variable declaration", $1);}
    | fun_declaration {$$ = create_and_add("function declaration", $1);}
    ;

var_declaration
    : INT IDENTIFIER_LIST ';'
    {
        $$ = json_object();
        json_object_set_new($$, "type", json_string("int"));
        json_object_set($$, "IDENTIFIERS", $2);
        json_decref($2);
    }
    ;

IDENTIFIER_LIST
    : ID {$$ = $1;}
    | IDENTIFIER_LIST ',' ID { $$ = add_to_array($1, $3);}
    ;

fun_declaration
    : INT  ID '(' params ')' compound_stmt
    {
        $$ = json_object();
        json_object_set($$, "return_type", json_string("int"));
        json_object_set($$, "function_name", $2);
        json_object_set($$, "params", $4);
        json_object_set($$, "statement", $6);
    }
    | VOID  ID '(' params ')' compound_stmt
    {
        $$ = json_object();
        json_object_set($$, "return_type", json_string("void"));
        json_object_set($$, "function_name", $2);
        json_object_set($$, "params", $4);
        json_object_set($$, "statement", $6);
    }
    ;

params
    : VOID {$$ = json_string("void");}
    | param_list {$$ = $1;}
    ;

param_list
    : param_list ',' param {$$ = add_to_array($1, $3);}
    | param { $$ = $1;}
    ;

param
    : INT ID
    {
        $$ = json_object();
        json_object_set($$, "type", json_string("int"));
        json_object_set($$, "name", $2);
    }
    ;

compound_stmt
    : '{' stmt_list '}' {$$ = $2;}
    ;

stmt_list
    : mixed_stmt    {$$ = $1;}
    | stmt_list mixed_stmt {$$ = add_to_array($1, $2);}
    ;

mixed_stmt
    : var_declaration {$$ = $1;}
    | statement {$$ = $1;}
    ;

statement
    : expression_stmt {$$ = $1;}
    | compound_stmt {$$ = $1;}
    | if_else_stmt {$$ = $1;}
    | while_stmt {$$ = $1;}
    | return_stmt {$$ = $1;}
    ;

expression_stmt
    : expression ';' {$$ = $1;}
    | ';' {$$ = json_object();}
    ;

if_else_stmt
    : if_stmt ELSE statement
    {
        $$ = $1;
        json_object_set($$, "else_statement", $3);
    }
    | if_stmt {$$ = $1;}
    ;

if_stmt
    : IF '(' expression ')' statement
    {
        $$ = json_object();
        json_object_set($$, "type", json_string("if clause"));
        json_object_set($$, "condition", $3);
        json_object_set($$, "statement", $5);
    }
    ;

while_stmt
    : WHILE '(' expression ')' statement
    {
        $$ = json_object();
        json_object_set($$, "type", json_string("while clause"));
        json_object_set($$, "condition", $3);
        json_object_set($$, "statement", $5);
    }
    ;

return_stmt
    : RETURN expression ';'
    {
        $$ = json_object();
        json_object_set($$, "type", json_string("return"));
        json_object_set($$, "expression", $2);
    }
    ;

expression
    : ID '=' expression
    {
        $$ = json_object();
        json_object_set($$, "type", json_string("assign"));
        json_object_set($$, "IDENTIFIER", $1);
        json_object_set($$, "expression", $3);
    }
    | simple_expression {$$ = $1;}
    ;

simple_expression
    : additive_expression {$$ = $1;}
    | simple_expression relop additive_expression {add_to_array($1, $3);}
    ;

relop
    : LS {$$ = json_string("<");}
    | LEQ {$$ = json_string("<=");}
    | GT {$$ = json_string(">");}
    | GEQ {$$ = json_string("<=");}
    | EQ {$$ = json_string("==");}
    | NEQ {$$ = json_string("!=");}
    ;

additive_expression
    : term {$$ = $1;}
    | term '+' term
    {
        $$ = json_object();
        json_object_set($$, "type", json_string("addition"));
        json_object_set($$, "opr1", $1);
        json_object_set($$, "opr2", $3);
    }
    | term '-' term
    {
        $$ = json_object();
        json_object_set($$, "type", json_string("substitution"));
        json_object_set($$, "opr1", $1);
        json_object_set($$, "opr2", $3);
    }
    ;

term
    : factor {$$ = $1;}
    | factor '*' factor
    {
        $$ = json_object();
        json_object_set($$, "type", json_string("multiplication"));
        json_object_set($$, "opr1", $1);
        json_object_set($$, "opr2", $3);
    }
    | factor '/' factor
    {
        $$ = json_object();
        json_object_set($$, "type", json_string("division"));
        json_object_set($$, "opr1", $1);
        json_object_set($$, "opr2", $3);
    }
    ;

factor
    : '(' expression ')' {$$ = $2;}
    | ID {$$ = $1;}
    | call {$$ = $1;}
    | NUM {$$ = $1;}
    ;

call
    : ID '(' arg_list ')'
    {
        $$ = json_object();
        json_object_set($$, "calling", $1);
        json_object_set($$, "parameter", $3);
    }
    | ID '(' ')'
    {
        $$ = json_object();
        json_object_set($$, "calling", $1);
        json_object_set($$, "parameter", json_string("void"));
    }
    ;

arg_list
    : expression {$$ = $1;}
    | arg_list ',' expression {add_to_array($1, $3);}
    ;

%%

void yyerror(const char *s)
{
    fflush(stdout) ;
    fprintf(stderr, "*** %s\n", s) ;
}
