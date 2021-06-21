#include "graphADT.h"
int main(void) {
    edge edges[] = {
        {0,1},
        {1,2},
        {2,3}
    };
    int n = sizeof(edges)/sizeof(edges[0]);     //total number of edges

    graphADT graph = newGraph(edges, n);

    return 0;
}