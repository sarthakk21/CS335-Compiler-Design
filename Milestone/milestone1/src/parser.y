%{
    #include <iostream>
    #include <string>
    #include <vector>
    #include <unordered_map>
    #include <map>
    #include <iomanip>
    #include <stack>
    #include <fstream>
    #include "parser.tab.h" 
    using namespace std;
    extern int yylineno;
    void yyerror(const char *s);
    int yylex();
    extern int yyparse();
    extern FILE *yyin;
    extern char* yytext;
    int nodeId = 0;
    ofstream fout("AST.dot");

    struct Node {
        string valy;
        int id;
        vector<Node*> children;
    };

    struct Node* root;

    Node* createNode(string value) {
        Node *node = new Node;
        node->valy = value;
        node->id = nodeId++; 
        return node;
    }

%}

%define parse.error verbose

%union {
    char* stringr;
    struct Node* node;
}

%type <node> file_input 
%type <node> funcdef
%type <node> f_funcdef
%type <node> parameters
%type <node> f_parameters
%type <node> typedargslist
%type <node> tfpdef
%type <node> f_tfpdef
%type <node> stmt
%type <node> simple_stmt
%type <node> f_simple_stmt
%type <node> semicolon_small_stmt
%type <node> small_stmt
%type <node> expr_stmt
%type <node> f_expr_stmt
%type <node> expr_stmt_continue
%type <node> annassign
%type <node> f_typedargslist
%type <node> testlist_star_expr
%type <node> testlist_star_expr_continue
%type <node> augassign
%type <node> flow_stmt
%type <node> break_stmt
%type <node> continue_stmt
%type <node> return_stmt
%type <node> f_return_stmt
%type <node> raise_stmt
%type <node> f_raise_stmt
%type <node> ff_raise_stmt
%type <node> global_stmt
%type <node> nonlocal_stmt
%type <node> assert_stmt
%type <node> f_assert_stmt
%type <node> compound_stmt
%type <node> if_stmt
%type <node> if_stmt_continue
%type <node> f_cond_stmt
%type <node> while_stmt
%type <node> for_stmt
%type <node> suite
%type <node> f_suite
%type <node> test
%type <node> f_test
%type <node> test_nocond
%type <node> or_test
%type <node> and_test
%type <node> not_test
%type <node> comparison
%type <node> comp_op
%type <node> star_expr
%type <node> expr
%type <node> xor_expr
%type <node> and_expr
%type <node> shift_expr
%type <node> f_shift_expr
%type <node> arith_expr
%type <node> f_arith_expr
%type <node> term
%type <node> f_term
%type <node> factor
%type <node> power
%type <node> f_power
%type <node> atom_expr
%type <node> atom
%type <node> f_atom_LPAREN
%type <node> f_atom_LBRACKET
%type <node> string_continue
%type <node> testlist_comp
%type <node> f_testlist_comp_test
%type <node> testlist_comp_continue
%type <node> f_test_star_expr_continue
%type <node> trailer
%type <node> f_trailer
%type <node> subscriptlist
%type <node> subscript_list_continue
%type <node> exprlist
%type <node> exprlist_continue
%type <node> exprlist_continue_continue
%type <node> testlist
%type <node> testlist_continue
%type <node> classdef
%type <node> f_classdef
%type <node> f_f_classdef
%type <node> arglist
%type <node> f_comma
%type <node> arglist_continue
%type <node> argument
%type <node> f_argument
%type <node> comp_iter
%type <node> comp_for
%type <node> comp_if
%type <node> f_comp_cond
%type <node> start

%token <stringr> NUMBER
%token <stringr> STRING
%token <stringr> NAME
%token <stringr> INDENT DEDENT
%token <stringr> FROM DEF CLASS IF IN IS ELSE ELIF WHILE FOR RETURN BREAK CONTINUE TRUEE FALSEE NONE ASSERT GLOBAL NONLOCAL RAISE AND OR NOT PLUSEQUAL MINEQUAL DOUBLESTAREQUAL STAREQUAL DOUBLESLASHEQUAL SLASHEQUAL PERCENTEQUAL AMPERSANDEQUAL VBAREQUAL CIRCUMFLEXEQUAL ATEQUAL LEFTSHIFTEQUAL RIGHTSHIFTEQUAL LEFTSHIFT RIGHTSHIFT EQEQUAL NOTEQUAL LESSEQUAL LESSTHAN GREATEREQUAL GREATERTHAN DOUBLESTAR ARROW PLUS MINUS STAR DOUBLESLASH SLASH EQUALS LPAREN RPAREN LBRACKET RBRACKET LBRACE RBRACE COLON SEMICOLON COMMA DOT VBAR CIRCUMFLEX AMPERSAND AT PERCENT TILDE QUOTE DOUBLEQUOTE NEWLINE ENDMARKER 

%start start

%%

start:
    file_input{
        $$ = createNode("START");
        root = $$;
        $$->children.push_back($1);
    }
    ;

file_input: 
      { 
        $$ = NULL;
        // $$->children.push_back(createNode("EMPTY"));
    }
    | NEWLINE file_input 
    {   $$ = $2;
        // createNode("file_input");
        // $$->children.push_back(createNode($1));
        // $$->children.push_back($2);
    }
    | stmt file_input
    {
        if($1 == NULL && $2 == NULL){
            $$ = NULL;
        }
        else{
            if($1 == NULL){
                $$ = $2;
            }
            else if($2 == NULL){
                $$ = $1;
            }
            else{
                $$ = createNode("file_input");
                $$->children.push_back($1);
                $$->children.push_back($2);
            }
        }
    }
    ;

funcdef:
    DEF NAME parameters f_funcdef
    {
        $$ = createNode("funcdef");
        string temp = string("DEF (") + $1 + ")";
        $$->children.push_back(createNode(temp));
        temp = string("NAME (") + $2 + ")";
        $$->children.push_back(createNode(temp));
        $$->children.push_back($3);
        $$->children.push_back($4);
    }
    ;

f_funcdef:
    COLON suite
    {
        if($2 == NULL){
            string temp = string("COLON (") + $1 + ")";
            $$ = createNode(temp);
        }
        else{
            $$ = createNode("f_funcdef");
            string temp = string("COLON (") + $1 + ")";
            $$->children.push_back(createNode(temp));
            $$->children.push_back($2);
        }
    }
    | ARROW test COLON suite
    {
        $$ = createNode("f_funcdef");
        string temp = string("ARROW (") + $1 + ")";
        $$->children.push_back(createNode(temp));
        $$->children.push_back($2);
        temp = string("COLON (") + $3 + ")";
        $$->children.push_back(createNode(temp));
        $$->children.push_back($4);
    }
    ;

parameters: 
    LPAREN f_parameters
    {
        string temp = string("LPAREN (") + $1 + ")";
        if($2 == NULL){
            $$ = createNode(temp);
        }
        else{
            $$ = createNode("parameters");
            $$->children.push_back(createNode(temp));
            $$->children.push_back($2);
        }
        
    }
    ;

f_parameters:
    typedargslist RPAREN
    {
        string temp = string("RPAREN (") + $2 + ")";
        if($1 == NULL){
            $$ = createNode(temp);
        }
        else{
            $$ = createNode("f_parameters");
            $$->children.push_back($1);
            $$->children.push_back(createNode(temp));
        }    
    }
    | RPAREN
    {
        string temp = string("RPAREN (") + $1 + ")";
        $$ = createNode(temp);
        // $$->children.push_back(createNode($1));
    }
    ;

typedargslist: 
    tfpdef f_typedargslist
    {
        if($1 == NULL && $2 == NULL){
            $$ = NULL;
        }
        else{
            if($1 == NULL){
                $$ = $2;
            }
            else if($2 == NULL){
                $$ = $1;
            }
            else{
                $$ = createNode("typedargslist");
                $$->children.push_back($1);
                $$->children.push_back($2);
            }
        }
    }
    | typedargslist COMMA tfpdef f_typedargslist
    {
        string temp = string("COMMA (") + $2 + ")";
        if($1 == NULL && $3 == NULL && $4 == NULL){
            $$ = createNode(temp);
        }
        else{
            $$ = createNode("typedargslist");
            $$->children.push_back($1);
            $$->children.push_back(createNode(temp));
            $$->children.push_back($3);
            $$->children.push_back($4);
        }
    }
    ;

tfpdef: 
    NAME f_tfpdef
    {
        string temp = string("NAME (") + $1 + ")";
        if($2 == NULL){
            $$ = createNode(temp);
        }
        else{
            $$ = createNode("tfpdef");
            $$->children.push_back(createNode(temp));
            $$->children.push_back($2);
        }
    }
    ;

f_tfpdef:
     
    {
        $$ = NULL;
        // $$->children.push_back(createNode("EMPTY"));
    }
    | COLON test
    {
        string temp = string("COLON (") + $1 + ")";
        if($2 == NULL){
            $$ = createNode(temp);
        }
        else{
            $$ = createNode("f_tfpdef");
            $$->children.push_back(createNode(temp));
            $$->children.push_back($2);
        }
    }
    ;

stmt: 
    simple_stmt
    {
        $$ = $1;
        // createNode("stmt");
        // $$->children.push_back($1);
    }
    | compound_stmt
    {
        $$ = $1;
        // createNode("stmt");
        // $$->children.push_back($1);
    }
    ;

simple_stmt: 
    small_stmt semicolon_small_stmt f_simple_stmt
    {
        if($1 == NULL && $2 == NULL && $3 == NULL){
            $$ = NULL;
        }
        else{
            if($1 == NULL && $2 == NULL){
                $$ = $3;
            }
            else if($1 == NULL && $3 == NULL){
                $$ = $2;
            }
            else if($2 == NULL && $3 == NULL){
                $$ = $1;
            }
            else{
                $$ = createNode("simple_stmt");
                $$->children.push_back($1);
                $$->children.push_back($2);
                $$->children.push_back($3);
            }
        }
    }
    ;

f_simple_stmt:
    SEMICOLON NEWLINE
    {
        string temp = string("SEMICOLON (") + $1 + ")";
        $$ = createNode(temp);
        // createNode("f_simple_stmt");
        // $$->children.push_back(createNode($1));
        // $$->children.push_back(createNode($2));
    }
    | NEWLINE
    {
        $$ = NULL;
        // createNode("f_simple_stmt");
        // $$->children.push_back(createNode($1));
    }
    ;

semicolon_small_stmt:
    semicolon_small_stmt SEMICOLON small_stmt
    {
        string temp = string("SEMICOLON (") + $2 + ")";
        if($1 == NULL && $3 == NULL){
            $$ = createNode(temp);
        }
        else{
            $$ = createNode("semicolon_small_stmt");
            $$->children.push_back($1);
            $$->children.push_back(createNode(temp));
            $$->children.push_back($3);
        }
    }
    |  
    {
        $$ = NULL;
        // $$->children.push_back(createNode("EMPTY"));
    }
    ;

small_stmt:
    expr_stmt
    {
        $$ = $1;
        // createNode("small_stmt");
        // $$->children.push_back($1);
    }
    | flow_stmt
    {
        $$ = $1; 
        // createNode("small_stmt");
        // $$->children.push_back($1);
    }
    | global_stmt
    {
        $$ = $1;
        // createNode("small_stmt");
        // $$->children.push_back($1);
    }
    | nonlocal_stmt
    {
        $$ = $1;
        // createNode("small_stmt");
        // $$->children.push_back($1);
    }
    | assert_stmt
    {
        $$ = $1;
        // createNode("small_stmt");
        // $$->children.push_back($1);
    }
    ;

expr_stmt: 
    testlist_star_expr f_expr_stmt
    {
        if($1 == NULL && $2 == NULL){
            $$ = NULL;
        }
        else{
            if($1 == NULL){
                $$ = $2;
            }
            else if($2 == NULL){
                $$ = $1;
            }
            else{
                int cnt = 0;

                $$ = createNode("expr_stmt");
                $$->children.push_back($1);
                for(auto it: $2 -> children){
                    $$->children.push_back(it);
                }
                
                // for(auto it: $2 -> children){
                //     if(cnt == 0){
                //         $$ = createNode(it -> valy);
                //         $$->children.push_back($1);
                //         cnt++;
                //         continue;
                //     }
                //     else{
                //         $$->children.push_back(it);
                //     }
                    
                // }
                
            }
        }
    }
    ;

f_expr_stmt:
    annassign
    {
        $$ = $1;
        // createNode("f_expr_stmt");
        // $$->children.push_back($1);
    }
    | augassign testlist
    {
        if($1 == NULL && $2 == NULL){
            $$ = NULL;
        }
        else{
            if($1 == NULL){
                $$ = $2;
            }
            else if($2 == NULL){
                $$ = $1;
            }
            else{
                $$ = createNode("f_expr_stmt");
                $$->children.push_back($1);
                $$->children.push_back($2);
            }
        }
    }
    | expr_stmt_continue
    {
        $$ = $1;
        // createNode("f_expr_stmt");
        // $$->children.push_back($1);
    }
    ;

expr_stmt_continue:
    expr_stmt_continue EQUALS testlist_star_expr
    {
        string temp = string("EQUALS (") + $2 + ")";
        if($1 == NULL && $3 == NULL){
            $$ = createNode(temp);
        }
        else{
            $$ = createNode("expr_stmt_continue");
            $$->children.push_back($1);
            $$->children.push_back(createNode(temp));
            $$->children.push_back($3);
        }
    }
    |  
    {
        $$ = NULL;
        // $$->children.push_back(createNode("EMPTY"));
    }
    ;

annassign: 
    COLON test f_typedargslist
    {
        string temp = string("COLON (") + $1 + ")";
        if($2 == NULL && $3 == NULL){
            $$ = createNode(temp);
        }
        else{
            $$ = createNode("annassign");
            $$->children.push_back(createNode(temp));
            $$->children.push_back($2);
            $$->children.push_back($3);
        }
    }
    ;

f_typedargslist:
     
    {
        $$ = NULL;
        // $$->children.push_back(createNode("EMPTY"));
    }
    | EQUALS test
    {
        string temp = string("EQUALS (") + $1 + ")";
        if($2 == NULL){
            $$ = createNode(temp);
        }
        else{
            $$ = createNode("f_typedargslist");
            $$->children.push_back(createNode(temp));
            $$->children.push_back($2);
        }
    }
    ;

testlist_star_expr: 
    f_test_star_expr_continue testlist_star_expr_continue f_comma
    {
        if($1 == NULL && $2 == NULL && $3 == NULL){
            $$ = NULL;
        }
        else{
            if($1 == NULL && $2 == NULL){
                $$ = $3;
            }
            else if($1 == NULL && $3 == NULL){
                $$ = $2;
            }
            else if($2 == NULL && $3 == NULL){
                $$ = $1;
            }
            else{
                $$ = createNode("testlist_star_expr");
                $$->children.push_back($1);
                $$->children.push_back($2);
                $$->children.push_back($3);
            }
        }
    }
    ;

testlist_star_expr_continue:
    testlist_star_expr_continue COMMA f_test_star_expr_continue
    {
        string temp = string("COMMA (") + $2 + ")";
        if($1 == NULL && $3 == NULL){
            $$ = createNode(temp);
        }
        else{
            $$ = createNode("testlist_star_expr_continue");
            $$->children.push_back($1);
            $$->children.push_back(createNode(temp));
            $$->children.push_back($3);
        }
    }
    |  
    {
        $$ = NULL;
        // $$->children.push_back(createNode("EMPTY"));
    }
    ;


augassign:
    PLUSEQUAL
    {
        string temp = string("PLUSEQUAL (") + $1 + ")";
        $$ = createNode(temp); 
        // createNode("augassign");
        // $$->children.push_back(createNode($1));
    }
    | MINEQUAL
    {
        string temp = string("MINEQUAL (") + $1 + ")";
        $$ = createNode(temp);
        // createNode("augassign");
        // $$->children.push_back(createNode($1));
    }
    | STAREQUAL 
    {
        string temp = string("STAREQUAL (") + $1 + ")";
        $$ = createNode(temp);
        // createNode("augassign");
        // $$->children.push_back(createNode($1));
    }
    | SLASHEQUAL 
    {
        string temp = string("SLASHEQUAL (") + $1 + ")";
        $$ = createNode(temp);
        // createNode("augassign");
        // $$->children.push_back(createNode($1));
    }
    | PERCENTEQUAL 
    {
        string temp = string("PERCENTEQUAL (") + $1 + ")";
        $$ = createNode(temp);
        // createNode("augassign");
        // $$->children.push_back(createNode($1));
    }
    | AMPERSANDEQUAL 
    {
        string temp = string("AMPERSANEQUAL (") + $1 + ")";
        $$ = createNode(temp);
        // createNode("augassign");
        // $$->children.push_back(createNode($1));
    }
    | VBAREQUAL 
    {
        string temp = string("VBAREQUAL (") + $1 + ")";
        $$ = createNode(temp);
        // createNode("augassign");
        // $$->children.push_back(createNode($1));
    }
    | CIRCUMFLEXEQUAL 
    {
        string temp = string("CIRCUMFLEXEQUAL (") + $1 + ")";
        $$ = createNode(temp);
        // createNode("augassign");
        // $$->children.push_back(createNode($1));
    }
    | LEFTSHIFTEQUAL 
    {
        string temp = string("LEFTSHIFTEQUAL (") + $1 + ")";
        $$ = createNode(temp);
        // createNode("augassign");
        // $$->children.push_back(createNode($1));
    }
    | RIGHTSHIFTEQUAL 
    {
        string temp = string("RIGHTSHIFTEQUAL (") + $1 + ")";
        $$ = createNode(temp);
        // createNode("augassign");
        // $$->children.push_back(createNode($1));
    }
    | DOUBLESTAREQUAL 
    {
        string temp = string("DOUBLESTAREQUAL (") + $1 + ")";
        $$ = createNode(temp);
        // createNode("augassign");
        // $$->children.push_back(createNode($1));
    }
    | DOUBLESLASHEQUAL
    {
        string temp = string("DOUBLESLASHEQUAL (") + $1 + ")";
        $$ = createNode(temp);
        // createNode("augassign");
        // $$->children.push_back(createNode($1));
    }
    ;

flow_stmt: 
    break_stmt
    {
        $$ = $1;
        // createNode("flow_stmt");
        // $$->children.push_back($1);
    }
    | continue_stmt
    {
        $$ = $1;
        // createNode("flow_stmt");
        // $$->children.push_back($1);
    }
    | return_stmt
    {
        $$ = $1;
        // createNode("flow_stmt");
        // $$->children.push_back($1);
    }
    | raise_stmt
    {
        $$ = $1;
        // createNode("flow_stmt");
        // $$->children.push_back($1);
    }
    ;

break_stmt: 
    BREAK{
        string temp = string("BREAK (") + $1 + ")";
        $$ = createNode(temp);
        // createNode("break_stmt");
        // $$->children.push_back(createNode($1));

    } 
    ;

continue_stmt: 
    CONTINUE
    {
        string temp = string("CONTINUE (") + $1 + ")";
        $$ = createNode(temp);
        // createNode("continue_stmt");
        // $$->children.push_back(createNode($1));
    }
    ;

return_stmt: 
    RETURN f_return_stmt
    {
        string temp = string("RETURN (") + $1 + ")";
        if($2 == NULL){
            $$ = createNode(temp);
        }
        else{
            $$ = createNode("return_stmt");
            $$->children.push_back(createNode(temp));
            $$->children.push_back($2);
        }
    }
    ;

f_return_stmt:
     
    {
        $$ = NULL;
        // $$->children.push_back(createNode("EMPTY"));
    }
    | testlist
    {
        $$ = $1;
        // createNode("f_return_stmt");
        // $$->children.push_back($1);
    }
    ;

raise_stmt: 
    RAISE f_raise_stmt
    {
        string temp = string("RAISE (") + $1 + ")";
        if($2 == NULL){
            $$ = createNode(temp);
        }
        else{
            $$ = createNode("raise_stmt");
            $$->children.push_back(createNode(temp));
            $$->children.push_back($2);
        }
    }
    ;

f_raise_stmt:
     
    {
        $$ = NULL;
        // $$->children.push_back(createNode("EMPTY"));
    }
    | test ff_raise_stmt
    {
        if($1 == NULL && $2 == NULL){
            $$ = NULL;
        }
        else{
            if($1 == NULL){
                $$ = $2;
            }
            else if($2 == NULL){
                $$ = $1;
            }
            else{
                $$ = createNode("f_raise_stmt");
                $$->children.push_back($1);
                $$->children.push_back($2);
            }
        }
    }
    ;
ff_raise_stmt:
     
    {
        $$ = NULL;
        // $$->children.push_back(createNode("EMPTY"));
    }
    | FROM test
    {
        string temp = string("FROM (") + $1 + ")";
        if($2 == NULL){
            $$ = createNode(temp);
        }
        else{
            $$ = createNode("ff_raise_stmt");
            $$->children.push_back(createNode(temp));
            $$->children.push_back($2);
        }
    }
    ;

global_stmt: 
    GLOBAL NAME
    {
        string temp = string("GLOBAL (") + $1 + ")";
        $$ = createNode("global_stmt");
        $$->children.push_back(createNode(temp));
        temp = string("NAME (") + $2 + ")";
        $$->children.push_back(createNode(temp));
    }
    | global_stmt COMMA NAME
    {
        string temp = string("COMMA (") + $2 + ")";
        $$ = createNode("global_stmt");
        $$->children.push_back($1);
        $$->children.push_back(createNode(temp));
        temp = string("NAME (") + $3 + ")";
        $$->children.push_back(createNode(temp));
    }
    ;

nonlocal_stmt: 
    NONLOCAL NAME
    {
        string temp = string("NONLOCAL (") + $1 + ")";
        $$ = createNode("nonlocal_stmt");
        $$->children.push_back(createNode(temp));
        temp = string("NAME (") + $2 + ")";
        $$->children.push_back(createNode(temp));
    }
    | nonlocal_stmt COMMA NAME
    {
        string temp = string("COMMA (") + $2 + ")";
        $$ = createNode("nonlocal_stmt");
        $$->children.push_back($1);
        $$->children.push_back(createNode(temp));
        temp = string("NAME (") + $3 + ")";
        $$->children.push_back(createNode(temp));
    }
    ;

assert_stmt: 
    ASSERT test f_assert_stmt
    {
        string temp = string("ASSERT (") + $1 + ")";
        if($2 == NULL && $3 == NULL){
            $$ = createNode(temp);
        }
        else{
            $$ = createNode("assert_stmt");
            $$->children.push_back(createNode(temp));
            $$->children.push_back($2);
            $$->children.push_back($3);
        }
    }
    ;

f_assert_stmt:
     
    {
        $$ = NULL;
        // $$->children.push_back(createNode("EMPTY"));
    }
    | COMMA test
    {
        string temp = string("COMMA (") + $1 + ")";
        if($2 == NULL){
            $$ = createNode(temp);
        }
        else{
            $$ = createNode("f_assert_stmt");
            $$->children.push_back(createNode(temp));
            $$->children.push_back($2);
        }
    }
    ;

compound_stmt: 
    if_stmt
    {
        $$ = $1;
        // createNode("compound_stmt");
        // $$->children.push_back($1);
    }
    | while_stmt
    {
        $$ = $1;
        // createNode("compound_stmt");
        // $$->children.push_back($1);
    }
    | for_stmt
    {
        $$ = $1;
        // createNode("compound_stmt");
        // $$->children.push_back($1);
    }
    | funcdef
    {
        $$ = $1;
        // createNode("compound_stmt");
        // $$->children.push_back($1);
    }
    | classdef
    {
        $$ = $1;
        // createNode("compound_stmt");
        // $$->children.push_back($1);
    }
    ;

if_stmt: 
    IF test COLON suite if_stmt_continue f_cond_stmt
    {
        string temp = string("IF (") + $1 + ")";
        $$ = createNode("if_stmt");
        $$->children.push_back(createNode(temp));
        $$->children.push_back($2);
        temp = string("COLON (") + $3 + ")";
        $$->children.push_back(createNode(temp));
        $$->children.push_back($4);
        $$->children.push_back($5);
        $$->children.push_back($6);
    }
    ;

if_stmt_continue:
     
    {
        $$ = NULL;
        // $$->children.push_back(createNode("EMPTY"));
    }
    | if_stmt_continue ELIF test COLON suite
    {
        string temp = string("ELIF (") + $2 + ")";
        $$ = createNode("if_stmt_continue");
        $$->children.push_back($1);
        $$->children.push_back(createNode(temp));
        $$->children.push_back($3);
        temp = string("COLON (") + $4 + ")";
        $$->children.push_back(createNode(temp));
        $$->children.push_back($5);
    }
    ;

f_cond_stmt:
     
    {
        $$ = NULL;
        // $$->children.push_back(createNode("EMPTY"));
    }
    | ELSE COLON suite
    {
        string temp = string("ELSE (") + $1 + ")";
        $$ = createNode("f_cond_stmt");
        $$->children.push_back(createNode(temp));
        temp = string("COLON (") + $2 + ")";
        $$->children.push_back(createNode(temp));
        $$->children.push_back($3);
    }
    ;

while_stmt: 
    WHILE test COLON suite f_cond_stmt
    {
        string temp = string("WHILE (") + $1 + ")";
        $$ = createNode("while_stmt");
        $$->children.push_back(createNode(temp));
        $$->children.push_back($2);
        temp = string("COLON (") + $3 + ")";
        $$->children.push_back(createNode(temp));
        $$->children.push_back($4);
        $$->children.push_back($5);
    }
    ;

for_stmt: 
    FOR exprlist IN testlist COLON suite f_cond_stmt
    {
        string temp = string("FOR (") + $1 + ")";
        $$ = createNode("for_stmt");
        $$->children.push_back(createNode(temp));
        $$->children.push_back($2);
        temp = string("IN (") + $3 + ")";
        $$->children.push_back(createNode(temp));
        $$->children.push_back($4);
        temp = string("COLON (") + $5 + ")";
        $$->children.push_back(createNode(temp));
        $$->children.push_back($6);
        $$->children.push_back($7);
    }
    ;

suite: 
    simple_stmt{
        $$ = $1;
        // createNode("suite");
        // $$->children.push_back($1);
    }
    | INDENT stmt f_suite DEDENT
    {
        if($2 == NULL && $3 == NULL){
            $$ = NULL;
        }
        else{
            if($2 == NULL){
                $$ = $3;
            }
            else if($3 == NULL){
                $$ = $2;
            }
            else{
                $$ = createNode("suite");
                // $$->children.push_back(createNode($1));
                $$->children.push_back($2);
                $$->children.push_back($3);
                // $$->children.push_back(createNode($4));
            }
        }
    }
    ;

f_suite: 
       
    {
        $$ = NULL;
        // $$->children.push_back(createNode("EMPTY"));
    }
    | f_suite stmt
    {
        if($1 == NULL && $2 == NULL){
            $$ = NULL;
        }
        else{
            if($1 == NULL){
                $$ = $2;
            }
            else if($2 == NULL){
                $$ = $1;
            }
            else{
                $$ = createNode("f_suite");
                $$->children.push_back($1);
                $$->children.push_back($2);
            }
        }
    }
    ;

test:
    or_test f_test
    {
        if($1 == NULL && $2 == NULL){
            $$ = NULL;
        }
        else{
            if($1 == NULL){
                $$ = $2;
            }
            else if($2 == NULL){
                $$ = $1;
            }
            else{
                $$ = createNode("test");
                $$->children.push_back($1);
                $$->children.push_back($2);
            }
        }
    }
    ;

f_test:
     
    {
        $$ = NULL;
        // $$->children.push_back(createNode("EMPTY"));
    }
    | IF or_test ELSE test
    {
        string temp = string("IF (") + $1 + ")";
        $$ = createNode("f_test");
        $$->children.push_back(createNode(temp));
        $$->children.push_back($2);
        temp = string("ELSE (") + $3 + ")";
        $$->children.push_back(createNode(temp));
        $$->children.push_back($4);
    }
    ;

test_nocond:
    or_test 
    {
        $$ = $1;
        // createNode("test_nocond");
        // $$->children.push_back($1);
    }
    ;

or_test: 
    and_test
    {
        $$ = $1;
        // createNode("or_test");
        // $$->children.push_back($1);
    }
    | or_test OR and_test
    {
        string temp = string("OR (") + $2 + ")";
        if($1 == NULL && $3 == NULL){
            $$ = createNode(temp);
        }
        else{
            $$ = createNode("or_test");
            $$->children.push_back($1);
            $$->children.push_back(createNode(temp));
            $$->children.push_back($3);
        }
    }
    ;

and_test: 
    not_test
    {
        $$ = $1;
        // createNode("and_test");
        // $$->children.push_back($1);
    }
    | and_test AND not_test
    {
        string temp = string("AND (") + $2 + ")";
        if($1 == NULL && $3 == NULL){
            $$ = createNode(temp);
        }
        else{
            $$ = createNode("and_test");
            $$->children.push_back($1);
            $$->children.push_back(createNode(temp));
            $$->children.push_back($3);
        }
    }
    ;

not_test: 
    NOT not_test
    {
        string temp = string("NOT (") + $1 + ")";
        if($2 == NULL){
            $$ = createNode(temp);
        }
        else{
            $$ = createNode("not_test");
            $$->children.push_back(createNode(temp));
            $$->children.push_back($2);
        }
    }
    | comparison
    {
        $$ = $1;
        // createNode("not_test");
        // $$->children.push_back($1);
    }
    ;

comparison: 
    expr
    {
        $$ = $1;
        // createNode("comparison");
        // $$->children.push_back($1);
    }
    | comparison comp_op expr
    {
        if($1 == NULL && $2 == NULL && $3 == NULL){
            $$ = NULL;
        }
        else{
            if($1 == NULL && $2 == NULL){
                $$ = $3;
            }
            else if($1 == NULL && $3 == NULL){
                $$ = $2;
            }
            else if($2 == NULL && $3 == NULL){
                $$ = $1;
            }
            else{
                $$ = createNode("comparison");
                $$->children.push_back($1);
                $$->children.push_back($2);
                $$->children.push_back($3);
            }
        }
    }
    ;

comp_op: 
    LESSTHAN
    {
        string temp = string("LESSTHAN (") + $1 + ")";
        $$ = createNode(temp);
        // createNode("comp_op");
        // $$->children.push_back(createNode($1));
    }
    | GREATERTHAN
    {
        string temp = string("GREATERTHAN (") + $1 + ")";
        $$ = createNode(temp);
        // createNode("comp_op");
        // $$->children.push_back(createNode($1));
    }
    | EQEQUAL
    {
        string temp = string("EQEQUAL (") + $1 + ")";
        $$ = createNode(temp);
        // createNode("comp_op");
        // $$->children.push_back(createNode($1));
    }
    | GREATEREQUAL
    {
        string temp = string("GREATEREQUAL (") + $1 + ")";
        $$ = createNode(temp);
        // createNode("comp_op");
        // $$->children.push_back(createNode($1));
    }
    | LESSEQUAL
    {
        string temp = string("LESSEQUAL (") + $1 + ")";
        $$ = createNode(temp); 
        // createNode("comp_op");
        // $$->children.push_back(createNode($1));
    }
    | NOTEQUAL
    {
        string temp = string("NOTEQUAL (") + $1 + ")";
        $$ = createNode(temp);
        // createNode("comp_op");
        // $$->children.push_back(createNode($1));
    }
    | IN
    {
        string temp = string("IN (") + $1 + ")";
        $$ = createNode(temp);
        // createNode("comp_op");
        // $$->children.push_back(createNode($1));
    }
    | NOT IN
    {
        string temp = string("NOT (") + $1 + ")";
        $$ = createNode("comp_op");
        $$->children.push_back(createNode(temp));
        temp = string("IN (") + $2 + ")";
        $$->children.push_back(createNode(temp));
    }
    | IS
    {
        string temp = string("IS (") + $1 + ")";
        $$ = createNode(temp);
        // createNode("comp_op");
        // $$->children.push_back(createNode($1));
    }
    | IS NOT
    {
        string temp = string("IS (") + $1 + ")";
        $$ = createNode("comp_op");
        $$->children.push_back(createNode(temp));
        temp = string("NOT (") + $2 + ")";
        $$->children.push_back(createNode(temp));
    }
    ;

star_expr:
    STAR expr
    {
        string temp = string("STAR (") + $1 + ")";
        if($2 == NULL){
            $$ = createNode(temp);
        }
        else{
            $$ = createNode("star_expr");
            $$->children.push_back(createNode(temp));
            $$->children.push_back($2);
        }
    }
    ;

expr: 
    xor_expr
    {
        $$ = $1;
        // createNode("expr");
        // $$->children.push_back($1);
    }
    | expr VBAR xor_expr
    {
        string temp = string("VBAR (") + $2 + ")";
        if($1 == NULL && $3 == NULL){
            $$ = createNode(temp);
        }
        else{
            $$ = createNode("expr");
            $$->children.push_back($1);
            $$->children.push_back(createNode(temp));
            $$->children.push_back($3);
        }
    }
    ;

xor_expr: 
    and_expr
    {
        $$ = $1;
        // createNode("xor_expr");
        // $$->children.push_back($1);
    }
    | xor_expr CIRCUMFLEX and_expr
    {
        string temp = string("CIRCUMFLEX (") + $2 + ")";
        if($1 == NULL && $3 == NULL){
            $$ = createNode(temp);
        }
        else{
            $$ = createNode("xor_expr");
            $$->children.push_back($1);
            $$->children.push_back(createNode(temp));
            $$->children.push_back($3);
        }
    }
    ;

and_expr: 
    shift_expr
    {
        $$ = $1;
        // createNode("and_expr");
        // $$->children.push_back($1);
    }
    | and_expr AMPERSAND shift_expr
    {
        string temp = string("AMPERSAND (") + $2 + ")";
        if($1 == NULL && $3 == NULL){
            $$ = createNode(temp);
        }
        else{
            $$ = createNode("and_expr");
            $$->children.push_back($1);
            $$->children.push_back(createNode(temp));
            $$->children.push_back($3);
        }
    }
    ;

shift_expr: 
    arith_expr
    {
        $$ = $1;
        // createNode("shift_expr");
        // $$->children.push_back($1);
    }
    | shift_expr f_shift_expr
    {
        if($1 == NULL && $2 == NULL){
            $$ = NULL;
        }
        else{
            if($1 == NULL){
                $$ = $2;
            }
            else if($2 == NULL){
                $$ = $1;
            }
            else{
                $$ = createNode("shift_expr");
                $$->children.push_back($1);
                $$->children.push_back($2);
            }
        }
    }
    ;

f_shift_expr:
    LEFTSHIFT arith_expr
    {
        string temp = string("LEFTSHIFT (") + $1 + ")";
        if($2 == NULL){
            $$ = createNode(temp);
        }
        else{
            $$ = createNode("f_shift_expr");
            $$->children.push_back(createNode(temp));
            $$->children.push_back($2);
        }
    }
    | RIGHTSHIFT arith_expr
    {
        string temp = string("RIGHTSHIFT (") + $1 + ")";
        if($2 == NULL){
            $$ = createNode(temp);
        }
        else{
            $$ = createNode("f_shift_expr");
            $$->children.push_back(createNode(temp));
            $$->children.push_back($2);
        }
    }
    ;

arith_expr: 
    term
    {
        $$ = $1;
        // createNode("arith_expr");
        // $$->children.push_back($1);
    }
    | arith_expr f_arith_expr
    {
        if($1 == NULL && $2 == NULL){
            $$ = NULL;
        }
        else{
            if($1 == NULL){
                $$ = $2;
            }
            else if($2 == NULL){
                $$ = $1;
            }
            else{
               
                int cnt = 0;
                for(auto it: $2 -> children){
                    if(cnt == 0){
                        $$ = createNode(it->valy);
                        $$->children.push_back($1);
                        cnt++;
                        continue;
                    }
                    $$->children.push_back(it);
                }
                
            }
        }
    }
    ;

f_arith_expr:
    PLUS term
    {
        string temp = string("PLUS (") + $1 + ")";
        if($2 == NULL){
            $$ = createNode(temp);
        }
        else{

            $$ = createNode("f_arith_expr");
            $$->children.push_back(createNode(temp));
            $$->children.push_back($2);
        }
    }
    | MINUS term
    {
        string temp = string("MINUS (") + $1 + ")";
        if($2 == NULL){
            $$ = createNode(temp);
        }
        else{
            $$ = createNode("f_arith_expr");
            $$->children.push_back(createNode(temp));
            $$->children.push_back($2);
        }
    }
    ;

term: 
    factor
    {
        $$ = $1;
        // createNode("term");
        // $$->children.push_back($1);
    }
    | term f_term
    {
        if($1 == NULL && $2 == NULL){
            $$ = NULL;
        }
        else{
            if($1 == NULL){
                $$ = $2;
            }
            else if($2 == NULL){
                $$ = $1;
            }
            else{
                int cnt = 0;
                for(auto it: $2->children){
                    if(cnt == 0){
                        $$ = createNode(it->valy);
                        $$->children.push_back($1);
                        cnt++;
                        continue;
                    }
                    $$->children.push_back(it);
                }
                
            }
        }
    }
    ;

f_term:
    STAR factor
    {
        string temp = string("STAR (") + $1 + ")";
        if($2 == NULL){
            $$ = createNode(temp);
        }
        else{
            $$ = createNode("f_term");
            $$->children.push_back(createNode(temp));
            $$->children.push_back($2);
        }
    }
    | SLASH factor
    {
        string temp = string("SLASH (") + $1 + ")";
        if($2 == NULL){
            $$ = createNode(temp);
        }
        else{
            $$ = createNode("f_term");
            $$->children.push_back(createNode(temp));
            $$->children.push_back($2);
        }
    }
    | PERCENT factor
    {
        string temp = string("PERCENT (") + $1 + ")";
        if($2 == NULL){
            $$ = createNode(temp);
        }
        else{
            $$ = createNode("f_term");
            $$->children.push_back(createNode(temp));
            $$->children.push_back($2);
        }
    }
    | DOUBLESLASH factor
    {
        string temp = string("DOUBLESLASH (") + $1 + ")";
        if($2 == NULL){
            $$ = createNode(temp);
        }
        else{
            $$ = createNode("f_term");
            $$->children.push_back(createNode(temp));
            $$->children.push_back($2);
        }
    }

factor: 
    power
    {
        $$ = $1;
        // createNode("factor");
        // $$->children.push_back($1);
    }
    | PLUS factor
    {
        string temp = string("PLUS (") + $1 + ")";
        if($2 == NULL){
            $$ = createNode(temp);
        }
        else{
            $$ = createNode("factor");
            $$->children.push_back(createNode(temp));
            $$->children.push_back($2);
        }
    }
    | MINUS factor
    {
        string temp = string("MINUS (") + $1 + ")";
        if($2 == NULL){
            $$ = createNode(temp);
        }
        else{
            $$ = createNode("factor");
            $$->children.push_back(createNode(temp));
            $$->children.push_back($2);
        }
    }
    | TILDE factor
    {
        string temp = string("TILDE (") + $1 + ")";
        if($2 == NULL){
            $$ = createNode(temp);
        }
        else{
            $$ = createNode("factor");
            $$->children.push_back(createNode(temp));
            $$->children.push_back($2);
        }
    }
    ;

power: 
    atom_expr f_power
    {
        if($1 == NULL && $2 == NULL){
            $$ = NULL;
        }
        else{
            if($1 == NULL){
                $$ = $2;
            }
            else if($2 == NULL){
                $$ = $1;
            }
            else{
                $$ = createNode("power");
                $$->children.push_back($1);
                $$->children.push_back($2);
            }
        }
    }
    ;

f_power:
     
    {
        $$ = NULL;
        // $$->children.push_back(createNode("EMPTY"));
    }
    | DOUBLESTAR factor
    {
        string temp = string("DOUBLESTAR (") + $1 + ")";
        if($2 == NULL){
            $$ = createNode(temp);
        }
        else{
            $$ = createNode("f_power");
            $$->children.push_back(createNode(temp));
            $$->children.push_back($2);
        }
    }
    ;

atom_expr: 
    atom
    {
        $$ = $1;
        // createNode("atom_expr");
        // $$->children.push_back($1);
    }
    | atom_expr trailer
    {
        if($1 == NULL && $2 == NULL){
            $$ = NULL;
        }
        else{
            if($1 == NULL){
                $$ = $2;
            }
            else if($2 == NULL){
                $$ = $1;
            }
            else{
                $$ = createNode("atom_expr");
                $$->children.push_back($1);
                $$->children.push_back($2);
            }
        }
    }
    ;

atom: 
    LPAREN f_atom_LPAREN
    {
        string temp = string("LPAREN (") + $1 + ")";
        if($2 == NULL){
            $$ = createNode(temp);
        }
        else{
            $$ = createNode("atom");
            $$->children.push_back(createNode(temp));
            $$->children.push_back($2);
        }
    }
    | LBRACKET f_atom_LBRACKET
    {
        string temp = string("LBRACKET (") + $1 + ")";
        if($2 == NULL){
            $$ = createNode(temp);
        }
        else{
            $$ = createNode("atom");
            $$->children.push_back(createNode(temp));
            $$->children.push_back($2);
        }
    }
    | NAME
    {
        string temp = string("NAME (") + $1 + ")";
        $$ = createNode(temp);
        // createNode("atom");
        // $$->children.push_back(createNode($1));
    }
    | NUMBER
    {
        string temp = string("NUMBER (") + $1 + ")";
        $$ = createNode(temp);
        // createNode("atom");
        // $$->children.push_back(createNode($1));
    }
    | string_continue
    {
        $$ = $1;
        // createNode("atom");
        // $$->children.push_back($1);
    }
    | NONE
    {
        string temp = string("NONE (") + $1 + ")";
        $$ = createNode(temp);
        // createNode("atom");
        // $$->children.push_back(createNode($1));
    }
    | TRUEE
    {
        string temp = string("TRUE (") + $1 + ")";
        $$ = createNode(temp);
        // createNode("atom");
        // $$->children.push_back(createNode($1));
    }
    | FALSEE
    {
        string temp = string("FALSE (") + $1 + ")";
        $$ = createNode(temp);
        // createNode("atom");
        // $$->children.push_back(createNode($1));
    }
    ;

f_atom_LPAREN:
    RPAREN
    {
        string temp = string("RPAREN (") + $1 + ")";
        $$ = createNode(temp);
        // createNode("f_atom_LPAREN");
        // $$->children.push_back(createNode($1));
    }
    | testlist_comp RPAREN
    {
        string temp = string("RPAREN (") + $2 + ")";
        if($1 == NULL){
            $$ = createNode(temp);
        }
        else{
            $$ = createNode("f_atom_LPAREN");
            $$->children.push_back($1);
            $$->children.push_back(createNode(temp));
        }
    }
    ;

f_atom_LBRACKET:
    RBRACKET
    {
        string temp = string("RBRACKET (") + $1 + ")";
        $$ = createNode(temp);
        // createNode("f_atom_LBRACKET");
        // $$->children.push_back(createNode($1));
    }
    | testlist_comp RBRACKET
    {
        string temp = string("RBRACKET (") + $2 + ")";
        if($1 == NULL){
            $$ = createNode(temp);
        }
        else{
            $$ = createNode("f_atom_LBRACKET");
            $$->children.push_back($1);
            $$->children.push_back(createNode(temp));
        }
    }
    ;

string_continue:
    string_continue STRING
    {
        string temp = string("STRING (") + $2 + ")";
        if($1 == NULL){
            $$ = createNode(temp);
        }
        else{
            $$ = createNode("string_continue");
            $$->children.push_back($1);
            $$->children.push_back(createNode(temp));
        }
    }
    | STRING
    {
        string temp = string("STRING (") + $1 + ")";
        $$ = createNode(temp);
        // createNode("string_continue");
        // $$->children.push_back(createNode($1));
    }
    ;

testlist_comp: 
    test f_testlist_comp_test
    {
        if($1 == NULL && $2 == NULL){
            $$ = NULL;
        }
        else{
            if($1 == NULL){
                $$ = $2;
            }
            else if($2 == NULL){
                $$ = $1;
            }
            else{
                $$ = createNode("testlist_comp");
                $$->children.push_back($1);
                $$->children.push_back($2);
            }
        }
    }
    | star_expr f_testlist_comp_test
    {
        if($1 == NULL && $2 == NULL){
            $$ = NULL;
        }
        else{
            if($1 == NULL){
                $$ = $2;
            }
            else if($2 == NULL){
                $$ = $1;
            }
            else{
                $$ = createNode("testlist_comp");
                $$->children.push_back($1);
                $$->children.push_back($2);
            }
        }
    }
    ;

f_testlist_comp_test:
    comp_for
    {
        $$ = $1;
        // createNode("f_testlist_comp_test");
        // $$->children.push_back($1);
    }
    | testlist_comp_continue f_comma
    {
        if($1 == NULL && $2 == NULL){
            $$ = NULL;
        }
        else{
            if($1 == NULL){
                $$ = $2;
            }
            else if($2 == NULL){
                $$ = $1;
            }
            else{
                $$ = createNode("f_testlist_comp_test");
                $$->children.push_back($1);
                $$->children.push_back($2);
            }
        }
    }
    ;

testlist_comp_continue:
    testlist_comp_continue COMMA f_test_star_expr_continue
    {
        string temp = string("COMMA (") + $2 + ")";
        if($1 == NULL && $3 == NULL){
            $$ = createNode(temp);
        }
        else{
            $$ = createNode("testlist_comp_continue");
            
            if($1 != NULL){
                for(auto it: $1->children){
                    $$->children.push_back(it);
                }
            }
            $$->children.push_back(createNode(temp));
            $$->children.push_back($3);
        }
    }
    |  
    {
        $$ = NULL;
        // $$->children.push_back(createNode("EMPTY"));
    }
    ;

f_test_star_expr_continue:
    test
    {
        $$ = $1;
        // createNode("f_test_star_expr_continue");
        // $$->children.push_back($1);
    }
    | star_expr
    {
        $$ = $1;
        // createNode("f_test_star_expr_continue");
        // $$->children.push_back($1);
    }
    ;

trailer: 
    LPAREN f_trailer
    {
        string temp = string("LPAREN (") + $1 + ")";
        if($2 == NULL){
            $$ = createNode(temp);
        }
        else{
            $$ = createNode("trailer");
            $$->children.push_back(createNode(temp));
            vector<Node*> tempchild = $2->children;
            if(tempchild.size()==0)
                $$->children.push_back($2);
            else{
                for(auto it: $2->children){
                    $$->children.push_back(it);
                }
            }
            
        }
    }
    | LBRACKET subscriptlist RBRACKET
    {
        string temp = string("LBRAKET (") + $1 + ")";
        $$ = createNode("trailer");
        $$->children.push_back(createNode(temp));
        $$->children.push_back($2);
        temp = string("RBRACKET (") + $3 + ")";
        $$->children.push_back(createNode(temp));
    }
    | DOT NAME
    {
        string temp = string("DOT (") + $1 + ")";
        $$ = createNode("trailer");
        $$->children.push_back(createNode(temp));
        temp = string("NAME (") + $2 + ")";
        $$->children.push_back(createNode(temp));
    }
    ;

f_trailer:
    RPAREN
    {
        string temp = string("RPAREN (") + $1 + ")";
        $$ = createNode(temp);
        // createNode("f_trailer");
        // $$->children.push_back(createNode($1));
    }
    | arglist RPAREN
    {
        string temp = string("RPAREN (") + $2 + ")";
        if($1 == NULL){
            $$ = createNode(temp);
        }
        else{
            $$ = createNode("f_trailer");
            $$->children.push_back($1);
            $$->children.push_back(createNode(temp));
        }
    }
    ;

subscriptlist:
    test subscript_list_continue f_comma
    {
        if($1 == NULL && $2 == NULL && $3 == NULL){
            $$ = NULL;
        }
        else{
            if($1 == NULL && $2 == NULL){
                $$ = $3;
            }
            else if($1 == NULL && $3 == NULL){
                $$ = $2;
            }
            else if($2 == NULL && $3 == NULL){
                $$ = $1;
            }
            else{
                $$ = createNode("subscriptlist");
                $$->children.push_back($1);
                $$->children.push_back($2);
                $$->children.push_back($3);
            }
        }
    }
    ;

subscript_list_continue:
    subscript_list_continue COMMA test
    {
        string temp = string("COMMA (") + $2 + ")";
        if($1 == NULL && $3 == NULL){
            $$ = createNode(temp);
        }
        else{
            $$ = createNode("subscript_list_continue");
            $$->children.push_back($1);
            $$->children.push_back(createNode(temp));
            $$->children.push_back($3);
        }
    }
    |  
    {
        $$ = NULL;
        // $$->children.push_back(createNode("EMPTY"));
    }
    ;

exprlist: 
    exprlist_continue exprlist_continue_continue f_comma
    {
        if($1 == NULL && $2 == NULL && $3 == NULL){
            $$ = NULL;
        }
        else{
            if($1 == NULL && $2 == NULL){
                $$ = $3;
            }
            else if($1 == NULL && $3 == NULL){
                $$ = $2;
            }
            else if($2 == NULL && $3 == NULL){
                $$ = $1;
            }
            else{
                $$ = createNode("exprlist");
                $$->children.push_back($1);
                $$->children.push_back($2);
                $$->children.push_back($3);
            }
        }
    }

exprlist_continue:
    expr
    {
        $$ = $1;
        // createNode("exprlist_continue");
        // $$->children.push_back($1);
    }
    | star_expr
    {
        $$ = $1;
        // createNode("exprlist_continue");
        // $$->children.push_back($1);
    }
    ;

exprlist_continue_continue:
    exprlist_continue_continue COMMA exprlist_continue
    {
        string temp = string("COMMA (") + $2 + ")";
        if($1 == NULL && $3 == NULL){
            $$ = createNode(temp);
        }
        else{
            $$ = createNode("exprlist_continue_continue");
            $$->children.push_back($1);
            $$->children.push_back(createNode(temp));
            $$->children.push_back($3);
        }
    }
    |  
    {
        $$ = NULL;
        // $$->children.push_back(createNode("EMPTY"));
    }
    ;

testlist:
    test testlist_continue f_comma
    {
        if($1 == NULL && $2 == NULL && $3 == NULL){
            $$ = NULL;
        }
        else{
            if($1 == NULL && $2 == NULL){
                $$ = $3;
            }
            else if($1 == NULL && $3 == NULL){
                $$ = $2;
            }
            else if($2 == NULL && $3 == NULL){
                $$ = $1;
            }
            else{
                $$ = createNode("testlist");
                $$->children.push_back($1);
                $$->children.push_back($2);
                $$->children.push_back($3);
            }
        }
    }
    ; 

testlist_continue:
    testlist_continue COMMA test
    {
        string temp = string("COMMA (") + $2 + ")";
        if($1 == NULL && $3 == NULL){
            $$ = createNode(temp);
        }
        else{
            $$ = createNode("testlist_continue");
            $$->children.push_back($1);
            $$->children.push_back(createNode(temp));
            $$->children.push_back($3);
        }
    }
    |  
    {
        $$ = NULL;
        // $$->children.push_back(createNode("EMPTY"));
    }
    ;

classdef:
    CLASS NAME f_classdef
    {
        string temp = string("CLASS (") + $1 + ")";
        $$ = createNode("classdef");
        $$->children.push_back(createNode(temp));
        temp = string("NAME (") + $2 + ")";
        $$->children.push_back(createNode(temp));
        $$->children.push_back($3);
    }
    ;

f_classdef:
    COLON suite
    {
        string temp = string("COLON (") + $1 + ")";
        if($2 == NULL){
            $$ = createNode(temp);
        }
        else{
            $$ = createNode("f_classdef");
            $$->children.push_back(createNode(temp));
            $$->children.push_back($2);
        }
    }
    | LPAREN f_f_classdef
    {
        string temp = string("LPAREN (") + $1 + ")";
        if($2 == NULL){
            $$ = createNode(temp);
        }
        else{
            $$ = createNode("f_classdef");
            $$->children.push_back(createNode(temp));
            $$->children.push_back($2);
        }
    }
    ;

f_f_classdef:
    RPAREN COLON suite
    {
        string temp = string("RPAREN (") + $1 + ")";
        $$ = createNode("f_f_classdef");
        $$->children.push_back(createNode(temp));
        temp = string("COLON (") + $2 + ")";
        $$->children.push_back(createNode(temp));
        $$->children.push_back($3);
    }
    | arglist RPAREN COLON suite
    {
        string temp = string("RPAREN (") + $2 + ")";
        $$ = createNode("f_f_classdef");
        $$->children.push_back($1);
        $$->children.push_back(createNode(temp));
        temp = string("COLON (") + $3 + ")";
        $$->children.push_back(createNode(temp));
        $$->children.push_back($4);
    }
    ;
arglist: 
    argument arglist_continue f_comma
    {
        if($1 == NULL && $2 == NULL && $3 == NULL){
            $$ = NULL;
        }
        else{
            if($1 == NULL && $2 == NULL){
                $$ = $3;
            }
            else if($1 == NULL && $3 == NULL){
                $$ = $2;
            }
            else if($2 == NULL && $3 == NULL){
                $$ = $1;
            }
            else{
                $$ = createNode("arglist");
                $$->children.push_back($1);
                $$->children.push_back($2);
                $$->children.push_back($3);
            }
        }
    }
    ;

f_comma:
     
    {
        $$ = NULL;
        // $$->children.push_back(createNode("EMPTY"));
    }
    | COMMA
    {
        string temp = string("COMMA (") + $1 + ")";
        $$ = createNode(temp);
        // $$ = createNode("f_comma");
        // $$->children.push_back(createNode($1));
    }
    ;

arglist_continue:
    arglist_continue COMMA argument
    {
        string temp = string("COMMA (") + $2 + ")";
        if($1 == NULL && $3 == NULL){
            $$ = createNode(temp);
        }
        else{
            $$ = createNode("arglist_continue");
            $$->children.push_back($1);
            $$->children.push_back(createNode(temp));
            $$->children.push_back($3);
        }
    }
    |  
    {
        $$ = NULL;
        // $$->children.push_back(createNode("EMPTY"));
    }
    ;

argument:
    test f_argument
    {
        if($1 == NULL && $2 == NULL){
            $$ = NULL;
        }
        else{
            if($1 == NULL){
                $$ = $2;
            }
            else if($2 == NULL){
                $$ = $1;
            }
            else{
                $$ = createNode("argument");
                $$->children.push_back($1);
                $$->children.push_back($2);
            }
        }
    }
    | DOUBLESTAR test
    {
        string temp = string("DOUBLESTAR (") + $1 + ")";
        if($2 == NULL){
            $$ = createNode(temp);
        }
        else{
            $$ = createNode("argument");
            $$->children.push_back(createNode(temp));
            $$->children.push_back($2);
        }
    }
    | STAR test
    {
        string temp = string("STAR (") + $1 + ")";
        if($2 == NULL){
            $$ = createNode(temp);
        }
        else{
            $$ = createNode("argument");
            $$->children.push_back(createNode(temp));
            $$->children.push_back($2);
        }
    }
    ;

f_argument:
     
    {
        $$ = NULL;
        // $$->children.push_back(createNode("EMPTY"));
    }
    | EQUALS test
    {
        string temp = string("EQUALS (") + $1 + ")";
        if($2 == NULL){
            $$ = createNode(temp);
        }
        else{
            $$ = createNode("f_argument");
            $$->children.push_back(createNode(temp));
            $$->children.push_back($2);
        }
    }
    | comp_for
    {
        $$ = $1;
        // createNode("f_argument");
        // $$->children.push_back($1);
    }
    ;

comp_iter: 
    comp_for
    {
        $$ = $1;
        // createNode("comp_iter");
        // $$->children.push_back($1);
    }
    | comp_if
    {
        $$ = $1;
        // createNode("comp_iter");
        // $$->children.push_back($1);
    }
    ;

comp_for:
    FOR exprlist IN or_test f_comp_cond
    {
        string temp = string("FOR (") + $1 + ")";
        $$ = createNode("comp_for");
        $$->children.push_back(createNode(temp));
        $$->children.push_back($2);
        temp = string("IN (") + $3 + ")";
        $$->children.push_back(createNode(temp));
        $$->children.push_back($4);
        $$->children.push_back($5);
    }
    ;


comp_if:
    IF test_nocond f_comp_cond
    {
        string temp = string("IF (") + $1 + ")";
        if($2 == NULL && $3 == NULL){
            $$ = createNode(temp);
        }
        else{
            $$ = createNode("comp_if");
            $$->children.push_back(createNode(temp));
            $$->children.push_back($2);
            $$->children.push_back($3);
        }
    }
    ;

f_comp_cond:
     
    {
        $$ = NULL;
        // $$->children.push_back(createNode("EMPTY"));
    }
    | comp_iter
    {
        $$ = $1;
        // createNode("f_comp_cond");
        // $$->children.push_back($1);
    }
    ;

%%

string escapeDOT(const string& label) {
    string escaped;
    for (char c : label) {
        if (c == '\"') escaped += "\\\"";
        else escaped += c;
    }
    return escaped;
}

void generateDOT(Node* node, ofstream& fout, const string& parentID = "", bool isRoot = true) {
    if (!node) return; 

    // Generate a unique identifier using the node's ID
    string nodeID = "\"" + escapeDOT(node->valy) + "_" + to_string(node->id) + "\"";

    // Print the node definition with its unique identifier and label
    fout << "    " << nodeID << " [label=\"" << escapeDOT(node->valy) << "\"];" << endl;

    // If not the root, print the edge from the parent to this node
    if (!isRoot) {
        fout << "    " << parentID << " -> " << nodeID << ";" << endl;
    }

    // Recursively process all children, passing the current node's ID as the new parentID
    for (Node* child : node->children) {
        generateDOT(child, fout, nodeID, false);
    }
}

int main(){
    yyin = fopen("input.txt", "r");

    yyparse();
    
    fout << "digraph G {" << endl;
    fout<<"node [ordering=out]\n";

    generateDOT(root, fout);
    fout << "}" << endl;
    fout.close();
    return 0;
}

void yyerror(const char *s){
    cerr<<"\nError found at line number: "<<yylineno<<"\n"<<s<<"\n";
    exit(1);
}