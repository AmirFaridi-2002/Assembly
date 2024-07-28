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
    call getstr
    
    mov rbx, [lower]
    mov rdx, [upper]

    ; mov rax, [lower]
    ; call PRINT_NUMBER
    ; call PRINT_NEWLINE
    ; mov rax, [upper]
    ; call PRINT_NUMBER
    ; call PRINT_NEWLINE

    mov rsi, buffer
    cmp rbx, rdx
    jg make_lower
    jl make_upper

    test_first:
        mov al, [buffer]
        cmp al, 'a'
        jge make_lower
        jl make_upper

    make_lower:
        mov al, [rsi]

        cmp al, 0
        je done

        cmp al, 'a'
        jge skip_conversion_lower

        add al, 0x20
        
        skip_conversion_lower:
            mov [rsi], al
            inc rsi
            jmp make_lower
        
    make_upper:
        mov al, [rsi]

        cmp al, 0
        je done

        cmp al, 'a'
        jl skip_conversion_upper

        sub al, 0x20

        skip_conversion_upper:
            mov [rsi], al
            inc rsi
            jmp make_upper

    done:
        mov rsi, buffer
        call PRINT_STRING

    ; call PRINT_NEWLINE

    Exit:
        mov     rax, sys_exit
        xor     rdi, rdi
        syscall

    getstr:
        push rax
        push rcx
        push rsi

        mov rsi, buffer
        xor rcx, rcx

        getstr_loop:
            call GETC
            cmp al, NL
            je getstr_end

            mov [rsi + rcx], al
            inc rcx

            cmp al, 'a'
            jge lower_case
            
            inc qword [upper]
            jmp getstr_loop

        lower_case:
            inc qword [lower]
            jmp getstr_loop

        getstr_end:
            pop rsi
            pop rcx
            pop rax
            ret


    section .data
        buffer : times 1000 db 0
        upper  : dq 4
        lower  : dq 4