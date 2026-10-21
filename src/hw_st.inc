;==============================================================================
; Atari ST includes

;==============================================================================
; Vectors
CPU_INITSSP                     equ     $0                                  ; Reset : Initial SSP
CPU_INITPC                      equ     $4                                  ; Reset : Initial PC
CPU_BUSERR                      equ     $8                                  ; Bus Error
CPU_ADDRERR                     equ     $C                                  ; Address Error
CPU_ILLEGALINSTR                equ     $10                                 ; Illegal Instruction
CPU_DIVBYZERO                   equ     $14                                 ; Zero Divide
CPU_CHKCHK2                     equ     $18                                 ; CHK, CHK2 Instruction
CPU_TRAP                        equ     $1C                                 ; cpTRAPcc, TRAPcc, TRAPV
CPU_PRIVVIOL                    equ     $20                                 ; Privilege Violation
CPU_TRACE                       equ     $24                                 ; Trace
CPU_LINEA                       equ     $28                                 ; Line 1010 Emulator (LineA)
CPU_LINEF                       equ     $2C                                 ; Line 1111 Emulator (LineF)
CPU_COPROC                      equ     $34                                 ; Coprocessor Protocol Violation (68030)
CPU_FORMATERR                   equ     $38                                 ; Format Error (68010)
CPU_UNINITVEC                   equ     $3C                                 ; Uninitialized Interrupt Vector
CPU_SPURIOUSINT                 equ     $60                                 ; Spurious Interrupt (Bus error during interrupt)

;==============================================================================
; Interrupts
LEV1_INT                        equ     $64                                 ; TT VME
LEV2_INT                        equ     $68                                 ; HBL
LEV3_INT                        equ     $6c                                 ; TT VME
LEV4_INT                        equ     $70                                 ; VBL
LEV5_INT                        equ     $74                                 ;
LEV6_INT                        equ     $78                                 ; MFP
LEV7_INT                        equ     $7c                                 ;

;==============================================================================
; Traps
TRAP_0                          equ     $80     
TRAP_1                          equ     $84                                 ; GemDOS
TRAP_2                          equ     $88                                 ; AES/VDI
TRAP_3                          equ     $8C     
TRAP_4                          equ     $90     
TRAP_5                          equ     $94     
TRAP_6                          equ     $98     
TRAP_7                          equ     $9C     
TRAP_8                          equ     $A0     
TRAP_9                          equ     $A4     
TRAP_A                          equ     $A8     
TRAP_B                          equ     $AC     
TRAP_C                          equ     $B0     
TRAP_D                          equ     $B4                                 ; BIOS
TRAP_E                          equ     $B8                                 ; XBIOS
TRAP_F                          equ     $BC     

;==============================================================================
; FPU vectors
FPU_UNORDERED                   equ     $C0                                 ; Branch or Set on Unordered Condition
FPU_INEXACT                     equ     $C4                                 ; Inexact Result 
FPU_DIVBYZERO                   equ     $C8                                 ; Divide by Zero
FPU_UNDERFLOW                   equ     $CC                                 ; Underflow
FPU_OPERROR                     equ     $D0                                 ; Operand Error
FPU_OVERFLOW                    equ     $D4                                 ; Overflow
FPU_NAN                         equ     $D8                                 ; Signaling NAN
FPU_RESERVED                    equ     $DC     

;==============================================================================
; MMU vectors
MMU_CONFIGERR                   equ     $E0                                 ; MMU Configuration Error

;==============================================================================
; GEMDOS (trap #1)
GEMDOS_PTERM                    equ     0
GEMDOS_CCONIN                   equ     1
GEMDOS_CCONOUT                  equ     2
GEMDOS_CAUXIN                   equ     3
GEMDOS_CAUXOUT                  equ     4
GEMDOS_CPRNOUT                  equ     5
GEMDOS_CRAWIO                   equ     6
GEMDOS_CRAWCIN                  equ     7
GEMDOS_CNECIN                   equ     8
GEMDOS_CCONWS                   equ     9
GEMDOS_CCONRS                   equ     10
GEMDOS_CCONIS                   equ     11
GEMDOS_DSETDRV                  equ     14
GEMDOS_CCONOS                   equ     16
GEMDOS_CPRNOS                   equ     17
GEMDOS_CAUXIS                   equ     18
GEMDOS_CAUXOS                   equ     19
GEMDOS_DGETDRV                  equ     25
GEMDOS_FSETDTA                  equ     26
GEMDOS_SUPER                    equ     32
GEMDOS_TGETDATE                 equ     42
GEMDOS_TSETDATE                 equ     43
GEMDOS_TGETTIME                 equ     44
GEMDOS_TSETTIME                 equ     45
GEMDOS_FGETDTA                  equ     47
GEMDOS_SVERSION                 equ     48
GEMDOS_PTERMRES                 equ     49
GEMDOS_DFREE                    equ     54
GEMDOS_DCREATE                  equ     57
GEMDOS_DDELETE                  equ     58
GEMDOS_DSETPATH                 equ     59
GEMDOS_FCREATE                  equ     60
GEMDOS_FOPEN                    equ     61
GEMDOS_FCLOSE                   equ     62
GEMDOS_FREAD                    equ     63
GEMDOS_FWRITE                   equ     64
GEMDOS_FDELETE                  equ     65
GEMDOS_FSEEK                    equ     66
GEMDOS_FATTRIB                  equ     67
GEMDOS_DGETPATH                 equ     71
GEMDOS_MALLOC                   equ     72
GEMDOS_MFREE                    equ     73
GEMDOS_MSHRINK                  equ     74
GEMDOS_PEXEC                    equ     75
GEMDOS_EXIT                     equ     76
GEMDOS_FSFIRST                  equ     78
GEMDOS_FSNEXT                   equ     79
GEMDOS_FRENAME                  equ     86
GEMDOS_FDATIME                  equ     87

;==============================================================================
; BIOS (trap #$D)
BIOS_GETMPB                     equ     0
BIOS_BCONSTAT                   equ     1
BIOS_BCONIN                     equ     2
BIOS_BCONOUT                    equ     3
BIOS_RWABS                      equ     4
BIOS_SETEXC                     equ     5
BIOS_TICKCAL                    equ     6
BIOS_GETBPB                     equ     7
BIOS_BCOSTAT                    equ     8
BIOS_MEDIACH                    equ     9
BIOS_DRVMAP                     equ     10
BIOS_KBSHIFT                    equ     11

;==============================================================================
; Extended BIOS (trap #$E)
XBIOS_INITMOUS                  equ     0
XBIOS_SSBRK                     equ     1
XBIOS_PHYSBASE                  equ     2
XBIOS_LOGBASE                   equ     3
XBIOS_GETREZ                    equ     4
XBIOS_SETSCREEN                 equ     5
XBIOS_SETPALETTE                equ     6
XBIOS_SETCOLOR                  equ     7
XBIOS_FLOPRD                    equ     8
XBIOS_FLOPWR                    equ     9
XBIOS_FLOPFMT                   equ     10
XBIOS_reserved                  equ     11
XBIOS_MIDIWS                    equ     12
XBIOS_MFPINT                    equ     13
XBIOS_IOREC                     equ     14
XBIOS_RSCONF                    equ     15
XBIOS_KEYTBL                    equ     16
XBIOS_RANDOM                    equ     17
XBIOS_PROTOBT                   equ     18
XBIOS_FLOPVER                   equ     19
XBIOS_SCRDMP                    equ     20
XBIOS_CURSCONF                  equ     21
XBIOS_SETTIME                   equ     22
XBIOS_GETTIME                   equ     23
XBIOS_BIOSKEYS                  equ     24
XBIOS_IKBDWS                    equ     25
XBIOS_JDISINT                   equ     26
XBIOS_JENABINT                  equ     27
XBIOS_GIACCESS                  equ     28
XBIOS_OFFGIBIT                  equ     29
XBIOS_ONGIBIT                   equ     30
XBIOS_XBTIMER                   equ     31
XBIOS_DOSOUND                   equ     32
XBIOS_SETPRT                    equ     33
XBIOS_KBDVBASE                  equ     34
XBIOS_KBRATE                    equ     35
XBIOS_PRTBLK                    equ     36
XBIOS_VSYNC                     equ     37
XBIOS_SUPEXEC                   equ     38
XBIOS_PUNTAES                   equ     39

;==============================================================================
; System errors
BIOSERR_OK                      equ     0
BIOSERR_ERROR                   equ     -1
BIOSERR_DRVNR                   equ     -2
BIOSERR_UNCMD                   equ     -3
BIOSERR_CRC                     equ     -4
BIOSERR_BADRQ                   equ     -5
BIOSERR_SEEK                    equ     -6
BIOSERR_MEDIA                   equ     -7
BIOSERR_SECNF                   equ     -8
BIOSERR_PAPER                   equ     -9
BIOSERR_WRITF                   equ     -10
BIOSERR_READF                   equ     -11
BIOSERR_GENRL                   equ     -12
BIOSERR_WRPRO                   equ     -13
BIOSERR_CHNG                    equ     -14
BIOSERR_UNDEV                   equ     -15
BIOSERR_BADSF                   equ     -16
BIOSERR_OTHER                   equ     -17

DOSERR_INVFN                    equ     -32
DOSERR_FILNF                    equ     -33
DOSERR_PTHNF                    equ     -34
DOSERR_NHNDL                    equ     -35
DOSERR_ACCDN                    equ     -36
DOSERR_IHNDL                    equ     -37
DOSERR_NSMEM                    equ     -39
DOSERR_IMBA                     equ     -40
DOSERR_DRIVE                    equ     -46
DOSERR_NMFIL                    equ     -49

ERR_RANGE                       equ     -64
ERR_INTRN                       equ     -65
ERR_PLFMT                       equ     -66
ERR_GSBF                        equ     -67

;==============================================================================
; Line A stuff
VPLANES                         equ     0
VWRAP                           equ     2
CONTRL                          equ     4
INTIN                           equ     8
PTSIN                           equ     12
INTOUT                          equ     16
PTSOUT                          equ     20
COLBIT0                         equ     24
COLBIT1                         equ     26
COLBIT2                         equ     28
COLBIT3                         equ     30
LSTLIN                          equ     32
LNMASK                          equ     34
WMODE                           equ     36
X1                              equ     38
Y1                              equ     40
X2                              equ     42
Y2                              equ     44
PATPTR                          equ     46
PATMSK                          equ     50
MFILL                           equ     52
CLIP                            equ     54
XMINCL                          equ     56
YMINCL                          equ     58
XMAXCL                          equ     60
YMAXCL                          equ     62
XDDA                            equ     64
DDAINC                          equ     66
SCALDIR                         equ     68
MONO                            equ     70
SRCX                            equ     72
SRCY                            equ     74
DSTX                            equ     76
DSTY                            equ     78
DELX                            equ     80
DELY                            equ     82
FBASE                           equ     84
FWIDTH                          equ     88
STYLE                           equ     90
LITEMSK                         equ     92
SKEWMSK                         equ     94
WEIGHT                          equ     96
ROFF                            equ     98
LOFF                            equ     100
SCALE                           equ     102
CHUP                            equ     104
TEXTFG                          equ     106
SCRTCHP                         equ     108
SCRT2                           equ     112
TEXTBG                          equ     114
COPYTRAN                        equ     116
SEEDABORT                       equ     118

INIT                            equ     $A000
PUTPIX                          equ     $A001
GETPIX                          equ     $A002
ABLINE                          equ     $A003
HABLINE                         equ     $A004
RECTFILL                        equ     $A005
POLYFILL                        equ     $A006
BITBLT                          equ     $A007
TEXTBLT                         equ     $A008
SHOWCUR                         equ     $A009
HIDECUR                         equ     $A00A
CHGCUR                          equ     $A00B
DRSPIRITE                       equ     $A00C
UNSPIRITE                       equ     $A00D
COPYRSTR                        equ     $A00E
SEEDFILL                        equ     $A00F

LINE_A_                         macro
                                dc.w     \1
                                endm

;==============================================================================
; Misc. addresses
PAR_BUSY                        equ     $100                                ; ST-MFP-0 - Centronics busy
RS232_DCD                       equ     $104                                ; ST-MFP-1 - RS-232 DCD
RS232_CTS                       equ     $108                                ; ST-MFP-2 - RS-232 CTS
BLITTER_DONE                    equ     $10C                                ; ST-MFP-3 - Blitter done
TIMER_D                         equ     $110                                ; ST-MFP-4 - Timer D (USART timer)
TIMER_C                         equ     $114                                ; ST-MFP-5 - Timer C (200hz Clock)
KBD_MIDI                        equ     $118                                ; ST-MFP-6 - Keyboard/MIDI (ACIA)
FDC_HDC                         equ     $11C                                ; ST-MFP-7 - FDC/HDC
TIMER_B                         equ     $120                                ; ST-MFP-8 - Timer B (HBL)
MFP_SEND_ERR                    equ     $124                                ; ST-MFP-9 - Send Error
MFP_BUF_EMPTY                   equ     $128                                ; ST-MFP-10 - Send buffer empty
MFP_RECV_ERR                    equ     $12C                                ; ST-MFP-11 - Receive error
MFP_RECV_FULL                   equ     $130                                ; ST-MFP-12 - Receive buffer full
TIMER_A                         equ     $134                                ; ST-MFP-13 - Timer A (STE sound)
RS232_RING                      equ     $138                                ; ST-MFP-14 - RS-232 Ring detect
MFP_MONO_DETECT                 equ     $13C                                ; ST-MFP-15 - GPI7 - Monochrome Detect

;==============================================================================
; System variables
RESVECTOR                       equ     $42A
FLOCK                           equ     $43E
NVBLS                           equ     $454
_VBLQUEUE                       equ     $456
_FRCLOCK                        equ     $466
CONTERM                         equ     $484
_HZ_200                         equ     $4BA
VBL_SLOT_1                      equ     $4D2                                ; slot 1 of the default VBL queue

;==============================================================================
; Hardware registers
MMU_MEMCONF                     equ     $FFFF8001                           ; .b MMU memory configuration                  BIT 3 2 1 0 R/W
                                                                            ;    Bank 0                                        | | | |
                                                                            ;    00 - 128k ------------------------------------+-+ | |
                                                                            ;    01 - 512k ------------------------------------+-+ | |
                                                                            ;    10 - 2m --------------------------------------+-+ | |
                                                                            ;    11 - reserved --------------------------------+-' | |
                                                                            ;    Bank 1                                            | |
                                                                            ;    00 - 128k ----------------------------------------+-+
                                                                            ;    01 - 512k ----------------------------------------+-+
                                                                            ;    10 - 2m ------------------------------------------+-+
                                                                            ;    11 - reserved ------------------------------------+-'
    
VID_POS                         equ     $FFFF8200                           ; .b Video screen memory position (R/W)
VID_POS_H                       equ     $FFFF8201                           ; .b Video screen memory position (High byte) (R/W)
VID_POS_M                       equ     $FFFF8203                           ; .b Video screen memory position (Mid byte) (R/W)

VID_ADDR                        equ     $FFFF8204                           ; .b Video address pointer
VID_ADDR_H                      equ     $FFFF8205                           ; .b Video address pointer (High byte) (R)
VID_ADDR_M                      equ     $FFFF8207                           ; .b Video address pointer (Mid byte) (R)
VID_ADDR_L                      equ     $FFFF8209                           ; .b Video address pointer (Low byte) (R)

VID_SYNC_MODE                   equ     $FFFF820A                           ; .b Video synchronization mode (R/W)
                                                                            ;                         BIT 1
                                                                            ;    0 - 60hz, 1 - 50hz ------+

VID_COLOR_0                     equ     $FFFF8240                           ; .w Video palette register 0 (R/W)
VID_COLOR_1                     equ     $FFFF8242                           ; .w Video palette register 1
VID_COLOR_2                     equ     $FFFF8244                           ; .w Video palette register 2
VID_COLOR_3                     equ     $FFFF8246                           ; .w Video palette register 3
VID_COLOR_4                     equ     $FFFF8248                           ; .w Video palette register 4
VID_COLOR_5                     equ     $FFFF824A                           ; .w Video palette register 5
VID_COLOR_6                     equ     $FFFF824C                           ; .w Video palette register 6
VID_COLOR_7                     equ     $FFFF824E                           ; .w Video palette register 7
VID_COLOR_8                     equ     $FFFF8250                           ; .w Video palette register 8
VID_COLOR_9                     equ     $FFFF8252                           ; .w Video palette register 9
VID_COLOR_10                    equ     $FFFF8254                           ; .w Video palette register 10
VID_COLOR_11                    equ     $FFFF8256                           ; .w Video palette register 11
VID_COLOR_12                    equ     $FFFF8258                           ; .w Video palette register 12
VID_COLOR_13                    equ     $FFFF825A                           ; .w Video palette register 13
VID_COLOR_14                    equ     $FFFF825C                           ; .w Video palette register 14
VID_COLOR_15                    equ     $FFFF825E                           ; .w Video palette register 15

VID_RESOL                       equ     $FFFF8260                           ; .b Shifter resolution                         BIT 1 0 (R/W)
                                                                            ;    00 320x200x4 bitplanes (16 colors) ------------+-+
                                                                            ;    01 640x200x2 bitplanes (4 colors) -------------+-+
                                                                            ;    10 640x400x1 bitplane  (1 colors) -------------+-'

FDC_SEC_COUNT                   equ     $FFFF8604                           ; .w (R/W)
FDC_DMA_STATUS                  equ     $FFFF8606                           ; .w DMA mode/status                             BIT 2 1 0 (R)
                                                                            ;    Condition of FDC DATA REQUEST signal -----------' | |
                                                                            ;    0 - sector count null,1 - not null ---------------' |
                                                                            ;    0 - no error, 1 - DMA error ------------------------'
                                                                            ;
                                                                            ;    DMA mode/status                 BIT 8 7 6 . 4 3 2 1 . (W)
                                                                            ;    0 - read FDC/HDC,1 - write ---------' | | | | | | | 
                                                                            ;    0 - HDC access,1 - FDC access --------' | | | | | | 
                                                                            ;    0 - DMA on,1 - no DMA ------------------' | | | | | 
                                                                            ;    Reserved ---------------------------------' | | | | 
                                                                            ;    0 - FDC reg,1 - sector count reg -----------' | | | 
                                                                            ;    0 - FDC access,1 - HDC access ----------------' | | 
                                                                            ;    0 - pin A1 low, 1 - pin A1 high ----------------' | 
                                                                            ;    0 - pin A0 low, 1 - pin A0 high ------------------' 

FDC_DMA_BASE_H                  equ     $FFFF8609                           ; .b DMA base and counter (High byte) (R/W)
FDC_DMA_BASE_M                  equ     $FFFF860B                           ; .b DMA base and counter (Mid byte) (R/W)
FDC_DMA_BASE_L                  equ     $FFFF860D                           ; .b DMA base and counter (Low byte) (R/W)

PSG_SEL                         equ     $FFFF8800                           ; .b Read data/Register select (R/W)
                                                                            ;    0 Channel A Freq Low              BIT 7 6 5 4 3 2 1 0
                                                                            ;    1 Channel A Freq High                     BIT 3 2 1 0
                                                                            ;    2 Channel B Freq Low              BIT 7 6 5 4 3 2 1 0
                                                                            ;    3 Channel B Freq High                     BIT 3 2 1 0
                                                                            ;    4 Channel C Freq Low              BIT 7 6 5 4 3 2 1 0
                                                                            ;    5 Channel C Freq High                     BIT 3 2 1 0
                                                                            ;    6 Noise Freq                          BIT 5 4 3 2 1 0
                                                                            ;    7 Mixer Control                   BIT 7 6 5 4 3 2 1 0
                                                                            ;      Port B IN/OUT (1=Output) -----------' | | | | | | |
                                                                            ;      Port A IN/OUT ------------------------' | | | | | |
                                                                            ;      Channel C Noise (1=Off) ----------------' | | | | |
                                                                            ;      Channel B Noise --------------------------' | | | |
                                                                            ;      Channel A Noise ----------------------------' | | |
                                                                            ;      Channel C Tone (0=On) ------------------------' | |
                                                                            ;      Channel B Tone ---------------------------------' |
                                                                            ;      Channel A Tone -----------------------------------'
                                                                            ;    8 Channel A Amplitude Control           BIT 4 3 2 1 0
                                                                            ;      Fixed/Variable Level (0=Fixed) -----------' | | | |
                                                                            ;      Amplitude level control --------------------+-+-+-'
                                                                            ;    9 Channel B Amplitude Control           BIT 4 3 2 1 0
                                                                            ;      Fixed/Variable Level ---------------------' | | | |
                                                                            ;      Amplitude level control --------------------+-+-+-'
                                                                            ;    10 Channel C Amplitude Control          BIT 4 3 2 1 0
                                                                            ;       Fixed/Variable Level --------------------' | | | |
                                                                            ;       Amplitude level control -------------------+-+-+-'
                                                                            ;    11 Envelope Period High           BIT 7 6 5 4 3 2 1 0
                                                                            ;    12 Envelope Period Low            BIT 7 6 5 4 3 2 1 0
                                                                            ;    13 Envelope Shape                         BIT 3 2 1 0
                                                                            ;       Continue ----------------------------------' | | |
                                                                            ;       Attack --------------------------------------' | |
                                                                            ;       Alternate -------------------------------------' |
                                                                            ;       Hold --------------------------------------------'
                                                                            ;       00xx - \____________________________________      
                                                                            ;       01xx - /|___________________________________      
                                                                            ;       1000 - \|\|\|\|\|\|\|\|\|\|\|\|\|\|\|\|\|\|\      
                                                                            ;       1001 - \____________________________________      
                                                                            ;       1010 - \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\      
                                                                            ;       1011 - \|-----------------------------------      
                                                                            ;       1100 - /|/|/|/|/|/|/|/|/|/|/|/|/|/|/|/|/|/|/      
                                                                            ;       1101 - /------------------------------------      
                                                                            ;       1110 - /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/      
                                                                            ;       1111 - /|___________________________________      
                                                                            ;    14 Port A                         BIT 7 6 5 4 3 2 1 0
                                                                            ;       IDE Drive On/OFF ------------------+ | | | | | | |    (F030)
                                                                            ;       SCC A (0=LAN, 1=Serial2) ----------' | | | | | | |      (TT)
                                                                            ;       Monitor jack GPO pin ----------------+ | | | | | |
                                                                            ;       Internal Speaker On/Off -------------' | | | | | |    (F030)
                                                                            ;       Centronics strobe ---------------------' | | | | |
                                                                            ;       RS-232 DTR output -----------------------' | | | |
                                                                            ;       RS-232 RTS output -------------------------' | | |
                                                                            ;       Drive select 1 ------------------------------' | |
                                                                            ;       Drive select 0 --------------------------------' |
                                                                            ;       Drive side select -------------------------------'
                                                                            ;    15 Port B (Parallel port)                            

PSG_DAT                         equ     $FFFF8802                           ; .b Write data (W)

MFP_PAR_DAT                     equ     $FFFFFA01                           ; .b Parallel Port Data Register (R/W)
MFP_ACT_EDGE                    equ     $FFFFFA03                           ; .b Active Edge Register              BIT 7 6 5 4 . 2 1 0 (R/W)
                                                                            ;    Monochrome monitor detect ------------' | | | | | | |
                                                                            ;    RS-232 Ring indicator ------------------' | | | | | |
                                                                            ;    FDC/HDC interrupt ------------------------' | | | | |
                                                                            ;    Keyboard/MIDI interrupt --------------------' | | | |
                                                                            ;    Reserved -------------------------------------' | | |
                                                                            ;    RS-232 CTS (input) -----------------------------' | |
                                                                            ;    RS-232 DCD (input) -------------------------------' |
                                                                            ;    Centronics busy ------------------------------------'
                                                                            ;
                                                                            ;        When port bits are used for input only:       
                                                                            ;    0 - Interrupt on pin high-low conversion             
                                                                            ;    1 - Interrupt on pin low-high conversion             

MFP_DAT_DIR                     equ     $FFFFFA05                           ; .b Data Direction                    BIT 7 6 5 4 3 2 1 0 (R/W)
                                                                            ;    0 - In, 1 - Out ----------------------+-+-+-+-+-+-+-'
MFP_INT_EN_A                    equ     $FFFFFA07                           ; .b Interrupt Enable A                BIT 7 6 5 4 3 2 1 0 (R/W)
MFP_INT_PENDING_A               equ     $FFFFFA0B                           ; .b Interrupt Pending A               BIT 7 6 5 4 3 2 1 0 (R/W)
MFP_INT_BUSY_A                  equ     $FFFFFA0F                           ; .b Interrupt In-service A            BIT 7 6 5 4 3 2 1 0 (R/W)
MFP_INT_MASK_A                  equ     $FFFFFA13                           ; .b Interrupt Mask A                  BIT 7 6 5 4 3 2 1 0 (R/W)
                                                                            ;    MFP Address                           | | | | | | | |
                                                                            ;    $13C GPI7-Monochrome Detect ----------' | | | | | | |
                                                                            ;    $138   RS-232 Ring Detector ------------' | | | | | |
                                                                            ;    $134 (STE sound)    Timer A --------------' | | | | |
                                                                            ;    $130    Receive buffer full ----------------' | | | |
                                                                            ;    $12C          Receive error ------------------' | | |
                                                                            ;    $128      Send buffer empty --------------------' | |
                                                                            ;    $124             Send error ----------------------' |
                                                                            ;    $120 (HBL)          Timer B ------------------------'
                                                                            ;    1 - Enable Interrupt            0 - Disable Interrupt

MFP_INT_EN_B                    equ     $FFFFFA09                           ; .b Interrupt Enable B                BIT 7 6 5 4 3 2 1 0 (R/W)
MFP_INT_PENDING_B               equ     $FFFFFA0D                           ; .b Interrupt Pending B               BIT 7 6 5 4 3 2 1 0 (R/W)
MFP_INT_BUSY_B                  equ     $FFFFFA11                           ; .b Interrupt In-service B            BIT 7 6 5 4 3 2 1 0 (R/W)
MFP_INT_MASK_B                  equ     $FFFFFA15                           ; .b Interrupt Mask B                  BIT 7 6 5 4 3 2 1 0 (R/W)
                                                                            ;    MFP Address                           | | | | | | | |
                                                                            ;    $11C                FDC/HDC ----------' | | | | | | |
                                                                            ;    $118          Keyboard/MIDI ------------' | | | | | |
                                                                            ;    $114 (200hz clock)  Timer C --------------' | | | | |
                                                                            ;    $110 (USART timer)  Timer D ----------------' | | | |
                                                                            ;    $10C           Blitter done ------------------' | | |
                                                                            ;    $108     RS-232 CTS - input --------------------' | |
                                                                            ;    $104     RS-232 DCD - input ----------------------' |
                                                                            ;    $100        Centronics Busy ------------------------'
                                                                            ;    1 - Enable Interrupt            0 - Disable Interrupt

MFP_VECTOR                      equ     $FFFFFA17                           ; .b Vector Register                   BIT 7 6 5 4 3 . . . (R/W)
                                                                            ;    Vector Base Offset -------------------+-+-+-' |
                                                                            ;    1 - *Software End-interrupt mode -------------+
                                                                            ;    0 - Automatic End-interrupt mode -------------'
                                                                            ;    * - Default operating mode

MFP_TIMER_A_CTRL                equ     $FFFFFA19                           ; .b Timer A Control                         BIT 4 3 2 1 0 (R/W)
MFP_TIMER_B_CTRL                equ     $FFFFFA1B                           ; .b Timer B Control                         BIT 4 3 2 1 0 (R/W)
                                                                            ;    Reset (force output low) -------------------' | | | |
                                                                            ;    ----------------------------------------------+-+-+-+
                                                                            ;    0000 - Timer stop, no function executed
                                                                            ;    0001 - Delay mode, divide by 4
                                                                            ;    0010 -     :           :     10
                                                                            ;    0011 -     :           :     16
                                                                            ;    0100 -     :           :     50
                                                                            ;    0101 -     :           :     64
                                                                            ;    0110 -     :           :     100
                                                                            ;    0111 - Delay mode, divide by 200
                                                                            ;    1000 - Event count mode
                                                                            ;    1xxx - Pulse extension mode, divide as above

MFP_TIMER_A_DAT                 equ     $FFFFFA1F                           ; .b Timer A Data (R/W)
MFP_TIMER_B_DAT                 equ     $FFFFFA21                           ; .b Timer B Data (R/W)

MFP_TIMER_CD_CTRL               equ     $FFFFFA1D                           ; .b Timer C & D Control                 BIT 6 5 4 . 2 1 0 (R/W)
                                                                            ;                                            Timer   Timer
                                                                            ;                                              C       D
                                                                            ;
                                                                            ;    000 - Timer stop
                                                                            ;    001 - Delay mode, divide by 4
                                                                            ;    010 -      :           :    10
                                                                            ;    011 -      :           :    16
                                                                            ;    100 -      :           :    50
                                                                            ;    101 -      :           :    64
                                                                            ;    110 -      :           :    100
                                                                            ;    111 - Delay mode, divide by 200

MFP_TIMER_C_DAT                 equ     $FFFFFA23                           ; .b Timer C Data (R/W)
MFP_TIMER_D_DAT                 equ     $FFFFFA25                           ; .b Timer D Data (R/W)
MFP_SYNC_CHAR                   equ     $FFFFFA27                           ; .b Sync Character (R/W)
MFP_USART_CTRL                  equ     $FFFFFA29                           ; .b USART Control                     BIT 7 6 5 4 3 2 1 . (R/W)
                                                                            ;    Clock divide (1 - div by 16) ---------' | | | | | | |
                                                                            ;    Word Length 00 - 8 bits ----------------+-+ | | | | |
                                                                            ;                01 - 7 bits ----------------+-+ | | | | |
                                                                            ;                10 - 6 bits ----------------+-+ | | | | |
                                                                            ;                11 - 5 bits ----------------+-' | | | | |
                                                                            ;    Bits Stop Start Format                      | | | | |
                                                                            ;    00     0    0   Synchronous ----------------+-+ | | |
                                                                            ;    01     1    1   Asynchronous ---------------+-+ | | |
                                                                            ;    10     1    1.5 Asynchronous ---------------+-+ | | |
                                                                            ;    11     1    2   Asynchronous ---------------+-' | | |
                                                                            ;    Parity (0 - ignore parity bit) -----------------' | |
                                                                            ;    Parity (0 - odd parity,1 - even) -----------------' |
                                                                            ;    Unused ---------------------------------------------'

MFP_RECV_STATUS                 equ     $FFFFFA2B                           ; .b Receiver Status                   BIT 7 6 5 4 3 2 1 0 (R/W)
                                                                            ;    Buffer full --------------------------' | | | | | | |
                                                                            ;    Overrun error --------------------------' | | | | | |
                                                                            ;    Parity error -----------------------------' | | | | |
                                                                            ;    Frame error --------------------------------' | | | |
                                                                            ;    Found - Search/Break detected ----------------' | | |
                                                                            ;    Match/Character in progress --------------------' | |
                                                                            ;    Synchronous strip enable -------------------------' |
                                                                            ;    Receiver enable bit --------------------------------'

MFP_TRANS_STATUS                equ     $FFFFFA2D                           ; .b Transmitter Status                BIT 7 6 5 4 3 2 1 0 (R/W)
                                                                            ;    Buffer empty -------------------------' | | | | | | |
                                                                            ;    Underrun error -------------------------' | | | | | |
                                                                            ;    Auto turnaround --------------------------' | | | | |
                                                                            ;    End of transmission ------------------------' | | | |
                                                                            ;    Break ----------------------------------------' | | |
                                                                            ;    High bit ---------------------------------------' | |
                                                                            ;    Low bit ------------------------------------------' |
                                                                            ;    Transmitter enable ---------------------------------'

MFP_USART_DAT                   equ     $FFFFFA2F                           ; .b USART data (R/W)

KBD_CTRL                        equ     $FFFFFC00                           ; .b Keyboard ACIA control             BIT 7 6 5 4 3 2 1 0 (W)
                                                                            ;    Rx Int enable (1 - enable) -----------' | | | | | | |
                                                                            ;    Tx Interrupts                           | | | | | | |
                                                                            ;    00 - RTS low, Tx int disable -----------+-+ | | | | |
                                                                            ;    01 - RTS low, Tx int enable ------------+-+ | | | | |
                                                                            ;    10 - RTS high, Tx int disable ----------+-+ | | | | |
                                                                            ;    11 - RTS low, Tx int disable,           | | | | | | |
                                                                            ;         Tx a break onto data out ----------+-' | | | | |
                                                                            ;    Settings                                    | | | | |
                                                                            ;    000 - 7 bit, even, 2 stop bit --------------+-+-+ | |
                                                                            ;    001 - 7 bit, odd, 2 stop bit ---------------+-+-+ | |
                                                                            ;    010 - 7 bit, even, 1 stop bit --------------+-+-+ | |
                                                                            ;    011 - 7 bit, odd, 1 stop bit ---------------+-+-+ | |
                                                                            ;    100 - 8 bit, 2 stop bit --------------------+-+-+ | |
                                                                            ;    101 - 8 bit, 1 stop bit --------------------+-+-+ | |
                                                                            ;    110 - 8 bit, even, 1 stop bit --------------+-+-+ | |
                                                                            ;    111 - 8 bit, odd, 1 stop bit ---------------+-+-' | |
                                                                            ;    Clock divide                                      | |
                                                                            ;    00 - Normal --------------------------------------+-+
                                                                            ;    01 - Div by 16 -----------------------------------+-+
                                                                            ;    10 - Div by 64 -----------------------------------+-+
                                                                            ;    11 - Master reset --------------------------------+-'
                                                                            ;
                                                                            ;    Keyboard ACIA control             BIT 7 6 5 4 3 2 1 0 (R)
                                                                            ;    Interrupt request --------------------' | | | | | | |
                                                                            ;    Parity error ---------------------------' | | | | | |
                                                                            ;    Rx overrun -------------------------------' | | | | |
                                                                            ;    Framing error ------------------------------' | | | |
                                                                            ;    CTS ------------------------------------------' | | |
                                                                            ;    DCD --------------------------------------------' | |
                                                                            ;    Tx data register empty ---------------------------' |
                                                                            ;    Rx data register full ------------------------------'

KBD_DAT                         equ     $FFFFFC02                           ; .b Keyboard ACIA data (R/W)
MID_CTL                         equ     $FFFFFC04                           ; .b MIDI ACIA control                 BIT 7 6 5 4 3 2 1 0 (W)
                                                                            ;    Rx Int enable (1 - enable) -----------' | | | | | | |
                                                                            ;    Tx Interrupts                           | | | | | | |
                                                                            ;    00 - RTS low, Tx int disable -----------+-+ | | | | |
                                                                            ;    01 - RTS low, Tx int enable ------------+-+ | | | | |
                                                                            ;    10 - RTS high, Tx int disable ----------+-+ | | | | |
                                                                            ;    11 - RTS low, Tx int disable,           | | | | | | |
                                                                            ;         Tx a break onto data out ----------+-' | | | | |
                                                                            ;    Settings                                    | | | | |
                                                                            ;    000 - 7 bit, even, 2 stop bit --------------+-+-+ | |
                                                                            ;    001 - 7 bit, odd, 2 stop bit ---------------+-+-+ | |
                                                                            ;    010 - 7 bit, even, 1 stop bit --------------+-+-+ | |
                                                                            ;    011 - 7 bit, odd, 1 stop bit ---------------+-+-+ | |
                                                                            ;    100 - 8 bit, 2 stop bit --------------------+-+-+ | |
                                                                            ;    101 - 8 bit, 1 stop bit --------------------+-+-+ | |
                                                                            ;    110 - 8 bit, even, 1 stop bit --------------+-+-+ | |
                                                                            ;    111 - 8 bit, odd, 1 stop bit ---------------+-+-' | |
                                                                            ;    Clock divide                                      | |
                                                                            ;    00 - Normal --------------------------------------+-+
                                                                            ;    01 - Div by 16 -----------------------------------+-+
                                                                            ;    10 - Div by 64 -----------------------------------+-+
                                                                            ;    11 - Master reset --------------------------------+-'
                                                                            ;
                                                                            ;    MIDI ACIA control                 BIT 7 6 5 4 3 2 1 0 (R)
                                                                            ;    Interrupt request --------------------' | | | | | | |
                                                                            ;    Parity error ---------------------------' | | | | | |
                                                                            ;    Rx overrun -------------------------------' | | | | |
                                                                            ;    Framing error ------------------------------' | | | |
                                                                            ;    CTS ------------------------------------------' | | |
                                                                            ;    DCD --------------------------------------------' | |
                                                                            ;    Tx data register empty ---------------------------' |
                                                                            ;    Rx data register full ------------------------------'

MID_DAT                         equ     $FFFFFC06                           ; .b MIDI ACIA data (R/W)
