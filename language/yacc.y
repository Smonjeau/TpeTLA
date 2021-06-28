%{

#include <stdio.h>
#include "symbol_table.h"
#include <string.h>
#include <stdlib.h>
#include <ctype.h>
#include "ast.h"
#include "statement.h"
int yylex();
void yyerror(char *s);
enum types assert_same_type(char * n1, char * n2);
int yywrap(){
    return 1;
}
struct sym sym_table[MAX_SYMB];
int yydebug = 1;
int is_t_var = 1;
int found_entry_point = 0;
enum types type;
enum types value_type;
int new_graph_vertex_num = 0;
int temp_edges_qty = 0;
struct g_edge * temp_edges = NULL;
struct g_edge temp_edge;
struct sym * last_sym = NULL;
#define FORCE_PAR (void *)0x1
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
%type <ast> program defs list def type graph_type  condition cond_and cond_or cond_not
%type <ast> n s print e read while do_while gr_iter if assignment entry_point operation 
%token <symp> VAR
%token <val> VALUE
%token <str> STRING_LITERAL
%token <str> DFS BFS
%type <cond> cond_log  
%type <str> t
%type <val> expression

%token  DO WHILE  PLUS MINUS MULT DIV ASSIGN_OP  AND OR NOT TYPE IF ELSE 
%token  LETTER DECIMAL OPEN_PAR CLOSE_PAR OPEN_BRACKET CLOSE_BRACKET SEMICOLON ID ARROW DOUBLE_ARROW
%token  GRAPH INT STRING W_GRAPH TREE D_GRAPH  CONS COMMA  PRINT READ LOWER LOWER_EQ GREATER GREATER_EQ EQ N_EQ
%token  ENTRY_POINT

%left OR
%left AND
%left GREATER GREATER_EQ LOWER LOWER_EQ EQ N_EQ
%left PLUS MINUS 
%left MULT DIV
%left NOT



%%

program:  defs list {root =  add_node(PROGRAM_NODE, $1, $2, NULL);} | defs {root= add_node(PROGRAM_NODE,$1,add_node(LIST_NODE, NULL, NULL, NULL),NULL);};


list: s {$$ = add_node(LIST_NODE, $1, NULL, NULL);}
	| list s { $$ = add_node(LIST_NODE, $2, $1, NULL);}
   
        
	;

s:	e SEMICOLON {$$ = $1;}
	| while {$$ = $1 ;}
    | do_while {$$ = $1;}
    | gr_iter {$$ = $1;}
    | print { $$ = $1; }
    | read { $$ = $1; }
    | if {$$ = $1;}
    | entry_point {$$ = $1;}
    ;

entry_point: ENTRY_POINT {
                        if(!found_entry_point) {
                            found_entry_point = 1;
                            $$ = add_node(ENTRY_POINT_NODE, NULL, NULL, NULL);
                        } else {
                            yyerror("Multiple entry points detected");
                            YYABORT;
                        }

                    }
            ;

print: PRINT OPEN_PAR n CLOSE_PAR SEMICOLON {
        $$ = add_node(PRINT_NODE, $3, NULL, NULL);}
        ;

read: READ OPEN_PAR n CLOSE_PAR SEMICOLON { $$ = add_node(READ_NODE, $3, NULL, NULL);}
        ;

while:  WHILE OPEN_PAR condition CLOSE_PAR OPEN_BRACKET list CLOSE_BRACKET  {$$ = add_node(WHILE_NODE,$3,$6,NULL);}
        | WHILE OPEN_PAR condition CLOSE_PAR OPEN_BRACKET CLOSE_BRACKET {$$ = add_node(WHILE_NODE, $3, add_node(LIST_NODE, NULL, NULL, NULL), NULL);}
        ;
do_while:   DO OPEN_BRACKET list CLOSE_BRACKET WHILE OPEN_PAR condition CLOSE_PAR SEMICOLON {$$ = add_node(DO_WHILE_NODE,$7,$3,NULL);}
        | DO OPEN_BRACKET CLOSE_BRACKET WHILE OPEN_PAR condition CLOSE_PAR SEMICOLON {$$ = add_node(DO_WHILE_NODE, $6, add_node(LIST_NODE, NULL, NULL, NULL), NULL);}
    ;
if:     IF OPEN_PAR condition CLOSE_PAR OPEN_BRACKET list CLOSE_BRACKET
                {$$ = add_node(IF_NODE, $3, $6, NULL);}
        | IF OPEN_PAR condition CLOSE_PAR OPEN_BRACKET CLOSE_BRACKET
                {$$ = add_node(IF_NODE, $3, add_node(LIST_NODE, NULL, NULL, NULL), NULL);}

                ;
condition:  cond_log {$$ = add_node(COND_NODE,NULL,NULL,$1);}
    | cond_and {$$ = $1;}
    | cond_or {$$ = $1;}
    | cond_not {$$ = $1;}
    |  OPEN_PAR condition CLOSE_PAR {

                if($2->type  == OR_NODE || $2->type == AND_NODE){
                    $2->data = FORCE_PAR;

                }
                $$ =$2;}
    ;

cond_log:   t EQ t {enum types op_type = assert_same_type($1, $3); if(op_type == T_ERROR) {YYABORT;} condition * c = malloc(sizeof(struct condition)); c->cond_type = COND_EQ; c->cond1 = $1; c->cond2 = $3; $$ = c; if(op_type != NONE) c->involved_types = op_type;}
        |   t N_EQ t {enum types op_type = assert_same_type($1, $3); if(op_type == T_ERROR) {YYABORT;} condition * c = malloc(sizeof(struct condition)); c->cond_type = COND_NE; c->cond1 = $1; c->cond2 = $3; $$ =c; if(op_type != NONE) c->involved_types = op_type;}
        |   t LOWER t {enum types op_type = assert_same_type($1, $3); if(op_type == T_ERROR) {YYABORT;} condition * c = malloc(sizeof(struct condition)); c->cond_type = COND_LOWER; c->cond1 = $1; c->cond2 = $3; $$ =c; if(op_type != NONE) c->involved_types = op_type;} 
        |   t LOWER_EQ t {enum types op_type = assert_same_type($1, $3); if(op_type == T_ERROR) {YYABORT;} condition * c = malloc(sizeof(struct condition)); c->cond_type = COND_LOWER_EQ; c->cond1 = $1; c->cond2 = $3; $$ =c; if(op_type != NONE) c->involved_types = op_type;}
        |   t GREATER t {enum types op_type = assert_same_type($1, $3); if(op_type == T_ERROR) {YYABORT;} condition * c = malloc(sizeof(struct condition)); c->cond_type = COND_GREATER; c->cond1 = $1; c->cond2 = $3; $$ =c; if(op_type != NONE) c->involved_types = op_type;}
        |   t GREATER_EQ t {enum types op_type = assert_same_type($1, $3); if(op_type == T_ERROR) {YYABORT;} condition * c = malloc(sizeof(struct condition)); c->cond_type = COND_GREATER_EQ; c->cond1 = $1; c->cond2 = $3; $$ =c; if(op_type != NONE) c->involved_types = op_type;}
        ;
cond_and:   condition AND condition {ast_node * node = add_node(AND_NODE,$1,$3,NULL); $$ = node; };

cond_or:    condition OR condition  {ast_node * node = add_node(OR_NODE,$1,$3,NULL); $$ = node;};

cond_not:   NOT condition {$$ = add_node(NOT_NODE,$2,NULL,NULL);};

         


 e: assignment {$$ = $1;}
    |   n 
    ;

edges:
        edges COMMA edge {if (temp_edges == NULL) temp_edges = malloc(10*sizeof(struct g_edge));} 
        | edge {if (temp_edges == NULL) temp_edges = malloc(10*sizeof(struct g_edge));}
        ;

edge:   VALUE ARROW VALUE { printf("guardando edge\n");

                                 if((temp_edges_qty % 10) == 0)
                                    temp_edges = realloc(temp_edges,sizeof(temp_edges) + 10*sizeof(struct g_edge));
                                
                                 temp_edges[temp_edges_qty].from = $1;
                                 temp_edges[temp_edges_qty++].to = $3;
                                 printf("Nuevo edges qty: %d\n", temp_edges_qty);
                                 }; 
        | VALUE MINUS OPEN_PAR VALUE CLOSE_PAR ARROW VALUE {
                                printf("guardando edge con peso\n");
                                if((temp_edges_qty % 10) == 0)
                                    temp_edges = realloc(temp_edges,sizeof(temp_edges) + 10*sizeof(struct g_edge));
                                
                                temp_edges[temp_edges_qty].from = $1;
                                temp_edges[temp_edges_qty].to = $7;
                                temp_edges[temp_edges_qty++].weight = $4;
                                printf("Nuevo edges qty: %d\n", temp_edges_qty);

                                
                                }
        | VALUE LOWER MINUS OPEN_PAR VALUE CLOSE_PAR ARROW VALUE {
                                printf("guardando edge doble con peso\n");
                                if((temp_edges_qty % 10) == 0)
                                    temp_edges = realloc(temp_edges,sizeof(temp_edges) + 10*sizeof(struct g_edge));
                                
                                temp_edges[temp_edges_qty].from = $1;
                                temp_edges[temp_edges_qty].to = $8;
                                temp_edges[temp_edges_qty++].weight = $5;

                                temp_edges[temp_edges_qty].from = $8;
                                temp_edges[temp_edges_qty].to = $1;
                                temp_edges[temp_edges_qty++].weight = $5;

                                printf("Nuevo edges qty: %d\n", temp_edges_qty);

                                
                                }
        | VALUE DOUBLE_ARROW VALUE {
            if((temp_edges_qty % 10) == 0)
                temp_edges = realloc(temp_edges,sizeof(temp_edges) + 10*sizeof(struct g_edge));

            
            temp_edges[temp_edges_qty].from = $1;
            temp_edges[temp_edges_qty++].to = $3;
            temp_edges[temp_edges_qty].from = $3;
            temp_edges[temp_edges_qty++].to = $1;



        }
        ;


t:  n  {is_t_var = 1; $$ = ((struct sym *)$1->data)->name; } | VALUE { is_t_var = 0; char * buff = malloc(11); sprintf(buff, "%d", $1); $$ = buff;} // | OPEN_PAR expression CLOSE_PAR   {$$ = $2 ;};
    ;

defs:   defs def SEMICOLON {$$ = add_node(DEFS_NODE,$2,$1,NULL);}| def SEMICOLON {$$ = add_node(DEFS_NODE,$1,NULL,NULL);} | entry_point { $$ = $1;};

def:    type n {$$ = add_node(DEF_NODE,$1,$2,NULL);}
        | graph_type vertex_num n {
            
            $$ = add_node(DEF_NODE,$1,$3,NULL);
            }
        ;

vertex_num: OPEN_PAR VALUE CLOSE_PAR { new_graph_vertex_num = $2; {printf("VERTEX\n");} };

assignment:     n ASSIGN_OP expression {
                                ((struct sym *)$1->data)->type == T_INTEGER ? ((struct sym *)$1->data)->content.int_value = $3 : yyerror("Error al asignar int");
                                int * int_value = malloc(sizeof(int)); // FREEAME
                                *int_value = $3;
                                ast_node * int_value_node = add_node(EXPRESSION_NODE, NULL, NULL, int_value);
                                ast_node * node = add_node(ASSIGN_NODE, $1, int_value_node, NULL);
                                $$ = node;
                            }
            |   n ASSIGN_OP operation {
                                $$ = add_node(ASSIGN_NODE, $1, $3, NULL);
                            }
            |
                n ASSIGN_OP  STRING_LITERAL {
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
                                                        $$ = add_node(ASSIGN_NODE,$1,NULL,NULL);
                                                    }
            }
            ;

expression:     t {
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
operation:      t PLUS     t {
                    int len = strlen($1);
                    char * aux = malloc(len + 1);
                    strcpy(aux, $1);
                    ast_node * n1 = add_node(EXPRESSION_NODE, NULL, NULL, aux);
                    len = strlen($3);
                    aux = malloc(len + 1);
                    strcpy(aux, $3);
                    ast_node * n2 = add_node(EXPRESSION_NODE, NULL, NULL, aux);
                    $$ = add_node(PLUS_NODE,n1, n2, NULL); }
           |    t MINUS    t {
                    int len = strlen($1);
                    char * aux = malloc(len + 1);
                    strcpy(aux, $1);
                    ast_node * n1 = add_node(EXPRESSION_NODE, NULL, NULL, aux);
                    len = strlen($3);
                    aux = malloc(len + 1);
                    strcpy(aux, $3);
                    ast_node * n2 = add_node(EXPRESSION_NODE, NULL, NULL, aux);
                    $$ = add_node(MINUS_NODE,n1, n2, NULL); }
           |    t MULT     t {
                    int len = strlen($1);
                    char * aux = malloc(len + 1);
                    strcpy(aux, $1);
                    ast_node * n1 = add_node(EXPRESSION_NODE, NULL, NULL, aux);
                    len = strlen($3);
                    aux = malloc(len + 1);
                    strcpy(aux, $3);
                    ast_node * n2 = add_node(EXPRESSION_NODE, NULL, NULL, aux);
                    $$ = add_node(MULT_NODE,n1, n2, NULL); }
           |    t DIV      t {
                    int len = strlen($1);
                    char * aux = malloc(len + 1);
                    strcpy(aux, $1);
                    ast_node * n1 = add_node(EXPRESSION_NODE, NULL, NULL, aux);
                    len = strlen($3);
                    aux = malloc(len + 1);
                    strcpy(aux, $3);
                    ast_node * n2 = add_node(EXPRESSION_NODE, NULL, NULL, aux);
                    $$ = add_node(DIV_NODE,n1, n2, NULL); }
           ;


gr_iter:    DFS OPEN_PAR n COMMA t COMMA n CLOSE_PAR OPEN_BRACKET list CLOSE_BRACKET {

                    struct gr_iteration * aux = malloc(sizeof(struct gr_iteration)); //FREEEEEEEEE
                    aux->init = $5;
                    aux->var = (struct sym * ) $7->data;
                    $$ = add_node(DFS_NODE, $3, $10, aux);
            }
        | DFS OPEN_PAR n COMMA t COMMA n CLOSE_PAR OPEN_BRACKET CLOSE_BRACKET {
                    struct gr_iteration * aux = malloc(sizeof(struct gr_iteration)); //FREEEEEEEEE
                    aux->init = $5;
                    aux->var = (struct sym * ) $7->data;
                    $$ = add_node(DFS_NODE, $3, add_node(LIST_NODE, NULL, NULL, NULL), aux);
            }
        |   BFS OPEN_PAR n COMMA t COMMA n CLOSE_PAR OPEN_BRACKET list CLOSE_BRACKET {
                    struct gr_iteration * aux = malloc(sizeof(struct gr_iteration)); //FREEEEEEEEE
                    aux->init = $5;
                    aux->var = (struct sym * ) $7->data;
                    $$ = add_node(BFS_NODE, $3, $10, aux);
            }
        | BFS OPEN_PAR n COMMA t COMMA n CLOSE_PAR OPEN_BRACKET CLOSE_BRACKET {
                    struct gr_iteration * aux = malloc(sizeof(struct gr_iteration)); //FREEEEEEEEE
                    aux->init = $5;
                    aux->var = (struct sym * ) $7->data;
                    $$ = add_node(BFS_NODE, $3, add_node(LIST_NODE, NULL, NULL, NULL), aux);
            }


        ;
type: INT {type = T_INTEGER ; enum types * aux = malloc(sizeof(int)); *aux= T_INTEGER; $$ = add_node(TYPE_NODE,NULL,NULL,aux);} |
     STRING {type = T_STRING; enum types * aux = malloc(sizeof(int)); *aux= T_STRING; $$ = add_node(TYPE_NODE,NULL,NULL,aux);} 
     ;

graph_type: GRAPH {type=T_GRAPH; enum types * aux = malloc(sizeof(int)); *aux= T_GRAPH; $$ = add_node(TYPE_NODE,NULL,NULL,aux);} ;


n:  VAR {/*char * aux = strdup($1->name);*/ $$ = add_node(VAR_NODE,NULL,NULL,$1);};



%%

extern FILE * yyin;

enum types assert_same_type(char * n1, char * n2) {
    if(isdigit(n1[0]) || isdigit(n2[0]))
        return NONE;

    struct sym * sym1 = sym_table_look(n1);
    struct sym * sym2 = sym_table_look(n2);
    if(sym1 == NULL || sym2 == NULL) {
        return T_ERROR;
    }
    if(sym1->type != NONE && sym2->type != NONE) {
        if(sym1->type == sym2->type) {
            return sym1->type;
        }
        yyerror("Error: Incompatible types\n");
        return T_ERROR;
    }
    return NONE;    
}

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
void decode_operation(ast_node * node, FILE * c_out) {
    switch(node -> type){
        case PLUS_NODE:
            decode_operation(node->left, c_out);
            fprintf(c_out, " + ");
            decode_operation(node->right, c_out);
        break;
        case MINUS_NODE:
            decode_operation(node->left, c_out);
            fprintf(c_out, " - ");
            decode_operation(node->right, c_out);
        break;
        case MULT_NODE:
            decode_operation(node->left, c_out);
            fprintf(c_out, " * ");
            decode_operation(node->right, c_out);        break;
        case DIV_NODE:
            decode_operation(node->left, c_out);
            fprintf(c_out, " / ");
            decode_operation(node->right, c_out);        break;
        case EXPRESSION_NODE:
            fprintf(c_out, " %s", (char *) node -> data);
        break;
        default:
        break;
    }

}

void decode_condition(ast_node * node, FILE * c_out){
    condition * condition_aux;
    switch(node->type){
        case AND_NODE:
            if(node->left != NULL){
                if(node->data == FORCE_PAR){
                    fprintf(c_out,"( ");
                }
                decode_condition(node->left,c_out);
                fprintf(c_out," && ");
            }
            if (node->right != NULL){
                decode_condition(node->right,c_out);
                if (node->data == FORCE_PAR){

                    fprintf(c_out,")");
                }
            }
            break;
        case OR_NODE:
            if(node->left != NULL){
                if(node->data == FORCE_PAR){
                    fprintf(c_out,"( ");
                }
                decode_condition(node->left,c_out);
                fprintf(c_out," || ");
            }
            if (node->right != NULL){
                decode_condition(node->right,c_out);
                if (node->data == FORCE_PAR){

                    fprintf(c_out,")");
                }
            }
            break;    

        case NOT_NODE:
            if(node->left != NULL){
                fprintf(c_out,"! ");
                decode_condition(node->left,c_out);
                fprintf(c_out,"");
            }
            break;

        case COND_NODE:
            condition_aux = (struct condition*)node->data;
            if(condition_aux->involved_types == T_STRING) {
                if(condition_aux->cond_type == COND_EQ) {
                    fprintf(c_out, "strcmp(%s,%s)==0", condition_aux->cond1, condition_aux->cond2);
                } else if(condition_aux->cond_type == COND_NE) {
                    fprintf(c_out, "strcmp(%s,%s)!=0", condition_aux->cond1, condition_aux->cond2);
                } else {
                    fprintf(stderr, "Error: Incompatible comparison between strings\n");
                    abort();
                }
            } else {
                fprintf(c_out, "%s %s %s", condition_aux->cond1, condition_symbols[condition_aux->cond_type], condition_aux->cond2);
            }

            
            

            break;
    }
}

int graph_iterations_count = 0;

void decode_tree(ast_node * node, FILE * c_out) {
    enum types var_type;
    ast_node * left_var, *right_var;
    struct sym * left_sym;
    condition * condition_aux;
    struct graph_sym data;
    struct gr_iteration * griter;
    int current_graph_iter;
    int aux_node;

    switch(node->type) {
        case LIST_NODE:
            if(node->right != NULL)
                decode_tree(node->right, c_out);
            if(node->left != NULL)
                decode_tree(node->left, c_out);
            break;
        case ENTRY_POINT_NODE:
            fprintf(c_out, "entry_point:;");
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

                    case T_GRAPH:
                        fprintf(c_out,"print_graph(%s);",((struct sym *)node->left->data)->name);

                        break;
                }
                
            }
            break;

        case ASSIGN_NODE:
            left_var = node->left;
            printf("TOY EN ASSSIGN NODE\n");
            right_var = node->right;
            left_sym = (struct sym *)left_var->data;
            switch(left_sym->type) {
                case T_INTEGER:
                    if(right_var->type == EXPRESSION_NODE){
                        fprintf(c_out, "%s = %d;", left_sym->name, *((int *)right_var->data));
                    } else {
                        fprintf(c_out, "%s = ", left_sym->name);
                        decode_operation(node->right, c_out);
                        fprintf(c_out, "; ");

                    }
                    break;
                case T_STRING:
                    fprintf(c_out, "%s = %s;", left_sym->name, (char *)right_var->data);
                    break;

                case T_GRAPH:
                    data = left_sym->content.graph_data;
                    for (int i = 0; i< data.edges_qty;i++){
                        fprintf(c_out,"graph_add_edge(%s,%d,%d,%d);",left_sym->name,data.edges_info[i].from,data.edges_info[i].to, data.edges_info[i].weight);
                    }
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
            printf("ACAAA IF\n");
            left_var = node->left;
            condition_aux = (condition *)left_var->data;
            fprintf(c_out,"if(");
            decode_condition(left_var,c_out);
            fprintf(c_out,"){");
            if(node->right != NULL)
                decode_tree(node->right, c_out);
            fprintf(c_out, "}");
            break;

        case WHILE_NODE:
            left_var = node->left;
            fprintf(c_out, "while(");
            decode_condition(left_var,c_out);
            fprintf(c_out,"){");
            if(node->right != NULL)
                decode_tree(node->right, c_out);
            fprintf(c_out, "}");
            break;

        case DO_WHILE_NODE:
            left_var = node->left;
            fprintf(c_out, "do {");
            if(node->right != NULL)
                decode_tree(node->right, c_out);
            fprintf(c_out, "} while(");
            decode_condition(left_var,c_out);
            fprintf(c_out,");");
            break;

        case DFS_NODE:
            left_var = node->left;
            left_sym = (struct sym *)left_var->data;
            


            griter = (struct gr_iteration * ) node->data;
            if(!isdigit(griter->init[0]) && griter->init[0]!= '-'){
                struct sym * init_sym = sym_table_look(griter->init);
                if(init_sym->type != T_INTEGER)
                    yyerror("DFS root variable must be int.");
                else
                    aux_node = init_sym->content.int_value;
            }else
                aux_node = atoi(griter->init);
            if (aux_node < 0 || aux_node > left_sym->content.graph_data.nodes_qty)
                yyerror("Invalid start node");
            if(griter->var->type != T_INTEGER)
                yyerror("DFS iterator variable must be int.");
            current_graph_iter = graph_iterations_count++;
            fprintf(c_out, "int bfgljlrkwgwjr%d;", current_graph_iter);
            fprintf(c_out, "struct search_info * bfgljlrkwgwjr_%d;", current_graph_iter);
            fprintf(c_out,"bfgljlrkwgwjr_%d = search_info_create(%s);dfs(bfgljlrkwgwjr_%d, %s);\n",current_graph_iter,left_sym->name,current_graph_iter,griter->init);
            fprintf(c_out,"bfgljlrkwgwjr%d = 0; while(bfgljlrkwgwjr%d < bfgljlrkwgwjr_%d->reached) { %s = bfgljlrkwgwjr_%d->preorder[bfgljlrkwgwjr%d];",current_graph_iter,current_graph_iter,current_graph_iter,griter->var->name,current_graph_iter,current_graph_iter);
            decode_tree(node->right,c_out);

            fprintf(c_out,"bfgljlrkwgwjr%d++;}", current_graph_iter);    

            break;

        case BFS_NODE:
            left_var = node->left;
            left_sym = (struct sym *)left_var->data;

            griter = (struct gr_iteration * ) node->data;
             if(!isdigit(griter->init[0]) && griter->init[0]!= '-'){
                struct sym * init_sym = sym_table_look(griter->init);
                if(init_sym->type != T_INTEGER)
                    yyerror("BFS root variable must be int.");
                else
                    aux_node = init_sym->content.int_value;
            }else
                aux_node = atoi(griter->init);
            if (aux_node < 0 || aux_node > left_sym->content.graph_data.nodes_qty)
                yyerror("Invalid start node");
            if(griter->var->type != T_INTEGER)
                yyerror("BFS iterator variable must be int.");

            current_graph_iter = graph_iterations_count++;
            fprintf(c_out, "int bfgljlrkwgwjr%d;", current_graph_iter);
            fprintf(c_out, "struct search_info * bfgljlrkwgwjr_%d;", current_graph_iter);

            fprintf(c_out," bfgljlrkwgwjr_%d = search_info_create(%s);bfs(bfgljlrkwgwjr_%d, %s);\n",current_graph_iter,left_sym->name,current_graph_iter,griter->init);
            fprintf(c_out,"bfgljlrkwgwjr%d = 0; while(bfgljlrkwgwjr%d < bfgljlrkwgwjr_%d->reached) { %s = bfgljlrkwgwjr_%d->preorder[bfgljlrkwgwjr%d];",current_graph_iter,current_graph_iter,current_graph_iter,griter->var->name,current_graph_iter,current_graph_iter);
            decode_tree(node->right,c_out);

            fprintf(c_out,"bfgljlrkwgwjr%d++;}", current_graph_iter);    


            break;

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

    }else if(node->type == ENTRY_POINT_NODE) {
        fprintf(c_out, "entry_point:;");
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
    if(!found_entry_point) {
        fprintf(stderr, "Entry point not found.\n");
        exit(1);
    }
    if(root !=NULL){
        FILE * c_out = fopen("intermediate.c", "w+");
        if(c_out == NULL) {
            fprintf(stderr, "Unable to open intermediate.c file\n");
            exit(1);
        }

        fputs("#include \"graph_impl/graph.h\"\n", c_out);
        fputs("#include <stdio.h>\n", c_out);
        fputs("#include \"graph_impl/search.h\"\n", c_out);
        fputs("#include <string.h>\n", c_out);
        fputs("int main(){goto entry_point;", c_out);


        if(root->left != NULL){
            decode_defs(root->left, c_out);
        }
        if(root->right != NULL)
            decode_tree(root->right, c_out);

        fputs("return 0;}", c_out);
        fclose(c_out);

    }
    free_resources();

    system("gcc graph_impl/queue.c graph_impl/graph.c graph_impl/search.c intermediate.c -o runme");

    //TODO Descomentar esto
    /*if(remove("intermediate.c") != 0)
        fprintf(stderr, "Error when trying to remove intermediate.c\n");*/
    return 0;
 }
void yyerror(s)
char * s;
{
    fprintf( stderr,"Error message: %s\n",s);
    abort();
}

struct sym * sym_table_look(char * s){
    char * p;
    struct sym * st = NULL;
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
                printf("vertex num vale %d\n",new_graph_vertex_num);
                if(type == NONE){
                    yyerror("Variable not found\n");
                } else if(type == T_GRAPH && new_graph_vertex_num <= 0) {
                    yyerror("Wrong vertex number\n");
                }
                syms_counter++;
                st->name = strdup(s);
                printf("Guardamos en la tabla de simbolos la variable %s \n",st->name);
                st->type = type;
                if(type == T_GRAPH) {
                    printf("es de tipo grafo\n");
                    
                    st->content.graph_data.nodes_qty = new_graph_vertex_num;
                    new_graph_vertex_num = 0;

                }
                type = NONE;
                return st;
            }
    }
    type = NONE;
    yyerror("Limit of symbs reached\n");
}