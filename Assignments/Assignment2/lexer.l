%{
#include <iostream>
#include <cstdlib>
#include <cstring>
#include "parser.tab.h"
using namespace std;
extern void outputstats();
extern int yylex();
%}


%option yylineno
%option case-insensitive

WS           [ \n\t\r\f]*

%%

"<"{WS}"quiz"{WS}">"                      { 
                                            // cout << "QUIZ START " << yytext <<endl;
                                            return QUIZ_START; }
"<"{WS}"/"{WS}"quiz"{WS}">"               { 
                                            // cout << "QUIZ END " << yytext <<endl;
                                            return QUIZ_END; }
"<"{WS}"singleselect"                     { 
                                            // cout << "SINGLE SELECT START " << yytext <<endl;
                                            yylval.start = yylineno;
                                            return SINGLESELECT_START; }
"<"{WS}"/"{WS}"singleselect"{WS}">"       { 
                                            // cout << "SINGLE SELECT END " << yytext <<endl;
                                            return SINGLESELECT_END; }
"<"{WS}"multiselect"                      { 
                                            // cout << "MULTI SELECT START " << yytext <<endl;
                                            yylval.start = yylineno;
                                            return MULTISELECT_START; }
"<"{WS}"/"{WS}"multiselect"{WS}">"        { 
                                            // cout << "MULTI SELECT END " << yytext <<endl;
                                            return MULTISELECT_END; }
"<"{WS}"choice"{WS}">"                    { 
                                            // cout << "CHOICE START " << yytext <<endl;
                                            return CHOICE_START; }
"<"{WS}"/"{WS}"choice"{WS}">"             { 
                                            // cout << "CHOICE END " << yytext <<endl;
                                            return CHOICE_END; }
"<"{WS}"correct"{WS}">"                   { 
                                            // cout << "CORRECT START " << yytext <<endl;
                                            return CORRECT_START; }
"<"{WS}"/"{WS}"correct"{WS}">"            { 
                                            // cout << "CORRECT END " << yytext <<endl;
                                            return CORRECT_END; }
{WS}"marks"{WS}"="{WS}                    { 
                                            // cout << "MARKS " << yytext <<endl;
                                            return MARKS; }
{WS}[0-9]+{WS}                            {
                                            yylval.integral = atoi(yytext); 
                                            // cout << "INTEGER " << yytext <<endl;
                                            return INT; }
">"                                       {
                                            // cout << "CLOSING BRACKET " <<endl;
                                            return CLOSING_BRACKETS;}
{WS}                                      {// Skip whitespace 
                                          }          

[^>< \n\t\f\r\"]+                         { 
                                            // cout << "TEXT " << yytext <<endl;
                                           return TEXT; }
"\""                                      {
                                           return QUOTES;}
.                                         {
                                            // cout<< "F"<< endl;
                                          }

%%

// int main() {
//     yylex();
//     cout<<"hi"<<endl;
//     return 0;
// }

int yywrap(){
    return 1;
}

void yyerror(const char *s){
    cerr<<"\nError found at line number: "<<yylineno<<"\n"<< s <<"\n\nTerminating...\n";
    outputstats();
    exit(1);
}
