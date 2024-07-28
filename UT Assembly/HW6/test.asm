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

    call INP

    mov rcx, [R]
    mov rdx, [C]
    imul rcx, rdx
    xor rdx, rdx
    PRINT:
        xor rax, rax
        mov al, [matrix + rdx]
        call PRINT_NUMBER
        mov rax, Space
        call PUTC
        inc rdx
        loop PRINT

    call PRINT_NEWLINE

    Exit:
        mov     rax, sys_exit
        xor     rdi, rdi
        syscall

    INP:
        push rax
        push rbx
        push rcx
        push rdx
        push rsi
        push rdi

        xor rax, rax
        xor rdx, rdx
        INP_FIRST_LOOP:
            call GETC
            cmp al, Space
            je INP_FIRST_LOOP

            cmp al, NL
            je END_FIRST_LOOP

            sub al, 0x30
            mov [matrix + rdx], al
            inc rdx
            jmp INP_FIRST_LOOP
        
        END_FIRST_LOOP:
            mov [C], rdx
            mov rdi, matrix
            add rdi, rdx

        mov rcx, [R]
        dec rcx

        INP_SECOND_LOOP:
            push rcx
            mov rcx, [C]
            get_row:
                call READ_NUMBER
                mov [rdi], al
                inc rdi
                loop get_row
            pop rcx
        loop INP_SECOND_LOOP
    
        mov byte [rdi], NL

        pop rdi
        pop rsi
        pop rdx
        pop rcx
        pop rbx
        pop rax
        ret

    INDEX:      ; row : rbx, col : rdx -> res : rbx
        push rax
        mov rax, [C]
        imul rbx, rax
        add rbx, rdx
        pop rax
        ret

    MIN:        ; store min{DP[i-1][j], DP[i][j-1], DP[i-1][j-1]} in M
        push rax
        push rbx
        push rcx
        push rdx
        push rsi
        push rdi

        mov rsi, DP
        
        push rbx
        push rdx
        dec rbx
        call INDEX
        mov al, [rsi + rbx]
        mov [t1], al
        pop rdx
        pop rbx

        push rbx
        push rdx
        dec rdx
        call INDEX
        mov al, [rsi + rbx]
        mov [t2], al
        pop rdx
        pop rbx

        push rbx
        push rdx
        dec rbx
        dec rdx
        call INDEX
        mov al, [rsi + rbx]
        mov [t3], al
        pop rdx
        pop rbx

        mov al, [t1]
        mov bl, [t2]
        mov cl, [t3]

        M1:
        cmp al, bl
        jle M2
        mov al, bl
        M2:
        cmp al, cl
        jle M3
        mov al, cl
        M3:
        mov [M], al

        pop rdi
        pop rsi
        pop rdx
        pop rcx
        pop rbx
        pop rax
        ret



    SOLVE:
        push rax
        push rbx
        push rcx
        push rdx
        push rsi
        push rdi

        mov rdi, DP
        mov rsi, matrix
        mov rcx, [C]
        COPY_ROW:       ; copy first row into DP table
            mov [rdi], byte [rsi]
            inc rsi
            inc rdi
            loop COPY_ROW

        ; copy first column into DP table
        mov rdi, DP
        mov rsi, matrix
        xor rax, rax
        xor rbx, rbx
        xor rdx, rdx
        mov rcx, [R]
        COPY_COL:
            mov rbx, rax        ; row
            xor rdx, rdx        ; col
            call INDEX          ; index in rbx
            mov al, [rsi + rbx]
            mov [rdi + rbx], al
            inc rax
            loop COPY_COL

                    ; if matrix[i][j] == 1 then DP[i][j] = min(DP[i-1][j], DP[i][j-1], DP[i-1][j-1]) + 1 else 0
        mov rbx, 1
        mov rcx, [R]
        dec rcx
        FOR_i:
            push rcx
            mov rdx, 1
            mov rcx, [C]
            dec rcx
            FOR_j:
                push rbx
                call INDEX
                pop rbx
                cmp byte [matrix + rbx], 1
                jne ELSE
                call MIN
                mov al, [M]
                inc al
                jmp END_IF
                ELSE:
                mov al, 0
                END_IF:
                mov [DP + rbx], al
                inc rdx
                loop FOR_j
            pop rcx
            inc rbx
            loop FOR_i
        
        pop rdi
        pop rsi
        pop rdx
        pop rcx
        pop rbx
        pop rax
        ret

    FIND_MAX:
        push rax
        push rbx
        push rcx
        push rdx
        push rsi
        push rdi

        xor rax, rax
        mov rcx, [R]
        mov rdx, [C]
        imul rcx, rdx
        mov rsi, DP
        FIND_MAX_LOOP:
            mov al, [rsi]


    section .data
        matrix: times 1000 dq 0
        R:  dq 0
        C:  dq 0
        M:  db 0            ; min
        t1: db 0            ; dp[i-1][j]
        t2: db 0            ; dp[i][j-1]
        t3: db 0            ; dp[i-1][j-1]
        DP: times 1000 dq 0