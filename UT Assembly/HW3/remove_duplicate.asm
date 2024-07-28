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
    mov rcx, rax
    mov [n], rax    

    mov rbx, 0
    input_loop:
        call READ_NUMBER
        mov [head + rbx], rax
        add rbx, 8
        dec rcx
        jnz input_loop

    mov rax, [head]
    mov rbx, 0
    mov rcx, 0
    find_max:
        mov rax, [head + rbx]
        cmp rax, [max]
        jle not_max
        mov [max], rax
        
        not_max:
            add rbx, 8
            inc rcx
            cmp rcx, [n]
            jnz find_max

    mov rax, [max]
    inc rax
    mov [max], rax


    push rax
    mov rax, n
    mov rax, max
    mov rax, head
    pop rax


    call FIRST_LOOP
    call PRINT_ARRAY

    Exit:
        mov     rax, sys_exit
        xor     rdi, rdi
        syscall

    SPACE:
        push rax
        mov rax, Space
        call PUTC
        pop rax
        ret

    FIRST_LOOP:
        push rax
        push rbx
        push rcx
        push rdx
        push rsi
        push rdi

        mov rcx, [n]         
        sub rcx, 2
        imul rcx, 8         
        add rcx, head       ; maximum i

        mov rdx, head
        loop_first:
            push rdx
            call SECOND_LOOP
            pop rdx

            add rdx, 8
            cmp rdx, rcx
            jg end_first_loop

            jmp loop_first

        end_first_loop:
            pop rdi
            pop rsi
            pop rdx
            pop rcx
            pop rbx
            pop rax
            ret


    SECOND_LOOP:
        push rbp
        mov rbp, rsp

        push rax
        push rbx
        push rcx
        push rdx
        push rsi
        push rdi

        mov rdx, [rbp + 16] ; start index & iterator(j)
        mov rcx, rdx        ; i
        
        mov rbx, [n]
        dec rbx
        imul rbx, 8 
        add rbx, head       ; maximum j

        loop_second:    
            add rdx, 8
            cmp rdx, rbx
            jg end_second_loop
            
            push rcx
            push rdx
            call CHECK
            pop rdx
            pop rcx

            jmp loop_second
        
        end_second_loop:
            pop rdi
            pop rsi
            pop rdx
            pop rcx
            pop rbx
            pop rax
            pop rbp
            ret



    PRINT_ARRAY: ; print in reverse
        push rax
        push rbx
        push rcx
        push rdx

        mov rdx, 0          ; flag for first number
        mov rbx, [max]
        mov rcx, [n]
        imul rcx, 8

        print_loop:
            sub rcx, 8
            cmp rcx, 0
            jl end_print_loop
            mov rax, [head + rcx]
            
            cmp rbx, rax
            jne not_equal

            jmp print_loop
        
        not_equal:
            ; cmp rdx, 1
            ; je flag_first

            call PRINT_NUMBER
            call SPACE
            mov rdx, 1
            jmp print_loop
        
        ; flag_first:
        ;     call SPACE
        ;     call PRINT_NUMBER
        ;     jmp print_loop

        end_print_loop:
            ;call PRINT_NEWLINE
            pop rdx
            pop rcx
            pop rbx
            pop rax
            ret

            
            

    CHECK: ; params = {i, j} indices. if head[i] == head[j] and head[i] != max, then delete head[j] ------------------- Two useless pops are needed after calling this function
        push rbp
        mov rbp, rsp
        push rax
        push rbx
        push rcx
        push rdx
        push rdi
        push rsi

        mov rax, [rbp + 24] ; i
        mov rbx, [rbp + 16] ; j

        mov rdx, [max]
        cmp rdx, [rax]
        je end_check

        mov rcx, [rbx]
        cmp rcx, [rax]
        jne end_check

        mov [rbx], rdx

        end_check:
            pop rsi
            pop rdi
            pop rdx
            pop rcx
            pop rbx
            pop rax
            pop rbp
            ret


    section .data
        n: dq 4
        max: dq 0
        head: times 10000 dq 0