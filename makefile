
CC = gcc
CFGLAGS = -Wall
OBJ = lex.yy.o y.tab.o ast.o

.PHONY: clean
clean:
	rm -f lang
	rm -f runme
	rm -f intermediate.c
	cd language; make clean
all:
	cd language; make all
