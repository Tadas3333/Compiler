# Syntax
```c
int calculate(int x, int y) {
  while(x < y) {
    x = x + 1;
  }

  if(x == y) {
    return 1;
  }

  return 0;
}

int main() {
  int a = 2;
  int b = 10;

  if(calculate(a, b) != 0) {
    string s = "Success!";
    print(s);
  }

  return 0;
}

```

# How to run it
```c
ruby compiler.rb "file.txt"
```
