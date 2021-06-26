%{

#include <stdio.h>
#include "symbol_table.h"
#include "operation.h"
#include "statement.h"
#include "graph.h"
#include <string.h>
#include <stdlib.h>

int yylex();
void yyerror(char *s);
int yywrap(){
    return 1;
}

struct sym sym_table[MAX_SYMB];
int yydebug = 1;
//enum types type;
//enum types value_type;
int new_graph_vertex_num = 0;
int temp_edges_qty = 0;
struct g_edge * temp_edges = NULL;
struct g_edge temp_edge;
struct sym * last_sym = NULL;
int syms_counter = 0;
#define NODE_IN_RANGE(n,max) (n >= 0 && n < max)
%}

%union {
int val;
struct operation *operation;
struct statement * statement;
struct condition * condition;
struct variable * variable;
struct edge * edge;
int type;
int graph_type;
struct sym *symp;
char * str;
}

%type <operation> expression
%type <operation> operation
%type <statement> list
%type <statement> s
%type <statement> definition
%type <statement> assignment
%type <statement> if
%type <statement> do_while
%type <statement> while
%type <statement> gr_iter
%type <operation> condition
%type <operation> cond_log
%type <operation> cond_or
%type <operation> cond_and
%type <variable> n
%type <type> type
%type <statement> e
%type <operation> t
%type <edge> edges
%type <edge> edge

%token <str> VAR
%token <val> VALUE
%token <graph_type> GRAPH W_GRAPH D_GRAPH
%token <str> STRING_LITERAL
%token PLUS MINUS MULT DIV
%token WHILE DO IF
%token  ASSIGN_OP AND OR NOT RELATIONAL_OPS TYPE 
%token  LETTER DECIMAL OPEN_PAR CLOSE_PAR OPEN_BRACKET CLOSE_BRACKET SEMICOLON ID ARROW DOUBLE_ARROW
%token  DFS BFS INT STRING TREE CONS COMMA HYPHEN
%%

program:  defs list ;

list: s
	| list s
	;

s:	    e SEMICOLON
    |   while
    |   do_while
    |   if
    |   gr_iter
    ;

e:      definition
    |   assignment
    ;

if:     IF OPEN_PAR condition CLOSE_PAR OPEN_BRACKET list CLOSE_BRACKET
                {$$ = create_statement($3, $6, ST_IF); }
        ;
while:     WHILE OPEN_PAR condition CLOSE_PAR OPEN_BRACKET list CLOSE_BRACKET
                { $$ = create_statement($3,$6,ST_WHILE); }
        ;

do_while:   DO OPEN_BRACKET list CLOSE_BRACKET WHILE OPEN_PAR condition CLOSE_PAR
                { $$ = create_statement($7,$3,ST_DO_WHILE); }
    ;



condition:  cond_log 
    | cond_and 
    | cond_or
    | operation
    ;
    
cond_log:   condition RELATIONAL_OPS condition  
            ;

cond_and:   cond_log AND cond_log;

cond_or:    cond_log OR cond_log;

defs:   defs definition SEMICOLON | definition SEMICOLON ;

definition:     type n      
                    {$$ = create_definition($1, $2); }
            |   GRAPH OPEN_PAR VALUE CLOSE_PAR n 
                    {$$ = create_graph_definition($1, $3, $5);}
            |   D_GRAPH OPEN_PAR VALUE CLOSE_PAR n 
                    {$$ = create_graph_definition($1, $3, $5);}
            |   W_GRAPH OPEN_PAR VALUE CLOSE_PAR n 
                    {$$ = create_graph_definition($1, $3, $5);}
//            |   graph_type vertex_num n {type = T_GRAPH; printf("%d\n", new_graph_vertex_num);}
            ;

edges:      edges COMMA edge
        |   edge
        ;
//edges:
//        edges COMMA edge {if (temp_edges == NULL) temp_edges = malloc(10*sizeof(struct g_edge));} 
//        | edge           
//        | edge {if (temp_edges == NULL) temp_edges = malloc(10*sizeof(struct g_edge));}
//        ;

edge:       VALUE ARROW VALUE
                { $$ = create_edge($1, $3, S_EDGE_TYPE, 0); }
        |   VALUE HYPHEN OPEN_PAR VALUE CLOSE_PAR ARROW VALUE
                {$$ = create_w_edge($1, $7, $4, W_EDGE_TYPE, 0); }
        ;

type: INT {$$ = T_INTEGER ;} | STRING {$$ = T_STRING;} ;

assignment:     n ASSIGN_OP expression 
                        {$$ = create_assignment($1, $3, NULL); }
            |   n ASSIGN_OP  STRING_LITERAL  
                        { $$ = create_assignment($1, NULL, $3); }
            | n ASSIGN_OP OPEN_BRACKET edges CLOSE_BRACKET
                        {$$ = create_edges($1, $4); }
            ;
   
expression:     operation
            |   t
            ;
operation:      expression PLUS     expression {$$ = create_operation(OP_SUM, $1, $3);}
           |    expression MINUS    expression {$$ = create_operation(OP_MINUS, $1, $3);}
           |    expression MULT     expression {$$ = create_operation(OP_MULT, $1, $3);}
           |    expression DIV      expression {$$ = create_operation(OP_DIV, $1, $3);}
           ;
            
t:      VAR {$$ = create_op_from_var($1);}
    |   OPEN_PAR expression CLOSE_PAR   {$$ = create_paren($2); }
    |   VALUE {$$ = create_op_from_const($1);}
    ;

gr_iter:    DFS OPEN_PAR n CLOSE_PAR  {$$ = create_gr_iter($3,DFS_ITER); }
        |   BFS OPEN_PAR n CLOSE_PAR  {$$ = create_gr_iter($3,BFS_ITER); }
        ;

//graph_type: GRAPH {type=T_GRAPH;} ;

//vertex_num: OPEN_PAR VALUE CLOSE_PAR { new_graph_vertex_num = $2; };

n:  VAR     {$$ = create_variable($1);};

// d_node_def: ID DOUBLE_ARROW ID 
//        |   ID ARROW ID
//        ;
     
%%

extern FILE * yyin;

void free_resources(){
    struct sym  st;

    for (int i = 0 ; i < syms_counter ; i++){
        st = sym_table[i];

        free(st.name);
        if(st.type == T_STRING && st.content.string_value != NULL)
            free(st.content.string_value);
        else if(st.type == T_GRAPH){
            if (st.content.graph_data.edges_info != NULL)
                free(st.content.graph_data.edges_info);
        }
    }
}

int main(int argc, char *argv[]){
	
    if(argc == 2){
        //leemos del archivo
        yyin = fopen(argv[1],"r");
        while(!feof(yyin))
            yyparse();
    
    }else if (argc == 1){
        //TODO esto ta roto
        //leemos d stdin
        // while(getchar() != EOF)
            yyparse();
    }

    printf("m boi\n");
    free_resources();
    return 1;
 }
void yyerror(s)
char * s;
{
    fprintf( stderr,"errorr ---%s\n",s);
}
