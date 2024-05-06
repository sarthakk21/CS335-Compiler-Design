%{
    #include <bits/stdc++.h>
    #include <iostream>
    #include <string>
    #include <vector>
    #include <unordered_map>
    #include <map>
    #include <iomanip>
    #include <stack>
    #include <utility>
    #include <algorithm>
    #include <fstream>
    #include "parser.tab.h" 
    using namespace std;
    extern int yylineno;
    int offset_global = 0;
    stack<string> recent_loop;
    extern int global_lineno;
    extern int prev_lineno;
    stack<int> total_args_g;
    stack<int> func_lines;
    stack<int> offset_stack;
    stack<string> func_call_name_stack;
    int class_lines = 0;
    int list_flag = 0;
    int class_flag = 0;
    int len_flag = 0;
    vector<string> temp3ac;
    int trailer_flag = 0;
    int class_arg_flag = 0;
    int is_augassign = 0;
    int is_annassign = 0;
    int class_func_flag = 0;
    string global_list_iterator = "";
    string class_name = "";
    int class_offset = 0;
    string class_ofFunc = "";
    vector<string> range_values;
    vector<string> range_temp;
    int list_elems = 0;
    int t_ctr = 0;
    int t_ctr1 = 0;
    int isreturned = 0;
    int is_range = 0;
    vector<string > argument_templist;
    string g_type = "";
    string lex_name = "";
    string self_lex_name = "";
    string func_name = "";
    string func_call_name = "";
    int is_if = 0;
    stack<string> start_label_while;
    stack<string> end_label_while;
    stack<string> start_label_for;
    stack<string> mid_label_for;
    stack<string> end_label_for;
    stack<string> start_label_if;
    stack<string> temp_label_if;
    stack<string> end_label_if;
    stack<string> function_name;

    int is_expr_stmt_continue = 0;
    int indent_level = 0;   
    int arg_num = 0;
    int minus_flag = 0;
    string arg_name = "";
    void yyerror(const char *s);
    int yylex();
    extern int yyparse();
    extern FILE *yyin;
    extern char* yytext;
    int nodeId = 0;
    ofstream fout("symbol_table.txt");
    ofstream fout2("3AC.txt");
    vector <string> list_elements;

    struct Node {
        string valy;
        int id;
        vector<Node*> children;
        char tempvar[1000];
        int isfunc;
        char type[1000];
        string indextype;
    };
    struct Node* root;

    Node* createNode(string value) {
        Node *node = new Node;
        node->valy = value;
        node->id = nodeId++; 
        return node;
    }


    string traverseAndConcatenate(Node* root) {
        if (root == NULL) {
            return "";
        }
        if (root->children.size()==0) {
            return root->valy;
        }
        string fullString;
        for(int i=0;i<root->children.size();i++){
            fullString += traverseAndConcatenate(root->children[i]);
        }
        return fullString;
    }

    int sizeof_(string s){
        if(s =="int"){
            return sizeof(int);
        }
        if(s == "float"){
            return sizeof(double);
        }
        if(s == "bool"){
            return 1;
        }
        return 0;
    }

    class SymbolTable;

    class SymbolInfo {
        public:
        string type;
        int size;
        int offset;
        int line_no;
        int num_elems_list;
        string token;
        int arg_num;
        int total_args;
        SymbolTable* ptr = NULL;
        SymbolInfo(){}
        SymbolInfo(string type, int size, int line_no, SymbolTable* ptr, int total_args, int arg_num, string token, int num_elems_list){
            this->type = type;
            this->size = size;
            this->num_elems_list = num_elems_list;
            this->offset = offset_global;
            this->line_no = line_no;
            this->ptr = ptr;
            this->total_args = total_args;
            this->arg_num = arg_num;
            this->token = token;
        }
        SymbolInfo(string type, int size, int offset, int line_no, SymbolTable* ptr, int total_args, int arg_num, string token, int num_elems_list){
            this->type = type;
            this->size = size;
            this->num_elems_list = num_elems_list;
            this->offset = offset;
            this->line_no = line_no;
            this->ptr = ptr;
            this->total_args = total_args;
            this->arg_num = arg_num;
            this->token = token;
        }
    };

    class SymbolTable {
        public:
        unordered_map<string, SymbolInfo> table;
        SymbolTable* parent;
        string scope_name;
        int level_num;
        SymbolTable(SymbolTable* parent, int level_num, string scope_name){
            this->parent = parent;
            this->level_num = level_num;
            this->scope_name = scope_name;
        }

        int calc_table_size(){
            int size_ = 0;
            for(auto it : table){
                size_ += it.second.size;
            }
            return size_;
        }

        void add_entry(string lexeme, string type, int size, int line_no, SymbolTable* ptr, int total_args, int arg_num, string token, int num_elems_list){
            if(table.find(lexeme) != table.end()){
                cout << "Line " << line_no << ": Redeclaration of variable " << lexeme << endl;
                exit(1);
            }
            else{
                SymbolInfo temp(type, size, line_no, ptr, total_args, arg_num, token, num_elems_list);
                table[lexeme] = temp;
            } 
            g_type = "";
            list_elems = 0;
            num_elems_list = 0;
        }

        void add_entry_for_self(string lexeme, string type, int size, int offset, int line_no, SymbolTable* ptr, int total_args, int arg_num, string token, int num_elems_list){
            if(table.find(lexeme) != table.end()){
                cout << "Line " << line_no << ": Redeclaration of variable " << lexeme << endl;
                exit(1);
            }
            else{
                SymbolInfo temp(type, size, offset, line_no, ptr, total_args, arg_num, token, num_elems_list);
                table[lexeme] = temp;
            } 
            g_type = "";
            list_elems = 0;
            num_elems_list = 0;
        }

        void print_all_tables(SymbolTable* table, int indent = 0) {
        if (!table) return;
        string sname = table->scope_name;

        // Print the current table
        table->print_table(indent,sname);

        // Iterate through all entries in the current table
        for (auto& entry : table->table) {
            SymbolInfo& info = entry.second;
            if (info.ptr) {
                // If the entry has a nested symbol table, print it recursively
                print_all_tables(info.ptr, indent + 1);
            }
        }
    }

    // Updated print_table function with an additional indent parameter
    void print_table(int indent = 0, string scope_name = "") {
        string indentStr(indent * 4, ' '); // Create an indentation string
        fout << indentStr << "Level " << level_num << " Symbol Table: " << scope_name<<endl;
        fout << indentStr << left << setw(20) << "Name" 
             << setw(15) << "Type" 
             << setw(6) << "Size" 
             << setw(8) << "Offset" 
             << setw(5) << "Line" 
             << setw(11) << "Total_Args" 
             << setw(10) << "Arg_Num" 
             << setw(10) << "Token" << endl;

        fout << indentStr << setfill('-') << setw(59) << "" << setfill(' ') << endl; // Draw a line

        for(auto& it : table) {
            if (it.first != "len" && it.first != "__name__"){
            fout << indentStr << left << setw(20) << it.first 
                 << setw(15) << it.second.type 
                 << setw(6) << it.second.size 
                 << setw(8) << it.second.offset 
                 << setw(5) << it.second.line_no 
                 << setw(11) << it.second.total_args // Assuming 'total_args' is a member
                 << setw(10) << it.second.arg_num 
                 << setw(10) << it.second.token << endl;

            // If this symbol has a nested symbol table, it will be printed in the recursive call
        }
        }
    }

    };
    vector<pair<string, SymbolInfo*> > args_in_func;
    // unordered_map<string, vector<pair<string, SymbolInfo*> > > func_with_args;
    vector<string> val_reassign;
    int lhs_reassign = 0;
    stack<SymbolTable*> scope_stacku;
    SymbolTable* global_table = new SymbolTable(NULL, 0,"Global");

    SymbolInfo* lookup_temp(string lexeme, SymbolTable*table){
        if(lexeme[lexeme.size()-1] == ')'){
            lexeme.pop_back();
            while(lexeme[lexeme.size()-1] != '('){
                lexeme.pop_back();
            }
            lexeme.pop_back();
        }
        if(lexeme[lexeme.size()-1] == ']'){
            lexeme.pop_back();
            while(lexeme[lexeme.size()-1] != '['){
                lexeme.pop_back();
            }
            lexeme.pop_back();
        }
        SymbolTable* temp = table;
        while(temp != NULL){
            if(temp->table.find(lexeme) != temp->table.end()){
                return &(temp->table[lexeme]);
            }
            temp = temp->parent;
        }
        if(!(lexeme == "print" || lexeme == "print" || lexeme == "range")){
            cout << "Line " << prev_lineno << ": Variable " << lexeme << " not declared" << endl;
            exit(1);
            return NULL;
        }
        return NULL;
    }

    SymbolInfo * lookup(string lexeme);

    string getType_temp(string element, SymbolTable* table){
        string list_iterator = "";
        int is_list = 0;
        if(element[element.size()-1] == ')'){

            element.pop_back();
            while(element[element.size()-1] != '('){
                element.pop_back();
            }
            element.pop_back();
        }
        if(element[element.size()-1] == ']'){
            is_list = 1;
            element.pop_back();
            while(element[element.size()-1] != '['){
                char ch = element.back();
                element.pop_back();
                list_iterator.push_back(ch);
            }
            element.pop_back();
        }
        if(element.find('[') == string::npos){
            if (element.find(']') == string::npos){
                if (element.find(',') != string::npos){
                    cout << "Line: " << prev_lineno << " Element has invalid syntax, more than a 1-D array" << endl;
                    exit(1);
                }
                // This is a list
            }
            else {
                cout << "Line: " << prev_lineno << " Invalid syntax, incomplete square brackets" << endl;
                exit(1);
            }
         }
        if (!list_iterator.empty()){
            
            reverse(list_iterator.begin(),list_iterator.end());
            
            if(list_iterator.find(',') == string::npos){
                if ((list_iterator[0]=='_' || (list_iterator[0] >= 'a' && list_iterator[0] <= 'z') || (list_iterator[0] >= 'A' && list_iterator[0] <= 'Z')) && list_iterator != "True" && list_iterator != "False"){
                    SymbolInfo* iter = lookup_temp(list_iterator,table);
                    string temp_type_iter = iter->type;
                    if (temp_type_iter != "int"){
                        //Wrong type of iterator
                        global_list_iterator = "";
                        cout << "Line: " << prev_lineno << " This type \"" << temp_type_iter << "\" cannot be used to iterate any list." << endl;
                        exit(1);
                    }   
                    else {
                        //This is a variable of type int being used as a iterator. To see if this goes out of scope, we will check in runtime
                        global_list_iterator = "";
                        // cout << "Line: " << prev_lineno << " Global "<< global_list_iterator << " and element is " << element << endl;
                    } 
                }
                else if (getType_temp(list_iterator,table) == "int") {
                        global_list_iterator = list_iterator;
                }  
                else {
                    cout << "Line: " << prev_lineno << " This type \"" << getType_temp(list_iterator,table) << "\" cannot be used to iterate any list." << endl;
                    exit(1);
                }      
            }
            else {
                cout << "Line: " << prev_lineno << " Iterator has invalid syntax has a comma" << endl;
                exit(1);
            }
        }
        if(element == "True" || element == "False"){
            return "bool";
        }
        for(int i=0; i< element.size();i++){
            if(element[i] == '"'){
                return "str";
            }
            if(element[i] == '.'){
                if ( (i != element.size() - 1) && (element[i+1]=='_' || (element[i+1] >= 'a' && element[i+1] <= 'z') || (element[i+1] >= 'A' && element[i+1] <= 'Z')))
                {
                    if (element.substr(0,5) == "self."){
                        SymbolInfo* curr = lookup_temp(element,table);
                        string temp_type = curr->type;
                        return temp_type;
                    }
                    else {
                            size_t position = element.find('.');
                            string caller = element.substr(0, position);
                            string callee = element.substr(position+1);
                            SymbolInfo* temp = lookup(caller);
                            if (temp->type == "class"){
                                SymbolTable* class_table = temp->ptr;
                                if(class_table->table.find(callee) != class_table->table.end()){
                                    return class_table->table[callee].type;
                                }
                                else {
                                      if(class_table->table.find("self." + callee) != class_table->table.end()){
                                            return class_table->table["self." + callee].type;
                                    }
                                    else {
                                        cout<<"Line "<<prev_lineno<<": Function "<<callee<<" not defined"<<endl;
                                        exit(1);
                                    }
                                }
                            }
                            else if (lookup_temp(temp->type,table)->type == "class" ) {
                                SymbolTable* class_table = lookup_temp(temp->type,table)->ptr;
                                if(class_table->table.find(callee) != class_table->table.end()){
                                    return class_table->table[callee].type;
                                }
                                else {
                                    if(class_table->table.find("self." + callee) != class_table->table.end()){
                                            return class_table->table["self." + callee].type;
                                    }
                                    else {
                                        cout<<"Line "<<prev_lineno<<": Function "<<callee<<" not defined"<<endl;
                                        exit(1);
                                    }
                                }
                            }
                            else {
                                cout<<"Line "<<prev_lineno<<": Function "<<callee<<" not defined"<<endl;
                                exit(1);
                            } 
                    }
                }
                else {
                    return "float";
                }
            }
        }
        if(element[0]=='_' || (element[0] >= 'a' && element[0] <= 'z') || (element[0] >= 'A' && element[0] <= 'Z')){
            SymbolInfo* curr = lookup_temp(element,table);
            // cout << element << " " << curr->type << endl;
            string temp_type = curr->type;
            int temp_num = curr->num_elems_list;
            if(is_list){
                if (!global_list_iterator.empty()){
                    if ( stoi(global_list_iterator) < temp_num && stoi(global_list_iterator) >= 0){
                            temp_type = temp_type.substr(5);
                            temp_type.pop_back();
                    }
                    else {
                        cout << "Line: " << prev_lineno << " Index out of bounds for list " << element << endl;
                        exit(1); 
                    }
                } else {
                        temp_type = temp_type.substr(5);
                        temp_type.pop_back();
                }
            }
            return temp_type;
        }
        
        return "int";
    }



    SymbolInfo* lookup(string lexeme){
        if(lexeme[lexeme.size()-1] == ')'){
            lexeme.pop_back();
            while(lexeme[lexeme.size()-1] != '('){
                lexeme.pop_back();
            }
            lexeme.pop_back();
        }
        if(lexeme[lexeme.size()-1] == ']'){
            lexeme.pop_back();
            while(lexeme[lexeme.size()-1] != '['){
                lexeme.pop_back();
            }
            lexeme.pop_back();
        }
        SymbolTable* temp = scope_stacku.top();
        while(temp != NULL){
            if(temp->table.find(lexeme) != temp->table.end()){
                return &(temp->table[lexeme]);
            }
            temp = temp->parent;
        }
        if(!(lexeme == "print" || lexeme == "print" || lexeme == "range")){
            cout << "Line " << prev_lineno << ": Variable " << lexeme << " not declared" << endl;
            exit(1);
            return NULL;
        }
        return NULL;
    }

    SymbolInfo* lookup_type(string lexeme){
        if(lexeme[lexeme.size()-1] == ')'){
            lexeme.pop_back();
            while(lexeme[lexeme.size()-1] != '('){
                lexeme.pop_back();
            }
            lexeme.pop_back();
        }
        if(lexeme[lexeme.size()-1] == ']'){
            lexeme.pop_back();
            while(lexeme[lexeme.size()-1] != '['){
                lexeme.pop_back();
            }
            lexeme.pop_back();
        }
        SymbolTable* temp = scope_stacku.top();
        while(temp != NULL){
            if(temp->table.find(lexeme) != temp->table.end()){
                return &(temp->table[lexeme]);
            }
            temp = temp->parent;
            // if (temp != NULL) cout << "Line: " << prev_lineno << " " << temp->scope_name << endl; 
        }
        if(!(lexeme == "print" || lexeme == "range")){
            return NULL;
        }
        return NULL;
    }

     bool typecheck(string t1, string t2){
        // if(lookup_type(t1)->type == "class" ){
        //     if(lookup_type(t2)->type == "class" || t2 == "class"){
        //         return true;
        //     }
        //     else return false;
        // }
        // else{
        //     if(lookup_type(t2)->type == "class"){
        //         return false;
        //     }
        // }
        if(lookup_type(t1) != NULL){
            if(lookup_type(t1)->type == "class" ){
                if(lookup_type(t2) != NULL){
                    if(lookup_type(t2)->type == "class" || t2 == "class"){
                        return true;
                    }
                    else return false;
                }
                else if(t2 == "class"){
                    return true;
                }
                else return false;
            }
            else{
                if(lookup_type(t2) != NULL){
                    if(lookup_type(t2)->type == "class"){
                        return false;
                    }
                }
            }
            return false;
        }
        
        if(t1 == t2){
            //Do nothing 
            return true;
        }
        else if(t1 == "int" && t2 == "str"){
            cout<<"Line "<<prev_lineno<<" Error: Expected int, but "<<t2<<" provided"<<endl;
            exit(1);
        }
        else if(t1 == "str" && t2 == "int"){
            cout<<"Line "<<prev_lineno<<"Error: Expected str, but "<<t2<<" provided"<<endl;
            exit(1);
        }
        else if(t1 == "float" && t2 == "str"){
            cout<<"Line "<<prev_lineno<<"Error: Expected float, but "<<t2<<" provided"<<endl;
            exit(1);
        }
        else if(t1 == "str" && t2 == "float"){
            cout<<"Line "<<prev_lineno<<"Error: Expected str, but "<<t2<<" provided"<<endl;
            exit(1);
        }
        else if(t1 == "bool" && t2 == "str"){
            cout<<"Line "<<prev_lineno<<"Error: Expected bool, but "<<t2<<" provided"<<endl;
            exit(1);
        }
        else if(t1 == "str" && t2 == "bool"){
            cout<<"Line "<<prev_lineno<<"Error: Expected str, but "<<t2<<" provided"<<endl;
            exit(1);
        }
        else if(t1 == "int" && t2 == "float"){
            // *v = arg_values[i];
            return true;
        }
        else if(t1 == "float" && t2 == "int"){
            // *v = arg_values[i];
            return true;
        }
        else if(t1 == "int" && t2 == "bool"){
            // *v = (arg_values[i] == "True")?"1":"0";
            return true;
        }
        else if(t1 == "bool" && t2 == "int"){
            // *v = (stoi(arg_values[i]) > 0)?"True":"False";
            return true;
        }
        else if(t1 == "float" && t2 == "bool"){
            // *v = (arg_values[i] == "True")?"1":"0";
            return true;
        }
        else if(t1 == "bool" && t2 == "float"){
            // *v = (stof(arg_values[i]) > 0)?"True":"False";
            return true;
        }
        else{
            cout<<"Unexpected argument type1"<<endl;
            cout<<"Line: " << prev_lineno << "Expected "<<t1<<", but "<<t2<<" provided"<<endl;
            exit(1);
        }
    }

    void global_lookup(string lexeme){
        SymbolTable* temp = scope_stacku.top();
        while(temp != NULL){
            if(temp->table.find(lexeme) != temp->table.end()){
                SymbolInfo temp_info = temp->table[lexeme];
                temp->table.erase(lexeme);
                global_table->add_entry(lexeme, temp_info.type, temp_info.size, temp_info.line_no, temp_info.ptr, temp_info.total_args, temp_info.arg_num, temp_info.token, temp_info.num_elems_list);
                return;
            }
            temp = temp->parent;
        }
        cout << "Line " << prev_lineno << ": Variable " << lexeme << " not declared" << endl;
        exit(1);
        return;
    }

    string getType(string element){
        string list_iterator = "";
        int is_list = 0;
        if(element[element.size()-1] == ')'){

            element.pop_back();
            while(element[element.size()-1] != '('){
                element.pop_back();
            }
            element.pop_back();
        }
        if(element[element.size()-1] == ']'){
            is_list = 1;
            element.pop_back();
            while(element[element.size()-1] != '['){
                char ch = element.back();
                element.pop_back();
                list_iterator.push_back(ch);
            }
            element.pop_back();
        }
        if(element.find('[') == string::npos){
            if (element.find(']') == string::npos){
                if (element.find(',') != string::npos){
                    cout << "Line: " << prev_lineno << " Element has invalid syntax, more than a 1-D array" << endl;
                    exit(1);
                }
                // This is a list
            }
            else {
                cout << "Line: " << prev_lineno << " Invalid syntax, incomplete square brackets" << endl;
                exit(1);
            }
         }
        if (!list_iterator.empty()){
            
            reverse(list_iterator.begin(),list_iterator.end());
            
            if(list_iterator.find(',') == string::npos){
                if ((list_iterator[0]=='_' || (list_iterator[0] >= 'a' && list_iterator[0] <= 'z') || (list_iterator[0] >= 'A' && list_iterator[0] <= 'Z')) && list_iterator != "True" && list_iterator != "False"){
                    SymbolInfo* iter = lookup(list_iterator);
                    string temp_type_iter = iter->type;
                    if (temp_type_iter != "int"){
                        //Wrong type of iterator
                        global_list_iterator = "";
                        cout << "Line: " << prev_lineno << " This type \"" << temp_type_iter << "\" cannot be used to iterate any list." << endl;
                        exit(1);
                    }   
                    else {
                        //This is a variable of type int being used as a iterator. To see if this goes out of scope, we will check in runtime
                        global_list_iterator = "";
                        // cout << "Line: " << prev_lineno << " Global "<< global_list_iterator << " and element is " << element << endl;
                    } 
                }
                else if (getType(list_iterator) == "int") {
                        global_list_iterator = list_iterator;
                }  
                else {
                    cout << "Line: " << prev_lineno << " This type \"" << getType(list_iterator) << "\" cannot be used to iterate any list." << endl;
                    exit(1);
                }      
            }
            else {
                cout << "Line: " << prev_lineno << " Iterator has invalid syntax has a comma" << endl;
                exit(1);
            }
        }
        if(element == "True" || element == "False"){
            return "bool";
        }
        for(int i=0; i< element.size();i++){
            if(element[i] == '"'){
                return "str";
            }
            if(element[i] == '.'){
                if ( (i != element.size() - 1) && (element[i+1]=='_' || (element[i+1] >= 'a' && element[i+1] <= 'z') || (element[i+1] >= 'A' && element[i+1] <= 'Z')))
                {
                    if (element.substr(0,5) == "self."){
                    SymbolInfo* curr = lookup(element);
                    string temp_type = curr->type;
                    return temp_type;
                    }
                    else {
                            size_t position = element.find('.');
                            string caller = element.substr(0, position);
                            string callee = element.substr(position+1);
                            SymbolInfo* temp = lookup(caller);
                            if (temp->type == "class"){
                                SymbolTable* class_table = temp->ptr;
                                if(class_table->table.find(callee) != class_table->table.end()){
                                    return class_table->table[callee].type;
                                }
                                else {
                                      if(class_table->table.find("self." + callee) != class_table->table.end()){
                                            return class_table->table["self." + callee].type;
                                    }
                                    else {
                                        cout<<"Line "<<prev_lineno<<": Function "<<callee<<" not defined"<<endl;
                                        exit(1);
                                    }
                                }
                            }
                            else if (lookup(temp->type)->type == "class" ) {
                                SymbolTable* class_table = lookup(temp->type)->ptr;
                                if(class_table->table.find(callee) != class_table->table.end()){
                                    return class_table->table[callee].type;
                                }
                                else {
                                    if(class_table->table.find("self." + callee) != class_table->table.end()){
                                            return class_table->table["self." + callee].type;
                                    }
                                    else {
                                        cout<<"Line "<<prev_lineno<<": Function "<<callee<<" not defined"<<endl;
                                        exit(1);
                                    }
                                }
                            }
                            else {
                                cout<<"Line "<<prev_lineno<<": Function "<<callee<<" not defined"<<endl;
                                exit(1);
                            } 
                    }
                }
                else {
                    return "float";
                }
            }
        }
        if(element[0]=='_' || (element[0] >= 'a' && element[0] <= 'z') || (element[0] >= 'A' && element[0] <= 'Z')){
            SymbolInfo* curr = lookup(element);
            // cout << element << " " << curr->type << endl;
            string temp_type = curr->type;
            int temp_num = curr->num_elems_list;
            if(is_list){
                if (!global_list_iterator.empty()){
                    if ( stoi(global_list_iterator) < temp_num && stoi(global_list_iterator) >= 0){
                            temp_type = temp_type.substr(5);
                            temp_type.pop_back();
                    }
                    else {
                        cout << "Line: " << prev_lineno << " Index out of bounds for list " << element << endl;
                        exit(1); 
                    }
                } else {
                        temp_type = temp_type.substr(5);
                        temp_type.pop_back();
                }
            }
            return temp_type;
        }
        
        return "int";
    }
    void gen3AC(vector<string> code, int indentLevel){
        string indent = "";
        while(indentLevel--){
            indent += "\t";
        }
        // string indent = "\t"*indentLevel;
        fout2<<indent;
        for(auto it: code){
            fout2<<it;
        }
        fout2<<endl;
    }

    // void //genx86(vector<string> code){
    //     for(auto it: code){
    //         fout3<<it;
    //     }
    //     fout3<<endl;
    // }

    string newtemp(){
      string temp_var = "t"+to_string(t_ctr++);
      return temp_var;
    }
    string newLabel(){
      string temp_var = "L"+to_string(t_ctr1++);
      return temp_var;
    }

    void printPreorder(struct Node* node){
        if (node == NULL)
            return;

        // Deal with the node
        if(node->children.size()==0)cout << node->valy << " ";

        for(int i = 0; i < node->children.size(); i++){
            printPreorder(node->children[i]);
        }
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
    DEF NAME {
        function_name.push($2);
        gen3AC({"function ", $2, " :"},indent_level++);
        gen3AC({"begin func: "},indent_level);
        //genx8({"pushq\t%rbp"});
        //genx8({"movq\t%rsp, %rbp"});
        func_lines.push(global_lineno);
        if(class_arg_flag){
            class_func_flag = 1;
        }
    } parameters {
        SymbolTable* current_scope = scope_stacku.top();
        SymbolTable* func1_table = new SymbolTable(current_scope, current_scope->level_num + 1, $2);
        scope_stacku.push(func1_table);
        offset_stack.push(offset_global);
        offset_global = 0;
        SymbolTable* func_table = scope_stacku.top();
        int n = total_args_g.top();
        reverse(args_in_func.end()-n, args_in_func.end());
        
        for(int i = 0; i < n; i++){
            func_table->add_entry(args_in_func[args_in_func.size()-i-1].first, args_in_func[args_in_func.size()-i-1].second->type, args_in_func[args_in_func.size()-i-1].second->size, args_in_func[args_in_func.size()-i-1].second->line_no, args_in_func[args_in_func.size()-i-1].second->ptr, args_in_func[args_in_func.size()-i-1].second->total_args, args_in_func[args_in_func.size()-i-1].second->arg_num, args_in_func[args_in_func.size()-i-1].second->token, -1);
            offset_global += args_in_func[args_in_func.size()-i-1].second->size;
            
        }
        while(n>0){
            args_in_func.pop_back();
            n--;
        }
    } f_funcdef
    {   
        class_func_flag = 0;
        $$ = createNode("funcdef");
        string temp = string("DEF (") + $1 + ")";
        SymbolTable* func_table = scope_stacku.top();
        offset_global = offset_stack.top();
        offset_stack.pop();
        scope_stacku.pop();
        SymbolTable* current_scope = scope_stacku.top();
        if(!class_flag){
            current_scope->add_entry($2, $6->children[1]->valy, 0, func_lines.top(), func_table, total_args_g.top(), -1, "FUNCTION", -1);
        }
        else{ 
            current_scope->add_entry($2, class_name, 0, func_lines.top(), func_table, total_args_g.top(), -1,  "FUNCTION", -1); class_flag = 0;
        }
        // offset_global += 8;
        total_args_g.pop();
        func_lines.pop();
        $$->children.push_back(createNode($1));
        // temp = string("NAME (") + $2 + ")";
        $$->children.push_back(createNode($2));
        $$->children.push_back($4);
        $$->children.push_back($6);
        gen3AC({"end func: "},indent_level--);
        function_name.pop();
    }
    ;

f_funcdef:
    COLON {
        // SymbolTable* current_scope = scope_stacku.top();
        // SymbolTable* func_table = new SymbolTable(current_scope, current_scope->level_num + 1);
        // scope_stacku.push(func_table);
        class_flag = 1;
    } suite
    {
        if($3 == NULL){
            string temp = string("COLON (") + $1 + ")";
            $$ = createNode($1);
        }
        else{
            $$ = createNode("f_funcdef");
            string temp = string("COLON (") + $1 + ")";
            $$->children.push_back(createNode($1));
            $$->children.push_back($3);
        }
    }
    | ARROW test COLON {
        function_name.push($2->valy);
        // SymbolTable* current_scope = scope_stacku.top();
        // SymbolTable* func_table = new SymbolTable(current_scope, current_scope->level_num + 1);
        // scope_stacku.push(func_table);
        } 
        suite
    {
        $$ = createNode("f_funcdef");
        string temp = string("ARROW (") + $1 + ")";
        $$->children.push_back(createNode($1));
        $$->children.push_back($2);
        temp = string("COLON (") + $3 + ")";
        $$->children.push_back(createNode($3));
        $$->children.push_back($5);
        isreturned = 0;
    }
    ;

parameters: 
    LPAREN f_parameters
    {
        string temp = string("LPAREN (") + $1 + ")";
        if($2 == NULL){
            $$ = createNode($1);
        }
        else{
            $$ = createNode("parameters");
            $$->children.push_back(createNode($1));
            $$->children.push_back($2);
        }
        
    }
    ;

f_parameters:
    typedargslist RPAREN
    {
        total_args_g.push(arg_num);
        arg_num = 0;
        string temp = string("RPAREN (") + $2 + ")";
        if($1 == NULL){
            $$ = createNode($2);
        }
        else{
            $$ = createNode("f_parameters");
            $$->children.push_back($1);
            $$->children.push_back(createNode($2));
        }    
    }
    | RPAREN
    {
        total_args_g.push(arg_num);
        arg_num = 0;
        string temp = string("RPAREN (") + $1 + ")";
        $$ = createNode($1);
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
            // $$ = createNode(temp);
            $$ = createNode($2);
        }
        else{
            $$ = createNode("typedargslist");
            $$->children.push_back($1);
            $$->children.push_back(createNode($2));
            $$->children.push_back($3);
            $$->children.push_back($4);
        }
    }
    ;

tfpdef: 
    NAME f_tfpdef
    {
        arg_name = $1;
        if($2 == NULL && class_func_flag == 1){
            $$ = createNode($1);
            if(arg_name!="self"){
                cout<<"Line "<<prev_lineno<<" Error: Erroneous format without type hints"<<endl;
                exit(1);
            }
            else{
                arg_num++;
                args_in_func.push_back({arg_name, new SymbolInfo("NA", 8, func_lines.top(), NULL, -1, arg_num, "NAME", -1)});
            }
        } 
        else if ($2 == NULL && class_func_flag != 1) {
                cout<<"Line "<<prev_lineno<<" Error: Erroneous format without type hints"<<endl;
                exit(1);
        }
        else{
            if (class_func_flag == 1 && func_lines.size()==1) {
                for (int i = 0; i < args_in_func.size(); i++){
                    // cout << "Line: " << prev_lineno << " " << args_in_func[i].first << endl;
                    if (args_in_func[i].second->arg_num == 1){
                        if (args_in_func[i].second->type != "NA"){
                            cout<<"Line "<<prev_lineno<<" Error: The first argument in class should be self"<<endl;
                            exit(1);
                        }
                        break;
                    } 
                }
                // cout << "Line: " << prev_lineno << " " << "Done for once" << endl;
                }
            arg_num++;
            string arg_type = traverseAndConcatenate($2->children[1]);
            SymbolTable* current_scope = scope_stacku.top();
            if(arg_type!="float" && arg_type!="int" && arg_type!="bool" && arg_type!="str" && arg_type!="char"){
                args_in_func.push_back({arg_name, new SymbolInfo(arg_type, 8, func_lines.top(), NULL, -1, arg_num, "NAME",-1)});
                gen3AC({"popparam ", arg_name},indent_level);
                if(arg_num == 1){
                    //genx8({"movq\t%rdi, -",to_string(8),"(%rbp)"});
                }
                else if(arg_num == 2){
                    //genx8({"movq\t%rsi, -",to_string(8),"(%rbp)"});
                }
                else if(arg_num == 3){
                    //genx8({"movq\t%rdx, -",to_string(8),"(%rbp)"});
                }
                else if(arg_num == 4){
                    //genx8({"movq\t%rcx, -",to_string(8),"(%rbp)"});
                }
                else if(arg_num == 5){
                    //genx8({"movq\t%r8, -",to_string(8),"(%rbp)"});
                }
                else if(arg_num == 6){
                    //genx8({"movq\t%r9, -",to_string(8),"(%rbp)"});
                }
            }
            else{
                if(arg_type=="str"){
                    args_in_func.push_back({arg_name, new SymbolInfo(arg_type, 8, func_lines.top(), NULL, -1, arg_num,  "NAME",-1)});
                    gen3AC({"popparam ", arg_name},indent_level);
                    if(arg_num == 1){
                        //genx8({"movq\t%rdi, -",to_string(8),"(%rbp)"});
                    }
                    else if(arg_num == 2){
                        //genx8({"movq\t%rsi, -",to_string(8),"(%rbp)"});
                    }
                    else if(arg_num == 3){
                        //genx8({"movq\t%rdx, -",to_string(8),"(%rbp)"});
                    }
                    else if(arg_num == 4){
                        //genx8({"movq\t%rcx, -",to_string(8),"(%rbp)"});
                    }
                    else if(arg_num == 5){
                        //genx8({"movq\t%r8, -",to_string(8),"(%rbp)"});
                    }
                    else if(arg_num == 6){
                        //genx8({"movq\t%r9, -",to_string(8),"(%rbp)"});
                    }
                }
                else {
                    args_in_func.push_back({arg_name, new SymbolInfo(arg_type, sizeof_(arg_type), func_lines.top(), NULL, -1, arg_num, "NAME",-1)});
                    gen3AC({"popparam ", arg_name},indent_level);
                    if(arg_num == 1){
                        //genx8({"movq\t%rdi, -",to_string(8),"(%rbp)"});
                    }
                    else if(arg_num == 2){
                        //genx8({"movq\t%rsi, -",to_string(8),"(%rbp)"});
                    }
                    else if(arg_num == 3){
                        //genx8({"movq\t%rdx, -",to_string(8),"(%rbp)"});
                    }
                    else if(arg_num == 4){
                        //genx8({"movq\t%rcx, -",to_string(8),"(%rbp)"});
                    }
                    else if(arg_num == 5){
                        //genx8({"movq\t%r8, -",to_string(8),"(%rbp)"});
                    }
                    else if(arg_num == 6){
                        //genx8({"movq\t%r9, -",to_string(8),"(%rbp)"});
                    }
                }
            
            }
            $$ = createNode("tfpdef");
            $$->children.push_back(createNode($1));
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
            $$ = createNode($1);
        }
        else{
            $$ = createNode("f_tfpdef");
            $$->children.push_back(createNode($1));
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
        $$ = createNode($1);
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
            $$ = createNode($2);
        }
        else{
            $$ = createNode("semicolon_small_stmt");
            $$->children.push_back($1);
            $$->children.push_back(createNode($2));
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
    ;

expr_stmt: 
    testlist_star_expr { self_lex_name = traverseAndConcatenate($1); } f_expr_stmt
    {
        if($1 == NULL && $3 == NULL){
            $$ = NULL;
        }
        else{
            if($1 == NULL){
                $$ = $3;
            }
            else if($3 == NULL){
                $$ = $1;
            }
            else{
                int cnt = 0;
                
                $$ = createNode("expr_stmt");
                $$->children.push_back($1);
                for(auto it: $3 -> children){
                    $$->children.push_back(it);
                }
                strcpy($$->tempvar, ($1->valy).c_str());

                if(is_annassign){
                    gen3AC({$$->tempvar," = ",$3->tempvar},indent_level);
                    //genx8({"movq ", $3->tempvar, " ", $$->tempvar});
                    is_annassign = 0;
                }
                else if(is_augassign){
                    string temp = newtemp();
                    string op = $3->children[0]->valy;
                    op.pop_back();
                    op.insert(0," ");
                    op.push_back(' ');
                    gen3AC({temp, " = ", $1->valy, op, $3->tempvar},indent_level);
                    // genx86({"movq ", $3->tempvar, " ", temp});
                    if(op == " + "){
                        // genx86({"addq ", $3->tempvar, " ", $1->valy});
                    }
                    else if(op == " - "){
                        // genx86({"subq ", $3->tempvar, " ", $1->valy});
                    }
                    else if(op == " * "){
                        //genx86({"imulq ", $3->tempvar, " ", $1->valy});
                    }
                    else if(op == " / "){
                        //genx86({"idivq ", $3->tempvar, " ", $1->valy});
                    }
                    else if(op == " % "){
                        //genx86({"imodq ", $3->tempvar, " ", $1->valy});
                    }
                    gen3AC({$1->valy, " = ", temp},indent_level);  
                    //genx86({"movq ", temp, " ", $1->valy});
                    strcpy($$->tempvar, temp.c_str());
                    is_augassign = 0;
                }
                else if(is_expr_stmt_continue){
                    string t_self = $1->valy;
                    if(t_self.substr(0,5) == "self."){
                        gen3AC({$1->valy, " = ", $3->tempvar},indent_level);
                    }
                    else gen3AC({$1->tempvar, " = ", $3->tempvar},indent_level);
                    is_expr_stmt_continue = 0;
                }
            }
        }
    }
    ;

f_expr_stmt:
    annassign
    {
        is_annassign = 1;
        $$ = $1;
        // createNode("f_expr_stmt");
        // $$->children.push_back($1);
    }
    | augassign testlist
    {
        is_augassign = 1;
        // string var = $2->valy;
        // string temp = $2->valy;
        // if(temp[temp.size()-1] == ']'){
        //     temp.pop_back();
        //     string index = "";
        //     while(temp[temp.size()-1] != '['){
        //         index.push_back(temp[temp.size()-1]);
        //         temp.pop_back();
        //     }
        //     reverse(index.begin(), index.end());
        //     temp.pop_back();
        //     string new_temp = newtemp();
        //     gen3AC({new_temp, " = ", index, " * ", to_string(sizeof_(getType(var)))},indent_level);
        //     string temp1 = newtemp();
        //     gen3AC({temp1, " = ", temp, " + ", new_temp},indent_level);
        //     temp1 = "*(" + temp1 + ")";
        //     strcpy($2->tempvar, temp1.c_str());
            
        // }
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
                // strcpy($$->temp_var, $2->valy);
                // string tempo = newtemp();
                // string op =$1->valy;
                // op.pop_back();
                // gen3AC({tempo, "=", $1->tempvar, op, $2->tempvar});
                strcpy($$->tempvar, $2->tempvar);
            }
        }
    }
    | expr_stmt_continue
    {
        is_expr_stmt_continue = 1;
        $$ = $1;

        // createNode("f_expr_stmt");
        // $$->children.push_back($1);
    }
    ;

expr_stmt_continue:
    expr_stmt_continue EQUALS {
        // lhs_reassign = 1;
    } testlist_star_expr
    {
        string temp = $4->valy;
        string var = $4->valy;
        if(temp[temp.size()-1] == ']'){
            temp.pop_back();
            string index = "";
            while(temp[temp.size()-1] != '['){
                index.push_back(temp[temp.size()-1]);
                temp.pop_back();
            }
            reverse(index.begin(), index.end());
            temp.pop_back();
            string new_temp = newtemp();
            // lookup(index);
            gen3AC({new_temp, " = ", index, " * ", to_string(sizeof_(getType(var)))},indent_level);
            string temp1 = newtemp();
            gen3AC({temp1, " = ", temp, " + ", new_temp},indent_level);
            temp1 = "*(" + temp1 + ")";
            strcpy($4->tempvar, temp1.c_str());
            
        }
        // string temp = string("EQUALS (") + $2 + ")";
        // lhs_reassign = 0;
        // if(val_reassign.size()!=0){
        //     cout<<"Line "<<prev_lineno<<": Lesser number of values provided"<<endl;
        //     exit(1);
        // }
        if($1 == NULL && $4 == NULL){
            $$ = createNode($2);
        }
        else{
            $$ = createNode("expr_stmt_continue");
            $$->children.push_back($1);
            $$->children.push_back(createNode($2));
            $$->children.push_back($4);
            strcpy($$->tempvar, $4->tempvar);
            strcpy($$->type, $4->type);
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
        // cout<<prev_lineno<<endl;
        g_type = traverseAndConcatenate($2);
        string list_g_type;
        SymbolTable* current_scope = scope_stacku.top();
        if(!class_arg_flag || !(self_lex_name.substr(0,5) == "self.")){
            if(g_type!="float" && g_type!="int" && g_type!="bool" && g_type!="str" && g_type!="char"){
                if(g_type.substr(0,5)!="list["){
                    if(lookup(g_type)->type == "class"){
                        SymbolTable* temp_class = lookup(g_type)->ptr;
                        string element = "";
                        string class_elem_values = traverseAndConcatenate($3);
                        vector<string> arg_values;
                        int i=0;
                        while(i<class_elem_values.size()&&class_elem_values[i]!='('){
                            i++;
                        }
                        i++;
                        while(i<class_elem_values.size()&&class_elem_values[i]!=')'){
                            if(class_elem_values[i]!=','){
                                element+=class_elem_values[i];
                                if(i == class_elem_values.size()-2){
                                    arg_values.push_back(element);
                                    element = "";
                                }
                            }
                            else{
                                arg_values.push_back(element);
                                element = "";
                            }
                            i++;
                        }
                        if(temp_class->table["__init__"].total_args - 1 != arg_values.size()){
                            cout<<"Line "<<prev_lineno<<" Error: Constructor of class "<<g_type<<" expects "<<temp_class->table["__init__"].total_args<<" arguments"<<endl;
                            exit(1);
                        }
                        if(temp_class->table.find("__init__") == temp_class->table.end()){
                            cout<<"Line "<<prev_lineno<<" Error: Class "<<g_type<<" has no constructor"<<endl;
                            exit(1);
                        }
                        SymbolTable* ctor = temp_class->table["__init__"].ptr;
                        vector<pair<int,string> > init_args;
                        for(auto it: ctor->table){
                            if(it.second.arg_num != -1){
                                init_args.push_back({it.second.arg_num, it.second.type});
                            }
                        }
                        if(init_args[init_args.size()-1].second == "NA"){
                            init_args.pop_back();
                        }
                        reverse(init_args.begin(), init_args.end());

                        for(int i = 0; i < arg_values.size(); i++){
                            if(init_args[i].second != getType(arg_values[i])){
                                cout<<"Line "<<prev_lineno<<" Error: Expected "<<init_args[i].second<<", but "<<getType(arg_values[i])<<" provided"<<endl;
                                exit(1);
                            }
                        }
                        current_scope->add_entry(lex_name, g_type, 8, prev_lineno, NULL, -1, -1, "NAME", -1);
                    }
                    else{
                        cout<<"Line "<<prev_lineno<<" Error: Unexpected type"<<endl;
                    }
                }
                else{
                    list_g_type = g_type.substr(5);
                    list_g_type.pop_back();
                    string list_elem_values = traverseAndConcatenate($3);
                    list_elem_values = list_elem_values.substr(2);
                    list_elem_values.pop_back();
                    string element = "";
                    for(int i = 0; i < list_elem_values.size(); i++){
                        if(list_elem_values[i]!=','){
                            element+=list_elem_values[i];
                        }
                        else{
                            string type_of_elem = getType(element);
                            if(type_of_elem != list_g_type){
                                if(list_g_type=="float" && type_of_elem=="int"){
                                    element = "";
                                    continue;
                                }
                                else if(list_g_type=="int" && type_of_elem=="float"){
                                    element = "";
                                    continue;
                                }
                                else if(list_g_type=="bool" && type_of_elem=="int"){
                                    element = "";
                                    continue;
                                }
                                else if(list_g_type=="bool" && type_of_elem=="float"){
                                    element = "";
                                    continue;
                                }
                                else if(type_of_elem == "bool" && list_g_type == "int"){
                                    element = "";
                                    continue;
                                    
                                }
                                else if(type_of_elem == "bool" && list_g_type == "float"){
                                    element = "";
                                    continue;
                                    
                                }
                                else{
                                    cout<<"Line "<< prev_lineno <<": List contains element of a type other than the declaration"<<endl;
                                    exit(1);
                                }
                                
                            }
                            element = "";
                        }
                    }
                    // For the last element
                    if(element!=""){
                        string type_of_elem = getType(element);
                        if(type_of_elem != list_g_type){
                            if(list_g_type=="float" && type_of_elem=="int"){
                                element = "";
                            }
                            else if(list_g_type=="int" && type_of_elem=="float"){
                                element = "";
                            }
                            else if(list_g_type=="bool" && type_of_elem=="int"){
                                element = "";
                            }
                            else if(list_g_type=="bool" && type_of_elem=="float"){
                                element = "";
                            }
                            else if(type_of_elem == "bool" && list_g_type == "int"){
                                element = "";
                                
                            }
                            else if(type_of_elem == "bool" && list_g_type == "float"){
                                element = "";
                                
                            }
                            else{
                                cout<<"Line "<< prev_lineno <<": List contains element of a type other than the declaration"<<endl;
                                exit(1);
                            }
                        }      
                    }
                    int temp_size = list_elems*sizeof_(list_g_type);
                    current_scope->add_entry(lex_name, g_type, 8, prev_lineno, NULL, -1, -1, "LIST", list_elems);
                    offset_global += 8;
                }
            }
            else {
                if($3 == NULL){
                    int temp_size;
                    if(g_type =="str") temp_size = 8;
                    else temp_size = sizeof_(g_type);
                    current_scope->add_entry(lex_name, g_type, sizeof_(g_type), prev_lineno, NULL, -1, -1,  "NAME", -1);
                    offset_global += temp_size;
                }
                else{
                    string value = $3->children[1]->valy;
                    string v_type = $3->type;
                    int temp_size;
                    if(g_type =="str") temp_size = 8;
                    else temp_size = sizeof_(g_type);
                    if(value!="atom"){

                        if(g_type == v_type){
                            // cout<<"HI"<<endl;
                            current_scope->add_entry(lex_name, g_type, temp_size, prev_lineno, NULL, -1, -1,  "NAME", -1);
                            offset_global += temp_size;
                            
                        }
                        else if(g_type == "int" && value == "True"){
                            current_scope->add_entry(lex_name, g_type, temp_size, prev_lineno, NULL, -1, -1,  "NAME", -1);
                            offset_global += temp_size;

                        }
                        else if(g_type == "int" && value == "False"){
                            current_scope->add_entry(lex_name, g_type, temp_size, prev_lineno, NULL, -1, -1,  "NAME", -1);
                            offset_global += temp_size;
                        }
                        else if(g_type == "bool" && v_type == "int"){
                            if(stoi(value) <= 0){
                                current_scope->add_entry(lex_name, g_type, temp_size, prev_lineno, NULL, -1, -1,  "NAME", -1);
                                offset_global += temp_size;
                            }
                            else{
                                current_scope->add_entry(lex_name, g_type, temp_size, prev_lineno, NULL, -1, -1,  "NAME", -1);
                                offset_global += temp_size;
                            }
                        }
                        else if(g_type == "float" && v_type == "int"){
                            current_scope->add_entry(lex_name, g_type, temp_size, prev_lineno, NULL, -1, -1, "NAME", -1);
                            offset_global += temp_size;
                        }
                        else if(g_type == "int" && v_type == "float"){
                            current_scope->add_entry(lex_name, g_type, temp_size, prev_lineno, NULL, -1, -1, "NAME", -1);
                            offset_global += temp_size;
                        }
                        else if(g_type == "float" && value == "True"){
                            current_scope->add_entry(lex_name, g_type, temp_size, prev_lineno, NULL, -1, -1, "NAME", -1);
                            offset_global += temp_size;
                        }
                        else if(g_type == "float" && value == "False"){
                            current_scope->add_entry(lex_name, g_type, temp_size, prev_lineno, NULL, -1, -1, "NAME", -1);
                            offset_global += temp_size;
                        }
                        else if(g_type == "bool" && v_type == "float"){
                            if(stof(value) <= 0){
                                current_scope->add_entry(lex_name, g_type, temp_size, prev_lineno, NULL, -1, -1, "NAME", -1);
                                offset_global += temp_size;
                            }
                            else{
                                current_scope->add_entry(lex_name, g_type, temp_size, prev_lineno, NULL, -1, -1,  "NAME", -1);
                                offset_global += temp_size;
                            }
                        }
                        // else{
                        //     cout<<" Error: Expected "<< g_type<<", but "<<v_type<<" provided"<<endl;
                        //     exit(1);
                        // }
                        else{
                            cout<<"Line "<<prev_lineno<<" Error: Expected "<< g_type<<", but "<<v_type<<" provided"<<endl;
                            exit(1);
                        }
                    }
                }
            }
        }
        else{
            if(g_type!="float" && g_type!="int" && g_type!="bool" && g_type!="str" && g_type!="char"){
                if(g_type.substr(0,5)!="list["){
                    if(lookup(g_type)->type == "class"){
                        SymbolTable* temp_class = lookup(g_type)->ptr;
                        string element = "";
                        string class_elem_values = traverseAndConcatenate($3);
                        vector<string> arg_values;
                        int i=0;
                        while(i<class_elem_values.size()&&class_elem_values[i]!='('){
                            i++;
                        }
                        i++;
                        while(i<class_elem_values.size()&&class_elem_values[i]!=')'){
                            if(class_elem_values[i]!=','){
                                element+=class_elem_values[i];
                                if(i == class_elem_values.size()-2){
                                    arg_values.push_back(element);
                                    element = "";
                                }
                            }
                            else{
                                arg_values.push_back(element);
                                element = "";
                            }
                            i++;
                        }
                        if(temp_class->table["__init__"].total_args != arg_values.size()){
                            cout<<"Line "<<prev_lineno<<" Error: Constructor of class "<<g_type<<" expects "<<temp_class->table["__init__"].total_args<<" arguments"<<endl;
                            exit(1);
                        }
                        if(temp_class->table.find("__init__") == temp_class->table.end()){
                            cout<<"Line "<<prev_lineno<<" Error: Class "<<g_type<<" has no constructor"<<endl;
                            exit(1);
                        }
                        SymbolTable* ctor = temp_class->table["__init__"].ptr;
                        vector<pair<int,string> > init_args;
                        for(auto it: ctor->table){
                            if(it.second.arg_num != -1){
                                init_args.push_back({it.second.arg_num, it.second.type});
                            }
                        }
                        reverse(init_args.begin(), init_args.end());
                        for(int i = 0; i < arg_values.size(); i++){
                            if(init_args[i].second != getType(arg_values[i])){
                                cout<<"Line "<<prev_lineno<<" Error: Expected "<<init_args[i].second<<", but "<<getType(arg_values[i])<<" provided"<<endl;
                                exit(1);
                            }
                        }
                        current_scope->add_entry(lex_name, g_type, 8, prev_lineno, NULL, -1, -1, "NAME", -1);
                        
                    }
                    else{
                        cout<<"Line "<<prev_lineno<<" Error: Unexpected type"<<endl;
                    }
                }
                else{
                    list_g_type = g_type.substr(5);
                    list_g_type.pop_back();
                    string list_elem_values = traverseAndConcatenate($3);
                    list_elem_values = list_elem_values.substr(2);
                    list_elem_values.pop_back();
                    string element = "";
                    for(int i = 0; i < list_elem_values.size(); i++){
                        if(list_elem_values[i]!=','){
                            element+=list_elem_values[i];
                        }
                        else{
                            string type_of_elem = getType(element);
                            if(type_of_elem != list_g_type){
                                if(list_g_type=="float" && type_of_elem=="int"){
                                    element = "";
                                    continue;
                                }
                                else if(list_g_type=="int" && type_of_elem=="float"){
                                    element = "";
                                    continue;
                                }
                                else if(list_g_type=="bool" && type_of_elem=="int"){
                                    element = "";
                                    continue;
                                }
                                else if(list_g_type=="bool" && type_of_elem=="float"){
                                    element = "";
                                    continue;
                                }
                                else if(type_of_elem == "bool" && list_g_type == "int"){
                                    element = "";
                                    continue;
                                    
                                }
                                else if(type_of_elem == "bool" && list_g_type == "float"){
                                    element = "";
                                    continue;
                                    
                                }
                                else{
                                    cout<<"Line "<< prev_lineno <<": List contains element of a type other than the declaration"<<endl;
                                    exit(1);
                                }
                                
                            }
                            element = "";
                        }
                        // For the last element
                        if(element!=""){
                            string type_of_elem = getType(element);
                            if(type_of_elem != list_g_type){
                                if(list_g_type=="float" && type_of_elem=="int"){
                                    element = "";
                                }
                                else if(list_g_type=="int" && type_of_elem=="float"){
                                    element = "";
                                }
                                else if(list_g_type=="bool" && type_of_elem=="int"){
                                    element = "";
                                }
                                else if(list_g_type=="bool" && type_of_elem=="float"){
                                    element = "";
                                }
                                else if(type_of_elem == "bool" && list_g_type == "int"){
                                    element = "";
                                    
                                }
                                else if(type_of_elem == "bool" && list_g_type == "float"){
                                    element = "";
                                    
                                }
                                else{
                                    cout<<"Line "<< prev_lineno <<": List contains element of a type other than the declaration"<<endl;
                                    exit(1);
                                }
                            }      
                        }
                    }
                    int temp_size = list_elems*sizeof_(list_g_type);
                    current_scope->add_entry(self_lex_name, g_type, 8, prev_lineno, NULL, -1, -1, "LIST", list_elems);
                    offset_global += 8;
                }
            }
            else {
                // string Sself_lex_name = "self." + self_lex_name;
                class_offset = offset_stack.top();
                current_scope = current_scope->parent;
                if($3 == NULL){
                    int temp_size;
                    if(g_type =="str") temp_size = 8;
                    else temp_size = sizeof_(g_type);
                    current_scope->add_entry_for_self(self_lex_name, g_type, temp_size, class_offset, prev_lineno, NULL, -1, -1, "NAME", -1);
                    offset_stack.pop();
                    class_offset += temp_size;
                    offset_stack.push(class_offset);
                    self_lex_name = "";
                }
                else{
                    string value = $3->children[1]->valy;
                    int temp_size;
                    string v_type = $3->type;
                    if(g_type =="str") temp_size = 8;
                    else temp_size = sizeof_(g_type);
                    if(g_type == v_type){
                        current_scope->add_entry_for_self(self_lex_name, g_type, temp_size, class_offset, prev_lineno, NULL, -1, -1, "NAME", -1);
                        offset_stack.pop();
                        class_offset += temp_size;
                        offset_stack.push(class_offset);
                        self_lex_name = "";
                    }
                    else if(g_type == "int" && value == "True"){
                        current_scope->add_entry_for_self(self_lex_name, g_type, temp_size, class_offset, prev_lineno, NULL, -1, -1, "NAME", -1);
                        offset_stack.pop();
                        class_offset += temp_size;
                        offset_stack.push(class_offset);
                        self_lex_name = "";
                    }
                    else if(g_type == "int" && value == "False"){
                        current_scope->add_entry_for_self(self_lex_name, g_type, temp_size, class_offset, prev_lineno, NULL, -1, -1, "NAME", -1);
                        offset_stack.pop();
                        class_offset += temp_size;
                        offset_stack.push(class_offset);
                        self_lex_name = "";
                    }
                    else if(g_type == "bool" && v_type == "int"){
                        if(stoi(value) <= 0){
                            current_scope->add_entry_for_self(self_lex_name, g_type, temp_size, class_offset, prev_lineno, NULL, -1, -1, "NAME", -1);
                            offset_stack.pop();
                            class_offset += temp_size;
                            offset_stack.push(class_offset);
                            self_lex_name = "";
                        }
                        else{
                            current_scope->add_entry_for_self(self_lex_name, g_type, temp_size, class_offset, prev_lineno, NULL, -1, -1, "NAME", -1);
                            offset_stack.pop();
                            class_offset += temp_size;
                            offset_stack.push(class_offset);
                            self_lex_name = "";
                        }
                    }
                    else if(g_type == "float" && v_type == "int"){
                        current_scope->add_entry_for_self(self_lex_name, g_type, temp_size, class_offset, prev_lineno, NULL, -1, -1, "NAME", -1);
                        offset_stack.pop();
                        class_offset += temp_size;
                        offset_stack.push(class_offset);
                        self_lex_name = "";
                    }
                    else if(g_type == "int" && v_type == "float"){
                        current_scope->add_entry_for_self(self_lex_name, g_type, temp_size, class_offset, prev_lineno, NULL, -1, -1, "NAME", -1);
                        offset_stack.pop();
                        class_offset += temp_size;
                        offset_stack.push(class_offset);
                        self_lex_name = "";
                    }
                    else if(g_type == "float" && value == "True"){
                        current_scope->add_entry_for_self(self_lex_name, g_type, temp_size, class_offset, prev_lineno, NULL, -1, -1, "NAME", -1);
                        offset_stack.pop();
                        class_offset += temp_size;
                        offset_stack.push(class_offset);
                        self_lex_name = "";
                    }
                    else if(g_type == "float" && value == "False"){
                        current_scope->add_entry_for_self(self_lex_name, g_type, temp_size, class_offset, prev_lineno, NULL, -1, -1, "NAME", -1);
                        offset_stack.pop();
                        class_offset += temp_size;
                        offset_stack.push(class_offset);
                        self_lex_name = "";
                    }
                    else if(g_type == "bool" && v_type == "float"){
                        if(stof(value) <= 0){
                            current_scope->add_entry_for_self(self_lex_name, g_type, temp_size, class_offset, prev_lineno, NULL, -1, -1, "NAME", -1);
                            offset_stack.pop();
                        class_offset += temp_size;
                        offset_stack.push(class_offset);
                            self_lex_name = "";
                        }
                        else{
                            current_scope->add_entry_for_self(self_lex_name, g_type, temp_size, class_offset, prev_lineno, NULL, -1, -1, "NAME", -1);
                            offset_stack.pop();
                        class_offset += temp_size;
                        offset_stack.push(class_offset);
                            self_lex_name = "";
                        }
                    }
                    else{
                        cout<<"Line "<<prev_lineno<<" Error: Expected "<< g_type<<", but "<<v_type<<" provided"<<endl;
                        exit(1);
                    }
                }
            }
        }
        string temp = string("COLON (") + $1 + ")";
        if($2 == NULL && $3 == NULL){
            $$ = createNode($1);
        }
        else{
            $$ = createNode ("annassign");
            $$->children.push_back(createNode($1));
            $$->children.push_back($2);
            $$->children.push_back($3);
            // cout<<$3->tempvar<<endl;
            strcpy($$->tempvar, $3->tempvar);
            strcpy($$->type, $3->type);
            string t1 = $2->valy;
            string t2 = $3->type;

            if(typecheck(t1,t2) == 0){
                cout<<"Line "<<prev_lineno<<": Type mismatch"<<endl;
                exit(1);
            }
            
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
            $$ = createNode($1);
        }
        else{
            $$ = createNode("f_typedargslist");
            $$->children.push_back(createNode($1));
            $$->children.push_back($2);
        }
        // cout<<$2->tempvar<<endl;
        strcpy($$->tempvar, $2->tempvar);
        strcpy($$->type, $2->type);
        // cout<<$$->tempvar<<endl;
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
                // Might have to set differently
                lex_name = $1->valy;
                
            }
            else{
                $$ = createNode("testlist_star_expr");
                $$->children.push_back($1);
                $$->children.push_back($2);
                $$->children.push_back($3);
                lex_name = $1->valy;
            }
        }
    }
    ;

testlist_star_expr_continue:
    testlist_star_expr_continue COMMA f_test_star_expr_continue
    {
        string temp = string("COMMA (") + $2 + ")";
        if($1 == NULL && $3 == NULL){
            $$ = createNode($2);
        }
        else{
            $$ = createNode("testlist_star_expr_continue");
            $$->children.push_back($1);
            $$->children.push_back(createNode($2));
            $$->children.push_back($3);
            lex_name = $3->valy;
            
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
        $$ = createNode($1); 
        // createNode("augassign");
        // $$->children.push_back(createNode($1));
    }
    | MINEQUAL
    {
        string temp = string("MINEQUAL (") + $1 + ")";
        $$ = createNode($1);
        // createNode("augassign");
        // $$->children.push_back(createNode($1));
    }
    | STAREQUAL 
    {
        string temp = string("STAREQUAL (") + $1 + ")";
        $$ = createNode($1);
        // createNode("augassign");
        // $$->children.push_back(createNode($1));
    }
    | SLASHEQUAL 
    {
        string temp = string("SLASHEQUAL (") + $1 + ")";
        $$ = createNode($1);
        // createNode("augassign");
        // $$->children.push_back(createNode($1));
    }
    | PERCENTEQUAL 
    {
        string temp = string("PERCENTEQUAL (") + $1 + ")";
        $$ = createNode($1);
        // createNode("augassign");
        // $$->children.push_back(createNode($1));
    }
    | AMPERSANDEQUAL 
    {
        string temp = string("AMPERSANEQUAL (") + $1 + ")";
        $$ = createNode($1);
        // createNode("augassign");
        // $$->children.push_back(createNode($1));
    }
    | VBAREQUAL 
    {
        string temp = string("VBAREQUAL (") + $1 + ")";
        $$ = createNode($1);
        // createNode("augassign");
        // $$->children.push_back(createNode($1));
    }
    | CIRCUMFLEXEQUAL 
    {
        string temp = string("CIRCUMFLEXEQUAL (") + $1 + ")";
        $$ = createNode($1);
        // createNode("augassign");
        // $$->children.push_back(createNode($1));
    }
    | LEFTSHIFTEQUAL 
    {
        string temp = string("LEFTSHIFTEQUAL (") + $1 + ")";
        $$ = createNode($1);
        // createNode("augassign");
        // $$->children.push_back(createNode($1));
    }
    | RIGHTSHIFTEQUAL 
    {
        string temp = string("RIGHTSHIFTEQUAL (") + $1 + ")";
        $$ = createNode($1);
        // createNode("augassign");
        // $$->children.push_back(createNode($1));
    }
    | DOUBLESTAREQUAL 
    {
        string temp = string("DOUBLESTAREQUAL (") + $1 + ")";
        $$ = createNode($1);
        // createNode("augassign");
        // $$->children.push_back(createNode($1));
    }
    | DOUBLESLASHEQUAL
    {
        string temp = string("DOUBLESLASHEQUAL (") + $1 + ")";
        $$ = createNode($1);
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
    // string temp = string("BREAK (") + $1 + ")";
        $$ = createNode($1);
        if(recent_loop.top() == "while"){
            gen3AC({"goto ", end_label_while.top()},indent_level);
        }
        else if(recent_loop.top() == "for"){
            gen3AC({"goto ", end_label_for.top()},indent_level);
        }
        else{
            cout<<"Line "<<prev_lineno<<" Error: Break statement outside loop"<<endl;
        }
        // createNode("break_stmt");
        // $$->children.push_back(createNode($1));

    } 
    ;

continue_stmt: 
    CONTINUE
    {
        if(recent_loop.top() == "while"){
            gen3AC({"goto ", start_label_while.top()},indent_level);
        }
        else if(recent_loop.top() == "for"){
            gen3AC({"goto ", start_label_for.top()},indent_level);
        }
        else{
            cout<<"Line "<<prev_lineno<<" Error: Break statement outside loop"<<endl;
        }
        string temp = string("CONTINUE (") + $1 + ")";
        $$ = createNode($1);
        // createNode("continue_stmt");
        // $$->children.push_back(createNode($1));
    }
    ;

return_stmt: 
    RETURN f_return_stmt
    {
        // string temp = string("RETURN (") + $1 + ")";
        if($2 == NULL){
            $$ = createNode($1);
        }
        else{
            $$ = createNode("return_stmt");
            $$->children.push_back(createNode($1));
            $$->children.push_back($2);
        }
        gen3AC({"push ", $2->tempvar},indent_level);
        gen3AC({"return"},indent_level);
        string t1 = $2->type;
        string t2 = function_name.top();
        if(typecheck(t1,t2) == 0){
            cout<<"Line "<<prev_lineno<<" Error: Unexpected return type"<<endl;
            exit(1);
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
        isreturned = 1;
        // createNode("f_return_stmt");
        // $$->children.push_back($1);
    }
    ;

raise_stmt: 
    RAISE f_raise_stmt
    {
        string temp = string("RAISE (") + $1 + ")";
        if($2 == NULL){
            $$ = createNode($1);
        }
        else{
            $$ = createNode("raise_stmt");
            $$->children.push_back(createNode($1));
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
            $$ = createNode($1);
        }
        else{
            $$ = createNode("ff_raise_stmt");
            $$->children.push_back(createNode($1));
            $$->children.push_back($2);
        }
    }
    ;

global_stmt: 
    GLOBAL NAME
    {
        string temp = string("GLOBAL (") + $1 + ")";
        global_lookup($2);
        $$ = createNode("global_stmt");
        $$->children.push_back(createNode($1));
        // temp = string("NAME (") + $2 + ")";
        $$->children.push_back(createNode($2));
    }
    | global_stmt COMMA NAME
    {
        string temp = string("COMMA (") + $2 + ")";
        global_lookup($3);
        $$ = createNode("global_stmt");
        $$->children.push_back($1);
        $$->children.push_back(createNode($2));
        // temp = string("NAME (") + $3 + ")";
        $$->children.push_back(createNode($3));
    }
    ;

nonlocal_stmt: 
    NONLOCAL NAME
    {
        string temp = string("NONLOCAL (") + $1 + ")";
        $$ = createNode("nonlocal_stmt");
        $$->children.push_back(createNode($1));
        // temp = string("NAME (") + $2 + ")";
        $$->children.push_back(createNode($2));
    }
    | nonlocal_stmt COMMA NAME
    {
        string temp = string("COMMA (") + $2 + ")";
        $$ = createNode("nonlocal_stmt");
        $$->children.push_back($1);
        $$->children.push_back(createNode($2));
        // temp = string("NAME (") + $3 + ")";
        $$->children.push_back(createNode($3));
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
    IF {
        // string Lstart = newLabel();
        // start_label_if.push(Lstart);
        is_if = 1;
        string Lend = newLabel();
        end_label_if.push(Lend);
        string Lmid = newLabel();
        temp_label_if.push(Lmid);
    } test COLON{
        gen3AC({"ifz ", $3->tempvar, " goto ", temp_label_if.top()},indent_level);
    } suite if_stmt_continue f_cond_stmt
    {
        $$ = createNode("if_stmt");
        $$->children.push_back(createNode($1));
        $$->children.push_back($3);
        // temp = string("COLON (") + $3 + ")";
        $$->children.push_back(createNode($4));
        $$->children.push_back($6);
        $$->children.push_back($7);
        $$->children.push_back($8);
        // if($7 == NULL && $8 == NULL){
        
        if($8 == NULL){
            gen3AC({temp_label_if.top(), ": "},indent_level);
        }
        temp_label_if.pop();
        gen3AC({end_label_if.top(), ": "},indent_level);
        end_label_if.pop();
        // }
        is_if = 0;
    }
    ;

if_stmt_continue:
     
    {
        $$ = NULL;
        // $$->children.push_back(createNode("EMPTY"));
    }
    | if_stmt_continue ELIF {
        string temp = temp_label_if.top();
        temp_label_if.pop();
        string current = end_label_if.top();
        gen3AC({"goto ", current},indent_level);
        gen3AC({temp, ": "},indent_level);
    }test COLON{
        string Lmid = newLabel();
        temp_label_if.push(Lmid);
        gen3AC({"ifz ",$4->tempvar, " goto ", temp_label_if.top()},indent_level);
    } suite
    {
        // gen3AC({end_label_if.top(),": "});
        $$ = createNode("if_stmt_continue");
        $$->children.push_back($1);
        $$->children.push_back(createNode($2));
        $$->children.push_back($4);
        // temp = string("COLON (") + $4 + ")";
        $$->children.push_back(createNode($5));
        $$->children.push_back($7);
    }
    ;

f_cond_stmt:
     
    {
        $$ = NULL;
        // $$->children.push_back(createNode("EMPTY"));
    }
    | ELSE COLON {
        string temp = temp_label_if.top();
        temp_label_if.pop();
        string current = end_label_if.top();
        string Lmid = newLabel();
        temp_label_if.push(Lmid);
        gen3AC({"goto ", current},indent_level);
        gen3AC({temp, ": "},indent_level);
    }suite
    {

        string temp = string("ELSE (") + $1 + ")";
        $$ = createNode("f_cond_stmt");
        $$->children.push_back(createNode($1));
        temp = string("COLON (") + $2 + ")";
        $$->children.push_back(createNode($2));
        $$->children.push_back($4);
    }
    ;

while_stmt: 
    WHILE{
        recent_loop.push("while");
        string Lstart = newLabel();
        start_label_while.push(Lstart);
        string Lend = newLabel();
        end_label_while.push(Lend);
        gen3AC({start_label_while.top() , ": "},indent_level);
    } test COLON{
        gen3AC({"ifz ", $3->tempvar, " goto ", end_label_while.top()},indent_level);
    } suite f_cond_stmt
    {
        
        // string temp = string("WHILE (") + $1 + ")";
        $$ = createNode("while_stmt");
        $$->children.push_back(createNode($1));
        $$->children.push_back($3);
        // temp = string("COLON (") + $4 + ")";
        $$->children.push_back(createNode($4));
        $$->children.push_back($6);
        $$->children.push_back($7);
        if($7 == NULL){
            gen3AC({"goto ", start_label_while.top()},indent_level);
            gen3AC({end_label_while.top(), ": "},indent_level);
            start_label_while.pop();
            end_label_while.pop();
        }
        recent_loop.pop();
    }
    ;

for_stmt: 
    FOR {
        string Lstart = newLabel();
        start_label_for.push(Lstart);
        string Lmid = newLabel();
        mid_label_for.push(Lmid);
        string Lend = newLabel();
        end_label_for.push(Lend);
        recent_loop.push("for");
    
    }exprlist IN testlist COLON{
        lookup($3->valy);
        gen3AC({$3 -> valy, " = ", range_temp[0]},indent_level);
        gen3AC({"goto ", mid_label_for.top()},indent_level);
        gen3AC({start_label_for.top() , ": "},indent_level);
        gen3AC({range_temp[0], " = ",  $3->valy, " + ", range_temp[2]},indent_level);
        gen3AC({$3->valy, " = ", range_temp[0]},indent_level);
        gen3AC({mid_label_for.top(), ": "},indent_level);
        gen3AC({"ifz ",range_temp[0], " < ", range_temp[1], " goto ", end_label_for.top()},indent_level);
    } suite f_cond_stmt
    {
        gen3AC({"goto ", start_label_for.top()},indent_level);
        gen3AC({end_label_for.top() + ": "},indent_level);

        range_temp.clear();
        start_label_for.pop();
        mid_label_for.pop();
        end_label_for.pop();

        string temp = string("FOR (") + $1 + ")";
        $$ = createNode("for_stmt");
        $$->children.push_back(createNode($1));
        $$->children.push_back($3);
        // temp = string("IN (") + $4 + ")";
        $$->children.push_back(createNode($4));
        $$->children.push_back($5);
        // temp = string("COLON (") + $5 + ")";
        $$->children.push_back(createNode($6));
        $$->children.push_back($8);
        $$->children.push_back($9);
        recent_loop.pop();
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
        $$ = createNode("f_test");
        $$->children.push_back(createNode($1));
        $$->children.push_back($2);
        // temp = string("ELSE (") + $3 + ")";
        $$->children.push_back(createNode($3));
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
            $$ = createNode($2);
        }
        else{
            $$ = createNode(traverseAndConcatenate($1)+"or"+traverseAndConcatenate($3));
            $$->children.push_back($1);
            $$->children.push_back(createNode($2));
            $$->children.push_back($3);
            strcpy($$->tempvar, newtemp().c_str());
            strcpy($$->type, $1->type);
            string t1 = $1->type;
            string t2 = $3->type;
            if(typecheck(t1,t2)){
                gen3AC({$$->tempvar," = ", $1->tempvar," ", $2, " ", $3->tempvar},indent_level);
            }
            else{
                cout<<"Line "<<prev_lineno<<" Error: Type mismatch2"<<endl;
                exit(1);
            }
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
            $$ = createNode($2);
        }
        else{
            $$ = createNode(traverseAndConcatenate($1)+"and"+traverseAndConcatenate($3));
            $$->children.push_back($1);
            $$->children.push_back(createNode($2));
            $$->children.push_back($3);
            strcpy($$->tempvar, newtemp().c_str());
            strcpy($$->type, $1->type);
            string t1 = $1->type;
            string t2 = $3->type;
            if(typecheck(t1,t2)){
                gen3AC({$$->tempvar," = ", $1->tempvar," ", $2, " ", $3->tempvar},indent_level);
            }
            else{
                cout<<"Line "<< prev_lineno<<" Error: Type mismatch3"<<endl;
                exit(1);
            }
        }
    }
    ;

not_test: 
    NOT not_test
    {   
        string temp = string("NOT (") + $1 + ")";
        if($2 == NULL){
            $$ = createNode($1);
        }
        else{
            $$ = createNode(traverseAndConcatenate($2));
            $$->children.push_back(createNode($1));
            $$->children.push_back($2);
            strcpy($$->tempvar, newtemp().c_str());
            strcpy($$->type, $2->type);
            gen3AC({$$->tempvar," = ", $1, " ", $2->tempvar},indent_level);
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
        // cout << $$->valy << endl;
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
                $$ = createNode(traverseAndConcatenate($1)+traverseAndConcatenate($2)+traverseAndConcatenate($3));
                $$->children.push_back($1);
                $$->children.push_back($2);
                $$->children.push_back($3);
                strcpy($$->tempvar, newtemp().c_str());
                strcpy($$->type, $1->type);
                string t1 = $1->type;
                string t2 = $3->type;
                if(typecheck(t1,t2)){
                    gen3AC({$$->tempvar," = ", $1->tempvar," ", $2->valy, " ", $3->tempvar},indent_level);
                }
                else{
                    cout<<"Line "<<prev_lineno<<" Error: Type mismatch4"<<endl;
                    exit(1);
                }
            }
        }
    }
    ;

comp_op: 
    LESSTHAN
    {
        string temp = string("LESSTHAN (") + $1 + ")";
        $$ = createNode($1);
        // createNode("comp_op");
        // $$->children.push_back(createNode($1));
    }
    | GREATERTHAN
    {
        string temp = string("GREATERTHAN (") + $1 + ")";
        $$ = createNode($1);
        // createNode("comp_op");
        // $$->children.push_back(createNode($1));
    }
    | EQEQUAL
    {
        string temp = string("EQEQUAL (") + $1 + ")";
        $$ = createNode($1);
        // createNode("comp_op");
        // $$->children.push_back(createNode($1));
    }
    | GREATEREQUAL
    {
        string temp = string("GREATEREQUAL (") + $1 + ")";
        $$ = createNode($1);
        // createNode("comp_op");
        // $$->children.push_back(createNode($1));
    }
    | LESSEQUAL
    {
        string temp = string("LESSEQUAL (") + $1 + ")";
        $$ = createNode($1); 
        // createNode("comp_op");
        // $$->children.push_back(createNode($1));
    }
    | NOTEQUAL
    {
        string temp = string("NOTEQUAL (") + $1 + ")";
        $$ = createNode($1);
        // createNode("comp_op");
        // $$->children.push_back(createNode($1));
    }
    | IN
    {
        string temp = string("IN (") + $1 + ")";
        $$ = createNode($1);
        // createNode("comp_op");
        // $$->children.push_back(createNode($1));
    }
    | NOT IN
    {
        string temp = string("NOT (") + $1 + ")";
        $$ = createNode("comp_op");
        $$->children.push_back(createNode($1));
        temp = string("IN (") + $2 + ")";
        $$->children.push_back(createNode($2));
    }
    | IS
    {
        string temp = string("IS (") + $1 + ")";
        $$ = createNode($1);
        // createNode("comp_op");
        // $$->children.push_back(createNode($1));
    }
    | IS NOT
    {
        string temp = string("IS (") + $1 + ")";
        $$ = createNode("comp_op");
        $$->children.push_back(createNode($1));
        temp = string("NOT (") + $2 + ")";
        $$->children.push_back(createNode($2));
    }
    ;

star_expr:
    STAR expr
    {
        string temp = string("STAR (") + $1 + ")";
        if($2 == NULL){
            $$ = createNode($1);
        }
        else{
            $$ = createNode("star_expr");
            $$->children.push_back(createNode($1));
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
            $$ = createNode($2);
        }
        else{
            $$ = createNode("expr");
            $$->children.push_back($1);
            $$->children.push_back(createNode($2));
            $$->children.push_back($3);
            strcpy($$->tempvar, newtemp().c_str());
            strcpy($$->type, $1->type);
            string t1 = $1->type;
            string t2 = $3->type;
            if(typecheck(t1,t2)){
                gen3AC({$$->tempvar," = ", $1->tempvar," ", $2, " ", $3->tempvar},indent_level);
            }
            else{
                cout<<"Line "<<prev_lineno<<" Error: Type mismatch5"<<endl;
                exit(1);
            }
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
            $$ = createNode($2);
        }
        else{
            $$ = createNode(traverseAndConcatenate($1)+"^"+traverseAndConcatenate($3));
            $$->children.push_back($1);
            $$->children.push_back(createNode($2));
            $$->children.push_back($3);
            strcpy($$->tempvar, newtemp().c_str());
            strcpy($$->type, $1->type);
            string t1 = $1->type;
            string t2 = $3->type;
            if(typecheck(t1,t2)){
                gen3AC({$$->tempvar," = ", $1->tempvar," ", $2, " ", $3->tempvar},indent_level);
            }
            else{
                cout<<"Line "<<prev_lineno<<" Error: Type mismatch6"<<endl;
                exit(1);
            }
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
            $$ = createNode($2);
        }
        else{
            $$ = createNode(traverseAndConcatenate($1)+"&"+traverseAndConcatenate($3));
            $$->children.push_back($1);
            $$->children.push_back(createNode($2));
            $$->children.push_back($3);
            strcpy($$->tempvar, newtemp().c_str());
            strcpy($$->type, $1->type);
            string t1 = $1->type;
            string t2 = $3->type;
            if(typecheck(t1,t2)){
                gen3AC({$$->tempvar," = ", $1->tempvar," ", $2, " ", $3->tempvar},indent_level);
            }
            else{
                cout<<"Line "<<prev_lineno<<" Error: Type mismatch7"<<endl;
                exit(1);
            }
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
                $$ = createNode(traverseAndConcatenate($1)+traverseAndConcatenate($2)); 
                $$->children.push_back($1);
                $$->children.push_back($2);
                strcpy($$->tempvar, newtemp().c_str());
                strcpy($$->type, $2->type);
                string t1 = $1->type;
                string t2 = $2->type;
                if(typecheck(t1,t2)){
                    gen3AC({$$->tempvar," = ", $1->tempvar, $2->children[0]->valy,$2->children[1]->tempvar},indent_level);
                }
                else{
                    cout<<"Line "<<prev_lineno<<" Error: Type mismatch8"<<endl;
                    exit(1);
                }
            }
        }
    }
    ;

f_shift_expr:
    LEFTSHIFT arith_expr
    {
        string temp = string("LEFTSHIFT (") + $1 + ")";
        if($2 == NULL){
            $$ = createNode($1);
        }
        else{
            $$ = createNode("f_shift_expr");
            $$->children.push_back(createNode($1));
            $$->children.push_back($2);
            strcpy($$->tempvar, $2->tempvar);
            strcpy($$->type, $2->type);
        }
    }
    | RIGHTSHIFT arith_expr
    {
        string temp = string("RIGHTSHIFT (") + $1 + ")";
        if($2 == NULL){
            $$ = createNode($1);
        }
        else{
            $$ = createNode("f_shift_expr");
            $$->children.push_back(createNode($1));
            $$->children.push_back($2);
            strcpy($$->tempvar, $2->tempvar);
            strcpy($$->type, $2->type);
        }
    }
    ;

arith_expr: 
    term
    {
        $$ = $1;
        // cout << $$->valy << endl;
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
                // $$ = createNode("arith_expr");
                // // $$ = createNode(traverseAndConcatenate($1)+traverseAndConcatenate($2));
                // $$->children.push_back($1);
                // $$->children.push_back($2);


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
                strcpy($$->tempvar, newtemp().c_str());
                strcpy($$->type, $2->type);
                string t1 = $1->type;
                string t2 = $2->type;
                if(typecheck(t1,t2)){
                    gen3AC({$$->tempvar," = ", $1->tempvar, " ", $2->children[0]->valy, " ", $2->tempvar},indent_level);
                }
                else{
                    cout<<"Line "<<prev_lineno<<" Error: Type mismatch9"<<endl;
                    exit(1);
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
            $$ = createNode($1);
        }
        else{

            $$ = createNode("f_arith_expr");
            $$->children.push_back(createNode($1));
            $$->children.push_back($2);
            strcpy($$->tempvar, $2->tempvar);
            strcpy($$->type, $2->type);
        }
    }
    | MINUS term
    {
        string temp = string("MINUS (") + $1 + ")";
        if($2 == NULL){
            $$ = createNode($1);
        }
        else{
            $$ = createNode("f_arith_expr");
            $$->children.push_back(createNode($1));
            $$->children.push_back($2);
            strcpy($$->tempvar, $2->tempvar);
            strcpy($$->type, $2->type);
        }
    }
    ;

term: 
    factor
    {
        $$ = $1;
        string t_class = $1->valy;
        // cout << t_class << endl;
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
                // int cnt = 0;
                // for(auto it: $2->children){
                //     if(cnt == 0){
                //         $$ = createNode(it->valy);
                //         $$->children.push_back($1);
                //         cnt++;
                //         continue;
                //     }
                //     $$->children.push_back(it);
                // }
                $$ = createNode("term");
                $$->children.push_back($1);
                $$->children.push_back($2);
                strcpy($$->tempvar, newtemp().c_str());
                strcpy($$->type, $2->type);
                string t1 = $1->type;
                string t2 = $2->type;

                if(typecheck(t1,t2)){
                    gen3AC({$$->tempvar," = ", $1->tempvar," ", $2->children[0]->valy," ", $2->tempvar},indent_level);
                }
                else{
                    cout<<"Line "<<prev_lineno<<"Error: Type mismatch10"<<endl;
                    exit(1);
                }
            }
        }
    }
    ;

f_term:
    STAR factor
    {
        // strcpy($$->tempvar, newtemp().c_str());
        // gen3AC({$$->tempvar,"=", $1->tempvar, $2->children[0]->valy,$2->children[1]->tempvar});
        string temp = string("STAR (") + $1 + ")";
        if($2 == NULL){
            $$ = createNode($1);
        }
        else{
            $$ = createNode("f_term");
            $$->children.push_back(createNode($1));
            $$->children.push_back($2);
            strcpy($$->tempvar, $2->tempvar);
            strcpy($$->type, $2->type);
        }
    }
    | SLASH factor
    {
        string temp = string("SLASH (") + $1 + ")";
        if($2 == NULL){
            $$ = createNode($1);
        }
        else{
            $$ = createNode("f_term");
            $$->children.push_back(createNode($1));
            $$->children.push_back($2);
            strcpy($$->tempvar, $2->tempvar);
            strcpy($$->type, $2->type);
        }
    }
    | PERCENT factor
    {
        string temp = string("PERCENT (") + $1 + ")";
        if($2 == NULL){
            $$ = createNode($1);
        }
        else{
            $$ = createNode("f_term");
            $$->children.push_back(createNode($1));
            $$->children.push_back($2);
            strcpy($$->tempvar, $2->tempvar);
            strcpy($$->type, $2->type);
        }
    }
    | DOUBLESLASH factor
    {
        string temp = string("DOUBLESLASH (") + $1 + ")";
        if($2 == NULL){
            $$ = createNode($1);
        }
        else{
            $$ = createNode("f_term");
            $$->children.push_back(createNode($1));
            $$->children.push_back($2);
            strcpy($$->tempvar, $2->tempvar);
            strcpy($$->type, $2->type);
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
        // string temp = string("PLUS (") + $1 + ")";
        if($2 == NULL){
            $$ = createNode($1);
        }
        else{
            $$ = createNode("factor");
            $$->children.push_back(createNode($1));
            $$->children.push_back($2);
            strcpy($$->tempvar,$2->tempvar);
            strcpy($$->type,$2->type);
        }
    }
    | MINUS{minus_flag=1;} factor
    {
        minus_flag=0;
        // string temp = string("MINUS (") + $1 + ")";
        if($3 == NULL){
            $$ = createNode($1);
        }
        else{
            $$ = createNode("factor");
            $$->children.push_back(createNode($1));
            $$->children.push_back($3);
            string new_temp = newtemp();
            string tempo = string($3->tempvar);
            strcpy($$->tempvar,new_temp.c_str());
            strcpy($$->type,$3->type);
            string num = $3->valy;
            if((num[0]<'0' && num[0]>'9') || (num[0] == '-'))
            gen3AC({new_temp, " = ", "-", tempo},indent_level);
            else
            gen3AC({new_temp, " = ", "-", num},indent_level);
        }
        $$->valy = "-" + $3->valy;
    }
    | TILDE factor
    {
        string temp = string("TILDE (") + $1 + ")";
        if($2 == NULL){
            $$ = createNode($1);
        }
        else{
            $$ = createNode("factor");
            $$->children.push_back(createNode($1));
            $$->children.push_back($2);
            string tempo = "~" + string($2->tempvar);
            strcpy($$->tempvar,tempo.c_str());
            strcpy($$->type,$2->type);
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
                $$->children.push_back(createNode(traverseAndConcatenate($1)));
                $$->children.push_back($2);
                string new_temp = newtemp();
                gen3AC({new_temp, " = ", $1->tempvar, " ** ", $2->tempvar},indent_level);
                strcpy($$->tempvar, new_temp.c_str());
                strcpy($$->type, $1->type);
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
            $$ = createNode($1);
        }
        else{
            $$ = createNode("f_power");
            $$->children.push_back(createNode($1));
            $$->children.push_back($2);
            strcpy($$->tempvar, $2->tempvar);
            strcpy($$->type, $2->type);
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
    | atom_expr {func_call_name_stack.push(traverseAndConcatenate($1));  if(func_call_name_stack.top() == "range") is_range = 1;} trailer
    {
        is_range = 0;
        if(func_call_name_stack.top() == "range"){
            if(range_values.size()==3){
                string new_temp = newtemp();
                gen3AC({new_temp, " = ", range_values[0]},indent_level);
                range_temp.push_back(new_temp);
                string new_temp2 = newtemp();
                gen3AC({new_temp2, " = ", range_values[1]},indent_level);
                range_temp.push_back(new_temp2);
                string new_temp3 = newtemp();
                gen3AC({new_temp3, " = ", range_values[2]},indent_level);
                range_temp.push_back(new_temp3);
            }
            if(range_values.size()==2){
                string new_temp = newtemp();
                gen3AC({new_temp, " = ", range_values[0]},indent_level);
                range_temp.push_back(new_temp);
                string new_temp2 = newtemp();
                gen3AC({new_temp2, " = ", range_values[1]},indent_level);
                range_temp.push_back(new_temp2);
                string new_temp3 = newtemp();
                gen3AC({new_temp3, " = ", "1"},indent_level);
                range_temp.push_back(new_temp3);
            }
            if(range_values.size()==1){
                string new_temp = newtemp();
                gen3AC({new_temp, " = ", "0"},indent_level);
                range_temp.push_back(new_temp);
                string new_temp2 = newtemp();
                gen3AC({new_temp2, " = ", range_values[0]},indent_level);
                range_temp.push_back(new_temp2);
                string new_temp3 = newtemp();
                gen3AC({new_temp3, " = ", "1"},indent_level);
                range_temp.push_back(new_temp3);
            }
        }
        range_values.clear();
        trailer_flag = 0;
        // func_call_name = traverseAndConcatenate($$);
        if($1 == NULL && $3 == NULL){
            $$ = NULL;
        }
        else{
            if($1 == NULL){
                $$ = $3;
            }
            else if($3 == NULL){
                $$ = $1;
            }
            else{
                $$ = createNode(traverseAndConcatenate($1)+traverseAndConcatenate($3));

                // $$->children.push_back($1);
                // $$->children.push_back($3);
            }
        }
        string tempo = traverseAndConcatenate($1)+traverseAndConcatenate($3);
        if(tempo[tempo.size()-1] == ']'&&tempo.substr(0,5)!= "list["){
            tempo.pop_back();
            string index = "";
            while(tempo[tempo.size()-1] != '['){
                index.push_back(tempo[tempo.size()-1]);
                tempo.pop_back();
            }
            string info = lookup($1->valy)->type;
            if(info.substr(0,5) == "list["){
                info = info.substr(5);
                info.pop_back();

            }
            reverse(index.begin(), index.end());
            tempo.pop_back();
            string new_temp = newtemp();
            gen3AC({new_temp, " = ", $3->tempvar, " * ", to_string((sizeof_(info)))},indent_level);
            string temp1 = newtemp();
            gen3AC({temp1, " = ", tempo, " + ", new_temp},indent_level);
            temp1 = "*(" + temp1 + ")";
            strcpy($1->tempvar, temp1.c_str());
            strcpy($$->tempvar, temp1.c_str());
            strcpy($$->type, info.c_str());
            strcpy($1->type, info.c_str());
        }

        string trailer_store = traverseAndConcatenate($3);
        // cout<<trailer_store<<endl;
        SymbolInfo* temp = NULL;
        if (trailer_store[0] != '.') {
            // cout << trailer_store << endl;
            string func_call_name1 = ""; 
            string func_top_stored = func_call_name_stack.top();  
            // cout << func_top_stored << endl;      
            for(int i =0; i < func_top_stored.size() ;i++){
                if(func_top_stored[i] == '.'){
                    class_ofFunc   = func_top_stored.substr(0,i);
                    func_call_name1 = func_top_stored.substr(i+1);

                    break;
                }
            }
            if (!(class_ofFunc.empty())) {
                string caller = class_ofFunc;
                string callee = func_call_name1;
                SymbolInfo* temp1 = lookup(caller);
                if (temp1->type == "class"){
                    SymbolTable* class_table = temp1->ptr;
                    temp = &(class_table->table[callee]);
                }
                else if (lookup(temp1->type)->type == "class" ) {
                    SymbolTable* class_table = lookup(temp1->type)->ptr;
                    temp = &(class_table->table[callee]);
                }
                class_ofFunc = "";
            }
            if($3->isfunc  && func_call_name_stack.top() != "range"){
                gen3AC({"stackpointer +xxx"},indent_level);
                gen3AC({"call ", func_call_name_stack.top(), " ", to_string(argument_templist.size())},indent_level);
                gen3AC({"stackpointer -yyy"},indent_level);
            }
            if(!len_flag){
                global_table->add_entry("len","int", 0, 0, NULL, 1, -1, "FUNCTION", -1);
                len_flag = 1;
            }
            argument_templist.clear();
            if(!(func_call_name_stack.top() == "print" || func_call_name_stack.top() == "range" || func_call_name_stack.top() == "list")){
                if (temp == NULL) {
                    temp = lookup(func_call_name_stack.top());
                }
                if(func_call_name_stack.top() == "len"){
                    string new_temp = newtemp();
                    // strcpy(new_temp, newtemp().c_str());
                    
                    gen3AC({new_temp, " = ", "popparam"},indent_level);
                    // $$->tempvar = new_temp;
                    strcpy($$->tempvar, new_temp.c_str());
                    strcpy($$->type, "int");
                }
                else if( temp->type != "None" && temp->ptr != NULL){
                    string new_temp = newtemp();
                    // strcpy(new_temp, newtemp().c_str());
                    
                    gen3AC({new_temp, " = ", "popparam"},indent_level);
                    // $$->tempvar = new_temp;
                    strcpy($$->tempvar, new_temp.c_str());
                    strcpy($$->type, temp->type.c_str());
                }
            }
        }
        else if (trailer_store[0] == '.') {
                //self.attribute

                //define -> handle
                //use  self +attribute 
                //class.init
                //object.method
                //object.attribute
                // self + attribute
                //object.variable 



                //NAME -> single variable
                // dot NAME -> attributes,method 
                string atom_name = traverseAndConcatenate($$);
                // cout<<($1->valy)<<endl;
                string self_temp = $1->valy;
                if(self_temp == "self") {
                    if(lookup_type(atom_name) != NULL){
                        SymbolInfo* lex_ptr = lookup_type(atom_name) ;
                        string class_type = lex_ptr->type;

                        // SymbolTable* temp = scope_stacku.top();
                    
                        // while(temp->parent->parent != NULL){
                        //     temp = temp->parent;
                        // }
                        // cout<<temp->scope_name<<endl;
                        // string temporary = getType_temp(atom_name, temp);
                        // cout<<temporary<<endl;
                        // string typo = getType(atom_name);
                        strcpy($$->type, class_type.c_str());
                        strcpy($$->tempvar, atom_name.c_str());
                    }
                }
                else{
                    SymbolInfo* lex_ptr = lookup($1-> valy) ;
                    string class_type = lex_ptr->type;
                    // cout<<atom_name<<endl;
                    // cout<<class_type<<endl;
                    if(self_temp == "self"){
                        
                    }
                    else if(class_type != "NA" && class_type != "class"){
                        // cout<<class_type<<endl;
                        SymbolTable* class_ptr = lookup(class_type)->ptr;
                        
                        string temporary = getType_temp(atom_name, class_ptr);
                        // cout<<temporary<<endl;
                        // string typo = getType(atom_name);
                        strcpy($$->type, temporary.c_str());
                        strcpy($$->tempvar, atom_name.c_str());
                    }
                    else if(class_type == "class"){
                        string temporary = $1->valy;
                        // cout<<temporary<<endl;
                        // string typo = getType(atom_name);
                        strcpy($$->type, temporary.c_str());
                        strcpy($$->tempvar, atom_name.c_str());
                    }
                }
                // else {
                //     SymbolTable* temp = scope_stacku.top();
                //     while(temp->parent->parent != NULL){
                //         temp = temp->parent;
                //     }
                //     cout<<temp->scope_name<<endl;
                //     string temporary = getType_temp(atom_name, temp);
                //     // cout<<temporary<<endl;
                //     // string typo = getType(atom_name);
                //     strcpy($$->type, temporary.c_str());
                //     strcpy($$->tempvar, atom_name.c_str());
                // }
                // cout<<temporary<<endl;
                // string typo = getType(atom_name);
                // strcpy($$->type, typo.c_str());
        }
        func_call_name_stack.pop();
    }
    ;

atom: 
    LPAREN f_atom_LPAREN
    {   
        string temp = string("LPAREN (") + $1 + ")";
        if($2 == NULL){
            $$ = createNode($1);
        }
        else{    
            $$ = createNode(traverseAndConcatenate($2));
            $$->children.push_back(createNode($1));
            $$->children.push_back($2);
            strcpy($$->tempvar, $2->tempvar);
            strcpy($$->type, $2->type);
        }
    }
    | LBRACKET {list_flag = 1;} f_atom_LBRACKET
    {
        // string temp = string("LBRACKET (") + $1 + ")";
        if($3 == NULL){
            $$ = createNode($1);
        }
        else{
            $$ = createNode("atom");
            $$->children.push_back(createNode($1));
            $$->children.push_back($3);
        }
        strcpy($$->tempvar, $3->tempvar);
        strcpy($$->type, $3->type);
    }
    | NAME
    {
        // string temp = string("NAME (") + $1 + ")";
        
        $$ = createNode($1);
        strcpy($$->tempvar, $1);
        // string namee = $1;
        if(lookup_type($1) != NULL){
            string temp = lookup_type($1)->type;
            strcpy($$->type, temp.c_str());
        }
        
        // createNode("atom");
        // $$->children.push_back(createNode($1));
    }
    | NUMBER
    {
        string temp = string("NUMBER (") + $1 + ")";
        if(list_flag){
            list_elems++;
        }
        if(is_range) {
            if(minus_flag) {
                string temp = string("-") + $1;
                range_values.push_back(temp);
                minus_flag = 0; 
            }
            else range_values.push_back($1);
        }
        // $$ = createNode(temp);
        $$ = createNode($1);
        
        if(!is_range){
            strcpy($$->tempvar, newtemp().c_str());
            if(minus_flag){
                // gen3AC({$$->tempvar, " = ", "-", $1},indent_level);
                minus_flag = 0;
            }
            else{
                gen3AC({$$->tempvar, " = ", $1},indent_level);
            }
        }
        strcpy($$->type, getType($1).c_str());
        // gen3AC({$$->tempvar, "=", $1});
        // createNode("atom");
        // $$->children.push_back(createNode($1));
    }
    | string_continue
    {
        if(list_flag)list_elems++;
        $$ = $1;
        // createNode("atom");
        // $$->children.push_back($1);
        if(!is_range){
            strcpy($$->tempvar, newtemp().c_str());
            gen3AC({$$->tempvar, " = ", $1->valy},indent_level);
        }
        strcpy($$->type, "str");
    }
    | NONE
    {
        // string temp = string("NONE (") + $1 + ")";
        $$ = createNode($1);
        strcpy($$->type, "None");
        // createNode("atom");
        // $$->children.push_back(createNode($1));
    }
    | TRUEE
    {
        string temp = string("TRUE (") + $1 + ")";
        // $$ = createNode(temp);
        $$ = createNode($1);
        strcpy($$->tempvar, $1);
        strcpy($$->type, "bool");
        // createNode("atom");
        // $$->children.push_back(createNode($1));
    }
    | FALSEE
    {
        string temp = string("FALSE (") + $1 + ")";
        // $$ = createNode(temp);
        $$ = createNode($1);
        strcpy($$->tempvar, $1);
        strcpy($$->type, "bool");
        // createNode("atom");
        // $$->children.push_back(createNode($1));
    }
    ;

f_atom_LPAREN:
    RPAREN
    {
        string temp = string("RPAREN (") + $1 + ")";
        $$ = createNode($1);
        // createNode("f_atom_LPAREN");
        // $$->children.push_back(createNode($1));
    }
    | testlist_comp RPAREN
    {   
        string temp = string("RPAREN (") + $2 + ")";
        if($1 == NULL){
            $$ = createNode($2);
        }
        else{
            $$ = createNode("f_atom_LPAREN");
            $$->children.push_back($1);
            $$->children.push_back(createNode($2));
            strcpy($$->tempvar, $1->tempvar);
            strcpy($$->type, $1->type); 
        }
    }
    ;

f_atom_LBRACKET:
    RBRACKET
    {
        string temp = string("RBRACKET (") + $1 + ")";
        list_flag=0;
        $$ = createNode($1);
        // createNode("f_atom_LBRACKET");
        // $$->children.push_back(createNode($1));
    }
    | testlist_comp{} RBRACKET
    {
        // string temp = string("RBRACKET (") + $2 + ")";
        list_flag=0;
        if($1 == NULL){
            $$ = createNode($3);
        }
        else{
            $$ = createNode("f_atom_LBRACKET");
            $$->children.push_back($1);
            $$->children.push_back(createNode($3));
        }
        int index_type_size = sizeof_($1->indextype);
        string new_temp = newtemp();
        for(int i = 0; i < list_elements.size(); i++){
            gen3AC({"*(", new_temp, " + ", to_string(i*index_type_size), ") = ", list_elements[i]},indent_level);
        }
        strcpy($$->tempvar, new_temp.c_str());
        string temp = "list[" +$1->indextype + "]";
        strcpy($$->type, temp.c_str()  );
        list_elements.clear();
    }
    ;

string_continue:
    string_continue STRING
    {
        string temp = string("STRING (") + $2 + ")";
        if(list_flag)list_elems++;
        if($1 == NULL){
            // $$ = createNode(temp);
            $$ = createNode($2);
        }
        else{
            $$ = createNode("string_continue");
            $$->children.push_back($1);
            $$->children.push_back(createNode($2));
        }
    }
    | STRING
    {
        string temp = string("STRING (") + $1 + ")";
        // $$ = createNode(temp);
        $$ = createNode($1);
        // createNode("string_continue");
        // $$->children.push_back(createNode($1));
    }
    ;

testlist_comp: 
    test f_testlist_comp_test
    {
        list_elements.insert(list_elements.begin(), $1->tempvar);
        
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
                for(auto it: $2->children){
                    $$->children.push_back(it);
                }
            }
        }
        // if($1->children.size()>0)$1-> valy = $1->children[0]-> valy + $$->valy + $1->children[1]->valy;
        // string temp = $1->valy;
        // if(temp[0]<0 && temp[0]>9)
        $$->indextype = getType($1->valy);
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
            // $$ = createNode(temp);
            $$ = createNode(",");
        }
        else{
            $$ = createNode("testlist_comp_continue");
            
            if($1 != NULL){
                for(auto it: $1->children){
                    $$->children.push_back(it);
                }
            }
            $$->children.push_back(createNode($2));
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
        if(list_flag){
            list_elements.push_back($1->tempvar);
        }
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
    LPAREN{trailer_flag = 1;}f_trailer
    { 
        string temp = string("LPAREN (") + $1 + ")";
        if($3 == NULL){
            $$ = createNode($1);
        }
        else{
            $$ = createNode("trailer");
            $$->children.push_back(createNode($1));
            vector<Node*> tempchild = $3->children;
            if(tempchild.size()==0)
                $$->children.push_back($3);
            else{
                for(auto it: $3->children){
                    $$->children.push_back(it);
                }
            }
            
        }
        $$->isfunc = 1;
    }
    | LBRACKET{trailer_flag = 1;} subscriptlist RBRACKET
    {
        string temp = string("LBRACKET (") + $1 + ")";
        $$ = createNode("trailer");
        $$->children.push_back(createNode($1));
        $$->children.push_back($3);
        temp = string("RBRACKET (") + $4 + ")";
        $$->children.push_back(createNode($4));
        strcpy($$->tempvar,$3->tempvar);
    }
    | DOT NAME
    {
        // if(class_flag){
        //     self_lex_name = $2;
        // }
        $$ = createNode("trailer");
        $$->children.push_back(createNode($1));
        // temp = string("NAME (") + $2 + ")";
        $$->children.push_back(createNode($2));
        strcpy($$->tempvar, $2);
        string name = $2;
        string to_bechecked = "self." + name;
        // if(lookup_type($2) == NULL){
        //     if (lookup_type(to_bechecked) == NULL){
        //         cout<< "Line: selfname "<< prev_lineno<<"   "<<to_bechecked<<endl;
        //         // Either we are defining an attribute or it doesn't exist
        //         strcpy($$->type,"NA");
        //     } else {
        //         string tempo = getType(to_bechecked);
        //         strcpy($$->type,tempo.c_str());
        //     }
        // } else {
        //     string tempo2 = getType($2);
        //     strcpy($$->type, tempo2.c_str());
        // }
    }
    ;

f_trailer:
    RPAREN
    {
        string temp = string("RPAREN (") + $1 + ")";
        $$ = createNode($1);
        // createNode("f_trailer");
        // $$->children.push_back(createNode($1));
        string func_top_stored2 = func_call_name_stack.top();
        if (func_top_stored2.find('.') != string::npos){
            size_t position = func_top_stored2.find('.');
            string caller = func_top_stored2.substr(0, position);
            string callee = func_top_stored2.substr(position+1);
            SymbolInfo* temp = lookup(caller);
            if (temp->type == "class"){
                SymbolTable* class_table = temp->ptr;
                if(class_table->table.find(callee) != class_table->table.end()){
                    class_table = class_table->table[callee].ptr;
                    vector<pair<int,string> > func_args;
                    for(auto it: class_table->table){
                        if(it.second.arg_num != -1){
                            func_args.push_back({it.second.arg_num, it.second.type});
                        }
                    }
                    if(func_args[func_args.size()-1].second == "NA"){
                        func_args.pop_back();
                    }
                    reverse(func_args.begin(), func_args.end());
                    if (func_args.size() != 0){
                        cout<<"Line "<<prev_lineno<<": Number of arguments do not match, expected "<<func_args.size()<<", but 0 provided"<<endl;
                        exit(1);
                    }
                }
                else {
                    cout<<"Line "<<prev_lineno<<": Caller "<<callee<<" not defined"<<endl;
                    exit(1);
                }
            }
            else if (lookup(temp->type)->type == "class" ) {
                SymbolTable* class_table = lookup(temp->type)->ptr;
                if(class_table->table.find(callee) != class_table->table.end()){
                    class_table = class_table->table[callee].ptr;
                          vector<pair<int,string> > func_args;
                    for(auto it: class_table->table){
                        if(it.second.arg_num != -1){
                            func_args.push_back({it.second.arg_num, it.second.type});
                        }
                    }
                    if(func_args[func_args.size()-1].second == "NA"){
                        func_args.pop_back();
                    }
                    reverse(func_args.begin(), func_args.end());
                    if (func_args.size() != 0){
                        cout<<"Line "<<prev_lineno<<": Number of arguments do not match, expected "<<func_args.size()<<", but 0 provided"<<endl;
                        exit(1);
                    }
                }
                else {
                    cout<<"Line "<<prev_lineno<<": Function "<<callee<<" not defined"<<endl;
                    exit(1);
                }
            }
            else {
                cout<<"Line "<<prev_lineno<<": Caller"<<caller<<" not defined"<<endl;
                exit(1);

            }
        }
    }
    | arglist RPAREN
    {
        // vector<pair<string,SymbolInfo*> > args = func_with_args[func_call_name];
        if(func_call_name_stack.top() == "print"){
            string element = "";
            string list_elem_values = traverseAndConcatenate($1);
            vector<string> arg_values;
            for(int i = 0; i < list_elem_values.size(); i++){
                if(list_elem_values[i]!=','){
                    element+=list_elem_values[i];
                    if(i == list_elem_values.size()-1){
                        arg_values.push_back(element);
                        element = "";
                    }
                }
                else{
                    arg_values.push_back(element);
                    element = "";
                }
            }

            for(auto it: argument_templist){
                gen3AC({"pushparam ",it},indent_level);
            }

            if(arg_values.size() != 1){
                cout<<"Line "<<prev_lineno<<": Print not supported in this way"<<endl;
                exit(1);
            
            }
            else{
                // cout<<arg_values[0]<<endl;
                if(getType(arg_values[0]) == "str"){
                }
                else{
                    SymbolInfo* temp = lookup(arg_values[0]);
                    if(temp == NULL){
                        cout<<"Line "<<prev_lineno<<": Variable "<<arg_values[0]<<" not defined"<<endl;
                        exit(1);
                    }
                }
            
            }
        }
        else if(func_call_name_stack.top() == "len"){
            string element = "";
            string list_elem_values = traverseAndConcatenate($1);
            vector<string> arg_values;
            for(int i = 0; i < list_elem_values.size(); i++){
                if(list_elem_values[i]!=','){
                    element+=list_elem_values[i];
                    if(i == list_elem_values.size()-1){
                        arg_values.push_back(element);
                        element = "";
                    }
                }
                else{
                    arg_values.push_back(element);
                    element = "";
                }
            }
            if(arg_values.size() != 1){
                cout<<"Line "<<prev_lineno<<": Print not supported in this way"<<endl;
                exit(1);
            
            }
            else{
                SymbolInfo* temp = lookup(arg_values[0]);
                if(temp->type.substr(0,5) != "list["){
                    cout<<"Line "<<prev_lineno<<": Unexpected Type for len"<<endl;
                    exit(1);
                }
            }
            for(auto it: argument_templist){
                gen3AC({"pushparam ",it},indent_level);
            }
        }
        else if(func_call_name_stack.top() == "range"){
            string element = "";
            string list_elem_values = traverseAndConcatenate($1);
            vector<string> arg_values;
            for(int i = 0; i < list_elem_values.size(); i++){
                if(list_elem_values[i]!=','){
                    element+=list_elem_values[i];
                    if(i == list_elem_values.size()-1){
                        arg_values.push_back(element);
                        element = "";
                    }
                }
                else{
                    arg_values.push_back(element);
                    element = "";
                }
            }

            if(arg_values.size() != 1 && arg_values.size() != 2 && arg_values.size() != 3){
                cout<<"Line "<<prev_lineno<<": Range not supported in this way"<<endl;
                exit(1);
            
            }
            else{
                for(int i = 0; i < arg_values.size(); i++){
                    if(getType(arg_values[i]) == "str"){

                        cout<<"Line "<<prev_lineno<<": Range not supported in this way -> str provided as argument"<<endl;
                        exit(1);

                    }
                    if(getType(arg_values[i]) != "int"){
                        SymbolInfo* temp = lookup(arg_values[i]);
                        if(temp == NULL){
                            cout<<"Line "<<prev_lineno<<": Variable "<<arg_values[0]<<" not defined"<<endl;
                            exit(1);
                        }
                    }
                }
             
            
            }
        }
        else{
            string func_call_name2 = "";
            string func_top_stored3 = func_call_name_stack.top();
            for(int i =0; i < func_top_stored3.size();i++){
                if(func_top_stored3[i] == '.'){
                    class_ofFunc   = func_top_stored3.substr(0,i);
                    func_call_name2 = func_top_stored3.substr(i+1);
                    break;
                }
            }
            if (!(class_ofFunc.empty())) {
                string caller = class_ofFunc;
                string callee = func_call_name2;
                SymbolInfo* temp = lookup(caller);
                if (temp->type == "class"){
                    SymbolTable* class_table = temp->ptr;
                    if(class_table->table.find(callee) != class_table->table.end()){
                        class_table = class_table->table[callee].ptr;
                        vector<pair<int,string> > func_args;
                        for(auto it: class_table->table){
                            if(it.second.arg_num != -1){
                                func_args.push_back({it.second.arg_num, it.second.type});
                            }
                        }
                        // if(func_args[func_args.size()-1].second == "NA"){
                        //     func_args.pop_back();
                        // }
                        // Don't need to popback as this is a class calling function, will have to pass self
                        reverse(func_args.begin(), func_args.end());
                        string element = "";
                        string list_elem_values = traverseAndConcatenate($1);
                        vector<string> arg_values;
                        for(int i = 0; i < list_elem_values.size(); i++){
                            if(list_elem_values[i]!=','){
                                element+=list_elem_values[i];
                                if(i == list_elem_values.size()-1){
                                    arg_values.push_back(element);
                                    element = "";
                                }
                            }
                            else{
                                arg_values.push_back(element);
                                element = "";
                            }
                        }
                        if(func_args.size() != arg_values.size()){
                            cout<<"Line "<<prev_lineno<<": Number of arguments do not match, expected "<<func_args.size()<<", but "<<arg_values.size()<<" provided"<<endl;
                            exit(1);
                        }
                        for(int i = 0 ;i<arg_values.size();i++){
                                if(func_args[i].second == getType(arg_values[i])){
                                    //Do nothing 
                                }
                                else if(func_args[i].second == "int" && getType(arg_values[i]) == "str"){
                                    cout<<"Line "<<prev_lineno<<" Error: Expected int, but "<<getType(arg_values[i])<<" provided"<<endl;
                                    exit(1);
                                }
                                else if(func_args[i].second == "str" && getType(arg_values[i]) == "int"){
                                    cout<<"Line "<<prev_lineno<<" Error: Expected str, but "<<getType(arg_values[i])<<" provided"<<endl;
                                    exit(1);
                                }
                                else if(func_args[i].second == "float" && getType(arg_values[i]) == "str"){
                                    cout<<"Line "<<prev_lineno<<" Error: Expected float, but "<<getType(arg_values[i])<<" provided"<<endl;
                                    exit(1);
                                }
                                else if(func_args[i].second == "str" && getType(arg_values[i]) == "float"){
                                    cout<<"Line "<<prev_lineno<<"Error: Expected str, but "<<getType(arg_values[i])<<" provided"<<endl;
                                    exit(1);
                                }
                                else if(func_args[i].second == "bool" && getType(arg_values[i]) == "str"){
                                    cout<<"Line "<<prev_lineno<<"Error: Expected bool, but "<<getType(arg_values[i])<<" provided"<<endl;
                                    exit(1);
                                }
                                else if(func_args[i].second == "str" && getType(arg_values[i]) == "bool"){
                                    cout<<"Line "<<prev_lineno<<"Error: Expected str, but "<<getType(arg_values[i])<<" provided"<<endl;
                                    exit(1);
                                }
                                else if(func_args[i].second == "int" && getType(arg_values[i]) == "float"){
                                    // *v = arg_values[i];
                                }
                                else if(func_args[i].second == "float" && getType(arg_values[i]) == "int"){
                                    // *v = arg_values[i];
                                }
                                else if(func_args[i].second == "int" && getType(arg_values[i]) == "bool"){
                                    // *v = (arg_values[i] == "True")?"1":"0";
                                }
                                else if(func_args[i].second == "bool" && getType(arg_values[i]) == "int"){
                                    // *v = (stoi(arg_values[i]) > 0)?"True":"False";
                                }
                                else if(func_args[i].second == "float" && getType(arg_values[i]) == "bool"){
                                    // *v = (arg_values[i] == "True")?"1":"0";
                                }
                                else if(func_args[i].second == "bool" && getType(arg_values[i]) == "float"){
                                    // *v = (stof(arg_values[i]) > 0)?"True":"False";
                                }
                                else{
                                    cout<<"Unexpected argument type"<<endl;
                                    cout<<"Expected "<<func_args[i].second<<", but "<<getType(arg_values[i])<<" provided"<<endl;
                                    exit(1);
                                }
                        }
                    }
                    else {
                        cout<<"Line "<<prev_lineno<<": Caller "<<callee<<" not defined"<<endl;
                        exit(1);
                    }
                }
                else if (lookup(temp->type)->type == "class" ) {
                    SymbolTable* class_table = lookup(temp->type)->ptr;
                    if(class_table->table.find(callee) != class_table->table.end()){
                        class_table = class_table->table[callee].ptr;
                        vector<pair<int,string> > func_args;
                        for(auto it: class_table->table){
                            if(it.second.arg_num != -1){
                                func_args.push_back({it.second.arg_num, it.second.type});
                            }
                        }
                        if(func_args[func_args.size()-1].second == "NA"){
                            func_args.pop_back();
                        }
                        reverse(func_args.begin(), func_args.end());
                        string element = "";
                        string list_elem_values = traverseAndConcatenate($1);
                        vector<string> arg_values;
                        for(int i = 0; i < list_elem_values.size(); i++){
                            if(list_elem_values[i]!=','){
                                element+=list_elem_values[i];
                                if(i == list_elem_values.size()-1){
                                    arg_values.push_back(element);
                                    element = "";
                                }
                            }
                            else{
                                arg_values.push_back(element);
                                element = "";
                            }
                        }
                        if(func_args.size() != arg_values.size()){
                            cout<<"Line "<<prev_lineno<<": Number of arguments do not match, expected "<<func_args.size()<<", but "<<arg_values.size()<<" provided"<<endl;
                            exit(1);
                        }
                        for(int i = 0 ;i<arg_values.size();i++){
                            // cout<<arg_values[i]<<endl;
                                if(func_args[i].second == getType(arg_values[i])){
                                    //Do nothing 
                                }
                                else if(func_args[i].second == "int" && getType(arg_values[i]) == "str"){
                                    cout<<"Line "<<prev_lineno<<" Error: Expected int, but "<<getType(arg_values[i])<<" provided"<<endl;
                                    exit(1);
                                }
                                else if(func_args[i].second == "str" && getType(arg_values[i]) == "int"){
                                    cout<<"Line "<<prev_lineno<<" Error: Expected str, but "<<getType(arg_values[i])<<" provided"<<endl;
                                    exit(1);
                                }
                                else if(func_args[i].second == "float" && getType(arg_values[i]) == "str"){
                                    cout<<"Line "<<prev_lineno<<" Error: Expected float, but "<<getType(arg_values[i])<<" provided"<<endl;
                                    exit(1);
                                }
                                else if(func_args[i].second == "str" && getType(arg_values[i]) == "float"){
                                    cout<<"Line "<<prev_lineno<<" Error: Expected str, but "<<getType(arg_values[i])<<" provided"<<endl;
                                    exit(1);
                                }
                                else if(func_args[i].second == "bool" && getType(arg_values[i]) == "str"){
                                    cout<<"Line "<<prev_lineno<<" Error: Expected bool, but "<<getType(arg_values[i])<<" provided"<<endl;
                                    exit(1);
                                }
                                else if(func_args[i].second == "str" && getType(arg_values[i]) == "bool"){
                                    cout<<"Line "<<prev_lineno<<" Error: Expected str, but "<<getType(arg_values[i])<<" provided"<<endl;
                                    exit(1);
                                }
                                else if(func_args[i].second == "int" && getType(arg_values[i]) == "float"){
                                    // *v = arg_values[i];
                                }
                                else if(func_args[i].second == "float" && getType(arg_values[i]) == "int"){
                                    // *v = arg_values[i];
                                }
                                else if(func_args[i].second == "int" && getType(arg_values[i]) == "bool"){
                                    // *v = (arg_values[i] == "True")?"1":"0";
                                }
                                else if(func_args[i].second == "bool" && getType(arg_values[i]) == "int"){
                                    // *v = (stoi(arg_values[i]) > 0)?"True":"False";
                                }
                                else if(func_args[i].second == "float" && getType(arg_values[i]) == "bool"){
                                    // *v = (arg_values[i] == "True")?"1":"0";
                                }
                                else if(func_args[i].second == "bool" && getType(arg_values[i]) == "float"){
                                    // *v = (stof(arg_values[i]) > 0)?"True":"False";
                                }
                                else{
                                    cout<<"Unexpected argument type"<<endl;
                                    cout<<"Expected "<<func_args[i].second<<", but "<<getType(arg_values[i])<<" provided"<<endl;
                                    exit(1);
                                }
                        }
                    }
                    else {
                        cout<<"Line "<<prev_lineno<<": Function "<<callee<<" not defined"<<endl;
                        exit(1);
                    }
                }
                else {
                    cout<<"Line "<<prev_lineno<<": Caller"<<caller<<" not defined"<<endl;
                    exit(1);

                }
                class_ofFunc = "";
            }
            else {
                SymbolTable* function_table = lookup(func_call_name_stack.top())->ptr;
                if(function_table->table.find("__init__") != function_table->table.end()){
                    function_table = function_table->table["__init__"].ptr;
                }
                vector<pair<int,string> > func_args;
                for(auto it: function_table->table){
                    if(it.second.arg_num != -1){
                        func_args.push_back({it.second.arg_num, it.second.type});
                    }
                }
                if(func_args[func_args.size()-1].second == "NA"){
                    func_args.pop_back();
                }
                reverse(func_args.begin(), func_args.end());
                // for(int i = 0; i < arg_values.size(); i++){
                //     if(init_args[i].second != getType(arg_values[i])){
                //         cout<<"Line "<<prev_lineno<<"Error: Expected "<<init_args[i].second<<", but "<<getType(arg_values[i])<<" provided"<<endl;
                //         exit(1);
                //     }
                // }

                string element = "";
                string list_elem_values = traverseAndConcatenate($1);
                vector<string> arg_values;
                for(int i = 0; i < list_elem_values.size(); i++){
                    if(list_elem_values[i]!=','){
                        element+=list_elem_values[i];
                        if(i == list_elem_values.size()-1){
                            arg_values.push_back(element);
                            element = "";
                        }
                    }
                    else{
                        arg_values.push_back(element);
                        element = "";
                    }
                }
                for(auto it: argument_templist){
                    gen3AC({"pushparam ",it},indent_level);
                }

                if(func_args.size() != arg_values.size()){
                    cout<<"Line "<<prev_lineno<<": Number of arguments do not match, expected "<<func_args.size()<<", but "<<arg_values.size()<<" provided"<<endl;
                    exit(1);
                }
                for(int i = 0 ;i<arg_values.size();i++){
                    // SymbolTable* ftable = scope_stacku.top();
                    // SymbolTable* functable = NULL;
                    // while(ftable != NULL){
                    //     if(ftable->table.find(func_call_name) != ftable->table.end()){
                    //         functable = ftable->table[func_call_name].ptr;
                            
                    //     }
                    //     ftable = ftable->parent;
                    // }
                //     string* v = &(functable->table[func_args[i].first].val);
                    if(func_args[i].second != "NA"){
                        if(func_args[i].second == getType(arg_values[i])){
                            // *v = arg_values[i];
                        }
                        else if(func_args[i].second == "int" && getType(arg_values[i]) == "str"){
                            cout<<"Line "<<prev_lineno<<" Error: Expected int, but "<<getType(arg_values[i])<<" provided"<<endl;
                            exit(1);
                        }
                        else if(func_args[i].second == "str" && getType(arg_values[i]) == "int"){
                            cout<<"Line "<<prev_lineno<<" Error: Expected str, but "<<getType(arg_values[i])<<" provided"<<endl;
                            exit(1);
                        }
                        else if(func_args[i].second == "float" && getType(arg_values[i]) == "str"){
                            cout<<"Line "<<prev_lineno<<" Error: Expected float, but "<<getType(arg_values[i])<<" provided"<<endl;
                            exit(1);
                        }
                        else if(func_args[i].second == "str" && getType(arg_values[i]) == "float"){
                            cout<<"Line "<<prev_lineno<<" Error: Expected str, but "<<getType(arg_values[i])<<" provided"<<endl;
                            exit(1);
                        }
                        else if(func_args[i].second == "bool" && getType(arg_values[i]) == "str"){
                            cout<<"Line "<<prev_lineno<<" Error: Expected bool, but "<<getType(arg_values[i])<<" provided"<<endl;
                            exit(1);
                        }
                        else if(func_args[i].second == "str" && getType(arg_values[i]) == "bool"){
                            cout<<"Line "<<prev_lineno<<" Error: Expected str, but "<<getType(arg_values[i])<<" provided"<<endl;
                            exit(1);
                        }
                        else if(func_args[i].second == "int" && getType(arg_values[i]) == "float"){
                            // *v = arg_values[i];
                        }
                        else if(func_args[i].second == "float" && getType(arg_values[i]) == "int"){
                            // *v = arg_values[i];
                        }
                        else if(func_args[i].second == "int" && getType(arg_values[i]) == "bool"){
                            // *v = (arg_values[i] == "True")?"1":"0";
                        }
                        else if(func_args[i].second == "bool" && getType(arg_values[i]) == "int"){
                            // *v = (stoi(arg_values[i]) > 0)?"True":"False";
                        }
                        else if(func_args[i].second == "float" && getType(arg_values[i]) == "bool"){
                            // *v = (arg_values[i] == "True")?"1":"0";
                        }
                        else if(func_args[i].second == "bool" && getType(arg_values[i]) == "float"){
                            // *v = (stof(arg_values[i]) > 0)?"True":"False";
                        }
                        else{
                            cout<<"Unexpected argument type"<<endl;
                            cout<<"Expected "<<func_args[i].second<<", but "<<getType(arg_values[i])<<" provided"<<endl;
                            exit(1);
                        }
                    }
                    else{
                        cout<<"Unexpected argument type"<<endl;
                        exit(1);
                    }
                }
            }
        }
        
        string temp = string("RPAREN (") + $2 + ")";
        if($1 == NULL){
            $$ = createNode($2);
        }
        else{
            $$ = createNode("f_trailer");
            $$->children.push_back($1);
            $$->children.push_back(createNode($2));
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
            // $$ = createNode(temp);
            $$ = createNode($2);
        }
        else{
            $$ = createNode("subscript_list_continue");
            $$->children.push_back($1);
            $$->children.push_back(createNode($2));
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
            // $$ = createNode(temp);
            $$ = createNode($2);
        }
        else{
            $$ = createNode("exprlist_continue_continue");
            $$->children.push_back($1);
            $$->children.push_back(createNode($2));
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
            // $$ = createNode(temp);
            $$ = createNode($2);
        }
        else{
            $$ = createNode("testlist_continue");
            $$->children.push_back($1);
            $$->children.push_back(createNode($2));
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
    CLASS NAME {
        gen3AC({"class ",$2, ":",},indent_level++);
        gen3AC({"begin class"},indent_level);
        SymbolTable* current_scope = scope_stacku.top();
        SymbolTable* class_table = new SymbolTable(current_scope, current_scope->level_num + 1, $2);
        offset_stack.push(offset_global);
        offset_global = 0;
        scope_stacku.push(class_table);
        class_name = $2;
        class_lines = global_lineno;
        class_arg_flag = 1;
    } f_classdef
    {
        class_arg_flag = 0;
        class_name = "";
        SymbolTable* class_table = scope_stacku.top();
        scope_stacku.pop();
        offset_global = offset_stack.top();
        offset_stack.pop();
        SymbolTable* current_scope = scope_stacku.top();
        current_scope->add_entry($2, "class", 0, class_lines, class_table, -1, -1, "CLASS", -1);
        // offset_global += 8;
        
        // string temp = string("CLASS (") + $1 + ")";
        $$ = createNode("classdef");
        $$->children.push_back(createNode($1));
        // temp = string("NAME (") + $2 + ")";
        $$->children.push_back(createNode($2));
        $$->children.push_back($4);
        gen3AC({"end class: "},indent_level--);
    }
    ;

f_classdef:
    COLON suite
    {
        string temp = string("COLON (") + $1 + ")";
        if($2 == NULL){
            $$ = createNode($1);
        }
        else{
            $$ = createNode("f_classdef");
            $$->children.push_back(createNode($1));
            $$->children.push_back($2);
        }
    }
    | LPAREN f_f_classdef
    {  
        string temp = string("LPAREN (") + $1 + ")";
        if($2 == NULL){
            $$ = createNode($1);
        }
        else{
            $$ = createNode("f_classdef");
            $$->children.push_back(createNode($1));
            $$->children.push_back($2);
        }
    }
    ;

f_f_classdef:
    RPAREN COLON suite
    {
        string temp = string("RPAREN (") + $1 + ")";
        $$ = createNode("f_f_classdef");
        $$->children.push_back(createNode($1));
        temp = string("COLON (") + $2 + ")";
        $$->children.push_back(createNode($2));
        $$->children.push_back($3);
    }
    | arglist RPAREN COLON {
        string parent_Class = $1->valy;
        SymbolTable* par = scope_stacku.top();
        SymbolTable* curr = scope_stacku.top();
        while(par != NULL){
            if(par->table.find(parent_Class) != par->table.end()){
                SymbolTable* class_table = par->table[parent_Class].ptr;
                for(auto it: class_table->table){
                    SymbolInfo* temp = new SymbolInfo(it.second);
                    if (it.first != "__init__"){
                        curr->add_entry_for_self(it.first, it.second.type, it.second.size, it.second.offset, it.second.line_no, it.second.ptr, it.second.total_args, it.second.arg_num, it.second.token, it.second.num_elems_list);
                    }
                    else {
                        
                    }
                }
                offset_global += class_table->calc_table_size(); 
            }
            par = par->parent;
        }
    }suite
    {   
        $$ = createNode("f_f_classdef");
        $$->children.push_back($1);
        $$->children.push_back(createNode($2));
        // temp = string("COLON (") + $3 + ")";
        $$->children.push_back(createNode($3));
        $$->children.push_back($5);
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
        // $$ = createNode(temp);
        $$ = createNode($1);
        // $$ = createNode("f_comma");
        // $$->children.push_back(createNode($1));
    }
    ;

arglist_continue:
    arglist_continue COMMA argument
    {
        string temp = string("COMMA (") + $2 + ")";
        if($1 == NULL && $3 == NULL){
            // $$ = createNode(temp);
            $$ = createNode($2);
        }
        else{
            $$ = createNode("arglist_continue");
            $$->children.push_back($1);
            $$->children.push_back(createNode($2));
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
        // cout<<$1->tempvar<<"!"<<endl;
        string t1 = $1->tempvar;
        if(t1 != ""){
            argument_templist.push_back($1->tempvar);
        }
        else{
            argument_templist.push_back($1->valy);
            // cout<<$1->valy<<endl;
        }
    }
    | DOUBLESTAR test
    {
        string temp = string("DOUBLESTAR (") + $1 + ")";
        if($2 == NULL){
            $$ = createNode($1);
        }
        else{
            $$ = createNode("argument");
            $$->children.push_back(createNode($1));
            $$->children.push_back($2);
        }
    }
    | STAR test
    {
        string temp = string("STAR (") + $1 + ")";
        if($2 == NULL){
            $$ = createNode($1);
        }
        else{
            $$ = createNode("argument");
            $$->children.push_back(createNode($1));
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
            $$ = createNode($1);
        }
        else{
            $$ = createNode("f_argument");
            $$->children.push_back(createNode($1));
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
        $$->children.push_back(createNode($1));
        $$->children.push_back($2);
        temp = string("IN (") + $3 + ")";
        $$->children.push_back(createNode($3));
        $$->children.push_back($4);
        $$->children.push_back($5);
    }
    ;


comp_if:
    IF test_nocond f_comp_cond
    {
        if($2 == NULL && $3 == NULL){
            $$ = createNode($1);
        }
        else{
            $$ = createNode("comp_if");
            $$->children.push_back(createNode($1));
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
    scope_stacku.push(global_table);
    global_table->add_entry("__name__", "str", 0, 0, NULL, 0, 0, "NAME", -1);
    // offset_stack.push(0);
    function_name.push("$");
    func_call_name_stack.push("$");
    yyparse();
    vector<string> temp;
    // temp.push_back("hi");
    // temp.push_back("hello");
    // temp.push_back("bye");
    // gen3AC(temp);
    global_table->print_all_tables(global_table);
    // global_table->print_table();
    // fout << "digraph G {" << endl;
    // fout<<"node [ordering=out]\n";

    // generateDOT(root, fout);
    // fout << "}" << endl;
    // fout.close();
    return 0;
}

void yyerror(const char *s){
    cerr<<"\nError found at line number: "<<prev_lineno<<"\n"<<s<<"\n";
    exit(1);
}