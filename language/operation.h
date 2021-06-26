#ifndef OPERATION__H
#define OPERATION__H

enum operators {
    NONE = 0,
    OP_SUM,
    OP_MINUS,
    OP_DIV,
    OP_MULT
};
struct operation{
    int op_type;
    struct  operation * op1, * op2;
    int value;
};

struct operation * create_operation(enum operators type, struct operation * op1, struct operation * op2);
enum operators operator_look(char * s);


#endif