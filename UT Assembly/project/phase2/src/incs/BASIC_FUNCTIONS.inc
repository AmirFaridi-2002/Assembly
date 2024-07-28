SECTION .text       ; GENERAL FUNCTIONS
    PUTC:
        PUSH   RCX
        PUSH   RDX
        PUSH   RSI
        PUSH   RDI
        PUSH   R11

        PUSH   AX
        MOV    RSI, RSP
        MOV    RDX, 1
        MOV    RAX, SYS_WRITE
        MOV    RDI, STDOUT
        SYSCALL
        POP    AX

        POP    R11
        POP    RDI
        POP    RSI
        POP    RDX
        POP    RCX
        RET
    
    PUTSTR:
        PUSH    RAX
        PUSH    RCX
        PUSH    RSI
        PUSH    RDX
        PUSH    RDI
        MOV     RDI, RSI
        CALL    STRLEN
        MOV     RAX, SYS_WRITE
        MOV     RDI, STDOUT
        SYSCALL
        POP     RDI
        POP     RDX
        POP     RSI
        POP     RCX
        POP     RAX
        RET
    
    STRLEN:
        PUSH    RBX
        PUSH    RCX
        PUSH    RAX
        XOR     RCX, RCX
        NOT     RCX
        XOR     RAX, RAX
        CLD
        REPNE   SCASB
        NOT     RCX
        LEA     RDX, [RCX - 1]
        POP     RAX
        POP     RCX
        POP     RBX
        RET
    
    PUTNL:
        PUSH    RAX
        MOV     RAX, NL
        CALL    PUTC
        POP     RAX
        RET
    
    PUTTAB:
        PUSH    RAX
        MOV     RAX, TAB
        CALL    PUTC
        POP     RAX
        RET

    PUTINT:
        PUSH    RAX
        PUSH    RBX
        PUSH    RCX
        PUSH    RDX

        SUB     RDX, RDX
        MOV     RBX, 10
        SUB     RCX, RCX
        CMP     RAX, 0
        JGE     w_Again
        PUSH    RAX
        MOV     AL, '-'
        CALL    PUTC
        POP     RAX
        NEG     RAX

        w_Again:
            CMP     RAX, 9
            JLE     c_End
            DIV     RBX
            PUSH    RDX
            INC     RCX
            SUB     RDX, RDX
            JMP     w_Again

        c_End:
            ADD     AL, 0x30
            CALL    PUTC
            DEC     RCX
            JL      w_End
            POP     RAX
            JMP     c_End

        w_End:
            POP     RDX
            POP     RCX
            POP     RBX
            POP     RAX
            ret

    GETC:
        PUSH   RCX
        PUSH   RDX
        PUSH   RSI
        PUSH   RDI
        PUSH   R11

        SUB    RSP, 1
        MOV    RSI, RSP
        MOV    RDX, 1
        MOV    RAX, SYS_READ
        MOV    RDI, STDIN
        SYSCALL
        MOV    AL, [RSI]
        ADD    RSP, 1

        POP    R11
        POP    RDI
        POP    RSI
        POP    RDX
        POP    RCX
        RET

    READSTR:        ; RDI: buffer
        PUSH    RAX
            READSTR_LOOP:
            CALL    GETC
            CMP     AL, NL
            JE      READSTR_END
            MOV     [RDI], AL
            INC     RDI
            JMP     READSTR_LOOP
        READSTR_END:
        MOV     BYTE [RDI], NULL
        POP     RAX
        RET


    READINT:
        PUSH   RCX
        PUSH   RBX
        PUSH   RDX

        MOV    BL,0
        MOV    RDX, 0

        r_Again:
            XOR    RAX, RAX
            CALL   GETC
            CMP    AL, '-'
            JNE    s_Again
            MOV    BL,1
            JMP    r_Again

        s_Again:
            CMP    AL, NL
            JE     r_End
            CMP    AL, ' '
            JE     r_End
            SUB    RAX, 0x30
            IMUL   RDX, 10
            ADD    RDX, RAX
            XOR    RAX, RAX
            CALL   GETC
            JMP    s_Again

        r_End:
            MOV    RAX, RDX
            CMP    BL, 0
            JE     s_End
            NEG    RAX

        s_End:
            POP   RDX
            POP   RBX
            POP   RCX
            RET

    PUTSPACE:
        PUSH    RAX
        MOV     RAX, SPACE
        CALL    PUTC
        POP     RAX
        RET
