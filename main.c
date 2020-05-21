#include <stdio.h>
#include <dlfcn.h>
#include "./ffi.h"

int main(void) {
  void *handle = dlopen("./libadd.so", RTLD_NOW);
  void *add = dlsym(handle, "add");

  callable c = { add };
  init_callable(&c);
  add_arg_callable(&c, 1);
  add_arg_callable(&c, 2);
  add_arg_callable(&c, 3);
  add_arg_callable(&c, 4);
  add_arg_callable(&c, 5);
  add_arg_callable(&c, 6);
  add_arg_callable(&c, 7);
  add_arg_callable(&c, 8);
  add_arg_callable(&c, 9);
  add_arg_callable(&c, 10);

  int x;
  runtime_call(&c, &x);
  printf("Result: %d\n", x);
}
