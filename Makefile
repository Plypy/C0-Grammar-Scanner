lexer: bison flex compile_lexer

parser: bison flex compile_parser

flex: test.l test.tab.c
	flex -o test.yy.c test.l

compile_lexer:
	gcc test.yy.c test.tab.c lexer.c -o lexer -l jansson

compile_parser:
	gcc test.yy.c test.tab.c parser.c -o parser -l jansson

bison: test.y
	bison test.y -d

clean:
	rm test.tab.c test.tab.h test.yy.c

