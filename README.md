##### 72.39 Teoría de Lenguajes, Autómatas y Compiladores - 1Q 2021

# Lenguaje para grafos basado en C


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
El lenguaje desarrollado está inspirado en el Lenguaje C, siguiendo las directivas del paradigma de programación imperativa, y añadiendo al mismo el manejo de grafos, digrafos y grafos ponderados. Se añadieron también funciones basadas en algoritmos vistos en la materia 93.59-Matemática Discreta, para el recorrido de árboles por medio de DFS y BFS.
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
make
```

### Uso

El compilador generado se encuentra en _TpeTLA/language_.

```shell
./build.sh [input] [output]
```

### Ejemplos

En la carpeta _examples_ pueden encontrarse los siguientes programas:
- example1, donde se implementa un contador, se testean las distintas operaciones aritméticas y la instrucción condicional, 
- _program2_, que hace algo,
- _program3_, que hace algo,
- _program4_, que hace algo, y
- _program5_, que hace algo.

Estos pueden ser compilados por medio del Makefile:

```shell
make examples
```

## Descripción de la gramática

### Tipos de datos

El lenguaje presenta los siguientes tipos:

* **int** _(número entero)_
* **string** _(cadena de caracteres)_
* **graph** _(más información en la [próxima sección](#grafos))_

Las definiciones y declaraciones deben encontrarse por separado, como se puede ver en los siguientes ejemplos:

```shell
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
bfs();
dfs();
```

- Mecanismo de entrada de datos READ
```
int a;

read(a);
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

*PEGAR GRAMÁTICA AQUÍ*

## Dificultades encontradas

- Resolución de conflictos _shift/reduce_ en la gramática.
- 

## Futuras extensiones

Las posibles mejoras y extensiones para el lenguaje que nos parecen pertinentes son:

- La incorporación de sentencias 'if-else' y 'for', así como comentarios.
- La ampliación de las funciones de operación sobre grafos, añadiendo algoritmos como los de Dijkstra y Kruskal.
- El manejo de matrices para la representación de grafos.
- El desarrollo de una función graficadora de grafos.

## Referencias
- Implementación de grafos (https://www.cs.yale.edu/homes/aspnes/pinewiki/C(2f)Graphs.html)
- Algoritmo BFS (https://www.programiz.com/dsa/graph-bfs)
- Algoritmo DFS (https://www.programiz.com/dsa/graph-dfs)
- Árbol de análisis sintáctico (https://efxa.org/2014/05/25/how-to-create-an-abstract-syntax-tree-while-parsing-an-input-stream/)
