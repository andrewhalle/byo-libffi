#include <stdio.h>
#include <dlfcn.h>

// not allowed to put this, else the compiler will helpfully generate
// code to call a function with this signature for us
// typedef int (*add_func)(int, int);

typedef struct {
  int x;
  int y;
  void *func;
} callable;

// this is the function we'll write in assembly
// takes a pointer to a callable, and a pointer to where
// to store the return
void runtime_call(void *c, void *ret);

int main(void) {
  void *handle = dlopen("./libadd.so", RTLD_NOW);
  void *add = dlsym(handle, "add");
  callable c = { 1, 2, add };
  int x;
  runtime_call(&c, &x);
  printf("1 + 2 = %d\n", x);
}
