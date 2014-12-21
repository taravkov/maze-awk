#include <stdlib.h>
#include <stdio.h>
#include <ctype.h>

#define WASD

int main(int argc, char **argv) {
  system("stty raw");

  #ifdef WASD
  enum { LEFT = 'A',
	 DOWN = 'S',
	 UP = 'W',
	 RIGHT = 'D',
	 QUIT = 'Q' };
  #endif
  
  #ifdef HJKL
  enum { LEFT = 'H',
	 DOWN = 'J',
	 UP = 'K',
	 RIGHT = 'L',
	 QUIT = 'Q' };
  #endif

  char c = toupper(getchar());
  
  switch(c) {
  case LEFT:
    fprintf(stdout, "LEFT");
    break;

  case DOWN:
    fprintf(stdout, "DOWN");
    break;

  case UP:
    fprintf(stdout, "UP");
    break;

  case RIGHT:
    fprintf(stdout, "RIGHT");
    break;

  case QUIT:
    fprintf(stdout, "QUIT");
    break;
  }

  system("stty cooked");
  return 0;
}
