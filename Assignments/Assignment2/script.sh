#!/bin/bash

bison  -d parser.y
flex -o lexer.c lexer.l
g++ parser.tab.c lexer.c -lfl
./a.out < tesfile.txt 
