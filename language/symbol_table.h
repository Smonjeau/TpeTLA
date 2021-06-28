#ifndef SYMBOL__TABLE__H
#define SYMBOL__TABLE__H

#define MAX_SYMB 1024

enum types{
    NONE = 0,
    T_INTEGER,
    T_STRING,
    T_GRAPH,
    T_TREE,
    T_ERROR
    };



struct g_edge{
    int from;
    int to;
    int weight;
};

struct graph_sym{
    int nodes_qty;
    struct g_edge * edges_info;
    int edges_qty;
};
struct sym{
    char * name; //nombre variable
    union{
        int int_value;
        char * string_value;
        struct graph_sym graph_data;
    }content;
    int type;
};

struct gr_iteration{
    char * init;
    struct sym * var;
};


struct sym * sym_table_look(char * s);
#endif