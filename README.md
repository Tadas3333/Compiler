# Syntax Example
```c
int a;
a = 0;

pakolei(a != 6): (
  a = (a + 2) - 1;
  jei(a == 5): (
    nutraukti;
  )
)

int apskaiciuoti(int x, int y): (
  int z;
  z = 2 + x * y;
  grazinti z;
)

apskaiciuoti(5, 3);
```

# Lexer Example
```c
635 asd 54.578 33. .34 6375.745 .81 .
>>=!!====+-/\\\*,@$(){}:
'str 124as 4 +-/\\*,@$"(){}\r\n!. 3.3 .3 3..'
'\\\"\''
// comment
"moo 34a 33" // comment
"\\\"'\'"
if elseif else continue break return char float int
```
```
ID      |LN     |TYPE           |VALUE
----------------------------------------
0       |1      |LIT_INT        |635
1       |1      |IDENT          |asd
2       |1      |LIT_FLOAT      |54.578
3       |1      |LIT_FLOAT      |33.
4       |1      |LIT_FLOAT      |.34
5       |1      |LIT_FLOAT      |6375.745
6       |1      |LIT_FLOAT      |.81
7       |1      |S_DOT          |
8       |2      |OP_G           |
9       |2      |OP_GE          |
10      |2      |OP_N           |
11      |2      |OP_NE          |
12      |2      |OP_DE          |
13      |2      |OP_E           |
14      |2      |OP_PLUS        |
15      |2      |OP_MINUS       |
16      |2      |OP_DIVIDE      |
17      |2      |S_ESC          |
18      |2      |S_ESC          |
19      |2      |S_ESC          |
20      |2      |OP_MULTIPLY    |
21      |2      |S_COM          |
22      |2      |S_AT           |
23      |2      |S_DOL          |
24      |2      |OP_PAREN_O     |
25      |2      |OP_PAREN_C     |
26      |2      |OP_BRACE_O     |
27      |2      |OP_BRACE_C     |
28      |2      |S_COL          |
29      |3      |LIT_STR        |str 124as 4 +-/\*,@$"(){}*CARRIAGE**NEWLINE*!. 3.3 .3 3..
30      |4      |LIT_STR        |\"'
31      |6      |LIT_STR        |moo 34a 33
32      |7      |LIT_STR        |\"''
33      |8      |KW_IF          |
34      |8      |KW_ELSEIF      |
35      |8      |KW_ELSE        |
36      |8      |KW_CONTINUE    |
37      |8      |KW_BREAK       |
38      |8      |KW_RETURN      |
39      |8      |KW_CHAR        |
40      |8      |KW_FLOAT       |
41      |8      |KW_INT         |
```
