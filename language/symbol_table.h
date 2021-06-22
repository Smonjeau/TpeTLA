#ifndef SYMBOL__TABLE__H
#define SYMBOL__TABLE__H

#define MAX_SYMB 1024

struct sym{
    char * name;
    int value;
};

struct sym * sym_table_look(char * s);
#endif