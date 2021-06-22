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



struct word{
	char * word_name;
	int word_type;
	struct word * next;
};

struct word * word_list;

extern void * malloc();

int add_word(int type, char * word){	

	struct word * wp;
	if(lookup_word(word) != LOOKUP) {
		printf("!!! warning: word %s already defined \n", word);
		return 0;
	}
	wp = (struct word *) malloc (sizeof (struct word) ) ;

	if(!wp)
		printf("null\n");
	
	wp->next = word_list;
	wp->word_name = (char *) malloc (strlen (word) +1) ;
	if(!wp->word_name)
		printf("null 2 \n");
	strcpy (wp->word_name, word) ;
	wp->word_type = type;
	word_list = wp;
	return 1; 
}

int lookup_word(char  * word){
	
	struct word * wp  = word_list;
	
	for(;wp;wp=wp->next){
		if(strcmp(wp->word_name,word) == 0)
			return wp->word_type;

	}
	return LOOKUP;
}
 
