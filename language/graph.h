#ifndef GRAPH__H
#define GRAPH__H

enum edge_type{
    S_EDGE_TYPE,
    D_EDGE_TYPE,
    W_EDGE_TYPE
};

typedef struct edge{
    int node1, node2;
    int weight;
    int is_digraph;     
    int edge_type;
}edge;

edge * create_edge(int node1, int node2, int edge_type, int is_digraph);

edge * create_w_edge(int node1, int node2, int weight, int edge_type, int is_digraph);

#endif