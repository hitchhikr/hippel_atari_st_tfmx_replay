;==============================================================================
; Atari STE includes

                                include "hw_st.inc"

;==============================================================================
; Hardware registers
VID_POS_L                       equ     $FFFF820D                           ; .b Video screen memory position (Low byte) (R/W) (STE)
VID_SCAN_W                      equ     $FFFF820F                           ; .b Width of a scanline (width in words-1) (R/W) (STE)
VID_HOR_SCR                     equ     $FFFF8265                           ; .b Horizontal scroll register (0-15) (STE)

SND_DMA_CTRL                    equ     $FFFF8901                           ; .b DMA Control Register              BIT 7 . 5 4 . . 1 0 (R/W)
                                                                            ;    1 - select record register -----------+   | |     | | (F030) 
                                                                            ;    0 - select replay register -----------'   | |     | | (F030)
                                                                            ;    Loop record buffer -----------------------' |     | | (F030)
                                                                            ;    DMA Record on ------------------------------'     | | (F030)
                                                                            ;    Loop replay buffer -------------------------------' | (STE)
                                                                            ;    DMA Replay on --------------------------------------' (STE)

SND_START_H                     equ     $FFFF8903                           ; .b Frame start address (high byte) (R/W) (STE)
SND_START_M                     equ     $FFFF8905                           ; .b Frame start address (mid byte) (R/W) (STE)
SND_START_L                     equ     $FFFF8907                           ; .b Frame start address (low byte) (R/W) (STE)
SND_COUNT_H                     equ     $FFFF8909                           ; .b Frame address counter (high byte) (R) (STE)
SND_COUNT_M                     equ     $FFFF890B                           ; .b Frame address counter (mid byte) (R) (STE)
SND_COUNT_L                     equ     $FFFF890D                           ; .b Frame address counter (low byte) (R) (STE)
SND_END_H                       equ     $FFFF890F                           ; .b Frame end address (high byte) (R/W) (STE)
SND_END_M                       equ     $FFFF8911                           ; .b Frame end address (mid byte) (R/W) (STE)
SND_END_L                       equ     $FFFF8913                           ; .b Frame end address (low byte) (R/W) (STE)

SND_MODE_CTRL                   equ     $FFFF8921                           ; .b Sound mode control                BIT 7 6 . . . . 1 0 (R/W) (STE)
                                                                            ;    0 - Stereo, 1 - Mono -----------------' |         | |
                                                                            ;    0 - 8bit -------------------------------+         | |
                                                                            ;    1 - 16bit (F030 only) ------------------'         | | (F030)
                                                                            ;    Frequency control bits                            | |
                                                                            ;    00 - Off (F030 only) -----------------------------+-+ (F030)
                                                                            ;    00 - 6258hz frequency (STe only) -----------------+-+
                                                                            ;    01 - 12517hz frequency ---------------------------+-+
                                                                            ;    10 - 25033hz frequency ---------------------------+-+
                                                                            ;    11 - 50066hz frequency ---------------------------+-'
                                                                            ;    Samples are always signed. In stereo mode, data is
                                                                            ;    arranged in pairs with high pair the left channel,low
                                                                            ;    pair right channel. Sample length MUST be even in
                                                                            ;    either mono or stereo mode.
                                                                            ;    Example: 8 bit Stereo : LRLRLRLRLRLRLRLR
                                                                            ;            16 bit Stereo : LLRRLLRRLLRRLLRR (F030)
                                                                            ;    2 track 16 bit stereo : LLRRllrrLLRRllrr (F030)
