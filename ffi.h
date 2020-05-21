#ifndef _LIBFFI_CLONE_H
#define _LIBFFI_CLONE_H

typedef enum {
  FFI_OK = 0,
} ffi_status;

// only one supported
typedef enum {
  SYSVAMD64 = 0,
} ffi_abi;

typedef struct {
  void *func;
  int *args;
  int n_args;
} callable;

typedef callable ffi_cif;

void init_callable(callable *c);
void add_arg_callable(callable *c, int arg);
void runtime_call(void *c, void *ret);

#endif
