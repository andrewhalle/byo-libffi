#include <stdio.h>
#include <dlfcn.h>

typedef int (*add_func)(int, int);

int main(void) {
  void *handle = dlopen("./libadd.so", RTLD_NOW);
  add_func add = (add_func) dlsym(handle, "add");
  printf("1 + 2 = %d\n", add(1, 2));
}
