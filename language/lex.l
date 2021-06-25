%{
#include "y.tab.h"
#include "symbol_table.h"

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
[0-9]+	{return(VALUE);}
[A-Za-z][A-Za-z0-9]*	{yylval.symp = sym_table_look(yytext); return(VAR);}
[a-zA-z]	{return(LETTER);}
%%


