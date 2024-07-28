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
    call INP
    call check_CONSEVUTIVE

    mov al, byte 1
    sub al, byte [CONSECUTIVE_FLAG]

    and al, byte [DIGIT_FLAG]
    and al, byte [UPPER_FLAG]
    and al, byte [LOWER_FLAG]

    cmp al, 0
    je PRINT_FALSE

    mov rax, [size]
    cmp rax, qword 8
    jl PRINT_FALSE

    cmp rax, qword 20
    jg PRINT_FALSE

    mov rsi, T
    call PRINT_STRING
    ; call PRINT_NEWLINE
    jmp Exit

    PRINT_FALSE:
    mov rsi, F
    call PRINT_STRING
    ; call PRINT_NEWLINE

    Exit:
        mov     rax, sys_exit
        xor     rdi, rdi
        syscall

    is_DIGIT:   ; checks if al is a digit. the answer is in ah
        cmp al, '0'
        jl  .not_digit
        cmp al, '9'
        jg  .not_digit
        mov ah, 1
        ret
        .not_digit:
            mov ah, 0
            ret

    is_LOWER:
        cmp al, 'a'
        jl  .not_lower
        cmp al, 'z'
        jg  .not_lower
        mov ah, 1
        ret
        .not_lower:
            mov ah, 0
            ret

    is_UPPER:
        cmp al, 'A'
        jl  .not_upper
        cmp al, 'Z'
        jg  .not_upper
        mov ah, 1
        ret
        .not_upper:
            mov ah, 0
            ret

    INP:
        push rax
        push rbx
        push rcx
        push rdx
        push rsi
        push rdi

        mov rdi, buffer
        xor rdx, rdx

        INP_LOOP:
            call GETC
            cmp al, NL
            je END_INP

            mov [rdi], al
            inc rdi
            inc rdx

            CHECK_D:
            call is_DIGIT
            cmp ah, 1
            jne CHECK_L
            mov byte [DIGIT_FLAG], 1

            CHECK_L:
            call is_LOWER
            cmp ah, 1
            jne CHECK_U
            mov byte [LOWER_FLAG], 1

            CHECK_U:
            call is_UPPER
            cmp ah, 1
            jne INP_LOOP
            mov byte [UPPER_FLAG], 1

            jmp INP_LOOP

        END_INP:
            mov [size], rdx
            pop rdi
            pop rsi
            pop rdx
            pop rcx
            pop rbx
            pop rax
            ret

    check_CONSEVUTIVE:  ; check if the buffer has 3 consecutive equal characters
        push rax
        push rbx
        push rcx
        push rdx
        push rsi
        push rdi

        mov rsi, buffer
        mov rcx, [size]
        sub rcx, 3
        
        xor rdx, rdx

        CHECK_LOOP:
            cmp rdx, rcx
            jg END_CHECK

            mov al, [rsi]
            cmp al, [rsi+1]
            jne NOT_EQUAL
            cmp al, [rsi+2]
            jne NOT_EQUAL

            mov byte [CONSECUTIVE_FLAG], 1
            jmp END_CHECK

            NOT_EQUAL:
                inc rsi
                inc rdx
                jmp CHECK_LOOP
            
        END_CHECK:
            pop rdi
            pop rsi
            pop rdx
            pop rcx
            pop rbx
            pop rax
            ret    


    section .data
        T: db "TRUE", 0
        F: db "FALSE", 0

        LOWER_FLAG: db 0
        UPPER_FLAG: db 0
        DIGIT_FLAG: db 0
        CONSECUTIVE_FLAG: db 0

        buffer: times 1000 db 0
        size: dq 0 