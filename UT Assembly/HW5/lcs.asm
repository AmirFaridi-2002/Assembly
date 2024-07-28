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




section .text                             ; I/O functions
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

    ; mov rsi, string_1
    ; call PRINT_STRING
    ; call PRINT_NEWLINE

    ; mov rsi, string_2
    ; call PRINT_STRING
    ; call PRINT_NEWLINE

    mov rsi, string_1
    mov rdi, string_2

    push qword [length_2]
    push qword [length_1]
    call lcs

    call PRINT_NUMBER
    ; call PRINT_NEWLINE

    Exit:
        mov     rax, sys_exit
        xor     rdi, rdi
        syscall
    
    lcs:                
        push rbp
        mov rbp, rsp

        push rbx
        push rcx
        push rdx

        mov rcx, [rbp + 16]         ; s_1[0...rcx]
        mov rdx, [rbp + 24]         ; s_2[0...rdx]

        cmp rcx, 0
        je base_case

        cmp rdx, 0
        je base_case

        mov bl, [rsi + rcx - 1]     ; s_1[rcx - 1]
        mov bh, [rdi + rdx - 1]     ; s_2[rdx - 1]

        cmp bl, bh
        jne not_equal

        dec rdx
        dec rcx
        push rdx
        push rcx

        call lcs

        pop rcx
        pop rdx

        inc rax
        pop rdx
        pop rcx
        pop rbx
        pop rbp
        ret

        base_case:
            xor rax, rax
            pop rdx
            pop rcx
            pop rbx
            pop rbp
            ret

        not_equal:
            push rcx
            push rdx

            dec rcx
            push rdx
            push rcx

            call lcs

            pop rcx
            pop rdx

            pop rdx
            pop rcx

            push rax
            
            dec rdx
            push rdx
            push rcx

            call lcs

            pop rcx
            pop rdx

            pop rdx
            update_max: xchg rax, rdx
            cmp rax, rdx
            jl update_max

            pop rdx
            pop rcx
            pop rbx
            pop rbp
            ret


    getstr:
        push rax
        push rcx
        push rsi
        push rdi

        mov rsi, string_1
        mov rdi, length_1
        xor rcx, rcx
        getstr_loop:
            call GETC
            cmp al, Space
            je getstr_end1
            mov [rsi + rcx], al
            inc rcx
            jmp getstr_loop

        getstr_end1:
            mov byte [rsi + rcx], 0
            mov [rdi], rcx
            ; dec rdi
            ; mov [indexing_1], rdi

        mov rsi, string_2
        mov rdi, length_2
        xor rcx, rcx
        getstr_pool:
            call GETC
            cmp al, NL
            je getstr_end2
            mov [rsi + rcx], al
            inc rcx
            jmp getstr_pool

        getstr_end2:
            mov byte [rsi + rcx], 0
            mov [rdi], rcx
            ; dec rdi
            ; mov [indexing_2], rdi
        
        pop rdi
        pop rsi
        pop rcx
        pop rax
        ret
        


    section .data
        string_1    :     times 1000 db 0
        string_2    :     times 1000 db 0

        length_1    :     dq 0
        length_2    :     dq 0

        ; string_1      :     db "XYGTAM", 0
        ; string_2      :     db "GXYTAKM", 0

        ; length_1      :     dq 6
        ; length_2      :     dq 7
