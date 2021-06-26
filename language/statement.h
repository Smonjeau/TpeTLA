#include "variable.h"
enum data_type{
    NONE = 0,
    T_INTEGER,
    T_STRING,
    T_GRAPH,
    T_TREE
};

enum statement_type{
    ASSIGNMENT,
    DEFINITION
};

typedef struct statement {
    int declaration_type;
    void * value;
}statement;

typedef struct assignment_info
{
    struct variable * variable;
    struct operation * operation;
}assignment_info;

typedef struct definition_info
{
    int data_type;
    variable * variable;
}definition_info;

statement * create_assignment(struct variable * v, struct operation * op);
statement * create_definition(int data_type, variable * v);
