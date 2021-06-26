#ifndef OPERATION__H
#define OPERATION__H

enum operators {
    //NONE = 0,
    OP_SUM,
    OP_MINUS,
    OP_DIV,
    OP_MULT,
    COND_EQ,
    COND_NE,
    COND_LOWER,
    COND_LOWER_EQ,
    COND_GREATER,
    COND_GREATER_EQ,
    PARENTHESIS
};
struct operation{
    int is_variable;        //Indica si la operacion es solo una variable o constante
    int op_type;
    struct  operation * op1, * op2;
    void * value;
};

struct operation * create_operation(enum operators type, struct operation * op1, struct operation * op2);

struct operation * create_paren(struct operation * op);

struct operation * create_op_from_var(char * v);
struct operation * create_op_from_const(int v);

enum operators operator_look(char * s);


#endif