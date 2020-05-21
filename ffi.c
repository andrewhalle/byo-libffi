#include <stdlib.h>
#include "./ffi.h"

void init_callable(callable *c) {
  c->args = (int*) malloc(16 * sizeof(int));
  c->n_args = 0;
}

void add_arg_callable(callable *c, int arg) {
  c->args[c->n_args] = arg;
  c->n_args++;
}
