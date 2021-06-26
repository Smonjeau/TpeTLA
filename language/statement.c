#include <stdlib.h>

#include "statement.h"
#include "operation.h"
#include "graph.h"

statement * create_assignment(struct variable * v, struct operation * op, char * s){
    statement * st = malloc(sizeof(statement));
    assignment_info * info = malloc(sizeof(assignment_info));
    info->variable = v;
    if(op != NULL){
        info->operation = op;
    } else if(s != NULL) {
        info->string = s;
    }

    st -> value = info;
    st -> declaration_type = ST_ASSIGNMENT;
    return st;

}

statement * create_edges(struct variable * v, struct edge * edge){
    statement * st = malloc(sizeof(statement));
    struct edges_info * info = malloc(sizeof(edges_info));
    info-> var = v;
    info -> edge = edge;
    
    st->value = info;
    st -> declaration_type = ST_EDGE_DEFINITION;

    return st;
}

statement * create_definition(int data_type, variable * v){
    statement * st = malloc(sizeof(statement));
    definition_info * info = malloc(sizeof(definition_info));
    info->data_type = data_type;
    info->variable = v;

    st->declaration_type= ST_DEFINITION;
    st->value = info;

    return st;
}

statement * create_graph_definition(int graph_type, int value, struct variable * var) {
    statement * st = malloc(sizeof(statement));
    graph_definition_info * info = malloc(sizeof(graph_definition_info));
    info->graph_type = graph_type;
    info-> variable = var;
    info-> vertex_num = value;

    st->declaration_type = ST_GRAPH_DEFINITION;
    st->value = info;

    return st;

}


statement * create_statement(struct operation * cond, struct statement * st, int type){
    statement * statement = malloc(sizeof(struct statement));
    statement_info * info = malloc(sizeof(statement_info));
    info->condition = cond;
    info->st = st;

    statement->declaration_type = type; 
    statement->value = info;

    return statement;

}

statement * create_gr_iter(struct variable * v, int iter_type) {
    statement * statement = malloc(sizeof(struct statement));
    graph_iter_info * info = malloc(sizeof(graph_iter_info));
    info ->var = v;
    info->iter_type = iter_type;

    statement -> declaration_type = ST_GR_ITER;
    statement -> value = info;

    return statement;
}