#ifndef STATEMENT__H
#define STATEMENT__H

//#include "variable.h"

/*
enum graph_type{
    S_GRAPH_TYPE,
    D_GRAPH_TYPE,
    W_GRAPH_TYPE
};

enum iter_type{
    BFS_ITER = 0,
    DFS_ITER
};

enum statement_type{
    ST_ASSIGNMENT,
    ST_DEFINITION,
    ST_GRAPH_DEFINITION,
    ST_EDGE_DEFINITION,
    ST_WHILE,
    ST_DO_WHILE,
    ST_IF,
    ST_GR_ITER
};*/

const char * condition_symbols[] = {"==", "!=", "<", "<=", ">", ">="};

enum condition_type{
    COND_EQ,
    COND_NE,
    COND_LOWER,
    COND_LOWER_EQ,
    COND_GREATER,
    COND_GREATER_EQ,
};
enum logical_operand{
    LOG_NOOP = 0,
    LOG_NOT,
    LOG_AND,
    LOG_OR
};

enum parenthesis{
    DONT_USE_PAR = 0,
    USE_PAR,
};

typedef struct condition{
    int is_boolean;          //Indica si la operacion es solo un bool
    enum condition_type cond_type;
    char * cond1, * cond2;
    enum types involved_types;

}condition;

/*
typedef struct statement {
    int declaration_type;
    void * value;
}statement;

typedef struct assignment_info {
    struct variable * variable;
    struct operation * operation;
    char * string;
}assignment_info;



typedef struct definition_info {
    int data_type;
    variable * variable;
}definition_info;

typedef struct graph_definition_info {
    int graph_type;
    variable * variable;
    int vertex_num;
}graph_definition_info;

typedef struct edges_info {
    variable * var;
    struct edge * edge;
}edges_info;

typedef struct statement_info {
    struct operation * condition;
    struct statement * st;
}statement_info;

typedef struct graph_iter_info {
    struct variable * var;
    int iter_type;
}graph_iter_info;


statement * create_assignment(struct variable * v, struct operation * op, char * s);
statement * create_definition(int data_type, variable * v);
statement * create_edges(struct variable * v, struct edge * edge);
statement * create_graph_definition(int graph_type, int value, struct variable * var);
statement * create_statement(struct operation * cond, struct statement * st, int type);
statement * create_gr_iter(struct variable * v, int iter_type);
*/
#endif