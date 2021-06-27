SP  (u8|u|U|L)
ES  (\\(['"\?\\abfnrtv]|[0-7]{1,3}|x[a-fA-F0-9]+))
WS  [ \t\v\n\f]

%{
#include "y.tab.h"
#include "symbol_table.h"
#include <stdlib.h>
#include "ast.h"

#define LOOKUP 0

int state;
%}

%%

\n	{ state = LOOKUP; }
"do"  { return(DO); }
"while"   { return(WHILE); }
"if"    {return(IF);   }
"else"   {return(ELSE);   }
"="	{return(ASSIGN_OP);}
";"	{return(SEMICOLON);}
"("	{return(OPEN_PAR);}
")"	{return(CLOSE_PAR);}
"{"	{return(OPEN_BRACKET);}
"}"	{return(CLOSE_BRACKET);}

"print"	{return(PRINT);}
"read"	{return(READ);}
"and" {return(AND);}
"or" {return(OR);}
"not" {return(NOT);}
"+"         {return(PLUS);}
"-"		{return(MINUS);}
"*"	{return(MULT);}
"/"	{return(DIV);}
"<" {return (LOWER);}
 "<=" {return(LOWER_EQ);}
 ">" {return(GREATER);}
 ">=" {return(GREATER_EQ);}
 "==" {return(EQ);}
 "!=" {return(N_EQ);}
"->" {return(ARROW);}
"<->"   {return(DOUBLE_ARROW);}
"int"	{return(INT);}
"string"	{return(STRING);}
"graph" {return(GRAPH);}
"," {return (COMMA);}
"_START_" {return (ENTRY_POINT);}

-?[0-9]+	{yylval.val = atoi(yytext) ; return(VALUE);}
[A-Za-z_][A-Za-z_0-9]*	{yylval.symp = sym_table_look(yytext); return(VAR);}
({SP}?\"([^"\\\n]|{ES})*\"{WS}*)+ {yylval.str = strdup(yytext); return(STRING_LITERAL);}
[a-zA-z]	{return(LETTER);}
%%


 