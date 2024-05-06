%option yylineno
%{
    #include "parser.tab.h"
    #include <bits/stdc++.h>
    using namespace std;
    extern int yylex();
    extern void yyerror(const char *s);
    vector <int> indent_stack;
    int num_spaces = 0;
    int poppy =0;
    int paren_counter = 0;
    
%}



SINGLE_SHORTSTRINGCHAR         [^\\\n\'] 
DOUBLE_SHORTSTRINGCHAR         [^\\\n\"]
SINGLE_STRINGCHAR              "\\"[^\']|"\\\'"
DOUBLE_STRINGCHAR              "\\"[^\"]|"\\\""
SINGLE_SHORTSTRINGITEM         {SINGLE_SHORTSTRINGCHAR}|{SINGLE_STRINGCHAR}
DOUBLE_SHORTSTRINGITEM         {DOUBLE_SHORTSTRINGCHAR}|{DOUBLE_STRINGCHAR}
SHORTSTRING                    \'{SINGLE_SHORTSTRINGITEM}*\'|\"{DOUBLE_SHORTSTRINGITEM}*\"

LONGSTRINGCHAR                [^\\]
SINGLE_LONGSTRINGITEM         {LONGSTRINGCHAR}|{SINGLE_STRINGCHAR}
DOUBLE_LONGSTRINGITEM         {LONGSTRINGCHAR}|{DOUBLE_STRINGCHAR}
LONGSTRING                    \'\'\'{SINGLE_LONGSTRINGITEM}*\'\'\'|\"\"\"{DOUBLE_LONGSTRINGITEM}*\”\”\”



NON_ZERO_DIGIT           "1"|"2"|"3"|"4"|"5"|"6"|"7"|"8"|"9"
DIGIT                    "0"|"1"|"2"|"3"|"4"|"5"|"6"|"7"|"8"|"9"
BIN_DIGIT                "0"|"1"
OCT_DIGIT                "0"|"1"|"2"|"3"|"4"|"5"|"6"|"7"
HEX_DIGIT                {DIGIT}|"a"|"b"|"c"|"d"|"e"|"f"|"A"|"B"|"C"|"D"|"E"|"F"
HEXINTEGER               "0"("x"|"X")(("_")?{HEX_DIGIT})+
OCTINTEGER               "0"("o"|"O")(("_")?{OCT_DIGIT})+
BININTEGER               "0"("b"|"B")(("_")?{BIN_DIGIT})+
DECINTEGER               {NON_ZERO_DIGIT}(("_")?{DIGIT})*|"0"+(("_")?"0")*
INTEGER                  {DECINTEGER}|{BININTEGER}|{OCTINTEGER}|{HEXINTEGER}



DIGIT_PART               {DIGIT}(("_")?{DIGIT})*
FRACTION                 "."{DIGIT_PART}
EXPONENT                 ("e"|"E")("+"|"-")?{DIGIT_PART}
POINTFLOAT               ({DIGIT_PART})?{FRACTION}|{DIGIT_PART}"."
EXPONENT_FLOAT           ({DIGIT_PART}|{POINTFLOAT}){EXPONENT}
FLOAT_NUMBER             {POINTFLOAT}|{EXPONENT_FLOAT}

IMAG_NUMBER              ({FLOAT_NUMBER}|{DIGIT_PART})("j"|"J")

NUMBERL                  {INTEGER}|{FLOAT_NUMBER}|{IMAG_NUMBER}

%x indentation_state
%s implicit_line_joining_state
%x explicit_line_joining_state

%%
<implicit_line_joining_state>.        {
                        unput(yytext[0]);
                        BEGIN (INITIAL);

                    }
<explicit_line_joining_state>. {
                        
                        if(yytext[0]!='\n'&&yytext[0]!='\r'){
                            cerr<<"Error: Explicit line joining character not at the end of line"<<endl;
                            exit(1);
                        }else if(yytext[0]=='\r'){
                            char c = yyinput();
                        }
                        BEGIN (INITIAL);
}
<indentation_state>.  { 
                      unput(yytext[0]);
                      if(yytext[0]!='#'){
                        if(indent_stack.size()==0){
                            indent_stack.push_back(0);
                        }
                        if(indent_stack.size()!=0){
                            int n = num_spaces/2;
                            if(indent_stack[indent_stack.size()-1]<n){
                                indent_stack.push_back(n);
                                // cout<<"INDENT "<<indent_stack[indent_stack.size()-1]<<endl;
                                yylval.stringr = strdup(yytext);
                              
                                BEGIN (INITIAL);
                                return INDENT;
                            }
                            else if(indent_stack[indent_stack.size()-1] == n){
                                BEGIN (INITIAL);
                                if (poppy == 0){ 
                                    // cout<<"NEWLINE "<<endl;
                                    yylval.stringr = strdup(yytext);
                                 
                                    return NEWLINE;
                                }
                            }
                            else if(indent_stack[indent_stack.size()-1] > n){
                                if(poppy==0){
                                    // cout<<"NEWLINE "<<endl;
                                    yylval.stringr = strdup(yytext);
                                 
                                    poppy = 1;
                                    return NEWLINE;
                                }

                                indent_stack.pop_back(); 
                                if(indent_stack[indent_stack.size()-1] < n){
                                    cerr<<"Indentation error "<<yylineno<<endl;
                                } 
                                // cout<<"DEDENT "<<indent_stack[indent_stack.size()-1]<<endl;
                                yylval.stringr = strdup(yytext);
                             
                                return DEDENT;
                            }
                        }
                      }
                      BEGIN (INITIAL);
                    }

"#"[^\r\n]*         { 
                        // cout<<"COMMENT "<<yytext<<endl;
                    }

"def"               { 
                        yylval.stringr = strdup(yytext); 
                        // cout<<"DEF "<<yytext<<endl; 
                        return DEF; 
                    }
"class"             {   
                        yylval.stringr = strdup(yytext); 
                        // cout<<"CLASS "<<yytext<<endl; 
                        return CLASS; 
                    }
"in"                {
                        yylval.stringr = strdup(yytext); 
                        // cout<<"IN "<<yytext<<endl; 
                        return IN; 
                    }
"if"                { 
                        yylval.stringr = strdup(yytext); 
                        // cout<<"IF "<<yytext<<endl; 
                        return IF; 
                    }
"is"                { 
                        yylval.stringr = strdup(yytext); 
                        // cout<<"IS "<<yytext<<endl; 
                        return IS; 
                    }
"else"              { 
                        yylval.stringr = strdup(yytext); 
                        // cout<<"ELSE "<<yytext<<endl; 
                        return ELSE; 
                    }
"elif"              { 
                        yylval.stringr = strdup(yytext); 
                        // cout<<"ELIF "<<yytext<<endl; 
                        return ELIF; 
                    }
"while"             {
                        yylval.stringr = strdup(yytext); 
                        // cout<<"WHILE "<<yytext<<endl; 
                        return WHILE; 
                    }
"for"               { 
                        yylval.stringr = strdup(yytext); 
                        // cout<<"FOR "<<yytext<<endl; 
                        return FOR; 
                    }
"return"            { 
                        yylval.stringr = strdup(yytext); 
                        // cout<<"RETURN "<<yytext<<endl; 
                        return RETURN; 
                    }
"break"             { 
                        yylval.stringr = strdup(yytext); 
                        // cout<<"BREAK "<<yytext<<endl; 
                        return BREAK; 
                    }
"continue"          { 
                        yylval.stringr = strdup(yytext); 
                        // cout<<"CONTINUE "<<yytext<<endl; 
                        return CONTINUE; 
                    }
"True"              { 
                        yylval.stringr = strdup(yytext); 
                        // cout<<"TRUEE "<<yytext<<endl; 
                        return TRUEE; 
                    }
"False"             { 
                        yylval.stringr = strdup(yytext); 
                        // cout<<"FALSEE "<<yytext<<endl; 
                        return FALSEE; 
                    }
"None"              { 
                        yylval.stringr = strdup(yytext); 
                        // cout<<"NONE "<<yytext<<endl; 
                        return NONE; 
                    }
"assert"            { 
                        yylval.stringr = strdup(yytext); 
                        // cout<<"ASSERT "<<yytext<<endl; 
                        return ASSERT; 
                    }
"global"            { 
                        yylval.stringr = strdup(yytext); 
                        // cout<<"GLOBAL "<<yytext<<endl; 
                        return GLOBAL; 
                    }
"nonlocal"          { 
                        yylval.stringr = strdup(yytext); 
                        // cout<<"NONLOCAL "<<yytext<<endl; 
                        return NONLOCAL; 
                    }
"raise"             { 
                        yylval.stringr = strdup(yytext); 
                        // cout<<"RAISE "<<yytext<<endl; 
                        return RAISE; 
                    }
"and"               { 
                        yylval.stringr = strdup(yytext); 
                        // cout<<"AND "<<yytext<<endl; 
                        return AND; 
                    }
"or"                { 
                        yylval.stringr = strdup(yytext); 
                        // cout<<"OR "<<yytext<<endl; 
                        return OR; 
                    }
"not"               { 
                        yylval.stringr = strdup(yytext); 
                        // cout<<"NOT "<<yytext<<endl; 
                        return NOT; 
                    }
"from"              { 
                        yylval.stringr = strdup(yytext); 
                        // cout<<"FROM "<<yytext<<endl; 
                        return FROM; 
                    }
"+="                { 
                        yylval.stringr = strdup(yytext); 
                        // cout<<"PLUSEQUAL "<<yytext<<endl; 
                        return PLUSEQUAL; 
                    }
"-="                { 
                        yylval.stringr = strdup(yytext); 
                        // cout<<"MINEQUAL "<<yytext<<endl; 
                        return MINEQUAL; 
                    }
"**="               { 
                        yylval.stringr = strdup(yytext); 
                        // cout<<"DOUBLESTAREQUAL "<<yytext<<endl; 
                        return DOUBLESTAREQUAL; 
                    }
"*="                { 
                        yylval.stringr = strdup(yytext); 
                        // cout<<"STAREQUAL "<<yytext<<endl; 
                        return STAREQUAL; 
                    }
"//="               { 
                        yylval.stringr = strdup(yytext); 
                        // cout<<"DOUBLESLASHEQUAL "<<yytext<<endl; 
                        return DOUBLESLASHEQUAL; 
                    }
"/="                { 
                        yylval.stringr = strdup(yytext); 
                        // cout<<"SLASHEQUAL "<<yytext<<endl; 
                        return SLASHEQUAL; 
                    }
"%="                { 
                        yylval.stringr = strdup(yytext); 
                        // cout<<"PERCENTEQUAL "<<yytext<<endl; 
                        return PERCENTEQUAL; 
                    }
"&="                { 
                        yylval.stringr = strdup(yytext); 
                        // cout<<"AMPERSANDEQUAL "<<yytext<<endl; 
                        return AMPERSANDEQUAL; 
                    }
"|="                { 
                        yylval.stringr = strdup(yytext); 
                        // cout<<"VBAREQUAL "<<yytext<<endl; 
                        return VBAREQUAL; 
                    }
"^="                { 
                        yylval.stringr = strdup(yytext); 
                        // cout<<"CIRCUMFLEXEQUAL "<<yytext<<endl; 
                        return CIRCUMFLEXEQUAL; 
                    }
"@="                { 
                        yylval.stringr = strdup(yytext); 
                        // cout<<"ATEQUAL "<<yytext<<endl; 
                        return ATEQUAL; 
                    }
"<<="               { 
                        yylval.stringr = strdup(yytext); 
                        // cout<<"LEFTSHIFTEQUAL "<<yytext<<endl; 
                        return LEFTSHIFTEQUAL; 
                    }
">>="               { 
                        yylval.stringr = strdup(yytext); 
                        // cout<<"RIGHTSHIFTEQUAL "<<yytext<<endl; 
                        return RIGHTSHIFTEQUAL; 
                    }
"<<"                { 
                        yylval.stringr = strdup(yytext); 
                        // cout<<"LEFTSHIFT "<<yytext<<endl; 
                        return LEFTSHIFT; 
                    }
">>"                { 
                        yylval.stringr = strdup(yytext); 
                        // cout<<"RIGHTSHIFT "<<yytext<<endl; 
                        return RIGHTSHIFT; 
                    }
"=="                { 
                        yylval.stringr = strdup(yytext); 
                        // cout<<"EQEQUAL "<<yytext<<endl; 
                        return EQEQUAL; 
                    }
"!="                { 
                        yylval.stringr = strdup(yytext); 
                        // cout<<"NOTEQUAL "<<yytext<<endl; 
                        return NOTEQUAL; 
                    }
"<="                { 
                        yylval.stringr = strdup(yytext); 
                        // cout<<"LESSEQUAL "<<yytext<<endl; 
                        return LESSEQUAL; 
                    }
"<"                 { 
                        yylval.stringr = strdup(yytext); 
                        // cout<<"LESSTHAN "<<yytext<<endl; 
                        return LESSTHAN; 
                    }
">="                { 
                        yylval.stringr = strdup(yytext); 
                        // cout<<"GREATEREQUAL "<<yytext<<endl; 
                        return GREATEREQUAL; 
                    }
">"                 { 
                        yylval.stringr = strdup(yytext); 
                        // cout<<"GREATERTHAN "<<yytext<<endl; 
                        return GREATERTHAN; 
                    }
"**"                { 
                        yylval.stringr = strdup(yytext); 
                        // cout<<"DOUBLESTAR "<<yytext<<endl; 
                        return DOUBLESTAR; 
                    }
"->"                { 
                        yylval.stringr = strdup(yytext); 
                        // cout<<"ARROW "<<yytext<<endl; 
                        return ARROW; 
                    }
"+"                 { 
                        yylval.stringr = strdup(yytext); 
                        // cout<<"PLUS "<<yytext<<endl; 
                        return PLUS; 
                    }
"-"                 { 
                        yylval.stringr = strdup(yytext); 
                        // cout<<"MINUS "<<yytext<<endl; 
                        return MINUS; 
                    }
"*"                 { 
                        yylval.stringr = strdup(yytext); 
                        // cout<<"STAR "<<yytext<<endl; 
                        return STAR; 
                    }
"//"                { 
                        yylval.stringr = strdup(yytext); 
                        // cout<<"DOUBLESLASH "<<yytext<<endl; 
                        return DOUBLESLASH; 
                    }
"/"                 { 
                        yylval.stringr = strdup(yytext); 
                        // cout<<"SLASH "<<yytext<<endl; 
                        return SLASH; 
                    }
"="                 { 
                        yylval.stringr = strdup(yytext); 
                        // cout<<"EQUALS "<<yytext<<endl; 
                        return EQUALS; 
                    }
"("                 { 
                        yylval.stringr = strdup(yytext); 
                        paren_counter++; 
                        // cout<<"LPAREN "<<yytext<<endl; 
                        return LPAREN; 
                    }
")"                 { 
                        yylval.stringr = strdup(yytext); 
                        paren_counter--; 
                        // cout<<"RPAREN "<<yytext<<endl; 
                        return RPAREN; 
                    }
"["                 { 
                        yylval.stringr = strdup(yytext); 
                        paren_counter++; 
                        // cout<<"LBRACKET "<<yytext<<endl; 
                        return LBRACKET; 
                    }
"]"                 { 
                        yylval.stringr = strdup(yytext); 
                        paren_counter--; 
                        // cout<<"RBRACKET "<<yytext<<endl; 
                        return RBRACKET; 
                    }
"{"                 { 
                        yylval.stringr = strdup(yytext); 
                        // cout<<"LBRACE "<<yytext<<endl; 
                        return LBRACE; 
                    }
"}"                 { 
                        yylval.stringr = strdup(yytext); 
                        // cout<<"RBRACE "<<yytext<<endl; .
                        return RBRACE; 
                    }
":"                 { 
                        yylval.stringr = strdup(yytext); 
                        // cout<<"COLON "<<yytext<<endl; 
                        return COLON; 
                    }
";"                 { 
                        yylval.stringr = strdup(yytext); 
                        // cout<<"SEMICOLON "<<yytext<<endl; 
                        return SEMICOLON; 
                    }
","                 { 
                        yylval.stringr = strdup(yytext); 
                        // cout<<"COMMA "<<yytext<<endl; 
                        return COMMA; 
                    }
"."                 { 
                        yylval.stringr = strdup(yytext); 
                        // cout<<"DOT "<<yytext<<endl; 
                        return DOT; 
                    }
"|"                 { 
                        yylval.stringr = strdup(yytext); 
                        // cout<<"VBAR "<<yytext<<endl; 
                        return VBAR; 
                    }
"^"                 { 
                        yylval.stringr = strdup(yytext); 
                        // cout<<"CIRCUMFLEX "<<yytext<<endl; 
                        return CIRCUMFLEX; 
                    }
"&"                 { 
                        yylval.stringr = strdup(yytext); 
                        // cout<<"AMPERSAND "<<yytext<<endl; 
                        return AMPERSAND; 
                    }
"@"                 { 
                        yylval.stringr = strdup(yytext); 
                        // cout<<"AT "<<yytext<<endl; 
                        return AT; 
                    }
"%"                 { 
                        yylval.stringr = strdup(yytext); 
                        // cout<<"PERCENT "<<yytext<<endl; 
                        return PERCENT; 
                    }
"~"                 { 
                        yylval.stringr = strdup(yytext); 
                        // cout<<"TILDE "<<yytext<<endl; 
                        return TILDE; 
                    }
"'"                 { 
                        yylval.stringr = strdup(yytext); 
                        // cout<<"QUOTE "<<yytext<<endl; 
                        return QUOTE; 
                    }
"\""                { 
                        yylval.stringr = strdup(yytext); 
                        // cout<<"DOUBLEQUOTE "<<yytext<<endl; 
                        return DOUBLEQUOTE; 
                    }
"\\"                { 
                        yylval.stringr = strdup(yytext); 
                        // cout<<"BACKSLASH "<<yytext<<endl; 
                        BEGIN(explicit_line_joining_state);
                    }
{NUMBERL}           { 
                        yylval.stringr = strdup(yytext); 
                        // cout<<"NUMBER "<<yytext<<endl; 
                        return NUMBER; 
                    }
{LONGSTRING}        {
                        string t = yytext;
                        int i = 3;
                        // cout<<t.size()<<endl;
                        while(i<t.size()){
                            // cout<<t[i]<<endl;
                            if(t[0]=='\'' && t[i]=='\''){
                                if(i+2<t.size()-3 && t[i+1]=='\'' && t[i+2]=='\''){
                                    cerr<<"Erroneous string found at line "<<yylineno<<endl;
                                    exit(1);
                                }
                            }
                            else if(t[0]=='\"' && t[i]=='\"'){
                                if(i+2<t.size()-3 && t[i+1]=='\"' && t[i+2]=='\"'){
                                    cerr<<"Erroneous string found at line"<<yylineno<<endl;
                                    exit(1);
                                }
                            }
                            i++;
                        }
                        // cout<<yytext <<" This is a long string"<<endl;
                        yylval.stringr = strdup(yytext);
                        return STRING;
                    }
{SHORTSTRING}       { yylval.stringr =strdup(yytext); return STRING;}

[ \t\v\r\f]+        {  }
"\n"|"\r\n"         {  
                        if(paren_counter == 0){
                            num_spaces = 0;
                            poppy = 0;
                            char c = yyinput();
                            // cout<<"c = \'"<<c<<"\'"<<endl;
                            while(c == '\n' || c == ' ' || c=='\r'){
                                if(c==' '){      
                                    c = yyinput();
                                    // cout<<"c = \'"<<c<<"\'"<<endl;
                                    num_spaces++;
                                }
                                if(c=='\n'){
                                    num_spaces = 0;
                                    c = yyinput();
                                    // cout<<"c = \'"<<c<<"\'"<<endl;
                                }
                                if(c=='\r'){
                                // c = yyinput();
                                    c = yyinput();
                                    // cout<<"c = \'"<<c<<"\'"<<endl;
                                    num_spaces = 0;
                                }
                                // c = yyinput();
                            }
                            unput(c);

                            // if(num_spaces == 0) return NEWLINE;
                            BEGIN (indentation_state);
                        }
                        else{
                            BEGIN(implicit_line_joining_state);
                        }
                    }
[a-zA-Z_][a-zA-Z0-9_]*  { 
                            yylval.stringr = strdup(yytext); 
                            // cout<<"NAME "<<yytext<<endl; 
                            return NAME; 
                        }

%%

// int main(int argc, char **argv) {
//     yylex();
//     return 0;
// }

int yywrap() {
    return 1;
}