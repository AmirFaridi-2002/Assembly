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
    xor rsi, rsi        ; even
    xor rdi, rdi        ; odd
    xor rax, rax
    STR_READ:
        xor rax, rax
        call GETC
        cmp al, NL
        je STR_END
        push rax
        and al, 0x1
        cmp al, 0
        je STR_EVEN
        
        STR_ODD:
        pop rax
        mov [odd + rdi], al
        inc rdi
        jmp STR_READ

        STR_EVEN:
        pop rax
        mov [even + rsi], al
        inc rsi
        jmp STR_READ

    STR_END:
        mov [eLEN], rsi
        mov [oLEN], rdi
        mov byte [even + rsi], 0
        mov byte [odd + rdi], 0

        mov rax, [eLEN]
        add rax, [oLEN]
        mov [tLEN], rax


    mov rsi, even
    mov rcx, [eLEN]
    push rsi
    push rcx
    call SORT

    mov rsi, odd
    mov rcx, [oLEN]
    push rsi
    push rcx
    call SORT

    mov rsi, even
    mov rdi, eos
    call FILL
    mov rsi, odd
    call FILL
    mov byte [rdi], 0

    mov rsi, odd
    mov rdi, oes
    call FILL
    mov rsi, even
    call FILL
    mov byte [rdi], 0


    ; mov rsi, eos
    ; call PRINT_STRING
    ; call PRINT_NEWLINE
    ; mov rsi, oes
    ; call PRINT_STRING
    ; call PRINT_NEWLINE

    ; ------------------------------------------------
    mov rsi, eos
    mov rcx, [tLEN]
    push rsi
    push rcx
    call CHECK

    xor rax, rax
    mov al, [ans]
    mov [tmp], al
    ; call PRINT_NUMBER
    ; call PRINT_NEWLINE

    mov rsi, oes
    push rsi
    push rcx
    call CHECK

    xor rbx, rbx
    mov bl, [ans]
    mov rax, rbx
    ; call PRINT_NUMBER
    ; call PRINT_NEWLINE

    xor rax, rax
    mov al, [tmp]
    or rax, rbx

    cmp rax, 0
    je NO

    mov rsi, TRUE
    call PRINT_STRING
    ; call PRINT_NEWLINE
    jmp Exit

    NO:
    mov rsi, FALSE
    call PRINT_STRING
    ; call PRINT_NEWLINE
    ; --------------------------------------------------------------------------



    Exit:
        mov     rax, sys_exit
        xor     rdi, rdi
        syscall
    
    CHECK:                      ; result in ans
        push rbp
        mov rbp, rsp
        push rax
        push rbx
        push rcx
        push rdx
        push rsi
        push rdi

        mov rsi, [rbp + 24]     ; string
        mov rcx, [rbp + 16]     ; size

        dec rcx
        xor rax, rax
        xor rbx, rbx
        xor rdx, rdx
        mov dl, 1
        FOR_i_CHECK:
            mov al, [rsi]
            mov bl, [rsi + 1]
            sub al, bl
            cmp al, 0
            jl NEGATE
            AFTER_NEG:
            cmp al, 1
            je EQUAL
            jne NEQUAL
            AFTER_SET:
            and dl, al
            inc rsi
            loop FOR_i_CHECK

        mov [ans], dl
        jmp RET

        NEGATE:
            imul rax, -1
            jmp AFTER_NEG
        
        EQUAL:
            mov al, 0
            jmp AFTER_SET
        
        NEQUAL:
            mov al, 1
            jmp AFTER_SET

        RET:
        pop rdi
        pop rsi
        pop rdx
        pop rcx
        pop rbx
        pop rax
        pop rbp
        ret 8    
        

    FILL: ; from rsi to rdi
        push rax
        xor rax, rax
        FILL_LOOP:
            mov al, [rsi]
            cmp al, 0
            je END_FILL
            mov [rdi], al
            inc rsi
            inc rdi
            jmp FILL_LOOP
        END_FILL:
        pop rax
        ret
        
    SORT:
        push rbp
        mov rbp, rsp
        push rax
        push rbx
        push rcx
        push rdx
        push rsi
        push rdi

        ; bubble sort
        mov rbx, [rbp + 24]     ; array to be sorted (bytes)
        mov rcx, [rbp + 16]     ; size of the array
        cmp rcx, 1
        jle BRK

        xor rax, rax
        xor rsi, rsi            ; i
        dec rcx
        FOR_i:
            mov byte [swp], 0
            push rcx
            mov rcx, [rbp + 16]
            sub rcx, rsi
            dec rcx
            xor rdi, rdi        ; j
            FOR_j:
                mov al, [rbx + rdi]
                cmp al, [rbx + rdi + 1]
                jle SKIP_SWAP
                mov al, [rbx + rdi]
                mov ah, [rbx + rdi + 1]
                mov [rbx + rdi], ah
                mov [rbx + rdi + 1], al
                mov byte [swp], 1
                SKIP_SWAP:
                inc rdi
                loop FOR_j
            pop rcx
            cmp byte [swp], 0
            je BRK
            inc rsi
            loop FOR_i

        BRK:
        pop rdi
        pop rsi
        pop rdx
        pop rcx
        pop rbx
        pop rax
        pop rbp
        ret 8
        

    section .data
        even        :      times 1000 db 0
        odd         :      times 1000 db 0  
        eo          :      times 1000 db 0 
        oe          :      times 1000 db 0
        oes         :      times 1000 db 0
        eos         :      times 1000 db 0
        eLEN        :      dq 0
        oLEN        :      dq 0
        tLEN        :      dq 0

        testinp     :      db "aab", 0
        len         :      dq 3


        TRUE        :      db "TRUE", 0
        FALSE       :      db "FALSE", 0
        swp         :      db 0
        ans         :      db 0
        tmp         :      db 0