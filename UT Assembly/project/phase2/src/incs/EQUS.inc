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
    O_TRUNC          EQU     0q01000

    ; FILE SEEK
    BEG_FILE_POS     EQU     0
    CURR_POS         EQU     1
    END_FILE_POS     EQU     2

    ; ASCII CHARACTERS
    NL               EQU     0xA
    NULL             EQU     0
    TAB              EQU     0x9
    SPACE            EQU     0x20