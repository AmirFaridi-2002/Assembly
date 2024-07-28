section .data
    sys_read        equ     0
    sys_write       equ     1
    sys_open        equ     2
    sys_close       equ     3
    sys_lseek       equ     8
    sys_create      equ     85
    sys_unlink      equ     87
    sys_mkdir       equ     83
    sys_makenewdir  equ     0q777
    sys_mmap        equ     9
    sys_mumap       equ     11
    sys_brk         equ     12
    sys_exit        equ     60
    stdin           equ     0
    stdout          equ     1
    stderr          equ     3

	PROT_NONE	    equ     0x0
    PROT_READ       equ     0x1
    PROT_WRITE      equ     0x2
    MAP_PRIVATE     equ     0x2
    MAP_ANONYMOUS   equ     0x20
    O_DIRECTORY     equ     0q0200000
    O_RDONLY        equ     0q000000
    O_WRONLY        equ     0q000001
    O_RDWR          equ     0q000002
    O_CREAT         equ     0q000100
    O_APPEND        equ     0q002000
    BEG_FILE_POS    equ     0
    CURR_POS        equ     1
    END_FILE_POS    equ     2
    
    sys_IRUSR       equ     0q400      
    sys_IWUSR       equ     0q200      

    NL              equ   0xA
    Space           equ   0x20
    Tab             equ   0x9




section .text
    PRINT_NEWLINE:                        
        push   rax
        mov    rax, NL
        call   PUTC
        pop    rax
        ret

    PUTC:	                              
        push   rcx
        push   rdx
        push   rsi
        push   rdi 
        push   r11 

        push   ax
        mov    rsi, rsp    
        mov    rdx, 1      
        mov    rax, sys_write
        mov    rdi, stdout 
        syscall
        pop    ax

        pop    r11
        pop    rdi
        pop    rsi
        pop    rdx
        pop    rcx
        ret

    PRINT_NUMBER:
        push   rax
        push   rbx
        push   rcx
        push   rdx

        sub    rdx, rdx
        mov    rbx, 10 
        sub    rcx, rcx
        cmp    rax, 0
        jge    w_Again
        push   rax 
        mov    al, '-'
        call   PUTC
        pop    rax
        neg    rax

    w_Again:                             
        cmp    rax, 9	
        jle    c_End
        div    rbx
        push   rdx
        inc    rcx
        sub    rdx, rdx
        jmp    w_Again

    c_End:                               
        add    al, 0x30
        call   PUTC
        dec    rcx
        jl     w_End
        pop    rax
        jmp    c_End

    w_End:                                
        pop    rdx
        pop    rcx
        pop    rbx
        pop    rax
        ret

    

    PRINT_STRING:
        push    rax
        push    rcx
        push    rsi
        push    rdx
        push    rdi

        mov     rdi, rsi
        call    GetStrlen
        mov     rax, sys_write  
        mov     rdi, stdout
        syscall 

        pop     rdi
        pop     rdx
        pop     rsi
        pop     rcx
        pop     rax
        ret
    
    GetStrlen:
        push    rbx
        push    rcx
        push    rax  

        xor     rcx, rcx
        not     rcx
        xor     rax, rax
        cld
                repne   scasb
        not     rcx
        lea     rdx, [rcx -1]  

        pop     rax
        pop     rcx
        pop     rbx
        ret

    GETC:
        push   rcx
        push   rdx
        push   rsi
        push   rdi 
        push   r11 

        
        sub    rsp, 1
        mov    rsi, rsp
        mov    rdx, 1
        mov    rax, sys_read
        mov    rdi, stdin
        syscall
        mov    al, [rsi]
        add    rsp, 1

        pop    r11
        pop    rdi
        pop    rsi
        pop    rdx
        pop    rcx

        ret

    READ_NUMBER:
        push   rcx
        push   rbx
        push   rdx

        mov    bl,0
        mov    rdx, 0

    r_Again:
        xor    rax, rax
        call   GETC
        cmp    al, '-'
        jne    s_Again
        mov    bl,1  
        jmp    r_Again
    
    s_Again:
        cmp    al, NL
        je     r_End
        cmp    al, ' '
        je     r_End
        sub    rax, 0x30
        imul   rdx, 10
        add    rdx,  rax
        xor    rax, rax
        call   GETC
        jmp    s_Again

    r_End:
        mov    rax, rdx 
        cmp    bl, 0
        je     s_End
        neg    rax 

    s_End:  
        pop    rdx
        pop    rbx
        pop    rcx
        ret

    
    MATCH:
        push 0
        cmp rcx, [n]
        jge retF
        pop rdx

        cmp al, 'I'
        je MATCH_I

        mov dl, [rsi + rcx]
        inc rcx

        push 0
        cmp al, dl
        jne retF

        jmp retT
    
    MATCH_I:
        mov al, [rsi + rcx]

        push 0
        cmp al, '0'
        jl retF

        cmp al, '9'
        jg retF

        integer_loop:
            inc rcx
            mov al, [rsi + rcx]

            cmp al, '0'
            jl integer_loop_end

            cmp al, '9'
            jg integer_loop_end

            jmp integer_loop

            integer_loop_end:
                jmp retT

    retF:
        pop rdx
        F_POP:
            cmp rdx, 0
            jle F_RET
            pop rbp
            dec rdx
            jmp F_POP
        F_RET:
            mov rbx, 0
            ret

    retT:
        pop rdx
        T_POP:
            cmp rdx, 0
            jle T_RET
            pop rbp
            dec rdx
            jmp T_POP
        T_RET:
            mov rbx, 1
            ret


    EXP:            
        push rcx
        call E1
        
        push 1
        cmp rbx, 1
        je retT
        pop rdx

        pop rcx
        call E2

        push 0
        cmp rbx, 1
        je retT

        jmp retF


    TERM:
        push rcx
        call T1

        push 1
        cmp rbx, 1
        je retT
        pop rdx
        
        pop rcx
        push rcx
        call T2

        push 1
        cmp rbx, 1
        je retT
        pop rdx

        pop rcx
        call T3

        push 0
        cmp rbx, 1
        je retT

        jmp retF
        

    E1:
        call TERM
        push 0
        cmp rbx, 1
        jne retF
        pop rdx

        mov al, '+'
        call MATCH
        push 0
        cmp rbx, 1
        jne retF
        pop rdx

        call EXP
        push 0
        cmp rbx, 1
        jne retF

        jmp retT

    E2:
        call TERM
        push 0
        cmp rbx, 1
        jne retF
        
        jmp retT


    T1:
        mov al, 'I'
        call MATCH
        push 0
        cmp rbx, 1
        jne retF
        pop rdx

        mov al, '*'
        call MATCH
        push 0
        cmp rbx, 1
        jne retF
        pop rdx

        call TERM
        push 0
        cmp rbx, 1
        jne retF

        jmp retT

    
    T2:
        mov al, 'I'
        call MATCH
        
        push 0
        cmp rbx, 1
        jne retF

        jmp retT

    T3:
        mov al, "("
        call MATCH
        push 0
        cmp rbx, 1
        jne retF
        pop rdx

        call EXP
        push 0
        cmp rbx, 1
        jne retF
        pop rdx

        mov al, ")"
        call MATCH
        push 0
        cmp rbx, 1
        jne retF

        jmp retT

    GET_STRING:
        push rbp
        mov rbp, rsp

        push rax
        push rbx
        push rcx
        push rdx
        push rsi
        push rdi

        mov rsi, buffer
        xor rcx, rcx

        .read_loop:
            call GETC
            cmp al, NL
            je .end_input

            mov [rsi + rcx], al
            inc rcx
            jmp .read_loop

        .end_input:
            mov byte [rsi + rcx], 0
            pop rdi
            pop rsi
            pop rdx
            pop rcx
            pop rbx
            pop rax
            pop rbp
            ret

section .text
    global _start


_start:
    mov rsi, buffer

    xor rax, rax
    xor rbx, rbx
    xor rcx, rcx
    xor rdx, rdx

    call GET_STRING
    mov rsi, buffer
    len_loop:
        cmp byte [rsi + rcx], 0
        je len_end
        inc rcx
        jmp len_loop

    len_end:
        mov [n], rcx
        xor rcx, rcx
        mov rsi, buffer


    call EXP
    mov rax, rbx
    cmp rcx, [n]
    jl .print_0

    mov rsi, accept
    call PRINT_STRING
    ;call PRINT_NEWLINE
    jmp Exit

    .print_0:
        mov rsi, reject
        call PRINT_STRING
        ;call PRINT_NEWLINE



    Exit:
        mov     rax, sys_exit
        xor     rdi, rdi
        syscall

    section .data
        n   : dq 5
        accept : db "accept", 0
        reject  : db "reject" , 0

        lpar: db "(", 0
        rpar: db ")", 0

        ;buffer: db "8+6-2", 0

    section .bss
        buffer resb 255