#!/bin/bash

# Fixed names for parser and lexer source files
PARSER_SOURCE="src/parser.y"
LEXER_SOURCE="src/lexer.l"

# Output executable name
PARSER_EXEC="src/parser_app"

# Initial values for options
test_file=""
verbose=0

# Function to display help
show_help() {
  echo "Usage: $0 [options]"
  echo ""
  echo "Options:"
  echo "  --input FILE    Specify the test file (tests/test<serialno>.py) to run through the parser. "
  echo "  --help          Display this help and exit."
  echo "  --verbose       Enable verbose mode."
}

# Parse command-line options
while [[ "$#" -gt 0 ]]; do
  case $1 in
    --input) test_file="$2"; shift ;;
    --help) show_help; exit 0 ;;
    --verbose) verbose=1 ;;
    *) echo "Unknown option: $1"; show_help; exit 1 ;;
  esac
  shift
done

# Check for mandatory options
if [[ -z "$test_file" ]]; then
  echo "Error: Test file is required."
  show_help
  exit 1
fi

# Verbose mode initial message
if [[ $verbose -eq 1 ]]; then
  echo "Test file: $test_file"
  echo "Output file for PDF: $output_file"
fi

# Generate lexer and parser code
if [[ $verbose -eq 1 ]]; then echo "Generating lexer and parser code..."; fi
flex -o src/lexer.c $LEXER_SOURCE
bison -d -o src/parser.c $PARSER_SOURCE

# Compile the lexer and parser code using g++
if [[ $verbose -eq 1 ]]; then echo "Compiling code with g++..."; fi
g++ -o $PARSER_EXEC src/lexer.c src/parser.c -ll
if [[ $verbose -eq 1 ]]; then echo "Compilation complete."; fi

# Run the parser on the test file and check for errors
if [[ $verbose -eq 1 ]]; then echo "Running parser on test file..."; fi
./$PARSER_EXEC < $test_file
if [ $? -ne 0 ]; then
  echo "Parser ended with an error. Stopping script."
  rm src/parser_app src/parser.c src/parser.h src/lexer.c
  exit 1
fi


rm src/parser_app src/parser.c src/parser.h src/lexer.c
if [[ $verbose -eq 1 ]]; then echo "Removed intermediate files"; fi
