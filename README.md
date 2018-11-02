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
635 asd 54.578 33. .34 6375.745 .81 . -45.3
>>=!!====+-/\\\*,@$(){}:
'str 124as 4 +-/\\*,@$"(){}\r\n!. 3.3 .3 3..'
'\\\"\''
// comment
"moo 34a 33" // comment
"\\\"'\'"
char float int jei kitjei kitaip testi nutraukti grazinti
```
```
ID      |LN     |TYPE           |VALUE
----------------------------------------
0       |1      |LIT_INT        |635
1       |1      |IDENT          |asd
2       |1      |LIT_FLOAT      |54.578
3       |1      |LIT_FLOAT      |33.0
4       |1      |LIT_FLOAT      |0.34
5       |1      |LIT_FLOAT      |6375.745
6       |1      |LIT_FLOAT      |0.81
7       |1      |S_DOT          |
8       |1      |LIT_FLOAT      |-45.3
9       |2      |OP_G           |
10      |2      |OP_GE          |
11      |2      |OP_N           |
12      |2      |OP_NE          |
13      |2      |OP_DE          |
14      |2      |OP_E           |
15      |2      |OP_PLUS        |
16      |2      |OP_MINUS       |
17      |2      |OP_DIVIDE      |
18      |2      |S_ESC          |
19      |2      |S_ESC          |
20      |2      |S_ESC          |
21      |2      |OP_MULTIPLY    |
22      |2      |S_COM          |
23      |2      |S_AT           |
24      |2      |S_DOL          |
25      |2      |OP_PAREN_O     |
26      |2      |OP_PAREN_C     |
27      |2      |OP_BRACE_O     |
28      |2      |OP_BRACE_C     |
29      |2      |S_COL          |
30      |3      |LIT_STR        |str 124as 4 +-/\*,@$"(){}
!. 3.3 .3 3..
31      |4      |LIT_STR        |\"'
32      |6      |LIT_STR        |moo 34a 33
33      |7      |LIT_STR        |\"''
34      |8      |KW_CHAR        |
35      |8      |KW_FLOAT       |
36      |8      |KW_INT         |
37      |8      |KW_IF          |
38      |8      |KW_ELSEIF      |
39      |8      |KW_ELSE        |
40      |8      |KW_CONTINUE    |
41      |8      |KW_BREAK       |
42      |8      |KW_RETURN      |
43      |9      |EOF            |
```
