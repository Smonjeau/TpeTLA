#include <stdlib.h>

#include "statement.h"
#include "operation.h"

statement * create_assignment(struct variable * v, struct operation * op){
    statement * st = malloc(sizeof(statement));
    assignment_info * info = malloc(sizeof(assignment_info));
    info->variable = v;
    info->operation = op;

    st -> value = info;
    st -> declaration_type = ASSIGNMENT;
    return st;

}

statement * create_definition(int data_type, variable * v){
    statement * st = malloc(sizeof(statement));
    definition_info * info = malloc(sizeof(definition_info));
    info->data_type = data_type;
    info->variable = v;

    st->declaration_type= DEFINITION;
    st->value = info;

    return st;
}