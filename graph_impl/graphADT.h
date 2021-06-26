#ifndef GRAPH_ADT__H
#define GRAPH_ADT__H

#define N 100

typedef struct graph
{
    struct node * head[N];
    
}graph;

typedef struct edge {           //TODO weighted edge and directional edge
    int src, dest;
}edge;

typedef struct node {
    int value;
    struct node * next;
}node;

typedef graph * graphADT;

graph * newGraph(struct edge edges[], int n);

#endif