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
        MOV     RSI, STRIDE_INP_MSG
        CALL    PUTSTR
        CALL    READINT
        MOV     [STRIDE], RAX
        
        MOV     RAX, [ROWS]             ; SET RESULT ROWS
        SUB     RAX, [KER_ROWS]
        MOV     RBX, [STRIDE]
        XOR     RDX, RDX
        DIV     RBX
        INC     RAX
        MOV     [CONV_RESULT_ROW], RAX

        MOV     RAX, [COLS]             ; SET RESULT COLS
        SUB     RAX, [KER_COLS]
        MOV     RBX, [STRIDE]
        XOR     RDX, RDX
        DIV     RBX
        INC     RAX
        MOV     [CONV_RESULT_COL], RAX

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

                        PUSH    RAX
                        MOV     RAX, [_i]
                        MOV     RBX, [STRIDE]
                        XOR     RDX, RDX
                        DIV     RBX
                        MOV     [_i], RAX

                        MOV     RAX, [_j]
                        MOV     RBX, [STRIDE]
                        XOR     RDX, RDX
                        DIV     RBX
                        MOV     [_j], RAX
                        POP     RAX

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
            ADD     R12, [STRIDE]
            SUB     RCX, [STRIDE]
            CMP     RCX, 0
            JG     .FOR_j

        POP     RCX
        ADD     R11, [STRIDE]
        SUB     RCX, [STRIDE]
        CMP     RCX, 0
        JG     .FOR_i

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
