section .data

    fname db "data.txt",0
    mode db "a",0                                ;;set file mode for reading
    format db "%d%c %d", 0

;;--- end of the data section -----------------------------------------------;;

section .bss
    c resd 1
    y resd 1
    x resd 1
    fp resb 1

section .text
    extern fopen
    global _main
    extern fscanf

_main:        
    push rbp
    mov rbp,rsp

    mov rax, mode
    push rax
    mov rax, fname
    push rax
    call fopen                
    mov [fp], rax ;store file pointer

    lea rax, [y]
    push rax        
    lea rax, [c] 
    push rax
    lea rax, [x]        
    push rax
    lea rax, [format]
    push rax
    mov rax, [fp] 
    push rax
    call fscanf

    ;at this point x, y and c has the data

    mov rax,0
    mov rsp,rbp
    pop rbp
    ret
