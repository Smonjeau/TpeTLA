#ifndef AST__H__
#define AST__H__
#include "symbol_table.h"
enum node_type{
    PROGRAM_NODE,
    IF_NODE,
    WHILE_NODE,
    DO_WHILE_NODE,
    GR_ITER_NODE,
    GR_ITER_COND_NODE,
    DEFS_NODE,
    DEF_NODE,
    TYPE_NODE,
    VAR_NODE,
    PRINT_NODE,
    READ_NODE,
    LIST_NODE,
    STMT_NODE,
    COND_NODE,
    ASSIGN_NODE,
    EXPRESSION_NODE,
    PLUS_NODE,
    MINUS_NODE,
    MULT_NODE,
    DIV_NODE,
    AND_NODE,
    OR_NODE,
    NOT_NODE,
    ENTRY_POINT_NODE,
    DFS_NODE,
    BFS_NODE

};

typedef struct ast_node{
    enum node_type type;
    struct ast_node * left;
    struct ast_node * right;
    void * data;
}ast_node;

/*
typedef struct ast_defs_node{
    enum node_type type;
    ast_node * left;
    ast_node * r;
    void * data;
    enum types def_type;

}ast_defs_node;

*/
/*
typedef struct ast_def_node{
    enum node_type type;
    //enum types def_type;
    ast_node * left; 
    ast_node * right;
    char * name;
}
*/
ast_node * add_node(enum node_type type, ast_node * l, ast_node * r, void * data);

ast_node * add_def_node(ast_node * l, ast_node * r, enum types def_type, char * var_name);
#endif

 