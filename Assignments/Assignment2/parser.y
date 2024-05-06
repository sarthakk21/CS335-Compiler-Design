%{
#include <iostream>
#include <cstdlib>
#include <string>
#include <cstring>
#include "parser.tab.h" // Bison-generated header file
using namespace std;
extern int yylineno;

void yyerror(const char *s);
extern int yylex();
extern int yyparse();
extern FILE *yyin;


int num_questions = 0;
int num_choices = 0;
int num_correct_answers = 0;
int single_select_count = 0;
int multi_select_count = 0;
int total_marks = 0;
int choices_this_question = 0;
int marks_value = 0;
int correct_this_question = 0;
int start_value = 0;

int *marks_array = new int[9]; 

void outputstats(){
    // Output statistics
    cout << "Number of questions: " << num_questions << endl;
    cout << "Number of singleselect questions: " << single_select_count << endl;
    cout << "Number of multiselect questions: " << multi_select_count << endl;
    cout << "Number of answer choices: " << num_choices << endl;
    cout << "Number of correct answers: " << num_correct_answers << endl;
    cout << "Total marks: " << total_marks << endl;
    // Output marks statistics
    for(int i = 0; i < 8; i++) {
        cout << "Number of " << i + 1 << " mark questions: " << marks_array[i] << endl;
    }
}

%}

%union {
    int integral;
    char *string;
    int start;
}
    
%token QUIZ_START
%token QUIZ_END
%token SINGLESELECT_START
%token SINGLESELECT_END
%token CLOSING_BRACKETS
%token MULTISELECT_START
%token MULTISELECT_END
%token CHOICE_START
%token CHOICE_END
%token CORRECT_START
%token CORRECT_END
%token <string> MARKS
%token <int> INT
%token <string> TEXT
%token QUOTES
%expect 6

%start quiz
%define parse.error verbose

%%
quiz: ignore QUIZ_START questions QUIZ_END ignore{
    outputstats();
}

questions: %empty | questions question

question: single_select_question {
            single_select_count++;
            num_questions++;
            num_correct_answers += correct_this_question;
            num_choices += choices_this_question;
            
            choices_this_question = 0;
            correct_this_question = 0;
        }
        | multi_select_question {
            multi_select_count++;
            num_questions++;
            num_correct_answers += correct_this_question;
            num_choices += choices_this_question;
            
            choices_this_question = 0;
            correct_this_question = 0;
        }

single_select_question: ignore single_select_question_start single_select_question_mid single_select_question_end {
    if(choices_this_question < 3 || choices_this_question > 4){
        cout << endl << endl << "ERROR : number of choices out of range at <singleselect> in line " << start_value << endl << endl;
        outputstats();
        exit(1);
    }
    total_marks += marks_value;
    marks_array[marks_value - 1]++;
}

single_select_question_start: SINGLESELECT_START  {
    start_value = yylval.start;
}

single_select_question_mid: ignore MARKS QUOTES INT QUOTES{
    marks_value = yylval.integral;
    if(marks_value != 1 && marks_value != 2){
        cout << endl << endl << "ERROR : invalid marks for single correct at line "<< start_value << endl << endl << endl;
        outputstats();
        exit(1);
    }
}

single_select_question_end: CLOSING_BRACKETS choices ignore correct ignore SINGLESELECT_END{

}

multi_select_question: ignore multi_select_question_start multi_select_question_mid multi_select_question_end {
    if(choices_this_question < 3 || choices_this_question > 4){
        cout << endl << endl << "ERROR : number of choices out of range at <multiselect> in line " << start_value << endl << endl;
        outputstats();
        exit(1);
    }
    total_marks += marks_value;
    marks_array[marks_value - 1]++;
}

multi_select_question_start: MULTISELECT_START {
    start_value = yylval.start;
}

multi_select_question_mid: ignore MARKS QUOTES INT QUOTES{
    marks_value = yylval.integral;
    if(marks_value != 2 && marks_value != 3 && marks_value != 4 && marks_value != 5 && marks_value != 6 && marks_value != 7 && marks_value != 8){
        cout << endl << endl << "ERROR : invalid marks for single correct at line "<< start_value << endl << endl <<endl;
        outputstats();
        exit(1);
    }
}

multi_select_question_end: CLOSING_BRACKETS choices ignore correct ignore MULTISELECT_END {

}


choices: %empty | choices ignore CHOICE_START ignore CHOICE_END {
    choices_this_question++;
}

correct: %empty | correct ignore CORRECT_START ignore CORRECT_END {
    correct_this_question++;
}



ignore: %empty | ignore TEXT | ignore INT | ignore CLOSING_BRACKETS {}

%%

int main(){

    yyin = fopen("testfile.txt", "r");
    yyparse();
}
