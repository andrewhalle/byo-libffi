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
							 mov     r10d, DWORD [rbx + 4 * rax]
							 push    r10
							 dec     eax
							 jmp     .loop_start

.loop_done:    neg     eax           ; want to jmp on 6 - n_args
               add     eax, 6
							 jmp     rax
               mov     r9d, DWORD [rbx + 4 * 5] ; order of registers is the calling convention
               mov     r8d, DWORD [rbx + 4 * 4]
               mov     ecx, DWORD [rbx + 4 * 3]
               mov     edx, DWORD [rbx + 4 * 2]
               mov     esi, DWORD [rbx + 4 * 1]
               mov     edi, DWORD [rbx + 4 * 0]

               mov     rbx, QWORD [rbp-40]  ; move addr of function into rbx
							 call    rbx

               mov     rbx, QWORD [rbp-40]  ; move addr of retval into rbx
               mov     rbx, QWORD [rbx+8]
               mov     DWORD [rbx], eax     ; retval is now in eax

               mov     rbx, QWORD [rbp-8]   ; restore rbx
               leave
               ret
