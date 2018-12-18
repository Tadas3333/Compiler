/*
  Tetris Game

  Color Indexes:
  - 1 DEFAULT
  - 2 RED
  - 3 BLUE
  - 4 GREEN
*/

int main() {
  run();
  return 0;
}

void run() {
  int x_size = 10;
  int y_size = 20;

  int **blocks = allocate(y_size);
  bool **current_position = allocate(y_size);
  bool *figure_exists = allocate(1);
  int *last_figure = allocate(1);
  bool *game_in_progress = allocate(1);
  int *current_color = allocate(1);
  int *rotation = allocate(1);
  int *cords = allocate(2);
  current_color[0] = 2;
  game_in_progress[0] = true;
  last_figure[0] = 2;
  figure_exists[0] = false;
  rotation[0] = 0;

  int i = 0;
  int x = 0;

  while(i < y_size) {
    blocks[i] = allocate(x_size);

    x = 0;
    while(x < x_size) {
      blocks[i][x] = 0;
      x = x+1;
    }

    current_position[i] = allocate(x_size);
    i = i+1;
  }

  while(game_in_progress[0]) {
    calculate(blocks, current_position, figure_exists, last_figure, game_in_progress, current_color, rotation, cords);
    draw(blocks, current_position, current_color);
    sleep(60);
  }
  print("\n\nGAME OVER!");
}

void calculate(int **blocks, bool **current_position, bool *figure_exists, int *last_figure, bool *game_in_progress, int *current_color, int *rotation, int *cords) {
  if(figure_exists[0] == false) {
    generate_new_figure(blocks, current_position, last_figure, game_in_progress, current_color, rotation);
    figure_exists[0] = true;
  }

  if(game_in_progress[0]) {
    move_figure_by_key_press(blocks, current_position, rotation, last_figure, cords);
    if(figure_can_move_down(blocks, current_position) == true) {
      move_figure_down(current_position);
    }
    else {
      save_figure_position(blocks, current_position, current_color);
      figure_exists[0] = false;
      int t=0;
      while(t < 19) {
        pop_figures(blocks);
        t = t+1;
      }
    }
  }
}

void pop_figures(int **blocks) {
  int y = 0;
  int x = 0;
  int cur_color;
  bool full_line = true;
  int last_color = 0;
  while(y < 20) {
    x = 0;
    full_line = true;
    last_color = 0;
    while(x < 10) {
      if(blocks[y][x] == 0) {
        full_line = false;
      }
      else {
        if(last_color == 0) {
          last_color = blocks[y][x];
        }
        else {
          if(last_color != blocks[y][x]) {
            full_line = false;
          }
        }
      }
      x = x+1;
    }

    if(full_line) {
      pop_line(blocks, y);
      break;
    }
    y = y+1;
  }
}

void pop_line(int **blocks, int position_at) {
  int x = 0;
  while(x < 10) {
    blocks[position_at][x] = 0;
    x = x+1;
  }

  int y = position_at;
  x = 0;
  // Move figure's blocks from the bottom
  while(y >= 0) {
    x = 0;
    while(x < 10) {
      if(blocks[y][x] > 0) {
        blocks[y+1][x] = blocks[y][x];
        blocks[y][x] = 0;
      }

      x = x+1;
    }
    y = y-1;
  }
}

void move_figure_by_key_press(int **blocks, bool **current_position, int *rotation, int *last_figure, int *cords) {
  if(left_key()) {
    if(figure_can_move_left(blocks, current_position)) {
      move_figure_left(current_position);
    }
  }
  elseif(right_key()) {
    if(figure_can_move_right(blocks, current_position)) {
      move_figure_right(current_position);
    }
  }

  if(r_key()) {
    rotate_figure(blocks, current_position, rotation, last_figure, cords);
  }
}

void set_cords(bool **current_position, int *cords) {
  int x = 0;
  int y = 0;
  bool assigned = false;

  while(y < 20) {
    x = 0;
    while(x < 9) {
      if(current_position[y][x] == true) {
        if(assigned == false) {
          cords[0] = y;
          cords[1] = x;
          assigned = true;
        }
      }
      x = x+1;
    }
    y = y+1;
  }
}

void remove_current(bool **current_position) {
  int x = 0;
  int y = 0;

  while(y < 20) {
    x = 0;
    while(x < 9) {
      current_position[y][x] = false;
      x = x+1;
    }
    y = y+1;
  }
}

void rotate_figure(int **blocks, bool **current_position, int *rotation, int *last_figure, int *cords) {
  // Clear current_position
  if(last_figure[0] != 1) {
    set_cords(current_position, cords);
  }

  if(rotation[0] == 0) {
    if(last_figure[0] == 1) {
    }
    elseif(last_figure[0] == 2) {
      // T
      if(blocks[cords[0]+1][cords[1]] > 0) {
        return;
      }
      elseif(blocks[cords[0]+2][cords[1]] > 0) {
        return;
      }
      elseif(blocks[cords[0]+1][cords[1]+1] > 0) {
        return;
      }
      if(cords[0]+1 > 19) {
        return;
      }
      elseif(cords[0]+1 > 19) {
        return;
      }
      elseif(cords[1]+1 < 0){
        return;
      }
      elseif(cords[1]+1 > 19){
        return;
      }
      remove_current(current_position);

      current_position[cords[0]][cords[1]] = true;
      current_position[cords[0]+1][cords[1]] = true;
      current_position[cords[0]+2][cords[1]] = true;
      current_position[cords[0]+1][cords[1]+1] = true;
    }
    else {
      // Line
      if(blocks[cords[0]-1][cords[1]+1] > 0) {
        return;
      }
      elseif(blocks[cords[0]][cords[1]+1] > 0) {
        return;
      }
      elseif(blocks[cords[0]+1][cords[1]+1] > 0) {
        return;
      }
      elseif(blocks[cords[0]+2][cords[1]+1] > 0) {
        return;
      }
      if(cords[0]+1 > 19) {
        return;
      }
      elseif(cords[0]+2 > 19) {
        return;
      }
      elseif(cords[1]+1 < 0){
        return;
      }
      elseif(cords[1]+1 > 19){
        return;
      }
      remove_current(current_position);
      current_position[cords[0]-1][cords[1]+1] = true;
      current_position[cords[0]][cords[1]+1] = true;
      current_position[cords[0]+1][cords[1]+1] = true;
      current_position[cords[0]+2][cords[1]+1] = true;
    }
    rotation[0] = 1;
  }
  elseif(rotation[0] == 1) {
    if(last_figure[0] == 1) {
    }
    elseif(last_figure[0] == 2) {
      // T
      if(blocks[cords[0]+1][cords[1]] > 0) {
        return;
      }
      elseif(blocks[cords[0]+1][cords[1]-1] > 0) {
        return;
      }
      elseif(blocks[cords[0]+1][cords[1]+1] > 0) {
        return;
      }
      elseif(blocks[cords[0]+2][cords[1]] > 0) {
        return;
      }
      if(cords[0]+1 > 19) {
        return;
      }
      elseif(cords[0]+2 > 19) {
        return;
      }
      elseif(cords[1]+1 < 0){
        return;
      }
      elseif(cords[1]+1 > 19){
        return;
      }
      elseif(cords[1]-1 < 0){
        return;
      }
      elseif(cords[1]-1 > 19){
        return;
      }
      remove_current(current_position);

      current_position[cords[0]+1][cords[1]] = true;
      current_position[cords[0]+1][cords[1]-1] = true;
      current_position[cords[0]+1][cords[1]+1] = true;
      current_position[cords[0]+2][cords[1]] = true;
    }
    else {
      // Line
      if(blocks[cords[0]+1][cords[1]+1] > 0) {
        return;
      }
      elseif(blocks[cords[0]+1][cords[1]] > 0) {
        return;
      }
      elseif(blocks[cords[0]+1][cords[1]-1] > 0) {
        return;
      }
      elseif(blocks[cords[0]+1][cords[1]-2] > 0) {
        return;
      }
      if(cords[0]+1 > 19) {
        return;
      }
      elseif(cords[1]+1 < 0){
        return;
      }
      elseif(cords[1]+1 > 19){
        return;
      }
      elseif(cords[1]-1 < 0){
        return;
      }
      elseif(cords[1]-1 > 19){
        return;
      }
      elseif(cords[1]-2 < 0){
        return;
      }
      elseif(cords[1]-2 > 19){
        return;
      }
      remove_current(current_position);

      current_position[cords[0]+1][cords[1]+1] = true;
      current_position[cords[0]+1][cords[1]] = true;
      current_position[cords[0]+1][cords[1]-1] = true;
      current_position[cords[0]+1][cords[1]-2] = true;
    }
    rotation[0] = 2;
  }
  elseif(rotation[0] == 2) {
    if(last_figure[0] == 1) {
    }
    elseif(last_figure[0] == 2) {
      // T
      if(blocks[cords[0]][cords[1]+1] > 0) {
        return;
      }
      elseif(blocks[cords[0]-1][cords[1]+1] > 0) {
        return;
      }
      elseif(blocks[cords[0]+1][cords[1]+1] > 0) {
        return;
      }
      if(cords[0]+1 > 19) {
        return;
      }
      elseif(cords[1]+1 < 0){
        return;
      }
      elseif(cords[1]+1 > 19){
        return;
      }
      remove_current(current_position);

      current_position[cords[0]][cords[1]] = true;
      current_position[cords[0]][cords[1]+1] = true;
      current_position[cords[0]-1][cords[1]+1] = true;
      current_position[cords[0]+1][cords[1]+1] = true;
    }
    else {
      // Line
      if(blocks[cords[0]][cords[1]+2] > 0) {
        return;
      }
      elseif(blocks[cords[0]-1][cords[1]+2] > 0) {
        return;
      }
      elseif(blocks[cords[0]+1][cords[1]+2] > 0) {
        return;
      }
      elseif(blocks[cords[0]+2][cords[1]+2] > 0) {
        return;
      }
      if(cords[0]+1 > 19) {
        return;
      }
      if(cords[0]+2 > 19) {
        return;
      }
      elseif(cords[1]+2 < 0){
        return;
      }
      elseif(cords[1]+2 > 19){
        return;
      }
      remove_current(current_position);

      current_position[cords[0]][cords[1]+2] = true;
      current_position[cords[0]-1][cords[1]+2] = true;
      current_position[cords[0]+1][cords[1]+2] = true;
      current_position[cords[0]+2][cords[1]+2] = true;
    }
    rotation[0] = 3;
  }
  else {
    if(last_figure[0] == 1) {
    }
    elseif(last_figure[0] == 2) {
      // T
      if(blocks[cords[0]+1][cords[1]-1] > 0) {
        return;
      }
      elseif(blocks[cords[0]+1][cords[1]] > 0) {
        return;
      }
      elseif(blocks[cords[0]+1][cords[1]+1] > 0) {
        return;
      }
      if(cords[0]+1 > 19) {
        return;
      }
      if(cords[0]+2 > 19) {
        return;
      }
      elseif(cords[1]-1 < 0){
        return;
      }
      elseif(cords[1]-1 > 19){
        return;
      }
      elseif(cords[1]+1 < 0){
        return;
      }
      elseif(cords[1]+1 > 19){
        return;
      }
      remove_current(current_position);

      current_position[cords[0]+1][cords[1]-1] = true;
      current_position[cords[0]+1][cords[1]] = true;
      current_position[cords[0]+1][cords[1]+1] = true;
      current_position[cords[0]][cords[1]] = true;
    }
    else {
      // Line
      if(blocks[cords[0]+1][cords[1]-1] > 0) {
        return;
      }
      elseif(blocks[cords[0]+1][cords[1]] > 0) {
        return;
      }
      elseif(blocks[cords[0]+1][cords[1]+1] > 0) {
        return;
      }
      elseif(blocks[cords[0]+1][cords[1]+2] > 0) {
        return;
      }
      if(cords[0]+1 > 19) {
        return;
      }
      elseif(cords[1]-1 < 0){
        return;
      }
      elseif(cords[1]-1 > 19){
        return;
      }
      elseif(cords[1]+1 < 0){
        return;
      }
      elseif(cords[1]+1 > 19){
        return;
      }
      elseif(cords[1]+2 < 0){
        return;
      }
      elseif(cords[1]+2 > 19){
        return;
      }
      remove_current(current_position);
      current_position[cords[0]+1][cords[1]-1] = true;
      current_position[cords[0]+1][cords[1]] = true;
      current_position[cords[0]+1][cords[1]+1] = true;
      current_position[cords[0]+1][cords[1]+2] = true;
    }
    rotation[0] = 0;
  }
}

void move_figure_down(bool **current_position) {
  int y = 19;
  int x = 0;
  // Move figure's blocks from the bottom
  while(y >= 0) {
    x = 0;
    while(x < 10) {
      if(current_position[y][x]) {
        current_position[y][x] = false;
        current_position[y+1][x] = true;
      }

      x = x+1;
    }
    y = y-1;
  }
}

void move_figure_left(bool **current_position) {
  int y = 0;
  int x = 0;
  while(y < 20) {
    x = 0;
    while(x < 10) {
      if(current_position[y][x]) {
        current_position[y][x] = false;
        current_position[y][x-1] = true;
      }

      x = x+1;
    }
    y = y+1;
  }
}

void move_figure_right(bool **current_position) {
  int y = 0;
  int x = 0;
  while(y < 20) {
    x = 9;
    while(x >= 0) {
      if(current_position[y][x]) {
        current_position[y][x] = false;
        current_position[y][x+1] = true;
      }

      x = x-1;
    }
    y = y+1;
  }
}

void save_figure_position(int **blocks, bool **current_position, int *current_color) {
  int y = 0;
  int x = 0;

  while(y < 20) {
    x = 0;
    while(x < 10) {
      if(current_position[y][x] == true) {
        blocks[y][x] = current_color[0];
        current_position[y][x] = false;
      }
      x = x+1;
    }
    y = y+1;
  }
}

bool figure_can_move_down(int **blocks, bool **current_position) {
  bool can_move_down = true;
  int y = 0;
  int x = 0;

  while(y < 20) {
    x = 0;
    while(x < 10) {
      if(current_position[y][x] == true) {
        if(y >= 19) {
          can_move_down = false;
        }
        elseif(blocks[y+1][x] > 0) {
          can_move_down = false;
        }
      }
      x = x+1;
    }
    y = y+1;
  }
  return can_move_down;
}

bool figure_can_move_left(int **blocks, bool **current_position) {
  bool can_move_left = true;
  int y = 0;
  int x = 0;

  while(y < 20) {
    x = 0;
    while(x < 10) {
      if(current_position[y][x] == true) {
        if(x == 0) {
          can_move_left = false;
        }
        elseif(blocks[y][x-1] > 0) {
          can_move_left = false;
        }
      }
      x = x+1;
    }
    y = y+1;
  }
  return can_move_left;
}

bool figure_can_move_right(int **blocks, bool **current_position) {
  bool can_move_right = true;
  int y = 0;
  int x = 0;

  while(y < 20) {
    x = 0;
    while(x < 10) {
      if(current_position[y][x] == true) {
        if(x == 9) {
          can_move_right = false;
        }
        elseif(blocks[y][x+1] > 0) {
          can_move_right = false;
        }
      }
      x = x+1;
    }
    y = y+1;
  }
  return can_move_right;
}

void generate_new_figure(int **blocks, bool **current_position, int *last_figure, bool *game_in_progress, int *current_color, int *rotation) {
  int x = 0;
  while(x < 10) {
    if(blocks[5][x] > 0) {
      game_in_progress[0] = false;
    }
    x = x+1;
  }

  if(game_in_progress[0] == false) {
    return;
  }

  if(last_figure[0] == 0) {
    current_position[0+2][3] = true;
    current_position[0+2][4] = true;
    current_position[1+2][3] = true;
    current_position[1+2][4] = true;
    last_figure[0] = 1;
  }
  elseif(last_figure[0] == 1) {
    current_position[0+2][4] = true;
    current_position[1+2][3] = true;
    current_position[1+2][4] = true;
    current_position[1+2][5] = true;
    last_figure[0] = 2;
  }
  else {
    current_position[0+4][3] = true;
    current_position[0+4][4] = true;
    current_position[0+4][5] = true;
    current_position[0+4][6] = true;
    last_figure[0] = 0;
  }

  if(current_color[0] == 2) {
    current_color[0] = 3;
  }
  else {
    current_color[0] = 2;
  }

  rotation[0] = 0;
}

void draw(int **blocks, bool **current_position, int *current_color) {
  int x = 0;
  int y = 0;

  clear();
  print("\n----------");
  while(y < 20) {
    x = 0;
    print("\n|");
    while(x < 10) {
      if(current_position[y][x]) {
        if(current_color[0] == 2) {
          rblc(" ");
        }
        else {
          bblc(" ");
        }
      }
      elseif(blocks[y][x] > 0) {
        if(blocks[y][x] == 2) {
          rblc(" ");
        }
        else {
          bblc(" ");
        }
      }
      else {
        if(y == 5) {
          print("-");
        }
        else {
          print(" ");
        }
      }
      x = x+1;
    }
    print("|");
    y = y+1;
  }
  print("\n----------");
}
