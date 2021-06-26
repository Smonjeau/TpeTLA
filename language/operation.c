#include <stdlib.h>
#include "operation.h"

/*
enum operators operator_look(char * s){
    switch (*s)
    {
    case '+':
        return OP_SUM;
        break;
    case '-':
        return OP_MINUS;
        break;
    case '/':
        return OP_DIV;
        break;
    case '*':
        return OP_MULT;
        break;
    default:
        yyerror("Not a valid operator");
        return NONE;
        break;
    }
    
}
*/
struct operation * create_operation(enum operators type, struct operation * op1, struct operation * op2){
    struct operation * ret = malloc(sizeof(struct operation));
    *ret = (struct operation)
    {
        .is_variable = 0,
        .op1 = op1,
        .op2 = op2,
        .op_type = type
    };
 
    return ret;
    
}

struct operation * create_paren(struct operation * op){
    struct operation * ret = malloc(sizeof(struct operation));
    *ret = (struct operation)
    {
        .is_variable = 0,
        .op1 = op,
        .op_type = PARENTHESIS
    };
 
    return ret;
}

struct operation * create_op_from_var(char * v){
    struct operation * ret = malloc(sizeof(struct operation));
    *ret = (struct operation)
    {
        .is_variable = 1,
        .value = (char *)v,
    };
    return ret;
}

struct operation * create_op_from_const(int v){
    struct operation * ret = malloc(sizeof(struct operation));
    *ret = (struct operation)
    {
        .is_variable = 1,
        .value = (int *) &v,
    };
    return ret;
}