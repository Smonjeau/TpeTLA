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
    char * name; //nombre variable
    union{
        int int_value;
        char * string_value;
        //TODO grafitos
    }content;
    enum types type;
};

struct sym * sym_table_look(char * s);
#endif