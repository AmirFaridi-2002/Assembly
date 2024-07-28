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


section .text
    global _start


_start:
    call READ_NUMBER
    mov [n], rax

    xor rsi, rsi
    mov rcx, [n]
    imul rcx, rcx
    READ_MAT:
        call READ_NUMBER
        mov [mat + rsi*8], rax
        inc rsi
        loop READ_MAT

    mov rcx, [n]
    xor rsi, rsi
    READ_V:
        call READ_NUMBER
        mov [v + rsi*8], rax
        inc rsi
        loop READ_V

    call SOLVE

    mov rcx, [n]
    xor rsi, rsi
    xor rbx, rbx
    PRINT_X:
        mov rax, [x + rsi*8]
        cmp rbx, 0
        jne NEWLINE
        je SET_RBX
        AFTER_NL:
        call PRINT_NUMBER
        inc rsi
        loop PRINT_X

    jmp Exit
    ; call PRINT_NEWLINE

    NEWLINE:
    call PRINT_NEWLINE
    inc rbx
    jmp AFTER_NL

    SET_RBX:
    inc rbx
    jmp AFTER_NL

    Exit:
        mov     rax, sys_exit
        xor     rdi, rdi
        syscall
    
        INDEX:          ; row : rbx
                        ; col : rdx
                        ; res : [idx] -> if out of bound, idx = -1
        push rax
        push rbx
        push rdx
        mov rbx, [i_]
        mov rdx, [j_]

        cmp rbx, [n]
        jge OOB
        cmp rdx, [n]
        jge OOB
        cmp rbx, 0
        jl OOB
        cmp rdx, 0
        jl OOB

        mov rax, [n]
        imul rbx, rax
        add rbx, rdx
        mov [idx], rbx
        RET_INDEX:
        pop rdx
        pop rbx
        pop rax
        ret
        
        OOB:
        mov qword [idx], -1
        jmp RET_INDEX


    SOLVE:  ; solve the equation and find x
        push rax
        push rbx
        push rcx
        push rdx
        push rsi
        push rdi
        push r8
        push r9
        push r10
        push r11

        xor rsi, rsi
        xor rdi, rdi
        mov rcx, [n]
        FOR_i:
            push rcx
            mov rcx, rsi
            xor rdi, rdi
            xor rax, rax
            mov [i_], rsi
            FOR_j:
                cmp rcx, 0
                je END_FOR_j
                mov [j_], rdi
                call INDEX
                mov r8, [idx]
                mov r11, [mat + r8*8]
                mov r8, [x + rdi*8]
                imul r11, r8
                add rax, r11
                inc rdi
                dec rcx
                jmp FOR_j
            END_FOR_j:
            mov r8, [v + rsi*8]
            sub r8, rax
            xchg rax, r8
            mov [j_], rsi
            call INDEX
            mov r8, [idx]
            mov r9, [mat + r8*8]
            xor rdx, rdx
            div r9
            mov [x + rsi*8], rax
            pop rcx
            inc rsi
            dec rcx
            jnz FOR_i

        pop r11
        pop r10
        pop r9
        pop r8
        pop rdi
        pop rsi
        pop rdx
        pop rcx
        pop rbx
        pop rax
        ret




    section .data
        n       :     dq 0                  ; size of matrix
        mat     :     times 1000 dq 0       ; matrix (lower triangular)
        v       :     times 1000 dq 0       ; vector v in mat*x=v
        x       :     times 1000 dq 0       ; solution x
        idx     :     dq 0
        i_      :     dq 0
        j_      :     dq 0


        ; n       : dq 3
        ; mat     : dq 1, 0, 0, 5, 3, 0, 4, 4, 9
        ; v       : dq 1, 8, 17
