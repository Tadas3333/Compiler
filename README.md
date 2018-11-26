# How to run it
```c
ruby compiler.rb "input.txt"
```

# Syntax
```c
/*
  Program Description
*/

int calculate(int x, int y) {
  while(x < y) {
    x = x + 1;
  }

  if(x == y) {
    return 1;
  }
  elseif(x > y) {
    return 2;
  }

  return 0;
}

int main() {
  int a = 2;
  int b = 10;

  if(calculate(a, b) != 0) {
    string s = "Success!";
    print(s); // Prints "Success!"
  }

  return 0;
}
```
