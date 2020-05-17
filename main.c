#include <stdio.h>
#include <dlfcn.h>

// not allowed to put this, else the compiler will helpfully generate
// code to call a function with this signature for us
// typedef int (*add_func)(int, int);

typedef struct {
  void *func;
  int *args;
  int n_args;
} callable;

void init_callable(callable *c) {
  c->args = (int*) malloc(16 * sizeof(int));
  c->n_args = 0;
}

void add_arg_callable(callable *c, int arg) {
  c->args[c->n_args] = arg;
  c->n_args++;
}

// this is the function we'll write in assembly
// takes a pointer to a callable, and a pointer to where
// to store the return
void runtime_call(void *c, void *ret);

int main(void) {
  void *handle = dlopen("./libadd.so", RTLD_NOW);
  void *add = dlsym(handle, "add");

  callable c = { add };
  init_callable(&c);
  add_arg_callable(&c, 1);
  add_arg_callable(&c, 2);

  int x;
  runtime_call(&c, &x);
  printf("1 + 2 = %d\n", x);
}
