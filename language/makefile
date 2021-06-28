
CC = gcc
CFGLAGS = -Wall
OBJ = lex.yy.o y.tab.o ast.o 

.PHONY: clean
clean:
	rm -rf *.o
	rm -rf *.gch
	rm -f y.tab.c
	rm -f y.tab.h
	rm -f lex.yy.c

all:
	flex lex.l
	yacc -d yacc.y 
	$(CC) $(CFLAGS) -c lex.yy.c y.tab.c ast.c 
	$(CC) $(CFLAGS) -o ../lang  $(OBJ) -ll
