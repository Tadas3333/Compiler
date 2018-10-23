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
635 asd 54.578 33. .34 6375.745.81.
>>=!!====+-/\\\*,@$(){}
'str 124as 4 +-/\\*,@$"(){}\r\n!. 3.3 .3 3..'
'\\\"\''
// comment
"asd 34a 33" // comment
"\\\"'\'"
if elseif else continue break return char float int
```
```
ID      |LN     |TYPE           |VALUE
----------------------------------------
0       |1      |LIT_INT        |635
1       |1      |IDENT          |asd
2       |1      |LIT_FLOAT      |5.5
3       |1      |LIT_FLOAT      |3.
4       |1      |LIT_FLOAT      |.3
5       |1      |LIT_FLOAT      |6.7
6       |1      |LIT_FLOAT      |.8
7       |1      |SYM_DOT        |
8       |2      |OP_G           |
9       |2      |OP_GE          |
10      |2      |OP_N           |
11      |2      |OP_NE          |
12      |2      |OP_DE          |
13      |2      |OP_E           |
14      |2      |OP_PLUS        |
15      |2      |OP_MINUS       |
16      |2      |OP_DIVIDE      |
17      |2      |SYM_ESC        |
18      |2      |SYM_ESC        |
19      |2      |SYM_ESC        |
20      |2      |OP_MULTIPLY    |
21      |2      |SYM_COM        |
22      |2      |SYM_ETA        |
23      |2      |SYM_DOL        |
24      |2      |OP_PAREN_O     |
25      |2      |OP_PAREN_C     |
26      |2      |OP_BRACE_O     |
27      |2      |OP_BRACE_C     |
28      |3      |LIT_STR        |str 124as 4 +-/\*,@$"(){}\r\n!. 3.3 .3 3..
29      |4      |LIT_STR        |\"'
30      |6      |LIT_STR        |asd 34a 33
31      |7      |LIT_STR        |\"''
32      |8      |KW_IF          |
33      |8      |KW_ELSEIF      |
34      |8      |KW_ELSE        |
35      |8      |KW_CONTINUE    |
36      |8      |KW_BREAK       |
37      |8      |KW_RETURN      |
38      |8      |KW_CHAR        |
39      |8      |KW_FLOAT       |
40      |8      |KW_INT         |
41      |9      |EOF            |
```
