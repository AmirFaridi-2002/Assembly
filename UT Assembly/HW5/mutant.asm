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
    mov rsi, string_1
    mov rdi, length_1
    push rsi
    push rdi

    call getstr

    mov rsi, string_2
    mov rdi, length_2
    push rsi
    push rdi

    call getstr

    call READ_NUMBER
    mov [n], rax
    

    ; mov rsi, string_1
    ; call PRINT_STRING
    ; call PRINT_NEWLINE

    ; mov rax, [length_1]
    ; call PRINT_NUMBER
    ; call PRINT_NEWLINE

    mov rdi, result

    mov rsi, string_1
    ; mov rdx, length_1

    ; cmp qword [n], rdx
    ; jg done

    mov rcx, [length_1]
    cmp rcx, [n]
    jle first_loop
    mov rcx, [n]


    first_loop:
        mov al, [rsi]
        mov [rdi], al
        inc rsi
        inc rdi
        loop first_loop


    mov rdx, [length_2]
    cmp rdx, [n]
    jle done

    mov rsi, string_2
    add rsi, [n]
    ; dec rsi

    second_loop:
        mov al, [rsi]
        cmp al, 0
        je done

        mov [rdi], al
        inc rsi
        inc rdi
        jmp second_loop



    done:
        mov rsi, result
        call PRINT_STRING

    ; call PRINT_NEWLINE

    Exit:
        mov     rax, sys_exit
        xor     rdi, rdi
        syscall 


    getstr:
        push rbp
        mov rbp, rsp
        push rax
        push rcx
        push rsi
        push rdi

        mov rsi, [rbp + 24]             ; address of the string to store the input in.
        mov rdi, [rbp + 16]             ; address of the length of the string.
        xor rcx, rcx

        getstr_loop:
            call GETC
            cmp al, NL
            je getstr_end

            mov [rsi + rcx], al
            inc rcx

            jmp getstr_loop

        getstr_end:
            mov byte [rsi + rcx], 0
            mov [rdi], rcx

        pop rdi
        pop rsi
        pop rcx
        pop rax
        pop rbp
        ret 16


    section .data
        string_1: times 100000 db 0
        length_1: dq 0

        string_2: times 100000 db 0
        length_2: dq 0

        result  : times 100000 db 0

        n       : dq 0

        ; string_1 : db "abcdefg", 0
        ; length_1 : dq 7

        ; string_2 : db "zyxwvutsrq", 0
        ; length_2 : dq 10

        ; result   : times 1000 db 0

        ; n        : dq 9

