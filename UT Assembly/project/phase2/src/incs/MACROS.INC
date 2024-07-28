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