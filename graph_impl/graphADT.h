#define N 100

typedef struct graph
{
    struct node * head[N];
    
}graph;

typedef struct edge {           //TODO weighted edge and directional edge
    int src, dest;
}edge;

typedef graph * graphADT;

graph * newGraph(struct edge edges[], int n);
