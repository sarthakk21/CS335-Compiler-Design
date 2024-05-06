%option case-insensitive
%option yylineno
%{
extern "C" {
    int yylex();
}

#include <iostream>
#include <map>
#include <string>
#include <algorithm>

using namespace std;

map<string, pair<string, int>> tokens;
map<string, int> caseInsensitiveTokenCounts;

void addOrUpdateToken(const string& lexeme, const string& type) {
    // Update tokens map
    auto it = tokens.find(lexeme);
    if (it == tokens.end()) { // New token
        tokens[lexeme] = make_pair(type, 1);
    } else { // Existing token
        it->second.second++;
    }

    // For keywords and operators, update caseInsensitiveTokenCounts map
    if (type == "KEYWORD" || type == "OPERATOR" || type == "LOGICAL_LITERAL" || type == "NAME" || type == "REAL_LITERAL") {
        string lexemeLower = lexeme;
        transform(lexemeLower.begin(), lexemeLower.end(), lexemeLower.begin(), ::tolower);

        // Update count in caseInsensitiveTokenCounts
        int& count = caseInsensitiveTokenCounts[lexemeLower];
        count++;

        // Update counts in tokens map for all case variations
        for (auto& token : tokens) {
            if (token.first.size() == lexeme.size()) {
                bool isEqual = true;
                for (size_t i = 0; i < lexeme.size(); ++i) {
                    if (tolower(token.first[i]) != lexemeLower[i]) {
                        isEqual = false;
                        break;
                    }
                }
                if (isEqual) {
                    token.second.second = count;
                }
            }
        }
    }
}
%}

ws              [ \t\r\n\f\v]+
DIGIT           [0-9]
LETTER          [a-zA-Z]
SIGNIFICAND     {DIGIT}+\.{DIGIT}*|{DIGIT}*\.{DIGIT}+
EXPONENT        [+-]{DIGIT}+|{DIGIT}+


%%
^{ws}*[!][^\n]*                           { /* Ignore comment */ }
[\n]{ws}*![^\n]*[\n]?                     { /* Ignore comment */ }
\"([^"'])*\'([^"])*\"                    { int lines = 0;
                                            char*curr = yytext;
                                            while (*curr) {
                                                if (*curr == '\n') lines++;
                                                curr++;
                                            }
                                            cout << "Illegal string " << yytext << " -> starting at line " << yylineno - lines << endl; 
                                          }

"allocatable"|"allocate"|"assign"|"associate"|"asynchronous"|"backspace"|"bind"|"call"|"case"|"class"|"close"|"common"|"contains"|"continue"|"cycle"|"codimension"|"contiguous"|"critical"|"data"|"deallocate"|"deferred"|"dimension"|"do"|"else"|"elsewhere"|"end"|"endfile"|"endif"|"entry"|"equivalence"|"exit"|"external"|"enum"|"enumerator"|"extends"|"forall"|"final"|"flush"|"format"|"function"|"goto"|"generic"|"import"|"if"|"implicit"|"inquire"|"intrinsic"|"include"|"interface"|"intent"|"lock"|"module"|"nopass"|"namelist"|"nullify"|"open"|"only"|"operator"|"optional"|"parameter"|"pause"|"print"|"program"|"pointer"|"private"|"pass"|"protected"|"procedure"|"public"|"read"|"return"|"recursive"|"result"|"rewind"|"rewrite"|"save"|"stop"|"subroutine"|"select"|"sequence"|"submodule"|"target"|"then"|"use"|"value"|"unlock"|"volatile"|"while"|"write" { addOrUpdateToken(yytext, "KEYWORD"); }

[+-]{SIGNIFICAND}[DE]{EXPONENT}           { addOrUpdateToken(yytext, "REAL_LITERAL"); }
{SIGNIFICAND}[DE]{EXPONENT}               { addOrUpdateToken(yytext, "REAL_LITERAL"); }
[+-]{SIGNIFICAND}                         { addOrUpdateToken(yytext, "REAL_LITERAL"); }
{SIGNIFICAND}                             { addOrUpdateToken(yytext, "REAL_LITERAL"); }
[+-]{DIGIT}+[DE]{EXPONENT}                { addOrUpdateToken(yytext, "REAL_LITERAL"); }
{DIGIT}+[DE]{EXPONENT}                    { addOrUpdateToken(yytext, "REAL_LITERAL"); }

\"([^"'])*\"                              { addOrUpdateToken(yytext, "CHAR_LITERAL"); }
\"[^'"]*\'[^"]*\"?                       { int lines = 0;
                                            char*curr = yytext;
                                            while (*curr) {
                                                if (*curr == '\n') 
                                            lines++;
                                                curr++;
                                            }
                                            cout << "Illegal string " << yytext << " -> starting at line " << yylineno - 
                                        lines << endl; 
                                          }
\"[^'"]*                                 { int lines = 0;
                                            char*curr = yytext;
                                            while (*curr) {
                                                if (*curr == '\n') 
                                            lines++;
                                                curr++;
                                            }
                                            cout << "Illegal string " << yytext << " -> starting at line " << yylineno - 
                                        lines << endl; 
                                          }


[-+]{DIGIT}+                              { addOrUpdateToken(yytext, "INT_LITERAL"); }
{DIGIT}+                                  { addOrUpdateToken(yytext, "INT_LITERAL"); }
".TRUE."|".FALSE."                        { addOrUpdateToken(yytext, "LOGICAL_LITERAL"); }

"&&"|"<<"|">>"|"||"|"**"|"//"|".EQ."|".NE."|".LT."|".LE."|".GT."|".GE."|"=="|"/="|"<="|">="|".NOT."|".AND."|".OR."|".NEQV."      { addOrUpdateToken(yytext, "OPERATOR"); }
"+"|"-"|"*"|"/"|"%"|"&"|"<"|">"|"="|".EQV."       { addOrUpdateToken(yytext, "OPERATOR"); }

{LETTER}({LETTER}|{DIGIT}|\_){63,}        { cout << "Illegal Name '" << yytext << "' of more than 63 characters at line " << yylineno << endl; }
{LETTER}({LETTER}|{DIGIT}|\_){0,62}       { addOrUpdateToken(yytext, "NAME"); }

"(/"|"/)"                                 { addOrUpdateToken(yytext, "DELIMITER"); }
[\(\)\[\]]                                { addOrUpdateToken(yytext, "DELIMITER"); }

[\\\{\}\,\.\:\;~?\`'^\|\$\#\@!]          { addOrUpdateToken(yytext, "SPECIAL_CHAR"); }

[\t\r\n\f\v ]                             { /* Ignore whitespace */ }
.                                         { cout << "Illegal character " << *yytext << " at line " << yylineno << endl; }

%%

int main() {
    yylex();
    cout << endl << "TOKEN    COUNT    LEXEME" << endl;
    for (const auto& token : tokens) {
        cout << token.second.first << " " << token.second.second << " " << token.first << endl;
    }

    return 0;
}