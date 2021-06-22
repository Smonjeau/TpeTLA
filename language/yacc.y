%{

#include <stdio.h>
#include "symbol_table.h"
#include <string.h>
int yylex();
void yyerror(char *s);
struct sym sym_table[MAX_SYMB];
int yydebug = 1;
%}

%union {
int val;
struct sym *symp;
}
%token <symp> VAR
%token <val> VALUE 

%token  DO WHILE  ARITHMETICAL_OPS ASSIGN_OP MULT_DIV_OPS AND OR NOT RELATIONAL_OPS  TYPE IF ELSE 
%token  LETTER DECIMAL OPEN_PAR CLOSE_PAR OPEN_BRACKET CLOSE_BRACKET SEMICOLON ID ARROW DOUBLE_ARROW
%token  GRAPH DFS BFS INT STRING W_GRAPH TREE D_GRAPH  CONS
%%

program:  defs list {;};


list: s
	| list s
	;

s:	e SEMICOLON
	| while
    | do_while
    | gr_iter
    ;
while:     WHILE OPEN_PAR condition CLOSE_PAR s
        |  WHILE OPEN_PAR condition CLOSE_PAR OPEN_BRACKET list CLOSE_BRACKET
        ;
do_while:   DO s WHILE OPEN_PAR condition CLOSE_PAR
    |       DO s WHILE OPEN_PAR condition CLOSE_PAR OPEN_BRACKET list CLOSE_BRACKET
    ;

condition:  cond_log 
    | cond_and 
    | cond_or
    ;
cond_log:   e RELATIONAL_OPS e;

cond_and:   cond_log AND cond_log;

cond_or:    cond_log OR cond_log;

e:  e ARITHMETICAL_OPS t
    | t
    ;

edge:   ARROW
        | DOUBLE_ARROW
        | '-''('number ')''-''>'
        ;

t:  t MULT_DIV_OPS f
        | f
        ;

f:  VAR | VALUE ;

defs:   defs def | def ;

def:    type n ';'
        | GRAPH n ASSIGN_OP OPEN_BRACKET node_defs CLOSE_BRACKET
        | D_GRAPH n ASSIGN_OP OPEN_BRACKET d_node_defs CLOSE_BRACKET
        | W_GRAPH n ASSIGN_OP OPEN_BRACKET w_node_defs CLOSE_BRACKET
        {printf("hola\n");}
        ;

gr_iter_type: DFS | BFS ;

gr_iter:    gr_iter_type OPEN_PAR n SEMICOLON n CLOSE_PAR s
        |   gr_iter_type OPEN_PAR n SEMICOLON n CLOSE_PAR OPEN_BRACKET list CLOSE_BRACKET

        ;
type: INT | STRING ;

n:  VAR ;

text:   l text 
        | d text
        | 
        ;
l:  LETTER ;

number: d number ;

d: DECIMAL ;

node_defs:  node_def
        |   node_defs node_def

        ;

d_node_defs:    d_node_def
            |   d_node_defs d_node_def
            ;
            
w_node_defs:    w_node_def 
            |   w_node_defs w_node_def
            ;

node_def:   ID ARROW ID ;

d_node_def: ID DOUBLE_ARROW ID 
        |   ID ARROW ID
        ;

w_node_def: ID '-' '>' '(' number '-' '>' ID ;

     
%%

extern FILE * yyin;

int main(int argc, char *argv[])
{
	/*
    yyin = fopen("lex", "r");	
	int i =0;
	printf("args: %s\n",argv[1]);
	printf("%p\n",yyin);
	printf("while\n");
	while(!feof(yyin)){
		printf("%d\n",i++);
		yyparse();
	}
	fclose(yyin);

	*/
	yyparse();
  return 1;
}
void yyerror(s)
char * s;
{
    fprintf( stderr,"errorr ---%s\n",s);
}

struct sym * sym_table_look(char * s){
        char * p;
        struct sym * st;
        int i;
        for(i=0;i<MAX_SYMB;i++){
                //ya definido
                st = &sym_table[i];
                if(st->name && !strcmp(st->name,s))
                        return st;

        
                if(!st->name){
                        st->name = strdup(s);
                        return st;
                }
        }
        yyerror("Limit of symbs reached\n");
}