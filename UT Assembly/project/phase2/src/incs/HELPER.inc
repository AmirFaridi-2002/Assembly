SECTION .data
    PYTHON_CMD        DB      '/usr/bin/python3', NULL
    PYTHON_FILE       DB      './convert.py', NULL
    I2T               DB      'i2t', NULL       ; IMAGE TO TEXT
    T2I               DB      't2i', NULL       ; TEXT TO IMAGE
    FORK_ERR_MSG      DB      'Fork error', NL, NULL
    CHILD_FAIL_MSG    DB      'Child process failed', NL, NULL
    CHILD_SUCCESS_MSG DB      'Executed script successfully.', NL, NULL
    RND_ERR_MSG       DB      'RDRAND failed', NL, NULL

SECTION .bss
    ARGS             RESD    256          ; Usage: /usr/bin/python3[0] GET_INPUT.py[1] <img_path>[2] NULL[3]
    STAT             RESD    1            ; STATUS OF THE CHILD PROCESS
SECTION .text   
RUN_PYTHON:
            ; RUN_PYTHON. ESI: PATH
            ;             AL:  MODE (0: I2T, OTHERWISE: T2I)
    PUSH    RAX
    PUSH    RBX
    PUSH    RCX
    PUSH    RDX
    PUSH    RSI
    PUSH    R15

    XOR     R15, R15
    MOV     R15D, I2T
    CMP     AL, 0
    JNE     .T2I
    JMP     .AFTER_SET_MODE
    .T2I:
    MOV     R15D, T2I
    .AFTER_SET_MODE:
    
    MOV     EAX, 2
    INT     0x80           ; FORK SYSCALL. CHILD PID IN EAX
    CMP     EAX, 0
    JG      .PARENT_PROCESS
    JNZ     .FORK_ERROR

    MOV     DWORD [ARGS], PYTHON_CMD
    MOV     DWORD [ARGS + 4], PYTHON_FILE
    MOV     DWORD [ARGS + 8], ESI
    MOV     DWORD [ARGS + 12], R15D
    MOV     DWORD [ARGS + 16], NULL

    MOV     EAX, 11
    MOV     EBX, PYTHON_CMD
    MOV     ECX, ARGS
    XOR     EDX, EDX
    INT     0x80           ; EXECVE SYSCALL

    .CHILD_FAIL:
    MOV     RSI, CHILD_FAIL_MSG
    CALL    PUTSTR         ; DEFINED IN BASIC_FUNCTIONS.inc
    MOV     EAX, 1
    XOR     EBX, EBX
    INT     0x80           ; EXIT CHILD PROCESS IF EXECVE FAILS

    .PARENT_PROCESS:
        MOV    EDI, EAX
        MOV    EAX, 7         ; WAITPID SYSCALL
        MOV    EBX, EDI
        MOV    ECX, STAT
        XOR    EDX, EDX
        INT    0x80           ; WAIT FOR CHILD PROCESS TO TERMINATE

        MOV    EAX, [STAT]
        SHR    EAX, 8         ; GET EXIT STATUS (STATUS >> 8)
        CMP    EAX, 0
        JE     .CHILD_SUCCESS  
        JMP    .CHILD_FAIL

    .FORK_ERROR:
        MOV    RSI, FORK_ERR_MSG
        CALL   PUTSTR
        MOV    EAX, 1
        XOR    EBX, EBX
        INT    0x80

    .CHILD_SUCCESS:
        MOV    RSI, CHILD_SUCCESS_MSG
        CALL   PUTSTR
        POP    R15
        POP    RSI
        POP    RDX
        POP    RCX
        POP    RBX
        POP    RAX
        RET


STR2INT:         ; STR2INT, RESULT IN RAX. MODIFIES THE RSI
    PUSH    RBX
    PUSH    RDX

    XOR     RAX, RAX
    XOR     RDX, RDX
    MOV     RBX, 10

    .STR2INT_LOOP:
        MOV     DL, [RSI]
        CMP     DL, SPACE
        JE      .STR2INT_END
        CMP     DL, NL
        JE      .STR2INT_END
        SUB     DL, 0x30
        IMUL    RAX, RBX
        ADD     RAX, RDX
        INC     RSI
        JMP     .STR2INT_LOOP
    .STR2INT_END:
    INC     RSI
    CMP     BYTE [RSI], NL
    JNE     .RETURN
    INC     RSI
    .RETURN:
    POP     RDX
    POP     RBX
    RET
    
READSTI:         ; READ STRING FROM STANDARD INPUT (FD 0). REMOVES NEWLINE CHARACTER
                ; ESI: BUFFER TO STORE
    PUSH    RAX
    PUSH    RBX
    PUSH    RCX
    PUSH    RDX
    MOV     EAX, 3
    MOV     EBX, 0
    MOV     ECX, ESI
    MOV     EDX, 256
    INT     0x80

    ; FIND NEWLINE CHARACTER AT THE END OF THE STRING
    XOR     RCX, RCX
    MOV     ECX, ESI
    .FIND_NL:
        CMP     BYTE [RCX], NL
        JE      .FOUND_NL
        INC     RCX
        JMP     .FIND_NL
    .FOUND_NL:
    MOV     BYTE [RCX], NULL

    POP     RDX
    POP     RCX
    POP     RBX
    POP     RAX
    RET

INT2STR:         ; R8: NUMBER, R9: FLAG SPACE, R10: FLAG NEWLINE,
                        ; -> RESULT ADDR IN RSI AND THE LENGTH IN RDX 
    PUSH    RAX
    PUSH    RBX
    PUSH    RCX
    PUSH    RDI
    PUSH    R8 ;(0)
    PUSH    R9 ;(0)
    PUSH    R10;(0)

    MOV     RAX, SYS_MMAP
    XOR     RDI, RDI
    MOV     RSI, 7                                  ; MAXIMUM NUMBER OF ROWS AND COLS = 9999, SPACE, NL, NULL (7 BYTES)
    MOV     RDX, PROT_READ | PROT_WRITE
    MOV     R10, MAP_PRIVATE | MAP_ANONYMOUS    
    XOR     R8, R8
    XOR     R9, R9
    SYSCALL

    POP     R10;(0)                                     ; RESOTORE THE PARAMS
    POP     R9 ;(0)
    POP     R8 ;(0)

    PUSH    RAX;(1)                                     ; STORE THE GENERATED ADDRESS
    PUSH    RAX;(2)

    MOV     RAX, R8
    MOV     RBX, 10
    XOR     RCX, RCX
    POP     RDI;(2)
    
    .I2S_LOOP:
        XOR     RDX, RDX
        DIV     RBX
        ADD     DL, 0x30
        PUSH    RDX;(3)
        INC     RCX
        TEST    RAX, RAX
        JNZ     .I2S_LOOP

    MOV     RDX, RCX
    .I2S_STORE:
        POP     RAX;(3)
        MOV     [RDI], AL
        INC     RDI
        LOOP    .I2S_STORE

    POP     RSI;(1)

    .FIRST_FLAG:
    CMP     R9, 1
    JNE     .SECOND_FLAG
    MOV     BYTE [RDI], SPACE
    INC     RDI
    INC     RDX
    .SECOND_FLAG:
    CMP     R10, 1
    JNE     .RETURN
    MOV     BYTE [RDI], NL
    INC     RDI
    INC     RDX
    .RETURN:
    MOV     BYTE [RDI], NULL
    POP     RDI
    POP     RCX
    POP     RBX
    POP     RAX
    RET

WRITE_TUPLE:     ; R12: TUPLE ADDR, R13: FD(ADDR), R14: DIM, R15: FLAG NL
                    ; WRITES A TUPLE WITH DIMENSION DIM TO FILE DESCRIPTOR FD
    PUSH    RAX
    PUSH    RBX
    PUSH    RCX
    PUSH    RDX
    PUSH    RSI
    PUSH    RDI
    PUSH    R8
    PUSH    R9
    PUSH    R10
    PUSH    R11
    PUSH    R12
    PUSH    R13
    PUSH    R14
    PUSH    R15

    DEC     R14
    JE      .ZERO_DIM

    .FILL_LOOP:   
        MOV     RAX, [R12]
        MOV     R8, RAX
        MOV     R9, 1
        XOR     R10, R10
        CALL    INT2STR
        PUSH    RSI
        MOV     RDI, R13
        CALL    FILE_WRITE
        POP     RSI
        DEALLOC RSI, 7
        ADD     R12, 8
        DEC     R14
        JNZ     .FILL_LOOP
        
    .ZERO_DIM:
    CMP     R15, 1
    JNE     .FLAG_OFF
    MOV     R10, 1
    JMP     .WRITE_LAST_ELEMENT
    .FLAG_OFF:     XOR     R10, R10

    .WRITE_LAST_ELEMENT:
    MOV     RAX, [R12]
    MOV     R8, RAX
    MOV     R9, 1
    CALL    INT2STR
    PUSH    RSI
    MOV     RDI, R13
    CALL    FILE_WRITE
    POP     RSI
    DEALLOC RSI, 7

    POP     R15
    POP     R14
    POP     R13
    POP     R12
    POP     R11
    POP     R10
    POP     R9
    POP     R8
    POP     RDI
    POP     RSI
    POP     RDX
    POP     RCX
    POP     RBX
    POP     RAX
    RET
        
SWAPM:           ; SWAP ELEMENTS OF RSI AND RDI WITH SIZE RDX (QWORDS)
    PUSH    RAX
    PUSH    RBX
    PUSH    RDX
    PUSH    RSI
    PUSH    RDI
    .SWAP_LOOP:
        MOV     RAX, [RSI]
        MOV     RBX, [RDI]
        MOV     [RSI], RBX
        MOV     [RDI], RAX
        ADD     RSI, 8
        ADD     RDI, 8
        DEC     RDX
        JNZ     .SWAP_LOOP
    
    POP     RDI
    POP     RSI
    POP     RDX
    POP     RBX
    POP     RAX
    RET

POSRAND:         ; GENERATES A POSITIVE RANDOM NUMBER. RESULT IN R15
    RDRAND  R15
    JC      .SUCCESS
    .FAIL:  MOV     RSI, RND_ERR_MSG
            CALL    PUTSTR
            CALL    EXIT
    .SUCCESS:
    CMP     R15, 0
    JG      .DONE
    NEG     R15
    .DONE:  RET
