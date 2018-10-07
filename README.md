# Description
Lithuanian C-Like Programing Language Compiler

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
