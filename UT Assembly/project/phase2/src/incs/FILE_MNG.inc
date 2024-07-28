SECTION .text

FILE_OPEN:      ; RDI: FILE PATH. RETURNS FD IN RAX
    PUSH    RDI
    PUSH    RSI
    MOV     RAX, SYS_OPEN
    MOV     RSI, O_RDWR | O_APPEND
    MOV     RDI, RDI
    SYSCALL
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

FILE_READ:      ; FILE_READ: RDI: FILE DESCRIPTOR (ADDR), 
                ; RSI: BUFFER (ADDR), RDX: SIZE (INTEGER)
                ; RETURNS NUMBER OF BYTES READ IN RAX
    PUSH    RBX
    PUSH    RCX
    PUSH    RDX
    PUSH    RSI
    PUSH    RDI
    MOV     RAX, SYS_READ
    MOV     RDI, [RDI]
    MOV     RSI, RSI
    MOV     RDX, RDX
    SYSCALL
    POP     RDI
    POP     RSI
    POP     RDX
    POP     RCX
    POP     RBX
    RET

FILE_CLEAR:     ; FILE_CLEAR: RDI: FILE PATH (ADDR)
    PUSH    RAX
    PUSH    RDI
    PUSH    RSI
    MOV     RAX, SYS_TRUNCATE
    MOV     RDI, RDI
    XOR     RSI, RSI
    SYSCALL
    POP     RSI
    POP     RDI
    POP     RAX
    RET