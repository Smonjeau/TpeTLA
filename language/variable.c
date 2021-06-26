#include <stdlib.h>
#include "variable.h"

variable * create_variable(char * name){
    variable * v = malloc(sizeof(variable));
    v -> name = name;
    
    return v;
}
