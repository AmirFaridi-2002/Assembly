%include "../phase2/src/incs/EQUS.inc"
%include "../phase2/src/incs/BASIC_FUNCTIONS.inc"

SECTION .text

FILE_OPEN:      ; RDI: FILE PATH. RETURNS FD IN RAX
    PUSH    RDI
    PUSH    RSI
    PUSH    RDX
    MOV     RAX, SYS_OPEN
    MOV     RSI, O_RDWR | O_CREAT | O_TRUNC
    MOV     RDI, RDI
    MOV     RDX, 0666
    SYSCALL
    POP     RDX
    POP     RSI
    POP     RDI
    RET


FILE_CLOSE:     ; FILE_CLOSE: RDI: FILE DESCRIPTOR (ADDR)
    PUSH    RAX
    PUSH    RDI
    MOV     RAX, SYS_CLOSE
    MOV     RDI, [RDI]
    SYSCALL
    POP     RDI
    POP     RAX
    RET



FILE_WRITE:     ; FILE_WRITE: RDI: FILE DESCRIPTOR (ADDR), 
                ; RSI: BUFFER (ADDR), RDX: SIZE (INTEGER)
    PUSH    RAX
    PUSH    RBX
    PUSH    RCX
    PUSH    RDX
    PUSH    RSI
    PUSH    RDI
    MOV     RAX, SYS_WRITE
    MOV     RDI, [RDI]
    MOV     RSI, RSI
    MOV     RDX, RDX
    SYSCALL
    POP     RDI
    POP     RSI
    POP     RDX
    POP     RCX
    POP     RBX
    POP     RAX
    RET

SECTION .text   ; Error and Exit. This section is also used in other inc files.
    PUTERR:     ; RSI: ERROR MESSAGE (ADDR)
        CALL    PUTSTR
    EXIT:
        MOV     EAX, 1
        XOR     EBX, EBX
        INT     0x80

section .data
    _N              dq 250  
    _stunum         dq 43
    _garbage        dq 300-86  
    _fd             dq 0
    _fn             db "./part1.txt", 0
    _cs             db "cs", 0
    _cs_len         dq 2
    _notcs          db "a", 0
    _notcs_len      dq 1
    _mod            dq 666
    
    FC_ERR          db "Error: File creation failed", 0
    SUCCESS         db "Success!", 0


section .text
    global _start
    _start:
        mov     RDI, _fn
        call    FILE_OPEN
        mov     rsi, FC_ERR
        cmp     rax, 3
        jl      PUTERR
        mov     [_fd], rax

        mov     rcx, [_N]
        WRITE_LOOP:
            push    rcx

                mov     rcx, [_stunum]
                write_cs:
                    mov     rdi, _fd
                    mov     rsi, _cs
                    mov     rdx, [_cs_len]
                    call    FILE_WRITE
                    loop    write_cs
                
                mov     rcx, [_garbage]
                write_notcs:
                    mov     rdi, _fd
                    mov     rsi, _notcs
                    mov     rdx, [_notcs_len]
                    call    FILE_WRITE
                    loop    write_notcs

            pop     rcx
            loop    WRITE_LOOP

        mov     rdi, _fd
        call    FILE_CLOSE
        mov     rsi, SUCCESS
        call    PUTERR
