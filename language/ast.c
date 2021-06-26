#include "ast.h"
#include <stdlib.h>
#include <stdio.h>
ast_node * add_node(enum node_type type, ast_node * l, ast_node * r, void * data){
    ast_node * ret = (ast_node *) malloc(sizeof(ast_node));
    if(ret == NULL){
        fprintf(stderr,"Fatal error\n");
        exit(1);
    }
    ret->type = type;
    ret->left = l;
    ret->right = r;
    ret->data = data;

    return ret;
}

/*
ast_node * add_def_node(ast_node * l, ast_node * r, enum types def_type, void * data){
    ast_defs_node * ret = (ast_defs_node *)  malloc(sizeof(ast_defs_node));
    if(ret == NULL){
        fprintf("Fatal error\n");
        exit(1);
    }
    ret->type = DEF;
    ret->left = l;
    ret->right = r;
    ret->def_type = def_type;
    ret->data = data;

    return ret;
}

*/