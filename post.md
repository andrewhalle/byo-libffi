# Implementing libffi

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

```c
int add(int x, int y) {
  return x + y;
}

int main(void) {
  int x = add(1, 2);
}
```

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

## Calling One Function

```c
typedef struct {
  void *addr;
  int x;
  int y;
} callable;
```

## Calling Any Function

## Writing a Compatability Layer

## Wrapping Up
