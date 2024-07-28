; NOTE: EVERY ERROR RESULTS IN EXITING THE PROGRAM!


%include "./incs/EQUS.inc"
%include "./incs/MACROS.inc"            ; MACRO TUPLE3 3 <a> <b> <c> -> RESULT ADDR IN RDI
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
%include "./incs/BASIC_FUNCTIONS.inc"
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
    STRIDE          DQ      1                   ; STRIDE OF THE CONVOLUTION                                         ;
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
    NOISE_PROB      DQ      5                   ; PROBABILITY OF NOISE (PERCENTAGE)                                 ;
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
    STRIDE_INP_MSG  DB      'Enter the stride of the convolution: ', NULL                                           ;
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


%include "./incs/HELPER.inc"
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


%include "./incs/FILE_MNG.inc"                          
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

%include "./incs/HANDLERS.inc"
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
