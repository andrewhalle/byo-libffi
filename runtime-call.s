global runtime_call

section .text
runtime_call:  push    rbp       ; prelude, move the address of the callable and the
               mov     rbp, rsp  ; retval into memory
               push    rbx
               sub     rsp, 40
               mov     QWORD [rbp-40], rdi
               mov     QWORD [rbp-48], rsi

               mov     rbx, QWORD [rbp-40]  ; move the pointer pointing to the array
               mov     rbx, QWORD [rbx+8]   ; of ints which will be our args into rbx

               mov     rax, QWORD [rbp-40]  ; put n_args in eax
               mov     eax, DWORD [rax+16]

.loop_start:   cmp     eax, 6
							 jle     .loop_done
							 mov     r10d, DWORD [rbx + 4 * (rax - 1)]
							 push    r10
							 dec     eax
							 jmp     .loop_start

.loop_done:    cmp     eax, 6
               je      .six_args
							 cmp     eax, 5
							 je      .five_args
							 cmp     eax, 4
							 je      .four_args
							 cmp     eax, 3
							 je      .three_args
							 cmp     eax, 2
							 je      .two_args
							 cmp     eax, 1
							 je      .one_arg
							 cmp     eax, 0
							 je      .zero_args

.six_args:     mov     r9d, DWORD [rbx + 4 * 5] ; order of registers is the calling convention
.five_args:    mov     r8d, DWORD [rbx + 4 * 4]
.four_args:    mov     ecx, DWORD [rbx + 4 * 3]
.three_args:   mov     edx, DWORD [rbx + 4 * 2]
.two_args:     mov     esi, DWORD [rbx + 4 * 1]
.one_arg:      mov     edi, DWORD [rbx + 4 * 0]

.zero_args:    mov     rbx, QWORD [rbp-40]  ; move addr of function into rbx
               mov     rbx, QWORD [rbx]
							 call    rbx

               mov     rbx, QWORD [rbp-48]  ; move addr of retval into rbx
               mov     DWORD [rbx], eax     ; move retval (currently in eax) into retval

               mov     rbx, QWORD [rbp-8]   ; restore rbx
               leave
               ret
