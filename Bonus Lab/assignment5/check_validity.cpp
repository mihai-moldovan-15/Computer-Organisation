#include <iostream>
#include <stack>

bool check_validity(std::string const& message) {
    std::stack<char> stk{};
    bool ok = true;
    for (int i = 0; message[i] != '\0'; ++i) {
        char c = message[i];
        bool open = (c == '(' || c == '[' || c == '{' || c == '<');

        if (!open) {
            bool close =  (c == ')' || c == ']' || c == '}' || c == '>');

            if (!close)
                continue;                   /// jmp loop

            if (stk.empty()) {
                ok = false;                 /// mov $0, %rax
                break;                      /// jmp endLoop
            }

            if (stk.top() == '(' && c != ')'){
                ok = false;                 /// mov $0, %rax
                break;                      /// jmp endLoop
            }

            if (stk.top() == '[' && c != ']'){
                ok = false;                 /// mov $0, %rax
                break;                      /// jmp endLoop
            }

            if (stk.top() == '{' && c != '}'){
                ok = false;                 /// mov $0, %rax
                break;                      /// jmp endLoop
            }

            if (stk.top() == '<' && c != '>'){
                ok = false;                 /// mov $0, %rax
                break;                      /// jmp endLoop
            }

            stk.pop();
            continue;                       ///jmp loop
        }

        stk.push(c);
        continue;                           /// jmp loop
    }

    return true;
}

int main() 
{
    std::cout << "Hello, World!";
    return 0;
}