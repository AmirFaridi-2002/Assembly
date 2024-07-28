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
    mov [R], rax
    call READ_NUMBER
    mov [C], rax

    xor rsi, rsi
    mov rcx, [R]
    READ_ROW_LOOP:
        push rcx
        mov rcx, [C]
        READ_COL_LOOP:
            call READ_NUMBER
            mov [matrix + rsi*8], rax
            inc rsi
            loop READ_COL_LOOP
        pop rcx
        loop READ_ROW_LOOP

    call SOLVE

    ; call PRINT_NEWLINE

    Exit:
        mov     rax, sys_exit
        xor     rdi, rdi
        syscall

    INDEX:              ; row : rbx
                        ; col : rdx
                        ; res : [idx] -> if out of bound, idx = -1
        cmp rbx, [R]
        jge .OOB
        cmp rdx, [C]
        jge .OOB
        cmp rbx, 0
        jl .OOB
        cmp rdx, 0
        jl .OOB


        push rax
        push rbx
        mov rax, [C]
        imul rbx, rax
        add rbx, rdx
        mov [idx], rbx
        pop rbx
        pop rax
        ret
        
        .OOB:
        mov qword [idx], -1
        ret

    SOLVE:
                        ; rbx : row
                        ; rdx : col
        xor rbx, rbx
        xor rdx, rdx
        mov rcx, [R]
        FOR_i:
            push rcx
            xor rdx, rdx
            mov rcx, [C]
            FOR_j:
                call INDEX
                mov rsi, [idx]
                mov [self], rsi

                UP:
                dec rbx
                call INDEX
                mov rsi, [idx]
                mov [up], rsi
                inc rbx
            
                DOWN:
                inc rbx
                call INDEX
                mov rsi, [idx]
                mov [down], rsi
                dec rbx

                LEFT:
                dec rdx
                call INDEX
                mov rsi, [idx]
                mov [left], rsi
                inc rdx

                RIGHT:
                inc rdx
                call INDEX
                mov rsi, [idx]
                mov [right], rsi
                dec rdx

                AFTER:
                call CHECK
                inc rdx
                dec rcx
                cmp rcx, 0
                jnz FOR_j

            AFTER_j:
            pop rcx
            inc rbx
            dec rcx
            cmp rcx, 0
            jnz FOR_i

        AFTER_i:
        call SORT
        
    CHECK:
        LOAD_UP:
        cmp byte [up], -1
        je LOAD_DOWN
        mov rsi, [up]
        mov rax, [matrix + rsi*8]
        mov [up], rax

        LOAD_DOWN:
        cmp byte [down], -1
        je LOAD_LEFT
        mov rsi, [down]
        mov rax, [matrix + rsi*8]
        mov [down], rax

        LOAD_LEFT:
        cmp byte [left], -1
        je LOAD_RIGHT
        mov rsi, [left]
        mov rax, [matrix + rsi*8]
        mov [left], rax

        LOAD_RIGHT:
        cmp byte [right], -1
        je LOAD_SELF
        mov rsi, [right]
        mov rax, [matrix + rsi*8]
        mov [right], rax

        LOAD_SELF:
        cmp byte [self], -1
        je LOAD_RIGHT
        mov rsi, [self]
        mov rax, [matrix + rsi*8]
        mov [self], rax

        CMP_UP:
        cmp qword [up], -1
        je CMP_DOWN
        cmp rax, [up]
        jle IS_NOT

        CMP_DOWN:
        cmp qword [down], -1
        je CMP_LEFT
        cmp rax, [down]
        jle IS_NOT

        CMP_LEFT:
        cmp qword [left], -1
        je CMP_RIGHT
        cmp rax, [left]
        jle IS_NOT

        CMP_RIGHT:
        cmp qword [right], -1
        je IS_LOCAL
        cmp rax, [right]
        jle IS_NOT

        IS_LOCAL:
        mov rdi, [size]
        mov [locals + rdi*8], rax
        inc rdi
        mov [size], rdi
        ret

        IS_NOT:
        ret

    SORT:
        mov rax, [size]
        mov rcx, rax
        mov rdi, rax
        mov rsi, rax
        dec rsi
        imul rsi, 8

        cmp rcx, 1
        je PRINT_INIT

        cmp rcx, 0
        jne STRT

        mov al, '['
        call PUTC
        mov al, ']'
        call PUTC
        jmp RET


        STRT:
            mov rbx, 0
            mov qword [swap], 0
        
        ITER:
            mov rax, [locals + rbx]
            cmp rax, [locals + rbx + 8]
            jbe NOSWAP

            mov rdx, [locals + rbx + 8]
            mov [locals + rbx + 8], rax
            mov [locals + rbx], rdx
            mov qword [swap], 1

        NOSWAP:
            add rbx, 8
            cmp rbx, rsi
            jne ITER
            cmp qword [swap], 1
            je STRT

        PRINT_INIT:
        mov rcx, [size]
        xor rsi, rsi
        xor rbx, rbx
        PRINT_LOOP:
            cmp rbx, 0
            jne PRINT_SPACE
            AFTER_SPACE:
            mov rbx, 1
            mov rax, [locals + rsi*8]
            call PRINT_NUMBER
            ; mov rax, Space
            ; call PUTC
            inc rsi
            loop PRINT_LOOP
            jmp RET

        PRINT_SPACE:
            mov rax, Space
            call PUTC
            jmp AFTER_SPACE

        RET:
        ret
    


    section .data
        R       :       dq 1
        C       :       dq 1
        idx     :       dq 0
        is_max  :       db 0
        matrix  :       times 1000 dq 0
        ; matrix  :       dq 1, 1, 1, 1, 1, 1
        ; matrix  :       dq 2, 3, 5, 1, 9, 4, 2, 2, 2
        ; matrix  :       dq 5
        locals  :       times 1000 dq 0
        size    :       dq 0
        up      :       dq 0
        down    :       dq 0
        left    :       dq 0
        right   :       dq 0
        self    :       dq 0
        swap    :       dq 0
        