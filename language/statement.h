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
    DEFINITION,
    WHILE,
    DO_WHILE,
    IF
};
/*
typedef struct condition
{
    int is_boolean;          //Indica si la operacion es solo un bool
    int condition_type;
    struct condition * cond1, * cond2;
    void * value;
}condition;
*/
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

typedef struct statement_info
{
    struct condition * condition;
    struct statement * st;
}statement_info;


statement * create_assignment(struct variable * v, struct operation * op);
statement * create_definition(int data_type, variable * v);
statement * create_statement(struct condition * cond, struct statement * st, int type);