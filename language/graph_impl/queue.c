#include <stdlib.h>
#include <stdio.h>

#define SIZE 100

typedef struct queue {
    int items[SIZE];
    int front;
    int rear;
}queue;

queue * create_queue(){
    queue * q = malloc(sizeof(queue));    
    q ->front = -1;
    q -> rear = -1;

    return q;
}

int is_empty(queue * q){
    return q -> rear == -1;   
}

void enqueue(queue * q, int value){
    if (q -> rear < SIZE)
    {
        if (q -> front == -1)
        {
            q -> front = 0;
        }
        q -> rear++;
        q -> items[q -> rear] = value;
    }
}


int dequeue(queue * q){
    int item;
    if (is_empty(q)){
        item = -1;
    }else {
        item = q -> items[q -> front];
        q -> front++;
        if (q->front > q->rear)
        {
            q->front = -1;
            q->rear = -1;
        }
        
    }
    return item;
}