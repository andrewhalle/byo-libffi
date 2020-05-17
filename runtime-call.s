global runtime_call

section .text
runtime_call:  push    rbp
               mov     rbp, rsp
               sub     rsp, 48
               mov     QWORD [rbp-40], rdi
               mov     QWORD [rbp-48], rsi
               mov     rax, QWORD [rbp-40]
               mov     QWORD [rbp-8], rax
               mov     rax, QWORD [rbp-48]
               mov     QWORD [rbp-16], rax
               mov     rax, QWORD [rbp-8]
               mov     rax, QWORD [rax+8]
               mov     QWORD [rbp-24], rax
               mov     rax, QWORD [rbp-8]
               mov     edx, DWORD [rax+4]
               mov     rax, QWORD [rbp-8]
               mov     eax, DWORD [rax]
               mov     rcx, QWORD [rbp-24]
               mov     esi, edx
               mov     edi, eax
               call    rcx
               mov     rdx, QWORD [rbp-16]
               mov     DWORD [rdx], eax
               nop
               leave
               ret

				while (n_args > 6) {
					push    6           ; push additional arguments onto the stack
					n_args--            ; don't actually decrement n_args, make a copy
				}

				jmp     6 - n_args    ; if we have 6 args, this doesn't jump and pushes
				                      ; into all registers
															; if we have less than 6 arguments, this skips the
															; unneeded registers

        mov     r9d, 5 ; order of registers is the calling convention
        mov     r8d, 4
        mov     ecx, 3
        mov     edx, 2
        mov     esi, 1
        mov     edi, 0

