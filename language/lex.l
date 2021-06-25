SP  (u8|u|U|L)
ES  (\\(['"\?\\abfnrtv]|[0-7]{1,3}|x[a-fA-F0-9]+))
WS  [ \t\v\n\f]

%{
#include "y.tab.h"
#include "symbol_table.h"
#include <stdlib.h>
#define LOOKUP 0

int state;
%}

%%

\n	{ state = LOOKUP; }

\.\n 	{ state = LOOKUP; return 0; }

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
"and" | "or" | "not" {return(LOGICAL_OPS);}
"+" |  "-"      {return(ARITHMETICAL_OPS);}
"<" | "<=" | ">" | ">=" | "==" | "!=" {return(RELATIONAL_OPS);}
"->" {return(ARROW);}
"<->"   {return(DOUBLE_ARROW);}
"int"	{return(INT);}
"string"	{return(STRING);}
"graph" {return(GRAPH);}
[0-9]+	{yylval.val = atoi(yytext) ; return(VALUE);}
[A-Za-z_][A-Za-z_0-9]*	{yylval.symp = sym_table_look(yytext); return(VAR);}
({SP}?\"([^"\\\n]|{ES})*\"{WS}*)+ {yylval.str = strdup(yytext); return(STRING_LITERAL);}
[a-zA-z]	{return(LETTER);}
%%


 