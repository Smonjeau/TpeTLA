lex $1
yacc -d $2
gcc -c lex.yy.c y.tab.c ast.c
gcc -o lang lex.yy.o y.tab.o ast.o -ll
