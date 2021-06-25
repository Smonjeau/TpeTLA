#ifndef SYMBOL__TABLE__H
#define SYMBOL__TABLE__H

#define MAX_SYMB 1024

enum types{
    NONE = 0,
    T_INTEGER,
    T_STRING,
    T_GRAPH,
    T_TREE
    };
struct sym{
    char * name;
    int value;
    enum types type;
};

struct sym * sym_table_look(char * s);
#endif