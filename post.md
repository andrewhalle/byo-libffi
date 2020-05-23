# Implementing libffi

_(repo for this post can be found on [GitHub](https://github.com/andrewhalle/clone-libffi))_

How does code written in one language (say, Python) call written in a different
language (say, C). It's clear that this is necessary (e.g. for perforance concerns) but,
if you're anything like me, it seems like black magic that this should be possible. How
can this possibly work.

A _Foreign Function Interface_ is the means why which code written in one language
calls code written in another language.

[libffi](https://github.com/libffi/libffi) is a low-level library that implements
the _calling convention_ for a particular platform. In this post I'll re-implement
a subset of the functionality provided by libffi and prove that it works by replacing
the real libffi and showing that the Python interpreter still works.

## The Basics

How does a function actually get called? On x86, we have the `call` instruction,
which has the following [definition](https://www.felixcloutier.com/x86/call):

> Saves procedure linking information on the stack and branches to the called
> procedure specified using the target operand.

We can see this in action via [a simple example](https://godbolt.org/z/ESQCRy)
(Compiler Explorer is a great tool for looking at compiler output).

<table style="margin-left: auto; margin-right: auto">
<tr>
<th style="padding: 0px 15px"> C </th>
<th style="padding: 0px 15px"> Assembly </th>
</tr>
<tr valign="top">
<td style="padding: 0px 15px">

```c
int add(int x, int y) {
  return x + y;
}

int main(void) {
  int x = add(1, 2);
}
```

</td>
<td style="padding: 0px 15px">

```asm
add:
        push    rbp
        mov     rbp, rsp
        mov     DWORD PTR [rbp-4], edi
        mov     DWORD PTR [rbp-8], esi
        mov     edx, DWORD PTR [rbp-4]
        mov     eax, DWORD PTR [rbp-8]
        add     eax, edx
        pop     rbp
        ret
main:
        push    rbp
        mov     rbp, rsp
        sub     rsp, 16
        mov     esi, 2
        mov     edi, 1
        call    add
        mov     DWORD PTR [rbp-4], eax
        mov     eax, 0
        leave
        ret
```

</td>
</tr>
</table>

This simple example reveals a lot about what the compiler does for us. Let's look closer at
this snippet in particular.

```asm
mov     esi, 2
mov     edi, 1
call    add
```

Why is the compiler putting the arguments to our `add` function into registers? Why these
registers, in this order? This is because of the _calling convention_ as previously mentioned.
The calling convention is the contract between compilers that allows separate compilation to
happen. The `add` function can assume that its first argument will be in `edi` and its second
argument will be in `esi` (more on this later). Moreover, the calling convention allows the calling
code (in this case, the `main` function) allows the calling code to assume that, after a
function is called, its return value will be in `eax`.

When a dynamic language like Python needs to call into some already compiled C code, how
does it marshall arguments into the appropriate registers? This is the job of libffi, and
what we'll implement in the following sections.

## Calling Code Loaded at Runtime

In order to call native code, the Python interpreter must load in a previously compiled
shared library (a .so file on Linux). This is accomplished via the functions `dlopen` and
`dlsym`. `dlopen` loads a shared object and returns a `void*` handle to that object. The
`dlsym` function takes a handle to a shared object and a string symbol to search for in
that shared object. As an example, to call an `add` function in a shared library `libadd.so`
you can write the following C code:

```c
#include <stdio.h>
#include <dlfcn.h>

typedef int (*add_func)(int, int);

int main(void) {
  void *handle = dlopen("./libadd.so", RTLD_NOW);
  add_func add = (add_func) dlsym(handle, "add");
  printf("1 + 2 = %d\n", add(1, 2));
}
```

This code opens the shared object (loading it immediately because of the flag `RTLD_NOW`),
grabs a pointer to the `add` function, casts that `void` pointer to a pointer to a function
taking two `int`s and returning an `int` (notice the `typedef` at the top of the file).

The `typedef` at the top of the file gives the compiler the information to generate code
to call this function. Our first goal will be to call this function without the `typedef`
(so we have to write the code to call this function, the compiler can't help us).

## Calling One Function

Let's start by defining a struct to hold some information for us, namely the address of the
function to call, and the arguments we're going to pass into that function.

```c
typedef struct {
  int x;
  int y;
  void *func;
} callable;
```

If this were a real library, storing the arguments inside the `callable` would be a bad
idea, because we might want to call this function with different arguments. However, it
will suffice for now.

We'd like to be able to write code like this:

```c
int main(void) {
  void *handle = dlopen("./libadd.so", RTLD_NOW);
  void *add = dlsym(handle, "add");
  callable c = { 1, 2, add };
  int retval;
  runtime_call(&c, &x);
  printf("1 + 2 = %d\n", retval);
}
```

What about this mysterious function `runtime_call`? `runtime_call` needs to do a few things:
 
  * put the first argument in `rdi`
  * put the second argument in `rsi`
  * `call` the function pointed to by `func`
  * put the return value (currently in `eax`) into `&retval`

Since we need direct register access (and the ability to issue a raw `call`) we'll need to
write this function in assembly (I use the NASM assembler).

Compiler Explorer can do most of the work for us here. [This example](https://godbolt.org/z/yTaHL6):

<table style="margin-left: auto; margin-right: auto">
<tr>
<th style="padding: 0px 15px"> C </th>
<th style="padding: 0px 15px"> Assembly </th>
</tr>
<tr valign="top">
<td style="padding: 0px 15px">

```c
int add(int x, int y) {
    return x + y;
}

typedef int (*add_func)(int, int);

typedef struct {
    int x;
    int y;
    void *func;
} callable;

void runtime_call(void* c, void* ret) {
    callable *c1 = (callable*) c;
    int *r1 = (int*) ret;
    add_func a = (add_func) c1->func;
    *r1 = a(c1->x, c1->y);
}

int main() {
    callable c = { 1, 2, add };
    int x;
    runtime_call(&c, &x);
    printf("1 + 2 = %d\n", x);
}
```

</td>
<td style="padding: 0px 15px">

```asm
add:
        push    rbp
        mov     rbp, rsp
        mov     DWORD PTR [rbp-4], edi
        mov     DWORD PTR [rbp-8], esi
        mov     edx, DWORD PTR [rbp-4]
        mov     eax, DWORD PTR [rbp-8]
        add     eax, edx
        pop     rbp
        ret
runtime_call:
        push    rbp
        mov     rbp, rsp
        sub     rsp, 48
        mov     QWORD PTR [rbp-40], rdi
        mov     QWORD PTR [rbp-48], rsi
        mov     rax, QWORD PTR [rbp-40]
        mov     QWORD PTR [rbp-8], rax
        mov     rax, QWORD PTR [rbp-48]
        mov     QWORD PTR [rbp-16], rax
        mov     rax, QWORD PTR [rbp-8]
        mov     rax, QWORD PTR [rax+8]
        mov     QWORD PTR [rbp-24], rax
        mov     rax, QWORD PTR [rbp-8]
        mov     edx, DWORD PTR [rax+4]
        mov     rax, QWORD PTR [rbp-8]
        mov     eax, DWORD PTR [rax]
        mov     rcx, QWORD PTR [rbp-24]
        mov     esi, edx
        mov     edi, eax
        call    rcx
        mov     rdx, QWORD PTR [rbp-16]
        mov     DWORD PTR [rdx], eax
        nop
        leave
        ret
.LC0:
        .string "1 + 2 = %d\n"
main:
        push    rbp
        mov     rbp, rsp
        sub     rsp, 32
        mov     DWORD PTR [rbp-16], 1
        mov     DWORD PTR [rbp-12], 2
        mov     QWORD PTR [rbp-8], OFFSET FLAT:add
        lea     rdx, [rbp-20]
        lea     rax, [rbp-16]
        mov     rsi, rdx
        mov     rdi, rax
        call    runtime_call
        mov     eax, DWORD PTR [rbp-20]
        mov     esi, eax
        mov     edi, OFFSET FLAT:.LC0
        mov     eax, 0
        call    printf
        mov     eax, 0
        leave
        ret
```

</td>
</tr>
</table>

clearly parallels what we're trying to do. And indeed, if we copy the assembly output
into a file `runtime-call.s`, build it with `nasm -f elf64 runtime-call.s` and link the
resulting object file with our `main.c` we'll successfully call this function! (this state
of the code is given by commit 03f737841f966df978341153023a2ac5f565f95e of the repo for
this post).

## Calling Any Function

## Writing a Compatability Layer

## Wrapping Up
