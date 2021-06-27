%{

#include <stdio.h>
#include "symbol_table.h"
#include <string.h>
#include <stdlib.h>
#include "ast.h"
#include "statement.h"
int yylex();
void yyerror(char *s);
struct sym sym_table[MAX_SYMB];
int yydebug = 1;
int is_t_var = 1;
enum types type;
enum types value_type;
int new_graph_vertex_num = 0;
int temp_edges_qty = 0;
struct g_edge * temp_edges = NULL;
struct g_edge temp_edge;
struct sym * last_sym = NULL;
int syms_counter = 0;
ast_node * root;
#define NODE_IN_RANGE(n,max) (n >= 0 && n < max)
%}

%union {
int val;
struct sym *symp;
char * str;
struct condition * cond;
struct ast_node  * ast;
struct expression * expr;
}
%type <ast> program defs list def type graph_type gr_iter_type condition
%type <ast> n s print e read while do_while gr_iter if assignment
%token <symp> VAR
%token <val> VALUE
%token <str> STRING_LITERAL
%type<val> operation expression
%type <cond> cond_log cond_and cond_or
%type <str> t

%token  DO WHILE  PLUS MINUS MULT DIV ASSIGN_OP MULT_DIV_OPS AND OR NOT TYPE IF ELSE 
%token  LETTER DECIMAL OPEN_PAR CLOSE_PAR OPEN_BRACKET CLOSE_BRACKET SEMICOLON ID ARROW DOUBLE_ARROW
%token  GRAPH DFS BFS INT STRING W_GRAPH TREE D_GRAPH  CONS COMMA  PRINT READ LOWER LOWER_EQ GREATER GREATER_EQ EQ N_EQ

%%

program:  defs list {root =  add_node(PROGRAM_NODE, $1, $2, NULL);} ;


list: s {$$ = add_node(LIST_NODE, $1, NULL, NULL);}
	| list s { $$ = add_node(LIST_NODE, $2, $1, NULL);}
        
	;

s:	e SEMICOLON {$$ = $1;}
	| while {$$ = $1 ;}
    | do_while {$$ = $1;}
    | gr_iter
    | print { $$ = $1; }
    | read { $$ = $1; }
    | if {$$ = $1;}
    ;

print: PRINT OPEN_PAR n CLOSE_PAR SEMICOLON {
        $$ = add_node(PRINT_NODE, $3, NULL, NULL);}
        ;

read: READ OPEN_PAR n CLOSE_PAR SEMICOLON { $$ = add_node(READ_NODE, $3, NULL, NULL);}
        ;

while:  WHILE OPEN_PAR condition CLOSE_PAR OPEN_BRACKET list CLOSE_BRACKET  {$$ = add_node(WHILE_NODE,$3,$6,NULL);}
        ;
do_while:   DO OPEN_BRACKET list CLOSE_BRACKET WHILE OPEN_PAR condition CLOSE_PAR SEMICOLON {$$ = add_node(DO_WHILE_NODE,$7,$3,NULL);}
    ;
if:     IF OPEN_PAR condition CLOSE_PAR OPEN_BRACKET list CLOSE_BRACKET
                {$$ = add_node(IF_NODE, $3, $6, NULL);/*$$ = create_statement($3, $6, ST_IF); */}

                ;
condition:  cond_log {$$ = add_node(COND_NODE,NULL,NULL,$1);}
    | cond_and {$$ = add_node(COND_NODE,NULL,NULL,$1);}
    | cond_or {$$ = add_node(COND_NODE,NULL,NULL,$1);}
    ;

cond_log:   t EQ t {condition * c = malloc(sizeof(struct condition)); c->cond_type = COND_EQ; c->cond1 = $1; c->cond2 = $3; $$ = c;}
        |   t N_EQ t {condition * c = malloc(sizeof(struct condition)); c->cond_type = COND_NE; c->cond1 = $1; c->cond2 = $3; $$ =c;}
        |   t LOWER t {condition * c = malloc(sizeof(struct condition)); c->cond_type = COND_LOWER; c->cond1 = $1; c->cond2 = $3; $$ =c;} 
        |   t LOWER_EQ t {condition * c = malloc(sizeof(struct condition)); c->cond_type = COND_LOWER_EQ; c->cond1 = $1; c->cond2 = $3; $$ =c;}
        |   t GREATER t {condition * c = malloc(sizeof(struct condition)); c->cond_type = COND_GREATER; c->cond1 = $1; c->cond2 = $3; $$ =c;}
        |   t GREATER_EQ t {condition * c = malloc(sizeof(struct condition)); c->cond_type = COND_GREATER_EQ; c->cond1 = $1; c->cond2 = $3; $$ =c;}
;
cond_and:   cond_log AND cond_log ;

cond_or:    cond_log OR cond_log;


 e: assignment {$$ = $1;}
    ;

edges:
        edges COMMA edge {if (temp_edges == NULL) temp_edges = malloc(10*sizeof(struct g_edge));} 
        | edge {if (temp_edges == NULL) temp_edges = malloc(10*sizeof(struct g_edge));}
        ;

edge:   node_def
        //TODO agregar mas tipos de flechitas
        | w_node_def
        ;


t:  n  {is_t_var = 1; $$ = ((struct sym *)$1->data)->name; } | VALUE { is_t_var = 0; char * buff = malloc(11); sprintf(buff, "%d", $1); $$ = buff;} // | OPEN_PAR expression CLOSE_PAR   {$$ = $2 ;};
    ;

defs:   defs def SEMICOLON {$$ = add_node(DEFS_NODE,$2,$1,NULL);}| def SEMICOLON {$$ = add_node(DEFS_NODE,$1,NULL,NULL);};

def:    type n {$$ = add_node(DEF_NODE,$1,$2,NULL);}
        | graph_type OPEN_PAR VALUE CLOSE_PAR n {new_graph_vertex_num = $3; ;$$ = add_node(DEF_NODE,$1,$5,NULL);}
        ;

assignment:     n ASSIGN_OP expression {
                                ((struct sym *)$1->data)->type == T_INTEGER ? ((struct sym *)$1->data)->content.int_value = $3 : yyerror("Error al asignar int");
                                int * int_value = malloc(sizeof(int)); // FREEAME
                                *int_value = $3;
                                ast_node * int_value_node = add_node(EXPRESSION_NODE, NULL, NULL, int_value);
                                ast_node * node = add_node(ASSIGN_NODE, $1, int_value_node, NULL);
                                $$ = node;
                            }
            |   n ASSIGN_OP  STRING_LITERAL {
                                        if(((struct sym *)$1->data)->type == T_STRING) {
                                            int len = strlen($3) + 1; ((struct sym *)$1->data)->content.string_value = malloc(len);
                                            strcpy(((struct sym *)$1->data)->content.string_value,$3);
                                            ((struct sym *)$1->data)->content.string_value[len - 1] = 0;
                                            

                                            char * new_str_literal = malloc(len); // FREEAME
                                            strcpy(new_str_literal,$3);
                                            ast_node * int_value_node = add_node(EXPRESSION_NODE, NULL, NULL, new_str_literal);
                                            ast_node * node = add_node(ASSIGN_NODE, $1, int_value_node, NULL);
                                            $$ = node;


                                        } else {
                                            yyerror("Error al asignar string");
                                        }
                                        
                                    }
            | n ASSIGN_OP OPEN_BRACKET edges CLOSE_BRACKET{ struct sym * s = (struct sym *)$1->data;
                                                    if(s->type == T_GRAPH){
                                                        int nqty = s->content.graph_data.nodes_qty;
                                                        printf("inicializando grafito\n");
                                                        for(int i = 0; i<temp_edges_qty;i++){
                                                            if(NODE_IN_RANGE(temp_edges[i].from,nqty) && NODE_IN_RANGE(temp_edges[i].to,nqty)){
                                                                // printf("Bien, de %d a %d\n",temp_edges[i].from,temp_edges[i].to);
                                                                ;
                                                            }else{
                                                                yyerror("Index out of range");
                                                                YYABORT;
                                                            }    
                                                        }
                                                        // free(temp_edges);
                                                        s->content.graph_data.edges_info = temp_edges;
                                                        s->content.graph_data.edges_qty = temp_edges_qty;
                                                        temp_edges = NULL;
                                                        temp_edges_qty = 0;
                                                    }
            }
            ;

expression:     operation {$$ = $1;}
            |   t {
                    if(is_t_var) {
                        struct sym * var_sym = sym_table_look($1);
                        if(var_sym->type != T_INTEGER) {
                            yyerror("Only int vars allowed in expressions");
                            YYABORT;
                        }
                        $$ = var_sym->content.int_value;
                    } else {
                        $$ = atoi($1);
                    }
                    
                }
            ;
operation:      expression PLUS     expression { $$ = $1 + $3; /*$$ = create_operation(OP_SUM, $1, $3);*/}
           |    expression MINUS    expression { $$ = $1 - $3;/*$$ = create_operation(OP_MINUS, $1, $3);*/}
           |    expression MULT     expression {$$ = $1 * $3; }
           |    expression DIV      expression { $$ = $1 / $3;}
           ;


gr_iter_type: DFS | BFS ;

gr_iter:    gr_iter_type OPEN_PAR n SEMICOLON n CLOSE_PAR s
        |   gr_iter_type OPEN_PAR n SEMICOLON n CLOSE_PAR OPEN_BRACKET list CLOSE_BRACKET

        ;
type: INT {type = T_INTEGER ; enum types * aux = malloc(sizeof(int)); *aux= T_INTEGER; $$ = add_node(TYPE_NODE,NULL,NULL,aux);} |
     STRING {type = T_STRING; enum types * aux = malloc(sizeof(int)); *aux= T_STRING; $$ = add_node(TYPE_NODE,NULL,NULL,aux);} 
     ;

graph_type: GRAPH {type=T_GRAPH; enum types * aux = malloc(sizeof(int)); *aux= T_GRAPH; $$ = add_node(TYPE_NODE,NULL,NULL,aux);} ;

//vertex_num: OPEN_PAR VALUE CLOSE_PAR { new_graph_vertex_num = $2; };

n:  VAR {/*char * aux = strdup($1->name);*/ $$ = add_node(VAR_NODE,NULL,NULL,$1);};


node_defs:  node_def
        |   node_defs node_def

        ;

d_node_defs:    d_node_def
            |   d_node_defs d_node_def
            ;
            
w_node_defs:    w_node_def 
            |   w_node_defs w_node_def
            ;

node_def:   VALUE ARROW VALUE { printf("guardando edge\n");

                                 if((temp_edges_qty % 10) == 0)
                                    temp_edges = realloc(temp_edges,sizeof(temp_edges) + 10*sizeof(struct g_edge));
                                
                                 temp_edges[temp_edges_qty].from = $1;
                                 temp_edges[temp_edges_qty++].to = $3;
                                 printf("Nuevo edges qty: %d\n", temp_edges_qty);
                                 }; 

d_node_def: ID DOUBLE_ARROW ID 
        |   ID ARROW ID
        ;

w_node_def: VALUE MINUS OPEN_PAR VALUE CLOSE_PAR ARROW VALUE {
                                printf("guardando edge con peso\n");
                                if((temp_edges_qty % 10) == 0)
                                    temp_edges = realloc(temp_edges,sizeof(temp_edges) + 10*sizeof(struct g_edge));
                                
                                temp_edges[temp_edges_qty].from = $1;
                                temp_edges[temp_edges_qty].to = $7;
                                temp_edges[temp_edges_qty++].weight = $4;
                                printf("Nuevo edges qty: %d\n", temp_edges_qty);

                                
                                }
 ; //TODO me da cosita
     
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

void decode_tree(ast_node * node, FILE * c_out) {
    enum types var_type;
    ast_node * left_var, *right_var;
    struct sym * left_sym;
    condition * condition_aux;

    switch(node->type) {
        case LIST_NODE:
            if(node->right != NULL)
                decode_tree(node->right, c_out);
            if(node->left != NULL)
                decode_tree(node->left, c_out);
            break;

        case PRINT_NODE:
            if(node->left != NULL && node->left->type == VAR_NODE) {
                var_type = ((struct sym *)node->left->data)->type;
                switch (var_type) {
                    case T_STRING:
                        fprintf(c_out, "printf(\"%%s\", %s);", ((struct sym *)node->left->data)->name);
                        break;
                    case T_INTEGER:
                        fprintf(c_out, "printf(\"%%d\", %s);", ((struct sym *)node->left->data)->name);
                        break;
                }
                
            }
            break;

        case ASSIGN_NODE:
            left_var = node->left;
            right_var = node->right;
            left_sym = (struct sym *)left_var->data;
            switch(left_sym->type) {
                case T_INTEGER:
                    fprintf(c_out, "%s = %d;", left_sym->name, *((int *)right_var->data));
                    break;
                case T_STRING:
                    fprintf(c_out, "%s = %s;", left_sym->name, (char *)right_var->data);
                    break;
            }
                
            break;

        case READ_NODE:
            left_var = node->left;
            left_sym = (struct sym *)left_var->data;
            switch(left_sym->type) {
                case T_INTEGER:
                    fprintf(c_out, "scanf(\"%%d\", &%s);", left_sym->name);
                    break;
                case T_STRING:
                    fprintf(c_out, "scanf(\"%%s\", %s);", left_sym->name);
                    break;
            }
            break;

        case IF_NODE:
            left_var = node->left;
            condition_aux = (condition *)left_var->data;
            fprintf(c_out, "if(%s %s %s){", condition_aux->cond1, condition_symbols[condition_aux->cond_type], condition_aux->cond2);
            decode_tree(node->right, c_out);
            fprintf(c_out, "}");
            ;

        case WHILE_NODE:
            left_var = node->left;
            condition_aux = (condition *)left_var->data;
            fprintf(c_out, "while(%s %s %s){", condition_aux->cond1, condition_symbols[condition_aux->cond_type], condition_aux->cond2);
            decode_tree(node->right, c_out);
            fprintf(c_out, "}");
            ;

        case DO_WHILE_NODE:
            left_var = node->left;
            condition_aux = (condition *)left_var->data;
            fprintf(c_out, "do {");
            decode_tree(node->right, c_out);
            fprintf(c_out, "} while(%s %s %s);", condition_aux->cond1, condition_symbols[condition_aux->cond_type], condition_aux->cond2);
            ;
    }
    
    
}

void decode_defs(ast_node * node, FILE * c_out) {
    if(node->right != NULL)
            decode_defs(node->right, c_out);
    if(node->left != NULL && node->left->type == DEF_NODE ){
        enum types t = *((int *) node->left->left->data);
        char * var_name = ((struct sym *) node->left->right->data)->name;
        struct sym * read_sym;
        switch(t) {
            case T_GRAPH:
                read_sym = (struct sym *) node->left->right->data;
                fprintf(c_out, "Graph %s;%s=graph_create(%d);", var_name, var_name, read_sym->content.graph_data.nodes_qty);

                break;
            case T_INTEGER:
                fprintf(c_out, "int %s;", var_name);
                break;
            case T_STRING:
                fprintf(c_out, "char * %s;", var_name);
                break;
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

    printf("Fin del parsing\n");
    if(root !=NULL){
        FILE * c_out = fopen("intermediate.c", "w+");
        if(c_out == NULL) {
            fprintf(stderr, "Unable to open intermediate.c file\n");
            exit(1);
        }

        fputs("#include \"graph_impl/graph.h\"\n", c_out);
        fputs("#include <stdio.h>\n", c_out);
        fputs("int main() {", c_out);


        if(root->left != NULL){
            decode_defs(root->left, c_out);
        }
        if(root->right != NULL)
            decode_tree(root->right, c_out);

        fputs("return 0;}", c_out);
        fclose(c_out);

    }
    free_resources();

    system("gcc graph_impl/queue.c graph_impl/graph.c intermediate.c -o runme");

    /*if(remove("intermediate.c") != 0)
        fprintf(stderr, "Error when trying to remove intermediate.c\n");*/
    return 0;
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
                else if(st->type == T_GRAPH){
                    printf("este es un grafo, tiene %d vertices\n",st->content.graph_data.nodes_qty);
                    for(int i = 0; i< st->content.graph_data.edges_qty ; i++)
                        printf("edge %d de %d a %d con peso %d\n",i,st->content.graph_data.edges_info[i].from,st->content.graph_data.edges_info[i].to,st->content.graph_data.edges_info[i].weight);
                }
                                
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
                syms_counter++;
                st->name = strdup(s);
                printf("Guardamos en la tabla de simbolos la variable %s \n",st->name);
                st->type = type;
                if(type == T_GRAPH) {
                    printf("es de tipo grafo\n");
                    
                    st->content.graph_data.nodes_qty = new_graph_vertex_num;
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