# Syntax Example
```c
int $a;
$a = 0;

pakolei ($a != 6) => (
  $a = ($a + 2) - 1;
  jei ($a == 5) => (
    nutraukti;
  )
)

int @apskaiciuoti(int $x, int $y) => (
  int $z;
  $z = 2 + $x * $y;
  grazinti $z;
)

@apskaiciuoti(5, 3);
```

# Lexer Output Example
```
ID      |LN     |TYPE           |VALUE
----------------------------------------
0       |1      |LIT_INT        |635
1       |2      |LIT_INT        |45
2       |2      |LIT_STR        |ads
3       |2      |OP_PLUS        |
4       |2      |OP_MINUS       |
```
