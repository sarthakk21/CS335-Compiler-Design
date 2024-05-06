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
    if (type == "KEYWORD" || type == "OPERATOR") {
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
DIGIT_STRING    [1-9][0-9]*
HEX_DIGIT       [1-9a-fA-F][0-9a-fA-F]*
LETTER          [a-zA-Z]
IDENTIFIER      {LETTER}({LETTER}|{DIGIT})*
COMMENT         \{*\}

%%
\{[^}]*\}                                 { /* Ignore comment */ }

"0x0"                                     { addOrUpdateToken(yytext, "HEXADECIMAL"); }
"0x"{HEX_DIGIT}+                          { addOrUpdateToken(yytext, "HEXADECIMAL"); }
"+"|"-"|"*"|"/"|"%"|"^"|"|"|"&"|"<<"|">>"|":="|"AND"|"OR"|"LEQ"|"LT"|"GEQ"|"GT"|"NOT"|"EQL"|"NEQ" { addOrUpdateToken(yytext, "OPERATOR"); }
"ARRAY"|"BEGIN"|"BOOLEAN"|"COMMENT"|"CONTINUE"|"DO"|"DOUBLE"|"ELSE"|"END"|"FALSE"|"FOR"|"IF"|"INTEGER"|"LABEL"|"LIST"|"LONG"|"OWN"|"PROCEDURE"|"STEP"|"SWITCH"|"THEN"|"TRUE"|"UNTIL"|"VALUE"|"WHILE" { addOrUpdateToken(yytext, "KEYWORD"); }

\"([^"'])*\"                             { addOrUpdateToken(yytext, "STRING"); }
\'([^'"])*\'                             { addOrUpdateToken(yytext, "STRING"); }
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
\'[^"']*\"[^']*\'?                       { int lines = 0;
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
\'[^"']*                                 { int lines = 0;
                                            char*curr = yytext;
                                            while (*curr) {
                                                if (*curr == '\n') 
                                            lines++;
                                                curr++;
                                            }
                                            cout << "Illegal string " << yytext << " -> starting at line " << yylineno - 
                                        lines << endl; 
                                          }

{IDENTIFIER}                              { addOrUpdateToken(yytext, "IDENTIFIER"); }

({DIGIT_STRING}+|0)\.({DIGIT}){1,6}       { addOrUpdateToken(yytext, "FLOATING_POINT"); } /*CHECK INVALID*/
"0"                                       { addOrUpdateToken(yytext, "INTEGER"); }
{DIGIT_STRING}                            { addOrUpdateToken(yytext, "INTEGER"); }
[;:,()\[\]{}]                             { addOrUpdateToken(yytext, "DELIMITER"); }
[ \t\r\n\f\v]+                            { /* Ignore whitespace */ }
.                                         { cout << "Illegal character '" << *yytext << "' at line " << yylineno << endl; }

%%

int main() {
    yylex();
    cout <<endl << "TOKEN    COUNT    LEXEME" << endl;
    for (const auto& token : tokens) {
        cout << token.second.first << " " << token.second.second << " " << token.first << endl;
    }

    return 0;
}
