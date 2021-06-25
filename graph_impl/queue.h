#include <stdlib.h>
#include <stdio.h>

#define SIZE 100

typedef struct queue * Queue;

Queue create_queue();

int is_empty(Queue q);

void enqueue(Queue q, int value);

int dequeue(Queue q);