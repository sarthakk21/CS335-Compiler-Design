#!/bin/bash

# Check if an input argument is given
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <input_file>"
    exit 1
fi

# Run the main script with the provided input file
./src/main_script.sh --input "$1"

# Compile the assembly code
gcc x86_code.s -o x86_code -no-pie

# Execute the compiled binary
./x86_code
