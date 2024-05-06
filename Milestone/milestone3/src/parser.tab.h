/* A Bison parser, made by GNU Bison 3.8.2.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015, 2018-2021 Free Software Foundation,
   Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <https://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* DO NOT RELY ON FEATURES THAT ARE NOT DOCUMENTED in the manual,
   especially those whose name start with YY_ or yy_.  They are
   private implementation details that can be changed or removed.  */

#ifndef YY_YY_PARSER_TAB_H_INCLUDED
# define YY_YY_PARSER_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token kinds.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    YYEMPTY = -2,
    YYEOF = 0,                     /* "end of file"  */
    YYerror = 256,                 /* error  */
    YYUNDEF = 257,                 /* "invalid token"  */
    NUMBER = 258,                  /* NUMBER  */
    STRING = 259,                  /* STRING  */
    NAME = 260,                    /* NAME  */
    INDENT = 261,                  /* INDENT  */
    DEDENT = 262,                  /* DEDENT  */
    FROM = 263,                    /* FROM  */
    DEF = 264,                     /* DEF  */
    CLASS = 265,                   /* CLASS  */
    IF = 266,                      /* IF  */
    IN = 267,                      /* IN  */
    IS = 268,                      /* IS  */
    ELSE = 269,                    /* ELSE  */
    ELIF = 270,                    /* ELIF  */
    WHILE = 271,                   /* WHILE  */
    FOR = 272,                     /* FOR  */
    RETURN = 273,                  /* RETURN  */
    BREAK = 274,                   /* BREAK  */
    CONTINUE = 275,                /* CONTINUE  */
    TRUEE = 276,                   /* TRUEE  */
    FALSEE = 277,                  /* FALSEE  */
    NONE = 278,                    /* NONE  */
    ASSERT = 279,                  /* ASSERT  */
    GLOBAL = 280,                  /* GLOBAL  */
    NONLOCAL = 281,                /* NONLOCAL  */
    RAISE = 282,                   /* RAISE  */
    AND = 283,                     /* AND  */
    OR = 284,                      /* OR  */
    NOT = 285,                     /* NOT  */
    PLUSEQUAL = 286,               /* PLUSEQUAL  */
    MINEQUAL = 287,                /* MINEQUAL  */
    DOUBLESTAREQUAL = 288,         /* DOUBLESTAREQUAL  */
    STAREQUAL = 289,               /* STAREQUAL  */
    DOUBLESLASHEQUAL = 290,        /* DOUBLESLASHEQUAL  */
    SLASHEQUAL = 291,              /* SLASHEQUAL  */
    PERCENTEQUAL = 292,            /* PERCENTEQUAL  */
    AMPERSANDEQUAL = 293,          /* AMPERSANDEQUAL  */
    VBAREQUAL = 294,               /* VBAREQUAL  */
    CIRCUMFLEXEQUAL = 295,         /* CIRCUMFLEXEQUAL  */
    ATEQUAL = 296,                 /* ATEQUAL  */
    LEFTSHIFTEQUAL = 297,          /* LEFTSHIFTEQUAL  */
    RIGHTSHIFTEQUAL = 298,         /* RIGHTSHIFTEQUAL  */
    LEFTSHIFT = 299,               /* LEFTSHIFT  */
    RIGHTSHIFT = 300,              /* RIGHTSHIFT  */
    EQEQUAL = 301,                 /* EQEQUAL  */
    NOTEQUAL = 302,                /* NOTEQUAL  */
    LESSEQUAL = 303,               /* LESSEQUAL  */
    LESSTHAN = 304,                /* LESSTHAN  */
    GREATEREQUAL = 305,            /* GREATEREQUAL  */
    GREATERTHAN = 306,             /* GREATERTHAN  */
    DOUBLESTAR = 307,              /* DOUBLESTAR  */
    ARROW = 308,                   /* ARROW  */
    PLUS = 309,                    /* PLUS  */
    MINUS = 310,                   /* MINUS  */
    STAR = 311,                    /* STAR  */
    DOUBLESLASH = 312,             /* DOUBLESLASH  */
    SLASH = 313,                   /* SLASH  */
    EQUALS = 314,                  /* EQUALS  */
    LPAREN = 315,                  /* LPAREN  */
    RPAREN = 316,                  /* RPAREN  */
    LBRACKET = 317,                /* LBRACKET  */
    RBRACKET = 318,                /* RBRACKET  */
    LBRACE = 319,                  /* LBRACE  */
    RBRACE = 320,                  /* RBRACE  */
    COLON = 321,                   /* COLON  */
    SEMICOLON = 322,               /* SEMICOLON  */
    COMMA = 323,                   /* COMMA  */
    DOT = 324,                     /* DOT  */
    VBAR = 325,                    /* VBAR  */
    CIRCUMFLEX = 326,              /* CIRCUMFLEX  */
    AMPERSAND = 327,               /* AMPERSAND  */
    AT = 328,                      /* AT  */
    PERCENT = 329,                 /* PERCENT  */
    TILDE = 330,                   /* TILDE  */
    QUOTE = 331,                   /* QUOTE  */
    DOUBLEQUOTE = 332,             /* DOUBLEQUOTE  */
    NEWLINE = 333,                 /* NEWLINE  */
    ENDMARKER = 334                /* ENDMARKER  */
  };
  typedef enum yytokentype yytoken_kind_t;
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
union YYSTYPE
{
#line 34 "parser.y"

    char* stringr;
    struct Node* node;

#line 148 "parser.tab.h"

};
typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;


int yyparse (void);


#endif /* !YY_YY_PARSER_TAB_H_INCLUDED  */
