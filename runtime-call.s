global runtime_call

section .text
runtime_call: push    rbp
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
