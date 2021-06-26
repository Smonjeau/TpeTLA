#include <stdlib.h>

#include "graph.h"

edge * create_edge(int node1, int node2, int edge_type, int is_digraph){
    edge * e = malloc(sizeof(edge));
    e->edge_type = edge_type;
    e->node1 = node1;
    e->node2 = node2;
    e->is_digraph = is_digraph;
    return e;
}

edge * create_w_edge(int node1, int node2, int weight, int edge_type, int is_digraph){
    edge * e = malloc(sizeof(edge));
    e->edge_type = edge_type;
    e->node1 = node1;
    e->node2 = node2;
    e->weight = weight;
    return e;
}
