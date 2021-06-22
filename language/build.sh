lex $1
yacc -d $2
gcc -c lex.yy.c y.tab.c
gcc -o lang lex.yy.o y.tab.o -ll
