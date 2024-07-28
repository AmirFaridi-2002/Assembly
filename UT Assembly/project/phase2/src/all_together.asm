; NOTE: EVERY ERROR RESULTS IN EXITING THE PROGRAM!


SECTION .EQUS
    ; SYSTEM CALLS
    SYS_READ         EQU     0
    SYS_WRITE        EQU     1
    SYS_OPEN         EQU     2
    SYS_CLOSE        EQU     3
    SYS_STAT         EQU     4
    SYS_FSTAT        EQU     5
    SYS_LSEEK        EQU     8
    SYS_MMAP         EQU     9
    SYS_MUNMAP       EQU     11
    SYS_BRK          EQU     12
    SYS_FORK         EQU     57
    SYS_EXECVE       EQU     59
    SYS_EXIT         EQU     60
    SYS_TRUNCATE     EQU     76
    SYS_MKDIR        EQU     83
    SYS_CREATE       EQU     85
    
    ; RESERVED FILE DESCRIPTORS
    STDIN            EQU     0
    STDOUT           EQU     1
    STDERR           EQU     2

    ; FILE MODES
    PROT_NONE        EQU     0x0
    PROT_READ        EQU     0x1
    PROT_WRITE       EQU     0x2
    MAP_PRIVATE      EQU     0x2
    MAP_ANONYMOUS    EQU     0x20
    
    ; FILE FLAGS
    O_DIRECTORY      EQU     0200000
    O_RDONLY         EQU     0q000000
    O_WRONLY         EQU     0q000001
    O_RDWR           EQU     0q000002
    O_CREAT          EQU     0q000100
    O_APPEND         EQU     0q002000

    ; FILE SEEK
    BEG_FILE_POS     EQU     0
    CURR_POS         EQU     1
    END_FILE_POS     EQU     2

    ; ASCII CHARACTERS
    NL               EQU     0xA
    NULL             EQU     0
    TAB              EQU     0x9
    SPACE            EQU     0x20


%macro TUPLE3 3     ; RESULT ADDR IN RDI
    PUSH    RAX
    PUSH    RBX
    PUSH    RCX
    PUSH    RDX
    PUSH    RSI
    PUSH    R8
    PUSH    R9
    PUSH    R10
    PUSH    R11
    PUSH    R12
    PUSH    R13
    PUSH    R14
    PUSH    R15
    mov     RAX, SYS_MMAP
    XOR     RDI, RDI
    MOV     RSI, 24
    MOV     RDX, PROT_READ | PROT_WRITE
    MOV     R10, MAP_PRIVATE | MAP_ANONYMOUS
    XOR     R8, R8
    XOR     R9, R9
    SYSCALL
    MOV     RDI, RAX
    POP     R15
    POP     R14
    POP     R13
    POP     R12
    POP     R11
    POP     R10
    POP     R9
    POP     R8
    POP     RSI
    POP     RDX
    POP     RCX
    POP     RBX
    POP     RAX
    MOV     QWORD [RDI], %1
    MOV     QWORD [RDI + 8], %2
    MOV     QWORD [RDI + 16], %3
%endmacro

%macro TUPLE2 2     ; RESULT ADDR IN RDI
    PUSH    RAX
    PUSH    RBX
    PUSH    RCX
    PUSH    RDX
    PUSH    RSI
    PUSH    R8
    PUSH    R9
    PUSH    R10
    PUSH    R11
    PUSH    R12
    PUSH    R13
    PUSH    R14
    PUSH    R15
    mov     RAX, SYS_MMAP
    XOR     RDI, RDI
    MOV     RSI, 16
    MOV     RDX, PROT_READ | PROT_WRITE
    MOV     R10, MAP_PRIVATE | MAP_ANONYMOUS
    XOR     R8, R8
    XOR     R9, R9
    SYSCALL
    MOV     RDI, RAX
    POP     R15
    POP     R14
    POP     R13
    POP     R12
    POP     R11
    POP     R10
    POP     R9
    POP     R8
    POP     RSI
    POP     RDX
    POP     RCX
    POP     RBX
    POP     RAX
    MOV     QWORD [RDI], %1
    MOV     QWORD [RDI + 8], %2
%endmacro


%macro TUPLE1 1   ; RESULT ADDR IN RDI
    PUSH    RAX
    PUSH    RBX
    PUSH    RCX
    PUSH    RDX
    PUSH    RSI
    PUSH    R8
    PUSH    R9
    PUSH    R10
    PUSH    R11
    PUSH    R12
    PUSH    R13
    PUSH    R14
    PUSH    R15
    mov     RAX, SYS_MMAP
    XOR     RDI, RDI
    MOV     RSI, 8
    MOV     RDX, PROT_READ | PROT_WRITE
    MOV     R10, MAP_PRIVATE | MAP_ANONYMOUS
    XOR     R8, R8
    XOR     R9, R9
    SYSCALL
    MOV     RDI, RAX
    POP     R15
    POP     R14
    POP     R13
    POP     R12
    POP     R11
    POP     R10
    POP     R9
    POP     R8
    POP     RSI
    POP     RDX
    POP     RCX
    POP     RBX
    POP     RAX
    MOV     QWORD [RDI], %1
%endmacro


%macro DEALLOC 2    ; DEALLOC 2 <ADDR> <SIZE>
    PUSH    RAX
    PUSH    RSI
    PUSH    RDI
    MOV     RDI, %1
    MOV     RAX, SYS_MUNMAP
    MOV     RSI, %2
    SYSCALL
    POP     RDI
    POP     RSI
    POP     RAX
%endmacro


%macro PIXEL_GC 1  ; <PIXEL(TUPLE) ADDR> -> RESULT IN RAX
    PUSH    RBX
    PUSH    RDX
    PUSH    RSI
    PUSH    R10
    PUSH    R11
    PUSH    R12

    MOV     RSI, %1
    MOV     R10, [RSI]          ; R
    MOV     R11, [RSI + 8]      ; G
    MOV     R12, [RSI + 16]     ; B
    ; RESULT = 0.299*R + 0.587*G + 0.114*B = (299*R + 587*G + 114*B)/1000

    MOV     RAX, 299
    IMUL    RAX, R10

    MOV     RBX, 587
    IMUL    RBX, R11
    ADD     RAX, RBX

    MOV     RBX, 114
    IMUL    RBX, R12
    ADD     RAX, RBX

    MOV     RBX, 1000
    XOR     RDX, RDX
    IDIV    RBX

    POP     R12
    POP     R11
    POP     R10
    POP     RSI
    POP     RDX
    POP     RBX
%endmacro

%macro GETIDX 4     ; <ROW> <COL> <i> <j> -> RESULT INDEX IN R15
    MOV     R15, %3
    IMUL    R15, %2
    ADD     R15, %4
%endmacro

%macro GETVAL 5     ; <MAT ADDR> <ROW> <COL> <i> <j> -> R15 = MAT[i][j]
    GETIDX %2, %3, %4, %5
    PUSH    RSI
    MOV     RSI, %1
    MOV     R15, [RSI + R15*8]
    POP     RSI
%endmacro

%macro SETVAL 6     ; <MAT ADDR> <ROW> <COL> <i> <j> <VAL> -> MAT[i][j] = VAL
    GETIDX %2, %3, %4, %5
    PUSH    RSI
    MOV     RSI, %1
    MOV     [RSI + R15*8], %6
    POP     RSI
%endmacro


%macro MAX 2        ; <a> <b> -> RAX = MAX(a, b)
    MOV     RAX, %1
    CMP     RAX, %2
    CMOVLE  RAX, %2
%endmacro

%macro MIN 2        ; <a> <b> -> RAX = MIN(a, b)
    MOV     RAX, %1
    CMP     RAX, %2
    CMOVGE  RAX, %2
%endmacro


%macro POOLING_SETTER 7     ; <MAT ADDR>(1) <ROW>(2) <COL>(3) <POOL SIZE>(4) <i>(5) <j>(6) <VAL>(7)  
                            ;       MAT[i // POOL_SIZE][j // POOL_SIZE] = VAL
    PUSH    RAX
    PUSH    RDX
    PUSH    R11
    PUSH    R12
    PUSH    R13
    PUSH    R14
    PUSH    R15

    XOR     RDX, RDX
    MOV     R11, %4     ; POOL SIZE
    MOV     RAX, %6     ; j
    DIV     R11         ; j // POOL SIZE
    MOV     R12, RAX    ; R12 = j // POOL SIZE
    MOV     RAX, %5     ; i
    XOR     RDX, RDX    
    DIV     R11         ; i // POOL SIZE
    MOV     R11, RAX    ; R11 = i // POOL SIZE

    MOV     RAX, %1
    MOV     RDX, %2
    MOV     R13, %3
    MOV     R14, %7
    SETVAL  RAX, RDX, R13, R11, R12, R14
    
    pop     R15
    pop     R14
    pop     R13
    pop     R12
    pop     R11
    pop     RDX
    pop     RAX
%endmacro

                                        ; MACRO TUPLE3 3 <a> <b> <c> -> RESULT ADDR IN RDI
                                        ; MACRO TUPLE2 2 <a> <b> -> RESULT ADDR IN RDI
                                        ; MACRO TUPLE1 1 <a> -> RESULT ADDR IN RDI
                                        ; MACRO DEALLOC 2 <ADDR> <SIZE>
                                        ; MACRO PIXEL_GC 1 <PIXEL(TUPLE) ADDR> -> RESULT IN RAX
                                        ; MACRO GETIDX 4 <ROW> <COL> <i> <j> -> RESULT INDEX IN R15
                                        ; MACRO GETVAL 5 <MAT ADDR> <ROW> <COL> <i> <j> -> R15 = MAT[i][j]
                                        ; MACRO SETVAL 6 <MAT ADDR> <ROW> <COL> <i> <j> <VAL> -> MAT[i][j] = VAL
                                        ; MACRO MAX 2 <a> <b> -> RESULT IN RAX
                                        ; MACRO MIN 2 <a> <b> -> RESULT IN RAX

                                        ; MACRO %macro POOLING_SETTER 7   <MAT ADDR> <ROW> <COL> <POOL SIZE> <i> <j> <VAL>  
                                                                        ; MAT[i // POOL_SIZE][j // POOL_SIZE] = VAL
                                        ; --------------------------------------------------------------------------------
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

; GENERAL FUNCTIONS
; -----------------------------------


SECTION .data
    ;----------------------------------------------MAIN DATA---------------------------------------------------------
    IMG_PATH        TIMES   256 DB 0                                                                                ;
    TXT_PATH        TIMES   256 DB 0                                                                                ;
                                                                                                                    ;
    FD              DQ      0                   ; FILE DESCRIPTOR                                                   ;
    GC_FLAG         DQ      0                   ; GRAYSCALE FLAG                                                    ;
                                                                                                                    ;
    ROWS            DQ      0                                                                                       ;
    COLS            DQ      0                                                                                       ;
    DIM             DQ      3                   ; DEFUALT RGB INPUT IMAGE                                           ;
                                                                                                                    ;
    TXT_CONTENT     TIMES   1000000 DB 0        ; BUFFER TO STORE THE TEXT FILE CONTENT                             ;
    CONTENT_LENGTH  DQ      1000000             ; MAXIMUM LENGTH OF THE TEXT FILE                                   ;
                                                                                                                    ;
                                                                                                                    ;
    IMG             TIMES   1000000 DQ 0        ; IMAGE MATRIX                                                      ;
                                                                                                                    ;
    ORG_DIM         DQ      3                   ; ORIGINAL DIMENSION                                                ;
    ORG_ROWS        DQ      0                   ; ORIGINAL ROWS                                                     ;
    ORG_COLS        DQ      0                   ; ORIGINAL COLS                                                     ;
    ORG_IMG         TIMES   1000000 DQ 0        ; TO STORE THE ORIGINAL IMAGE AFTER GRAYSCALING                     ;
                                       ; REMINDER: THE ORIGINAL IMAGE IS ADDRESSES OF TUPLES                        ;
    TMP             TIMES   1000000 DQ 0        ; TEMPORARY MATRIX                                                  ;
    ;----------------------------------------------------------------------------------------------------------------

    ;--------------------CONVOLUTION DATA SECTION--------------------------------------------------------------------
    KER_ROWS        DQ      0                                                                                       ;
    KER_COLS        DQ      0                                                                                       ;
    KER_SCALE       DQ      0                                                                                       ;
    KERNEL          TIMES   100     DQ 0        ; CONVOLUTION FILTER                                                ;
                                                                                                                    ;
    CONV_RESULT_ROW DQ      0                   ; ROWS - KER_ROWS + 1                                               ;
    CONV_RESULT_COL DQ      0                   ; COLS - KER_COLS + 1                                               ;
    CONV_RESULT     TIMES   1000000 DQ 0        ; RESULT OF CONVOLUTION.                                            ;
                                                                                                                    ;
    GAUSSIAN_BLUR_5 DQ      1, 4, 6, 4, 1, 4, 16, 24, 16, 4, 6, 24, 36, 24, 6, 4, 16, 24, 16, 4, 1                  ;
    GAUSSIAN_BLUR_3 DQ      1, 2, 1, 2, 4, 2, 1, 2, 1                                                               ;
                                                                                                                    ;
    SHARPEN_3       DQ      1, 0, 1, 0, 6, 0, 1, 0, 1                                                               ;
    LAPLACIAN_3     DQ      1, 0, 1, 0, 5, 0, 1, 0, 1                                                               ;
    ;----------------------------------------------------------------------------------------------------------------

    ;--------------------POOLING DATA SECTION------------------------------------------------------------------------
    POOL_SIZE       DQ      0                   ; POOLING SIZE (SQUAR MATRIX)                                       ;
    POOL_MAT        TIMES   1000000 DQ 0        ; POOLING MATRIX                                                    ;
                                                                                                                    ;
    POOL_RESULT_ROW DQ 0                        ; ROWS // POOL_SIZE                                                 ;
    POOL_RESULT_COL DQ 0                        ; COLS // POOL_SIZE                                                 ;
    POOL_RESULT     TIMES   1000000 DQ 0        ; RESULT OF POOLING                                                 ;
    ;----------------------------------------------------------------------------------------------------------------


    ;------------------------------------------NOISE DATA SECTION----------------------------------------------------
    NOISE_PROB      DQ      50                  ; PROBABILITY OF NOISE (PERCENTAGE)                                 ;
    NOISE_PXLS      DQ      0                   ; NUMBER OF NOISY PIXELS (ROWS * COLS * PROB)                       ;
    RESULT_NOISE    TIMES   1000000 DQ 0        ; RESULT OF IMAGE AFTER SALT-AND-PEPPER NOISE                       ;
    ;----------------------------------------------------------------------------------------------------------------


    ;--------------------------------------RESIZE DATA SECTION-------------------------------------------------------
    ROW_SCALE       DQ      0                   ; X SCALE FACTOR                                                    ;
    COL_SCALE       DQ      0                   ; Y SCALE FACTOR                                                    ;
    NEW_ROWS        DQ      0                   ; NEW ROWS                                                          ;
    NEW_COLS        DQ      0                   ; NEW COLS                                                          ;
    RESIZE_RESULT   TIMES   1000000 DQ 0        ; RESULT OF RESIZE                                                  ;
    ;----------------------------------------------------------------------------------------------------------------

    ;---------------------------------------TEMPORARY VARIABLE-------------------------------------------------------
                            ; USE THESE TO CALL MACROS TO PREVENT OVERWRITING THE REGISTERS                         ;
    _i              DQ      0                                                                                       ;
    _j              DQ      0                                                                                       ;
    _k              DQ      0                                                                                       ;
    _m              DQ      0                                                                                       ;
    _n              DQ      0                                                                                       ;
    _r              DQ      0                                                                                       ;
    _c              DQ      0                                                                                       ;
    _v              DQ      0                                                                                       ;
    _rax            DQ      0                                                                                       ;
    _rbx            DQ      0                                                                                       ;
    _rcx            DQ      0                                                                                       ;
    _rdx            DQ      0                                                                                       ;
    _rsi            DQ      0                                                                                       ;
    _rdi            DQ      0                                                                                       ;
    _r8             DQ      0                                                                                       ;
    _r9             DQ      0                                                                                       ;
    _r10            DQ      0                                                                                       ;
    _r11            DQ      0                                                                                       ;
    _r12            DQ      0                                                                                       ;
    _r13            DQ      0                                                                                       ;
    _r14            DQ      0                                                                                       ;
    _r15            DQ      0                                                                                       ;
    ;----------------------------------------------------------------------------------------------------------------
 
SECTION .MSGS
    ;-----------------------------------------MENU-------------------------------------------------------------------
    MENU            DB      '0. EXIT', NL           ; DONE.                                                         ;
                    DB      '1. OPEN', NL           ; DONE.                                                         ;
                    DB      '2. RESHAPE', NL        ; DONE.                                                         ;
                    DB      '3. RESIZE', NL         ; DONE.                                                         ;
                    DB      '4. GRAYSCALE', NL      ; DONE.                                                         ;
                    DB      '5. CONV FILTER', NL    ; DONE.                                                         ;
                    DB      '6. POOLING', NL        ; DONE.                                                         ;
                    DB      '7. NOISE', NL          ; DONE.                                                         ;
                    DB      '8. OUTPUT', NL         ; DONE.                                                         ;
                    DB      NULL                                                                                    ;
    ;----------------------------------------------------------------------------------------------------------------


    ;----------------------------------------MESSAGES----------------------------------------------------------------
    READADDR_MSG    DB      'Enter the address of the image file: ', NULL                                           ;
    ENTER_OP_MSG    DB      'Enter the operation: ', NULL                                                           ;
    LOADSUCCESS_MSG DB      'SUCCESS: Image loaded successfully!', NL, NULL                                         ;
    GS_SUCCESS_MSG  DB      'SUCCESS: Image converted to grayscale!', NL, NULL                                      ;
    POOLTYPE_MSG    DB      'Enter the pooling type (0 for average / 1 for max): ', NULL                            ;
    POOLSIZE_MSG    DB      'Enter the pooling matrix size: ', NULL                                                 ;
    POOLING_SUCCESS DB      'SUCCESS: Pooling done!', NL, NULL                                                      ;
    RESHAPE_MSG     DB      'Enter the new shape of the image: ', NULL                                              ;
    RESHAPE_DONE    DB      'SUCCESS: Reshape done!', NL, NULL                                                      ;
    NEW_ROWS_MSG    DB      'Enter the new number of rows: ', NULL                                                  ;
    NEW_COLS_MSG    DB      'Enter the new number of columns: ', NULL                                               ;
    RESIZE_DONE     DB      'SUCCESS: Resize done!', NL, NULL                                                       ;
    CONV_INP_MSG    DB      'Enter the convolution filter (1. GB3(Default), 2. GB5, 3. SHAR3, 4. LAP3):', NULL      ;
    HERE            DB      'HERE', NL, NULL                                                                        ;
    ;----------------------------------------------------------------------------------------------------------------


    ;-------------------------------------ERROR MESSAGES-------------------------------------------------------------
    OPEN_ERR_MSG    DB      'ERROR: Could not open the text file!', NL, NULL                                        ;
    TXTPATH_ERR     DB      'ERROR: Could not set the text file path!', NL, NULL                                    ;
    READ_ERR_MSG    DB      'ERROR: Could not read the image file!', NL, NULL                                       ;
    POOL_TYPE_ERR   DB      'ERROR: Invalid pooling type!', NL, NULL                                                ;
    POOL_SIZE_ERR   DB      'ERROR: Invalid pooling size!', NL, NULL                                                ;                                                     
    RESHAPE_INP_ERR DB      'ERROR: Invalid reshape input!', NL, NULL                                               ;
    RANDOM_GEN_ERR  DB      'ERROR: Could not generate random number!', NL, NULL                                    ;
    ;----------------------------------------------------------------------------------------------------------------


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

; RUN_PYTHON: ESI: PATH
            ; AL: MODE (0: I2T, OTHERWISE: T2I)
;           ---------------------------------------
; STR2INT:    RESULT IN RAX. MODIFIES THE RSI
;           ---------------------------------------
; READSTI:    READ STRING FROM STANDARD INPUT (FD 0), ESI: BUFFER TO STORE - REMOVES NEWLINE CHARACTER.
;           ---------------------------------------
; INT2STR:    R8: NUMBER, R9: FLAG SPACE, R10: FLAG NEWLINE,
            ; -> RESULT ADDR IN RSI AND THE LENGTH IN RDX 
;           ---------------------------------------
; PUTTUPLE:   R12: TUPLE ADDR, R13: FD(ADDR), R14: DIM, R15: FLAG NL
;           ---------------------------------------
; SWAP,:      SWAP ELEMENTS OF RSI AND RDI WITH SIZE RDX (BYTES)
;           ---------------------------------------
; POSRAND:    GENERATES A POSITIVE RANDOM NUMBER. RESULT IN R15
;           ---------------------------------------


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
; FILE_OPEN:      RDI: FILE_PATH (ADDR)
                ; O_RDWR: READ AND WRITE
                ; RETURNS FILE DESCRIPTOR IN RAX
;           ---------------------------------------
; FILE_CLOSE:     RDI: FILE DESCRIPTOR (ADDR)
;           ---------------------------------------
; FILE_WRITE:     RDI: FILE DESCRIPTOR (ADDR), 
                ; RSI: BUFFER (ADDR),
                ; RDX: SIZE (INTEGER)
;           ---------------------------------------
; FILE_READ:      RDI: FILE DESCRIPTOR (ADDR), 
                ; RSI: BUFFER (ADDR), 
                ; RDX: SIZE (INTEGER)
                ; RETURNS NUMBER OF BYTES READ IN RAX
;           ---------------------------------------
; FILE_CLEAR:     RDI: FILE PATH (ADDR)
;           ---------------------------------------



SECTION .text   ; Error and Exit. This section is also used in other inc files.
    PUTERR:     ; RSI: ERROR MESSAGE (ADDR)
        CALL    PUTSTR
    EXIT:
        MOV     EAX, 1
        XOR     EBX, EBX
        INT     0x80
    dbg:
        PUSH    RSI
        MOV     RSI, HERE
        CALL    PUTSTR
        POP     RSI
        RET

SECTION .text       ; OUTPUT_HANDLER
    ; NOTE:
    ;  WRITES THE CONTENT OF IMG TO A FILE
    ;  ASSUMPTION: IMG IS ADDRESSES OF TUPLES WITH DIMENSION DIM
    OUTPUT_HANDLER:
        PUSH   RAX
        PUSH   RBX
        PUSH   RCX
        PUSH   RDX
        PUSH   RSI
        PUSH   RDI
        PUSH   R8
        PUSH   R9
        PUSH   R10
        PUSH   R14
        PUSH   R15
        
        ; OPEN FILE TXT PATH
        MOV    RDI, TXT_PATH
        CALL   FILE_OPEN
        MOV    RSI, OPEN_ERR_MSG
        CMP    RAX, 2
        JLE    PUTERR
        MOV    [FD], RAX

        ; CLEAR FILE
        MOV    RDI, TXT_PATH
        CALL   FILE_CLEAR

        ; WRITE TO FILE (ROWS COLS DIM\n)
        MOV     R8, [ROWS]
        MOV     R9, 1  
        XOR     R10, R10
        CALL    INT2STR
        PUSH    RSI
        MOV     RDI, FD
        CALL    FILE_WRITE
        POP     RSI
        DEALLOC RSI, 7

        MOV     R8, [COLS]
        MOV     R9, 1  
        XOR     R10, R10
        CALL    INT2STR
        PUSH    RSI
        MOV     RDI, FD
        CALL    FILE_WRITE
        POP     RSI
        DEALLOC RSI, 7

        MOV     R8, [DIM]
        MOV     R9, 1
        XOR     R10, R10
        CALL    INT2STR
        PUSH    RSI
        MOV     RDI, FD
        CALL    FILE_WRITE
        POP     RSI
        DEALLOC RSI, 7


        MOV     R8, [GC_FLAG]
        XOR     R9, R9
        MOV     R10, 1
        CALL    INT2STR
        PUSH    RSI
        MOV     RDI, FD
        CALL    FILE_WRITE
        POP     RSI
        DEALLOC RSI, 7


        ; WRITE TO FILE (IMG)
        MOV     RSI, IMG
        MOV     RCX, [ROWS]
        MOV     R13, FD
        MOV     R14, [DIM]
        XOR     R15, R15
        .FOR_r:
            PUSH    RCX
            MOV     RCX, [COLS]
            .FOR_c:
                PUSH    RSI
                CMP     QWORD [GC_FLAG], 1
                JNE     .NOT_GC
                
                MOV     R15, [RSI]
                TUPLE1  R15
                MOV     RSI, RDI

                .NOT_GC:
                CMP     RCX, 1
                JNE     .NOT_LAST
                MOV     R15, 1
                JMP     .WT
                .NOT_LAST: MOV     R15, 0
                           CMP     QWORD [GC_FLAG], 1
                           JE      .WT_GC

                .WT:       CMP     QWORD [GC_FLAG], 1
                           JE      .WT_GC
                           MOV     R12, [RSI]
                           JMP     .CALL_WT
                
                .WT_GC:    MOV     R12, RSI
                .CALL_WT:  CALL    WRITE_TUPLE


                POP     RSI
                ADD     RSI, 8
                DEC     RCX
                JNZ     .FOR_c
            POP     RCX
            DEC     RCX
            JNZ     .FOR_r

        ; CLOSE FILE
        MOV     RDI, FD
        CALL    FILE_CLOSE
        MOV     QWORD [FD], 0

        MOV     RSI, TXT_PATH
        MOV     AL, 1
        CALL    RUN_PYTHON


        .RETURN:
        POP     R15
        POP     R14
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


SECTION .text       ; OPEN_HANDLER
    ; NOTE:
    ;  - IMG_PATH: PATH OF THE IMAGE FILE
    ;  - TXT_PATH: PATH OF THE TEXT FILE
    ;  - TXT_CONTENT: CONTENT OF THE TEXT FILE
    ;  - IMG: IMAGE MATRIX (ADDRESS OF A TUPLE)
    OPEN_HANDLER:
            PUSH    RAX
            PUSH    RBX
            PUSH    RCX
            PUSH    RDX
            PUSH    RSI
            PUSH    RDI
            PUSH    R15
            PUSH    R14
            PUSH    R13
            PUSH    R12

            MOV     RSI, READADDR_MSG                   
            CALL    PUTSTR                                  ; MSG: READADDR_MSG

            MOV     ESI, IMG_PATH   
            CALL    READSTI                                 ; Read IMG_PATH

            MOV     AL, 0
            MOV     ESI, IMG_PATH
            CALL    RUN_PYTHON                              ; Run Python Script

            CALL    .SET_TXTPATH                            ; Set TXT_PATH

            MOV     RDI, TXT_PATH
            CALL    FILE_OPEN                               ; Open TXT_PATH
            MOV     RSI, OPEN_ERR_MSG
            CMP     RAX, 2                                  
            JLE     PUTERR                                  ; FD leq 2 -> Error
            MOV     [FD], RAX
            
            MOV     RDI, FD
            MOV     RSI, TXT_CONTENT
            MOV     RDX, [CONTENT_LENGTH]
            CALL    FILE_READ                               
            MOV     RSI, READ_ERR_MSG
            CMP     RAX, 0
            JLE     PUTERR                                  ; If # of bytes read leq 0 -> Error
            MOV     [CONTENT_LENGTH], RAX

            MOV     RDI, FD
            CALL    FILE_CLOSE
            MOV     QWORD [FD], 0
            
            MOV     RSI, TXT_CONTENT
            CALL    STR2INT
            MOV     [ROWS], RAX
            CALL    STR2INT
            MOV     [COLS], RAX

            MOV     RCX, [ROWS]
            IMUL    RCX, [COLS]
            MOV     R15, IMG
            .IMGCPY_LOOP:                                   ; Read the RGB values of the image. Store them in a TUPLE3.
                CALL    STR2INT
                MOV     R12, RAX

                CALL    STR2INT
                MOV     R13, RAX

                CALL    STR2INT
                MOV     R14, RAX

                TUPLE3  R12, R13, R14
                MOV     [R15], RDI

                ADD     R15, 8
                LOOP    .IMGCPY_LOOP

            MOV     RAX, [ROWS]
            MOV     [ORG_ROWS], RAX
            MOV     RAX, [COLS]
            MOV     [ORG_COLS], RAX
            MOV     RSI, IMG
            MOV     RDI, ORG_IMG
            MOV     RCX, [ROWS]
            IMUL    RCX, [COLS]
            REP     MOVSB                                   ; COPY IMG TO ORG_IMG
            
            MOV     RSI, LOADSUCCESS_MSG
            CALL    PUTSTR

            
            POP     R12
            POP     R13
            POP     R14
            POP     R15
            POP     RDI
            POP     RSI
            POP     RDX
            POP     RCX
            POP     RBX
            POP     RAX
            RET

            .SET_TXTPATH:
                PUSH    RAX
                PUSH    RCX
                PUSH    RDX
                PUSH    RSI
                PUSH    RDI

                MOV     RSI, IMG_PATH
                MOV     RDI, TXT_PATH
                MOV     RCX, 256
                REP     MOVSB

                MOV     RDI, TXT_PATH
                CALL    STRLEN
                MOV     RSI, TXTPATH_ERR
                CMP     RDX, 0
                JLE     PUTERR

                MOV     RDI, TXT_PATH
                ADD     RDI, RDX
                DEC     RDI
                MOV     RCX, 6
                MOV     AL, '.'
                STD
                REPNE   SCASB
                ADD     RDI, 2
                MOV     BYTE [RDI], 't'
                MOV     BYTE [RDI + 1], 'x'
                MOV     BYTE [RDI + 2], 't'
                MOV     BYTE [RDI + 3], NULL

                POP     RDI
                POP     RSI
                POP     RDX
                POP     RCX
                POP     RAX
                RET




SECTION .text       ; RESHAPE_HANDLER
    RESHAPE_HANDLER:
        PUSH    RAX
        PUSH    RCX
        PUSH    RSI
        PUSH    R11
        PUSH    R12
        PUSH    R13
        PUSH    R14
        PUSH    R15

        MOV     RSI, RESHAPE_MSG
        CALL    PUTSTR
        CALL    READINT
        CMP     RAX, [DIM]
        JG      PUTERR
        JE      .DONE
        CMP     RAX, 0
        JL      PUTERR
        MOV     [DIM], RAX

        MOV     RSI, IMG
        MOV     RCX, [ROWS]
        IMUL    RCX, [COLS]
        .ZERO_LOOP:
            PUSH    RCX
            MOV     RCX, 3
            SUB     RCX, [DIM]
            MOV     R15, [RSI]
            MOV     R14, 2
            .CLEAR_ELEMENT:
                MOV     QWORD [R15 + R14*8], 0
                DEC     R14
                DEC     RCX
                CMP     RCX, 0
                JG      .CLEAR_ELEMENT
            ADD     RSI, 8
            POP     RCX
            LOOP    .ZERO_LOOP

        .DONE:
        MOV     RSI, RESHAPE_DONE
        CALL    PUTSTR

        POP     R15
        POP     R14
        POP     R13
        POP     R12
        POP     R11
        POP     RSI
        POP     RCX
        POP     RAX
        RET




    RESHAPE_HANDLER:
        PUSH    RAX
        PUSH    RCX
        PUSH    RSI
        PUSH    R11
        PUSH    R12
        PUSH    R13
        PUSH    R14
        PUSH    R15

        MOV     RSI, RESHAPE_MSG
        CALL    PUTSTR
        CALL    READINT
        CMP     RAX, [DIM]
        JG      PUTERR
        JE      .DONE
        CMP     RAX, 0
        JL      PUTERR
        MOV     [DIM], RAX

        MOV     RSI, IMG
        MOV     RCX, [ROWS]
        IMUL    RCX, [COLS]
        .ZERO_LOOP:
            PUSH    RCX
            MOV     RCX, 3
            SUB     RCX, [DIM]
            MOV     R15, [RSI]
            MOV     R14, 2
            .CLEAR_ELEMENT:
                MOV     QWORD [R15 + R14*8], 0
                DEC     R14
                DEC     RCX
                CMP     RCX, 0
                JG      .CLEAR_ELEMENT
            ADD     RSI, 8
            POP     RCX
            LOOP    .ZERO_LOOP

        .DONE:
        MOV     RSI, RESHAPE_DONE
        CALL    PUTSTR

        POP     R15
        POP     R14
        POP     R13
        POP     R12
        POP     R11
        POP     RSI
        POP     RCX
        POP     RAX
        RET





SECTION .text       ; NOISE_HANDLER
    NOISE_HANDLER:
        PUSH    RAX
        PUSH    RBX
        PUSH    RCX
        PUSH    RDX
        PUSH    R10
        PUSH    R11
        PUSH    R15

        MOV     RSI, IMG
        MOV     RCX, [ROWS]
        IMUL    RCX, [COLS]
        IMUL    RCX, [NOISE_PROB]
        XCHG    RAX, RCX
        MOV     RBX, 100
        XOR     RDX, RDX
        DIV     RBX
        XCHG    RAX, RCX
        .NOISE_LOOP:
            CALL    POSRAND
            MOV     RAX, R15  
            MOV     RBX, [ROWS]
            XOR     RDX, RDX
            DIV     RBX
            MOV     R10, RDX    ; i
              
            CALL    POSRAND
            MOV     RAX, R15
            MOV     RBX, [COLS]
            XOR     RDX, RDX
            DIV     RBX
            MOV     R11, RDX    ; j

            CALL    POSRAND
            MOV     RAX, R15
            AND     RAX, 1
            CMP     RAX, 0
            JE      .SALT
            MOV     RAX, 255
            .PEPPER:    SETVAL IMG, [ROWS], [COLS], R10, R11, RAX
                        JMP    .CONT
            .SALT:      SETVAL IMG, [ROWS], [COLS], R10, R11, RAX

        .CONT:
        DEC     RCX
        JNZ    .NOISE_LOOP



        POP     R15
        POP     R11
        POP     R10
        POP     RDX
        POP     RCX
        POP     RBX
        POP     RAX
        RET




SECTION .text       ; POOLING_HANDLER
    POOLING_HANDLER:
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

        MOV     RSI, POOLSIZE_MSG           ; GET THE POOLING SIZE
        CALL    PUTSTR
        CALL    READINT
        MOV     RSI, POOL_SIZE_ERR
        CMP     RAX, [ROWS]
        JG      PUTERR
        CMP     RAX, [COLS]
        JG      PUTERR
        MOV     [POOL_SIZE], RAX
        
        XOR     RDX, RDX
        MOV     RAX, [ROWS]         
        MOV     RBX, [POOL_SIZE]
        DIV     RBX
        MOV     [POOL_RESULT_ROW], RAX      ; SET THE VALUE OF THE ROWS OF THE RESULT MATRIX

        XOR     RDX, RDX
        MOV     RAX, [COLS]
        MOV     RBX, [POOL_SIZE]
        DIV     RBX
        MOV     [POOL_RESULT_COL], RAX      ; SET THE VALUE OF THE COLS OF THE RESULT MATRIX

        MOV     RSI, POOLTYPE_MSG           ; GET THE POOLING TYPE
        CALL    PUTSTR
        CALL    READINT
        CMP     RAX, 0
        JE      .AVG_POOL
        CMP     RAX, 1
        JE      .MAX_POOL
        MOV     RSI, POOL_TYPE_ERR
        JMP     PUTERR

        .AVG_POOL:
           ; R10 IS USED AS TEMPORARY VARIABLE
           XOR    R11, R11
           .FORA_i:;R11

                XOR     R12, R12
                .FORA_j:;R12

                    XOR     RAX, RAX;WINDOW SUM
                    MOV     R13, R11
                    .FORA_m:;R13

                        MOV     R14, R12
                        .FORA_n:;R14

                            GETVAL IMG, [ROWS], [COLS], R13, R14
                            ADD RAX, R15

                        MOV     R10, [POOL_SIZE]
                        ADD     R10, R12
                        INC     R14
                        CMP     R14, R10
                        JL      .FORA_n
                        .END_FORA_n:

                    MOV     R10, [POOL_SIZE]
                    ADD     R10, R11
                    INC     R13
                    CMP     R13, R10
                    JL      .FORA_m
                    .END_FORA_m:

                    MOV     R10, [POOL_SIZE]
                    IMUL    R10, R10
                    XOR     RDX, RDX
                    DIV     R10
                    MOV     [_v], RAX
                    MOV     [_i], R11
                    MOV     [_j], R12
                    POOLING_SETTER POOL_RESULT, [POOL_RESULT_ROW], [POOL_RESULT_COL], [POOL_SIZE], [_i], [_j], [_v]

                ADD     R12, [POOL_SIZE]
                CMP     R12, [COLS]
                JL      .FORA_j
                .END_FORA_j:

            ADD     R11, [POOL_SIZE]
            CMP     R11, [ROWS]
            JL      .FORA_i
            .END_FORA_i:
        JMP     .END_POOL

        .MAX_POOL:
            ; R10 IS USED AS TEMPORARY VARIABLE
            XOR     R11, R11
            .FORM_i:;R11
                
                XOR     R12, R12
                .FORM_j:;R12

                    XOR     RAX, RAX;MAXIMUM VALUE
                    MOV     R13, R11
                    .FORM_m:;R13

                        MOV     R14, R12
                       .FORM_n:;R14

                            GETVAL IMG, [ROWS], [COLS], R13, R14
                            MAX RAX, R15

                        MOV     R10, [POOL_SIZE]
                        ADD     R10, R12
                        INC     R14
                        CMP     R14, R10
                        JL      .FORM_n
                        .END_FORM_n:
                    
                    MOV     R10, [POOL_SIZE]
                    ADD     R10, R11
                    INC     R13
                    CMP     R13, R10
                    JL      .FORM_m
                    .END_FORM_m:

                    MOV     [_i], R11
                    MOV     [_j], R12
                    MOV     [_v], RAX
                    POOLING_SETTER POOL_RESULT, [POOL_RESULT_ROW], [POOL_RESULT_COL], [POOL_SIZE], [_i], [_j], [_v]

                ADD     R12, [POOL_SIZE]
                CMP     R12, [COLS]
                JL      .FORM_j
                .END_FORM_j:

            ADD     R11, [POOL_SIZE]
            CMP     R11, [ROWS]
            JL      .FORM_i
            .END_FORM_i:
        JMP     .END_POOL
        call dbg
        .END_POOL:
        MOV     RAX, [ROWS]
        MOV     RBX, [POOL_SIZE]
        XOR     RDX, RDX
        DIV     RBX
        MOV     [ROWS], RAX
        MOV     RAX, [COLS]
        MOV     RBX, [POOL_SIZE]
        XOR     RDX, RDX
        DIV     RBX
        MOV     [COLS], RAX

        MOV     RDX, [ROWS]
        IMUL    RDX, [COLS]
        MOV     RSI, POOL_RESULT
        MOV     RDI, IMG
        CALL    SWAPM

        MOV     RSI, POOLING_SUCCESS
        CALL    PUTSTR
        .RETURN:
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


SECTION .text       ; CONVOLVE_HANDLER
    CONVOLVE_HANDLER:
        PUSH    RSI
        PUSH    R8
        PUSH    R9
        PUSH    R10
        PUSH    R11
        PUSH    R12
        PUSH    R13
        PUSH    R14
        PUSH    R15

        MOV     RSI, CONV_INP_MSG
        CALL    PUTSTR
        CALL    READINT
        
        CMP     RAX, 1
        JE      .GB3

        CMP     RAX, 2
        JE      .GB5

        CMP     RAX, 3
        JE      .SHAR3

        CMP     RAX, 4
        JE      .LAP3

        .GB3:
        MOV     QWORD [KER_ROWS], 3
        MOV     QWORD [KER_COLS], 3
        MOV     QWORD [KER_SCALE], 16
        MOV     RSI, GAUSSIAN_BLUR_3
        JMP     .COPY

        .GB5:
        MOV     QWORD [KER_ROWS], 5
        MOV     QWORD [KER_COLS], 5
        MOV     QWORD [KER_SCALE], 256
        MOV     RSI, GAUSSIAN_BLUR_5
        JMP     .COPY

        .SHAR3:
        MOV     QWORD [KER_ROWS], 3
        MOV     QWORD [KER_COLS], 3
        MOV     QWORD [KER_SCALE], 1
        MOV     RSI, SHARPEN_3
        JMP     .COPY

        .LAP3:
        MOV     QWORD [KER_ROWS], 3
        MOV     QWORD [KER_COLS], 3
        MOV     QWORD [KER_SCALE], 1
        MOV     RSI, LAPLACIAN_3
        JMP     .COPY

        .COPY:
        MOV     RDI, KERNEL
        MOV     RCX, 100
        .COPY_LOOP:
            MOV     RAX, [RSI]
            MOV     [RDI], RAX
            ADD     RSI, 8
            ADD     RDI, 8
            LOOP    .COPY_LOOP
        

        .BEGIN_CONV:
        MOV     R14, [ROWS]             ; SET RESULT ROWS
        SUB     R14, [KER_ROWS]
        INC     R14
        MOV     [CONV_RESULT_ROW], R14

        MOV     R14, [COLS]             ; SET RESULT COLS
        SUB     R14, [KER_COLS]
        INC     R14
        MOV     [CONV_RESULT_COL], R14

        XOR     R11, R11
        MOV     RCX, [ROWS]
        SUB     RCX, [KER_ROWS]
        INC     RCX
        .FOR_i:;R11
            PUSH    RCX
            MOV     RCX, [COLS]
            SUB     RCX, [KER_COLS]
            INC     RCX

            XOR     R12, R12
            .FOR_j:;R12
                PUSH     RCX
                MOV      RCX, [KER_ROWS]
                
                XOR     RAX, RAX
                XOR     R13, R13
                .FOR_m:;R13
                    PUSH    RCX
                    MOV     RCX, [KER_COLS]

                    XOR     R14, R14
                    .FOR_n:;R14
                    PUSH    RCX

                        MOV     [_i], R11
                        MOV     [_j], R12
                        MOV     [_m], R13
                        MOV     [_n], R14

                                            ; <MAT ADDR>(1) <ROW>(2) <COL>(3) <KER ADDR>(4) <KER_ROW>(5) <KER_COL>(6) <i>(7) <j>(8) <m>(9) <n>(10)
                                                    ; <RESULT ADDR>(11) <RESULT_ROW>(12) <RESULT_COL>(13)
                                                    ; RESULT[i][j] += KER[m][n]*MAT[i + m][j + n]
                        PUSH    RBP
                        MOV     RBP, RSP
                        SUB     RSP, 8*3               ; 3 LOCAL VARIABLES (x, y, z)
                        PUSH    RAX
                        PUSH    RBX
                        PUSH    R15

                        ; RESULT[i][j] += KER[m][n]*MAT[i + m][j + n]
                        ; x = KER[m][n], y = MAT[i + m][j + n], z = RESULT[i][j]
                        ; RESULT[i][j] = z + x*y

                        GETVAL  KERNEL, [KER_ROWS], [KER_COLS], [_m], [_n]
                        MOV     QWORD [RBP - 8], R15  ; x

                        PUSH    R15 
                        MOV     R15, [_i]
                        ADD     R15, [_m]
                        MOV     [_r8], R15
                        MOV     R15, [_j]
                        ADD     R15, [_n]
                        MOV     [_r9], R15
                        POP     R15
                        GETVAL  IMG, [ROWS], [COLS], [_r8], [_r9]
                        MOV     QWORD [RBP - 16], R15 ; y

                        GETVAL  CONV_RESULT, [CONV_RESULT_ROW], [CONV_RESULT_COL], [_i], [_j]
                        MOV     QWORD [RBP - 24], R15 ; z

                        MOV     RAX, [RBP - 8]        ; x
                        MOV     RBX, [RBP - 16]       ; y
                        IMUL    RAX, RBX              ; x*y
                        ADD     RAX, [RBP - 24]       ; z + x*y

                        SETVAL CONV_RESULT, [CONV_RESULT_ROW], [CONV_RESULT_COL], [_i], [_j], RAX

                        POP     R15
                        POP     RBX
                        POP     RAX
                        ADD     RSP, 8*3
                        POP     RBP

                    POP     RCX
                    INC     R14
                    DEC     RCX
                    JNZ     .FOR_n
                
                POP     RCX
                INC     R13
                DEC     RCX
                JNZ     .FOR_m
            
            POP     RCX
            INC     R12
            DEC     RCX
            JNZ     .FOR_j

        POP     RCX
        INC     R11
        DEC     RCX
        JNZ     .FOR_i

        MOV     RAX, [CONV_RESULT_ROW]
        MOV     [ROWS], RAX
        MOV     RAX, [CONV_RESULT_COL]
        MOV     [COLS], RAX

        ; DIVIDE BY KER_SCALE
        MOV     RSI, CONV_RESULT
        MOV     RCX, [CONV_RESULT_ROW]
        IMUL    RCX, [CONV_RESULT_COL]
        MOV     RBX, [KER_SCALE]
        .DIV_LOOP:
            MOV     RAX, [RSI]
            XOR     RDX, RDX
            DIV     RBX
            MOV     [RSI], RAX
            ADD     RSI, 8
            LOOP    .DIV_LOOP

        MOV     RSI, IMG
        MOV     RDI, CONV_RESULT
        MOV     RDX, [CONV_RESULT_ROW]
        IMUL    RDX, [CONV_RESULT_COL]
        CALL    SWAPM

        POP     R15
        POP     R14
        POP     R13
        POP     R12
        POP     R11
        POP     R10
        POP     R9
        POP     R8
        POP     RSI
        RET





SECTION .text       ; GRAYSCALE_HANDLER
    GRAYSCALE_HANDLER:
        PUSH    RAX
        PUSH    RCX
        PUSH    RDX
        PUSH    RSI
        PUSH    R8

        MOV     RSI, IMG
        MOV     RCX, [ROWS]
        MOV     RDX, [COLS]
        IMUL    RCX, RDX
        .GS_LOOP:
            MOV     R8, [RSI]
            PIXEL_GC R8
            MOV     [RSI], RAX
            ADD     RSI, 8
            LOOP    .GS_LOOP

        MOV     QWORD [DIM], 1
        MOV     QWORD [GC_FLAG], 1

        MOV     RSI, GS_SUCCESS_MSG
        CALL    PUTSTR

        POP     R8
        POP     RSI
        POP     RDX
        POP     RCX
        POP     RAX
        RET





SECTION .text       ; RESIZE_HANDLER
    RESIZE_HANDLER:
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
        
        MOV     RSI, NEW_ROWS_MSG
        CALL    PUTSTR
        CALL    READINT
        MOV     [NEW_ROWS], RAX

        MOV     RSI, NEW_COLS_MSG
        CALL    PUTSTR
        CALL    READINT
        MOV     [NEW_COLS], RAX

        MOV     RAX, [ROWS]
        MOV     RBX, [NEW_ROWS]
        XOR     RDX, RDX
        DIV     RBX
        MOV     [ROW_SCALE], RAX

        MOV     RAX, [COLS]
        MOV     RBX, [NEW_COLS]
        XOR     RDX, RDX
        DIV     RBX
        MOV     [COL_SCALE], RAX

        MOV     R14, RESIZE_RESULT
        MOV     RSI, IMG
        MOV     R11, 0
        .FOR_i:

            MOV     R12, 0
            .FOR_j:

                MOV     RAX, R11
                IMUL    RAX, [ROW_SCALE]
                MOV     R8, RAX

                MOV     RAX, R12
                IMUL    RAX, [COL_SCALE]
                MOV     R9, RAX

                GETIDX  [ROWS], [COLS], R8, R9
                IMUL    R15, 8
                MOV     RSI, IMG
                ADD     RSI, R15

                CMP     QWORD [DIM], 3
                JE      .SET_FOR_DIM3
                CMP     QWORD [DIM], 2
                JE      .SET_FOR_DIM2
                CMP     QWORD [DIM], 1
                JE      .SET_FOR_DIM1

                .SET_FOR_DIM3:  MOV R8, [RSI]
                                MOV R9, [RSI]
                                MOV R10, [RSI]
                                MOV R8, [R8]
                                MOV R9, [R9 + 8]
                                MOV R10, [R10 + 16]
                                TUPLE3 R8, R9, R10
                                MOV [R14], RDI
                                JMP .NXT_j

                .SET_FOR_DIM2:  MOV R8, [RSI]
                                MOV R9, [RSI]
                                MOV R8, [R8]
                                MOV R9, [R9 + 8]
                                TUPLE2 R8, R9
                                MOV [R14], RDI
                                JMP .NXT_j
                
                .SET_FOR_DIM1:  CMP     QWORD [GC_FLAG], 1
                                JNE     .NOT_GC

                                MOV R8, [RSI]
                                MOV [R14], R8
                                JMP .NXT_j

                                .NOT_GC:
                                MOV R8, [RSI]
                                MOV R8, [R8]
                                TUPLE1 R8
                                MOV [R14], RDI
                                JMP .NXT_j
                
            .NXT_j:
            ADD     R14, 8
            INC     R12
            MOV     RCX, [NEW_COLS]
            CMP     RCX, R12
            JG      .FOR_j
            .END_FOR_j:

        
        .NXT_i:
        INC     R11
        MOV     RCX, [NEW_ROWS]
        CMP     RCX, R11
        JG      .FOR_i
        .END_FOR_i:


        MOV     RAX, [NEW_ROWS]
        MOV     [ROWS], RAX
        MOV     RAX, [NEW_COLS]
        MOV     [COLS], RAX

        MOV     RDX, [ROWS]
        IMUL    RDX, [COLS]
        MOV     RSI, IMG
        MOV     RDI, RESIZE_RESULT
        CALL    SWAPM

        .RETURN:
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

; ----------------------------



SECTION .text   ; MAIN
    global _start
    _start:
        while_true:
            mov rsi, MENU
            call PUTSTR
            call PUTNL
            mov  rsi, ENTER_OP_MSG
            call PUTSTR
            call READINT

            cmp rax, 0
            je EXIT

            cmp rax, 1
            je open_handler_jmp

            cmp rax, 2
            je reshape_handler_jmp

            cmp rax, 3
            je resize_handler_jmp

            cmp rax, 4
            je grayscale_handler_jmp

            cmp rax, 5
            je convolve_handler_jmp

            cmp rax, 6
            je pooling_handler_jmp

            cmp rax, 7
            je noise_handler_jmp

            cmp rax, 8
            je output_handler_jmp

            after_handler:
            jmp while_true

            open_handler_jmp:
                call OPEN_HANDLER
                jmp after_handler

            reshape_handler_jmp:
                call RESHAPE_HANDLER
                jmp after_handler
            
            resize_handler_jmp:
                call RESIZE_HANDLER
                jmp after_handler
            
            grayscale_handler_jmp:
                call GRAYSCALE_HANDLER
                jmp after_handler

            convolve_handler_jmp:
                call CONVOLVE_HANDLER
                jmp after_handler

            pooling_handler_jmp:
                call POOLING_HANDLER
                jmp after_handler

            noise_handler_jmp:
                call NOISE_HANDLER
                jmp after_handler
            
            output_handler_jmp:
                call OUTPUT_HANDLER
                jmp after_handler
