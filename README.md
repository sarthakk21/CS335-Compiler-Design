# Setup: 
1. Extract or clone the main folder where all the source files are inside 'milestone' directory.
2. Download the following libraries in milestone directory: bison, flex and graphviz.

``` bash
  sudo apt-get update 
  sudo apt-get install flex
  sudo apt-get install bison
  sudo apt-get install graphviz
``` 

# Running the shell script for Milestones:
## Milestone1 
1. Run the wrapper shell script 'main_scipt.sh' in milestone1 directory by the following commands (First command to be executed if you encounter an error while executing the script) :
``` bash
  sed -i 's/\r$//' src/main_script.sh
  ./src/main_script.sh --input tests/<testcasename>.py --verbose
```
2. The wrapper script supports the functions for input, output, help, verbose whenever required. 
3. Execute the following command to get an idea of how to run the script:
``` bash
  ./src/main_script.sh --help
```

## Milestone2
 1. Run the wrapper shell script 'main_scipt.sh' in milestone2 directory by the following commands (First command to be executed if you encounter an error while executing the script) :
``` bash
  sed -i 's/\r$//' src/main_script.sh
  ./src/main_script.sh tests/<testcasename>.py
```

## Milestone3 
1. Run the wrapper shell script 'x86\_simu.sh' in milestone3 directory by the following commands (First command to be executed if you encounter an error while executing the script) :
``` bash
  sed -i 's/\r$//' src/main_script.sh
  sed -i 's/\r$//' src/x86_simu.sh
  ./src/x86_simu.sh tests/<testcasename>.py
```

# Python Features Supported:
  ## Classes
    1. Can create a class object and access it's attributes and methods
    2. While inheriting a parent class, all of the parent class's self attribute as well as methods can be accessed here
    3. Can support multilevel inheritance and constructors
  ## Functions
    1.  Can call multiple functions inside definiton
    2.  Function calls with recursion
    3.  Can pass arrays along with other data types in function
    4.  Supports Range function with 1,2 or 3 arguments
    5.  Supports Len function with 1 argument which should be a list
    6.  Supports Print function with argument which can either be a string or a variable
 ## Array Referencing
    1.  Can pass arrays in functions
    2.  All the elements of an array can be updated if needed
    3.  Array index can only be an integer/variable of type int

  ## Miscellaneous
    1.  String comparison is supported, returns 0/1 according to the operations
    2.  Typecasting: True and False are converted to 1 and 0 respectively
    3.  All the basic operators are supported
    4.  Control flow via if-elif-else, for, while, break and continue
    5.  Logical Operators have been handled.
