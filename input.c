#include <stdlib.h>
#include <stdio.h>
#include <ctype.h>

int main(int argc, char **argv) {
  system("stty raw");
  
  enum { LEFT = 'H',
	 DOWN = 'J',
	 UP = 'K',
	 RIGHT = 'L',
	 QUIT = 'Q' };
  
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
