##### 72.39 Teoría de Lenguajes, Autómatas y Compiladores - 1Q 2021

# Lenguaje para grafos con salida en C


## Integrantes
- Monjeau Castro, Santiago (60394)
- Gomez, Lucas Sebastian (60408)
- Diaz Kralj, Luciana (60495)
- Volcovinsky, Bruno (60623)


## Índice
- [Idea subyacente y objetivo](#idea-subyacente-y-objetivo)
- [Consideraciones](#consideraciones)
- [Proyecto](#proyecto)
  * [Compilación](#compilación)
  * [Uso](#uso)
  * [Ejemplos](#ejemplos)
- [Descripción de la gramática](#descripción-de-la-gramática)
  * [Tipos de datos](#tipos-de-datos)
  * [Grafos](#grafos)
  * [Operadores](#operadores)
  * [Sentencias](#sentencias)
  * [Producciones](#producciones)
- [Dificultades encontradas](#dificultades-encontradas)
- [Futuras extensiones](#futuras-extensiones)
- [Referencias](#referencias)

## Idea subyacente y objetivo
El lenguaje desarrollado está inspirado en algunas instrucciones del Lenguaje C, presentando además el manejo de grafos, digrafos y grafos ponderados. Se añadieron también funciones basadas en algoritmos vistos en la materia 93.59-Matemática Discreta, para el recorrido de árboles por medio de DFS y BFS.
El compilador, desarrollado en C, genera en su salida programas en el mismo lenguaje.

## Consideraciones
Debido a la definición de la gramática, las declaraciones y las asignaciones se deben realizar en líneas separadas, las expresiones condicionales solo comparan variables, y la función _print_ permite imprimir únicamente variables. Además, no se tiene soporte para sentencias 'if-else' ni bucles de tipo 'for'.

## Proyecto
Para el desarrollo del presente trabajo práctico se utilizó el analizador léxico Lex y el compilador de compiladores YACC, el cual recibe como entrada una gramática en BNF. La descripción de la misma puede encontrarse entonces en los archivos _lex.l_ y _yacc.y_, situados en la carpeta _TpeTLA/language_.
La implementación de los grafos, con sus constructores y algoritmos de recorrido, pueden encontrarse en la carpeta _TpeTLA/graph\_impl_.
El compilador se encarga de generar un _abstract syntax tree (AST)_ para la generación de código, donde los nodos son los terminales y no-terminales que componen programa.

### Compilación

```shell
git clone https://github.com/Smonjeau/TpeTLA 
cd TpeTLA/
make all
```

### Uso

El compilador generado se encuentra en _TpeTLA/language_. Como ejecuta _gcc_, se debe lo tener instalado de antemano.

```shell
./lang [file]
./runme
```

### Ejemplos

En la carpeta _examples_ pueden encontrarse los siguientes programas:
- _example1_, donde se implementa un contador, se testean las distintas operaciones aritméticas y la instrucción condicional, 
- _example2_, donde se crea un grafo y se aplican los algoritmos DFS y BFS, mostrando el recorrido a cada paso;
- _example3_, donde se crea un grafo y se lo imprime en pantalla;
- _example4_, donde se calcula el factorial de un número recibido por entrada estándar; y
- _example5_, donde se lee por entrada estándar hasta recibir un número mayor a cero.

Estos se compilan y ejecutan de la siguiente forma:

```shell
./lang ./examples/example1
./runme
```

## Descripción de la gramática

### Tipos de datos

El lenguaje presenta los siguientes tipos:

* **int** _(número entero)_
* **string** _(cadena de caracteres)_
* **graph** _(más información en la [próxima sección](#grafos))_

Las definiciones y declaraciones deben encontrarse por separado, como se puede ver en los siguientes ejemplos:

```shell
_START_
int a;
int b;
string c;
graph (4) d;

a = 5;
b = a + 3 * a;
c = "Hola Mundo\n";
d = { 0-(12)->5 , 2->4 };
```

Se pueden emplear operadores al momento de realizar una asignación.

### Grafos

Para declarar un grafo, se define un nombre y la cantidad de nodos del mismo.

```
graph (<cantidad_de_nodos>) name;
```

Los nodos de los grafos están representados por valores de tipo _int_, unidos por aristas que pueden tomar las siguientes formas:

- **Aristas simples:** ->

```shell
d = { 1->5 , 3->4 };
```

- **Aristas con peso:** -(\<peso\>)->

```shell
d = { 1-(4)->5 , 3-(3)->4 };
```

### Operadores

Se definieron los siguientes operadores, enumerados en orden de precendencia, de la más baja a la más alta:

1. or	      _(OR lógico)_
2. and		      _(AND lógico)_
3. < > <= >= == !=	  _(Comparadores)_
4. \+ \-      _(Operadores de suma y resta)_
5. \* /           _(Operadores de multiplicación y división)_
6. not              _(Operador unario NOT)_

Los operadores lógicos no pueden utilizarse fuera de las condiciones de las funciones _if_, _while_ y _do while_. Por otro lado, los errores de precedencia pueden evitarse con el uso de paréntesis que envuelvan las expresiones.

### Sentencias

Como punto de entrada se tomó la palabra _START_. Esto se realizó por requisito del presente trabajo pero en el caso de este lenguaje no tiene sentido que _START_ no se encuentre al principio del programa.

Las sentencias pueden tomar las siguientes formas:
- Condicional IF
```
if(<condición>) {
    <sentencias>
}
```

- Bucle WHILE
```
while(<condición>) {
    <sentencias>
}
```

- Bucle DO-WHILE
```
do{
    <sentencias>
}
while(<condición>);
```

- Recorrido de grafos
```
graph (10) g;
int root;
int current_node;

g = { 0->1, 0->3, 3->5, 3->7, 7->9, 9->2, 2->4, 7->6, 6->8 };

bfs(g,root,current_node);
dfs(g,root,current_node);
```

- Mecanismo de entrada de datos READ
```
int a;
string s;

read(a);
read(s);

print(s);
print(a);
```

- Mecanismo de salida de datos PRINT 
```
int a;
string b;
graph (3) c;

a = 10;
b = "Test\n";
c = {1->2, 2->3};

print(a);
print(b);
print(c);
```

### Producciones

entry_point: ENTRY_POINT

program: defs list
       | defs

list: s
    | list s

s: e ;
 | while
 | do_while
 | gr_iter
 | print
 | read
 | if
 | entry_point

print: PRINT ( n ) ;

read: READ ( n ) ;

while: WHILE ( condition ) { list }
     | WHILE ( condition ) { }

do_while: DO { list } WHILE ( condition ) ;
        | DO { } WHILE ( condition ) ;

if: IF ( condition ) { list }
  | IF ( condition ) { }

condition: cond_log
         | cond_and
         | cond_or
         | cond_not
         | ( condition )

cond_log: t == t
        | t != t
        | t < t
        | t <= t
        | t > t
        | t >= t

cond_and: condition AND condition

cond_or: condition OR condition

cond_not: NOT condition

e: assignment
 | n

edges: edges , edge
     | edge

edge: VALUE -> VALUE
    | VALUE -( VALUE )-> VALUE
    | VALUE <-( VALUE )-> VALUE
    | VALUE <-> VALUE

t: n
 | VALUE

defs: defs def ;
    | def ;
    | entry_point

def: type n
   | graph_type vertex_num n

vertex_num: ( VALUE )

assignment: n = expression
          | n = operation
          | n = STRING_LITERAL
          | n = { edges }

expression: t

operation: t + t
         | t - t
         | t * t
         | t / t

gr_iter: DFS ( n , t , n ) { list }
       | DFS ( n , t , n ) { }
       | BFS ( n , t , n ) { list }
       | BFS ( n , t , n ) { }

type: INT
    | STRING

graph_type: GRAPH

n: VAR

## Dificultades encontradas

- **Resolución de conflictos _shift/reduce_ en la gramática.** En cierto momento la gramática se vio perturbada por 17 conflictos, los cuales no tardaron en volverse 60. Afortunadamente, esto se debió a la capacidad exponencial de propagación de errores, y al cambiar las producciones de tan solo dos gramáticas se volvió a tener cero conflictos.

- **Las definiciones se realizan al inicio del programa.** Debido a la forma en la que se generó la gramática inicialmente, las variables son definidas al inicio y luego podrán ser inicializadas. Esto ocurre tanto para el tipo int, string y graph.

- **Las operaciones aritméticas no se realizan de manera recursiva.** A causa de los conflictos anteriormente descritos, sumado a la falta de tiempo, las operaciones aritméticas se realizan entre variables y constantes. A diferencia de las operaciones lógicas que sí realizan la recursión correspondiente.

- **Variable global en la traducción a C.** Al intentar realizar la traducción de las operaciones dfs y bfs se necesitó de una variable global la cual podría interferir con las declaradas por el usuario. Para esto, se definió el nombre de la variable como una cadena de caracteres lo suficientemente larga como para que el usuario no elija ese nombre.


- **No hay manejo de aristas** Los grafos que son definidos no pueden ser editados, aunque si se los puede definir como un nuevo grafo (por ejemplo, uno que sea idéntico al anterior pero sin una arista).


## Futuras extensiones

Las posibles mejoras y extensiones para el lenguaje que nos parecen pertinentes son:

- La incorporación de sentencias 'if-else' y 'for', que no presentan grandes diferencias a las ya manejadas por el lenguaje.
- La ampliación de las funciones de operación sobre grafos, añadiendo algoritmos como los de Dijkstra y Kruskal. Dado el funcionamiento del lenguaje en su forma actual, tampoco presentarían grandes inconvenientes al momento de adaptarlos. Esto es para aprovechar los pesos de las aristas que no se llegaron a aprovechar en esta implementacion
- El manejo de matrices para la representación de grafos posee una complejidad un poco mayor, ya que se debe incluir un nuevo tipo de variable con todo lo que esto conlleva (definición, operaciones permitidas, funciones que trabajen con matrices).
- El desarrollo de una función para ilustrar grafos es otra alternativa que podría adaptarse a la estructura que presenta el lenguaje actual.

## Referencias
- Implementación de grafos (https://www.cs.yale.edu/homes/aspnes/pinewiki/C(2f)Graphs.html)
- Algoritmo BFS (https://www.programiz.com/dsa/graph-bfs)
- Algoritmo DFS (https://www.programiz.com/dsa/graph-dfs)
- Árbol de análisis sintáctico (https://efxa.org/2014/05/25/how-to-create-an-abstract-syntax-tree-while-parsing-an-input-stream/)
