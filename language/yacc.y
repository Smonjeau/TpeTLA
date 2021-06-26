%{

#include <stdio.h>
#include "symbol_table.h"
#include "operation.h"
#include <string.h>
#include <stdlib.h>

#include "operation.h"
int yylex();
void yyerror(char *s);
struct sym sym_table[MAX_SYMB];
int yydebug = 1;
enum types type;
enum types value_type;
int new_graph_vertex_num = 0;
struct sym * last_sym = NULL;

%}

%union {
int val;
enum operators * operator;
struct operation *operation;
struct sym *symp;
char * str;
}
%type <operation> operation
%type <val> e
%type <val> t

%token <symp> VAR
%token <val> VALUE
%token <str> STRING_LITERAL
%token <operator> ARITHMETICAL_OPS
%token <operator> MULT_DIV_OPS
%token  DO WHILE ASSIGN_OP AND OR NOT RELATIONAL_OPS  TYPE IF ELSE 
%token  LETTER DECIMAL OPEN_PAR CLOSE_PAR OPEN_BRACKET CLOSE_BRACKET SEMICOLON ID ARROW DOUBLE_ARROW
%token  GRAPH DFS BFS INT STRING W_GRAPH TREE D_GRAPH  CONS QUOTE 

%%

program:  defs list ;


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
cond_log:   e RELATIONAL_OPS e ;

cond_and:   cond_log AND cond_log;

cond_or:    cond_log OR cond_log;

e:  VAR ASSIGN_OP operation {sym_table_look($1->name)->type == T_INTEGER ? $1->content.int_value = $3 : yyerror("Error al asignar int");}
    | VAR ASSIGN_OP  STRING_LITERAL  {
                                        if(sym_table_look($1->name)->type == T_STRING) {
                                            int len = strlen($3) + 1; $1->content.string_value = malloc(len); 
                                            strcpy($1->content.string_value,$3);
                                            $1->content.string_value[len - 1] = 0;
                                            printf("STRING\n");
                                        } else {
                                            yyerror("Error al asignar string");
                                        }
                                        
                                    }
    | VAR ASSIGN_OP OPEN_BRACKET CLOSE_BRACKET
    ;

operation: operation ARITHMETICAL_OPS operation {$$ = create_operation(operator_look($2), $1, $2);}
           | t                                       
           ;
            

edges:
        edges edge
        | edge
        ;

edge:   node_def
        //TODO agregar mas tipos de flechitas
        ;

t:  t MULT_DIV_OPS t    {$$ = create_operation(operator_look($2), $1, $2);}
        | f
        ;

f:  VAR | VALUE ;

defs:   defs def SEMICOLON | def SEMICOLON ;

def:    type n 
        | graph_type vertex_num n {type = T_GRAPH; printf("%d\n", new_graph_vertex_num);}
        ;



gr_iter_type: DFS | BFS ;

gr_iter:    gr_iter_type OPEN_PAR n SEMICOLON n CLOSE_PAR s
        |   gr_iter_type OPEN_PAR n SEMICOLON n CLOSE_PAR OPEN_BRACKET list CLOSE_BRACKET

        ;
type: INT {type = T_INTEGER ;} | STRING {type = T_STRING;} ;

graph_type: GRAPH {type=T_GRAPH;} ;

vertex_num: OPEN_PAR VALUE CLOSE_PAR { new_graph_vertex_num = $2; };

n:  VAR;


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

node_def:   VALUE ARROW VALUE { printf("magia\n"); };

d_node_def: ID DOUBLE_ARROW ID 
        |   ID ARROW ID
        ;

w_node_def: ID '-' '>' '(' number '-' '>' ID ;
     
%%

extern FILE * yyin;

int main(int argc, char *argv[]){
	
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
            if(st->name && !strcmp(st->name,s)){
                
                if(type != NONE){
                        yyerror("Redefine variable\n");
                        type = NONE;
                        return st; //TODO SACAME
                        
                }
                
                printf("Ya estaba en la tabla, el nombre es %s y el valor es",st->name);
                if(st->type == T_INTEGER)
                    printf(" %d\n",st->content.int_value);
                else if(st->type == T_STRING)
                    printf(" %s\n",st->content.string_value);
                                
                return st;

            }


            if(!st->name){
                
                if(type == NONE){
                    yyerror("Variable not found\n");
                    return st; //TODO SACAME
                } else if(type == T_GRAPH && new_graph_vertex_num <= 0) {
                    yyerror("Wrong vertex number\n");
                    return st; //TODO SACAME
                }
                st->name = strdup(s);
                printf("Guardamos en la tabla de simbolos la variable %s \n",st->name);
                st->type = type;
                if(type == T_GRAPH) {
                    new_graph_vertex_num = 0;
                    //TODO crear grafo

                }
                type = NONE;
                return st;
            }
    }
    type = NONE;
    yyerror("Limit of symbs reached\n");
}