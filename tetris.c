/*
  Tetris Game

  Color Indexes:
  - 1 DEFAULT
  - 2 RED
  - 3 BLUE
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
  game_in_progress[0] = true;
  last_figure[0] = 7;
  figure_exists[0] = false;

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
    calculate(blocks, current_position, figure_exists, last_figure, game_in_progress);
    draw(blocks, current_position);
    sleep(500);
  }
  print("\n\nGAME OVER!");
}

void calculate(int **blocks, bool **current_position, bool *figure_exists, int *last_figure, bool *game_in_progress) {
  if(figure_exists[0] == false) {
    generate_new_figure(blocks, current_position, last_figure, game_in_progress);
    figure_exists[0] = true;
  }

  if(game_in_progress[0]) {
    move_figure_by_key_press(blocks, current_position);

    if(figure_can_move_down(blocks, current_position) == true) {
      move_figure_down(current_position);
    }
    else {
      save_figure_position(blocks, current_position);
      figure_exists[0] = false;
    }
  }
}

void move_figure_by_key_press(int **blocks, bool **current_position) {
  if(left_key() == true) {
    if(figure_can_move_left(blocks, current_position) == true) {
      move_figure_left(current_position);
    }
  }
  elseif(right_key() == true) {
    if(figure_can_move_right(blocks, current_position) == true) {
      move_figure_right(current_position);
    }
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
    y = y-1;
  }
}

void move_figure_right(bool **current_position) {
  int y = 0;
  int x = 0;
  while(y < 20) {
    x = 19;
    while(x >= 0) {
      if(current_position[y][x]) {
        current_position[y][x] = false;
        current_position[y][x+1] = true;
      }

      x = x-1;
    }
    y = y-1;
  }
}

void save_figure_position(int **blocks, bool **current_position) {
  int y = 0;
  int x = 0;

  while(y < 20) {
    x = 0;
    while(x < 10) {
      if(current_position[y][x] == true) {
        blocks[y][x] = 1;
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
        if(x == 18) {
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

void generate_new_figure(int **blocks, bool **current_position, int *last_figure, bool *game_in_progress) {
  int x = 0;
  while(x < 10) {
    if(blocks[2][x] > 0) {
      game_in_progress[0] = false;
    }
    x = x+1;
  }

  if(game_in_progress[0] == false) {
    return;
  }

  if(last_figure[0] == 0) { // FIGURE 2
    current_position[0][3] = true;
    current_position[1][3] = true;
    current_position[1][4] = true;
    current_position[1][5] = true;
    last_figure[0] = last_figure[0] + 1;
  }
  elseif(last_figure[0] == 1) { // FIGURE 3
    current_position[0][5] = true;
    current_position[1][3] = true;
    current_position[1][4] = true;
    current_position[1][5] = true;
    last_figure[0] = last_figure[0] + 1;
  }
  elseif(last_figure[0] == 2) { // FIGURE 4
    current_position[0][3] = true;
    current_position[0][4] = true;
    current_position[1][3] = true;
    current_position[1][4] = true;
    last_figure[0] = last_figure[0] + 1;
  }
  elseif(last_figure[0] == 3) { // FIGURE 5
    current_position[0][4] = true;
    current_position[0][5] = true;
    current_position[1][3] = true;
    current_position[1][4] = true;
    last_figure[0] = last_figure[0] + 1;
  }
  elseif(last_figure[0] == 4) { // FIGURE 6
    current_position[0][4] = true;
    current_position[1][3] = true;
    current_position[1][4] = true;
    current_position[1][5] = true;
    last_figure[0] = last_figure[0] + 1;
  }
  elseif(last_figure[0] == 5) { // FIGURE 7
    current_position[0][3] = true;
    current_position[0][4] = true;
    current_position[1][4] = true;
    current_position[1][5] = true;
    last_figure[0] = last_figure[0] + 1;
  }
  else { // FIGURE 1
    current_position[0][3] = true;
    current_position[0][4] = true;
    current_position[0][5] = true;
    current_position[0][6] = true;
    last_figure[0] = 0;
  }
}

void draw(int **blocks, bool **current_position) {
  int x = 0;
  int y = 0;

  clear();
  print("\n----------");
  while(y < 20) {
    x = 0;
    print("\n|");
    while(x < 10) {
      if(current_position[y][x]) {
        print("X");
      }
      elseif(blocks[y][x] > 0) {
        print("#");
      }
      else {
        if(y == 2) {
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
