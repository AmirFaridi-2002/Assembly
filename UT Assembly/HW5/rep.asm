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
    call READ_NUMBER
    mov [n], rax

    cmp rax, 0
    je Exit

    call sort
    call k_max

    ; call PRINT_NEWLINE

    Exit:
        mov     rax, sys_exit
        xor     rdi, rdi
        syscall

    check_newline:
        cmp rsi, 0
        je yes
        jne no

        yes:
            ret
        no:
            call PRINT_NEWLINE
            ret

    k_max:
        push rax
        push rsi

        mov rcx, [n]
        xor rsi, rsi

        _loop_kmx:
            mov rax, [lets + rsi]
            call check_newline
            call PUTC
            inc rsi
            loop _loop_kmx


        pop rsi
        pop rax
        ret

    print_arr:
        push rax
        push rsi
        push rcx

        mov rcx, 26
        xor rsi, rsi

        _loop_prnt:
            mov rax, [freq + rsi*8]
            call PRINT_NUMBER
            mov rax, Space
            call PUTC
            inc rsi
            loop _loop_prnt
        call PRINT_NEWLINE
        pop rcx
        pop rsi
        pop rax
        ret


    
    sort:                           ; sorts the freq and the lets array
        push rax
        push rdx
        push rbx

        strt:
            mov rbx, 0
            mov qword [swap], 0

        srt_loop:
            mov rax, [freq + rbx*8]
            mov rdx, [freq + (rbx + 1)*8]
            cmp rax, rdx
            jge srt_end

            mov rax, [freq + rbx*8]
            mov rdx, [freq + rbx*8 + 8]
            mov [freq + rbx*8], rdx
            mov [freq + rbx*8 + 8], rax

            mov al, [lets + rbx]
            mov ah, [lets + rbx + 1]
            mov [lets + rbx], ah
            mov [lets + rbx + 1], al

            mov qword [swap], 1

        srt_end:
            inc rbx
            cmp rbx, 25
            jl srt_loop

            cmp qword [swap], 1
            je strt

        pop rbx
        pop rdx
        pop rax
        ret



    getstr:
        push rax
        push rcx
        push rsi

        mov rsi, buffer
        xor rcx, rcx
        xor rax, rax

        getstr_loop:
            xor rax, rax
            call GETC
            cmp al, Space
            je getstr_end

            mov [rsi + rcx], al
            inc rcx
            
            sub al, 'a'
            add qword [freq + rax*8], 1

            jmp getstr_loop

        getstr_end:
            mov [rsi + rcx], byte 0
            mov [size], rcx

        pop rsi
        pop rcx
        pop rax
        ret

    section .data
        buffer: times 100000 db 0
        size : dq 12
        n    : dq 2
        swap : dq 0
        freq : times 26 dq 0                    ; each index represents the frequency of the corresponding letter
        lets : db "abcdefghijklmnopqrstuvwxyz", 0