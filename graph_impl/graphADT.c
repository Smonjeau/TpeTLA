#include <stdio.h>
#include <stdlib.h>

#include "graphADT.h"

typedef struct graph
{
    struct node * head[N];
    
}graph;


typedef struct node {
    int value;
    struct node * next;
}node;



graph * newGraph(struct edge edges[], int n){
    graph * g = (struct graph * ) malloc(sizeof(struct graph));

    for (int i = 0; i < N; i++)
    {
        g -> head[i] = NULL;
    }
    
    for (int i = 0; i < n; i++)
    {
        int src = edges[i].src;
        int dest = edges[i].dest;

        node * newNode = (node * ) malloc(sizeof(node));
        newNode -> next = g -> head[src];
        g -> head[src] = newNode;
    }
    
    return g;
}


