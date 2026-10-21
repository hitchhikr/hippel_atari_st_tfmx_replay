;==============================================================================
; Jochen Hippel's 'TFMX' music replayer for the Atari ST
; Disassembled and improved by hitchhikr (and decyphered by Claude).
;==============================================================================
;
;    tfmx_init    d0.w = subsong 1..n   start this subsong
;                 d0.w = 0              stop the music and mute the YM
;    tfmx_sfx     d0.b = effect number  play a sound effect
;    tfmx_play    call once per frame
;    tfmx_fade    d0.b = fade speed     fade the music out
;    tfmx_playing returns playing state (0 = playing / 1 = stopped)
;
;==============================================================================
;  HOW tfmx_play WORKS (one call per frame)
;==============================================================================
;
;  1. if a fade out is running, the 3 voices get one step quieter every speed+1 frames
;  2. if the music is stopped, only keep the 3 volumes at 0
;  3. every 'speed' frames, tfmx_read_row reads the next pattern row of each
;     voice, and its next track step when its pattern is over. A note starts
;     its instrument: volume sequence, frequency sequence, vibrato
;  4. every frame, tfmx_voice_update runs the frequency sequence (pitch,
;     tone/noise mode), the volume sequence, the vibrato and the portamento
;     of each voice, giving a YM tone period and a volume
;  5. if a sound effect is playing, its voice overrides one YM channel
;  6. YM registers 0 to 10 are written with a single movem.l
;
;==============================================================================

;==============================================================================
                                mc68000
                                opt     o+
                                opt     a+
;==============================================================================
                        
;==============================================================================
                                include "hw_ste.inc"
;==============================================================================
; add sfx support or not
USE_SFX                         equ     0

;==============================================================================
; ---- offsets of the value bytes in ym_registers_data (see there) ----
TFMX_YM_TONE_LO_A               equ     2                                   ; reg 0
TFMX_YM_TONE_HI_A               equ     6                                   ; reg 1
TFMX_YM_TONE_LO_B               equ     10                                  ; reg 2
TFMX_YM_TONE_HI_B               equ     14                                  ; reg 3
TFMX_YM_TONE_LO_C               equ     18                                  ; reg 4
TFMX_YM_TONE_HI_C               equ     22                                  ; reg 5
TFMX_YM_NOISE_GEN               equ     26                                  ; reg 6
TFMX_YM_CHANS_ON_OFF            equ     30                                  ; reg 7
TFMX_YM_VOL_A                   equ     34                                  ; reg 8
TFMX_YM_VOL_B                   equ     38                                  ; reg 9
TFMX_YM_VOL_C                   equ     42                                  ; reg 10

; ---- module header ----
TFMX_HDR_NUM_FSEQ               equ     4                                   ; .w frequency sequences - 1
TFMX_HDR_NUM_VSEQ               equ     6                                   ; .w volume sequences - 1
TFMX_HDR_NUM_PATTERNS           equ     8                                   ; .w patterns - 1
TFMX_HDR_NUM_STEPS              equ     10                                  ; .w track steps - 1
TFMX_HDR_PATTERN_SIZE           equ     12                                  ; .w bytes per pattern
TFMX_HDR_NUM_SUBSONGS           equ     16                                  ; .w subsongs - 1
TFMX_HDR_SIZE                   equ     32

TFMX_SEQ_SIZE                   equ     64                                  ; frequency / volume sequence size
TFMX_VSEQ_HEADER_SIZE           equ     5                                   ; volume sequence header
TFMX_TRACK_STEP_SIZE            equ     12                                  ; 3 voices * 4 bytes

; ---- sequence commands ----
TFMX_SEQ_LOOP                   equ     $E0                                 ; ,pos   both sequences
TFMX_SEQ_END                    equ     $E1                                 ;        both sequences
TFMX_SEQ_RETRIGGER              equ     $E2                                 ;        restart the volume sequence
TFMX_SEQ_VIBRATO                equ     $E3                                 ; ,s,d   vibrato speed/depth
TFMX_SEQ_TONE_NOISE             equ     $E4                                 ; ,n     tone + noise (mode 0)
TFMX_SEQ_NOISE                  equ     $E5                                 ;        noise only   (mode 1)
TFMX_SEQ_TONE                   equ     $E6                                 ;        tone only    (mode 2)
TFMX_SEQ_SET                    equ     $E7                                 ; ,n     switch to frequency sequence n
TFMX_SEQ_WAIT                   equ     $E8                                 ; ,n     both sequences
TFMX_SEQ_BUZZER                 equ     $E9                                 ; ,p     hardware envelope

; ---- track step effects (high nibble of byte +3) ----
TFMX_STEP_FX_SPEED              equ     $E0                                 ; $Ex: speed x
TFMX_STEP_FX_VOLUME             equ     $F0                                 ; $Fx: attenuation x

; ---- pattern ----
TFMX_NOTE_END_PATTERN           equ     1                                   ; note value that ends a pattern
TFMX_INFO_INSTRUMENT            equ     $1F                                 ; info bits 0-4: instrument
TFMX_INFO_PORTA_BIT             equ     5                                   ; info bit 5: portamento

; ---- voice structure (a0), TFMX_CH_SIZE bytes. tfmx_channel_a/b/c_dat are the ----
; ---- 3 music voices, tfmx_channel_sfx_dat is the sound effect voice      ----
TFMX_CH_TRACK_START             equ     0                                   ; .l this voice's column in the subsong's first track step
TFMX_CH_TRACK_POS               equ     4                                   ; .l offset of the next track step to read (n * 12)
TFMX_CH_NOTE                    equ     8                                   ; .b current note
TFMX_CH_NOTE_INFO               equ     9                                   ; .b info byte of that note (bit 5 = portamento)
TFMX_CH_VSEQ_PTR                equ     10                                  ; .l volume bytes of the instrument (after its header)
TFMX_CH_VSEQ_POS                equ     14                                  ; .l position in them
TFMX_CH_FSEQ_PTR                equ     18                                  ; .l frequency sequence
TFMX_CH_SOUND_TRANSPOSE         equ     22                                  ; .b instrument transpose (track step +2)
TFMX_CH_VSEQ_COUNT              equ     23                                  ; .b frames left before the next volume byte
TFMX_CH_VSEQ_SPEED              equ     24                                  ; .b frames per volume byte
TFMX_CH_VSEQ_WAIT               equ     25                                  ; .b volume sequence $E8 wait counter
TFMX_CH_FSEQ_WAIT               equ     26                                  ; .b frequency sequence $E8 wait counter
TFMX_CH_VIB_SPEED               equ     27                                  ; .b vibrato speed
TFMX_CH_VIB_DEPTH               equ     28                                  ; .b vibrato depth
TFMX_CH_VIB_POS                 equ     29                                  ; .b vibrato position, 0 to 2*depth
TFMX_CH_VIB_DELAY               equ     30                                  ; .b frames before the vibrato starts
TFMX_CH_PORTA_SPEED             equ     31                                  ; .b portamento speed (signed)
TFMX_CH_NOISE                   equ     32                                  ; .b noise value for this frame (0 = no change)
TFMX_CH_YM_CHANNEL              equ     33                                  ; .b YM channel 0-2 = its tone bit in the mixer
TFMX_CH_PATTERN_PTR             equ     34                                  ; .l current pattern
TFMX_CH_PATTERN_POS             equ     38                                  ; .l offset of the next row (2 bytes per row)
TFMX_CH_MODE                    equ     42                                  ; .b 0 = tone + noise, 1 = noise only, 2 = tone only
TFMX_CH_FSEQ_VALUE              equ     43                                  ; .b current frequency sequence value
TFMX_CH_TRANSPOSE               equ     44                                  ; .b note transpose (track step +1)
TFMX_CH_VOLUME                  equ     45                                  ; .b current volume from the volume sequence
TFMX_CH_VIB_FLAGS               equ     46                                  ; .b bit 0 toggles every frame, bit 5 = direction (1 = up),
                                                                            ;    bit 7 = every other frame (never set), bit 6 unused
                                                                            ;    47: unused
TFMX_CH_FSEQ_POS                equ     48                                  ; .l position in the frequency sequence
TFMX_CH_TRACK_END               equ     52                                  ; .l this voice's column in the step after the last one
TFMX_CH_PORTA_ACC               equ     56                                  ; .l portamento slide, 16.16 fixed point
TFMX_CH_ATTENUATION             equ     60                                  ; .b subtracted from the volume (track $Fx, fade)
                                                                            ;    61: unused
TFMX_CH_SIZE                    equ     62

; ---- tfmx_song_ctrl (a5 in tfmx_play) ----
TFMX_SONG_SPEED_COUNT           equ     0                                   ; .w frames left before the next row
TFMX_SONG_SPEED                 equ     2                                   ; .w frames per row
TFMX_SONG_STOPPED               equ     4                                   ; .w <> 0: music stopped

; ---- tfmx_mix_ctrl (a5 in tfmx_voice_update) ----
TFMX_MIX_MIXER                  equ     0                                   ; .b YM register 7, bits 0-5
TFMX_MIX_NOISE                  equ     1                                   ; .b YM register 6
TFMX_MIX_SFX_ON                 equ     2                                   ; .w 0 = no sound effect, else YM channel + 1

; ---- tfmx_fade_ctrl ----
TFMX_FADE_SPEED                 equ     0                                   ; .b 0 = no fade running
TFMX_FADE_COUNT                 equ     1                                   ; .b frames left before the next step
TFMX_FADE_STEP                  equ     2                                   ; .w 1-9: attenuation step, 10: stop
;==============================================================================

;==============================================================================
; Test program: plays subsong 1 until a key is pressed
;==============================================================================
test_start:
                                clr.l   -(a7)
                                move.w  #GEMDOS_SUPER,-(a7)
                                trap    #1
                                addq.l  #6,a7
                                move.l  d0,save_sp
                                move.w  sr,save_sr
                                move.w  #$2300,sr
                                bclr    #0,(CONTERM).w
                                moveq   #1,d0                               ; subsong 1
                                bsr     tfmx_init
                                move.l  #tfmx_play,(VBL_SLOT_1).w
wait_for_space:
                                cmp.b   #$39,(KBD_DAT).w
                                bne.b   wait_for_space
                                ; fade it away
                                moveq   #1,d0
                                bsr     tfmx_fade
                                ; and wait...
.wait_fade:
                                bsr     tfmx_playing
                                beq     .wait_fade
                                clr.l   (VBL_SLOT_1).w
                                moveq   #0,d0
                                bsr     tfmx_init
                                bset    #0,(CONTERM).w
                                move.w  (save_sr,pc),sr
                                move.l  (save_sp,pc),-(a7)
                                move.w  #GEMDOS_SUPER,-(a7)
                                trap    #1
                                addq.l  #6,a7
                                clr.w   -(a7)
                                trap    #1
save_sp:
                                ds.l    1
save_sr:
                                ds.w    1

;==============================================================================
; tfmx_fade - start a fade out of the music
; in:  d0.b = fade speed 0-31. The attenuation of the 3 voices grows by one
;      every speed+1 frames (see tfmx_play): 1, 2 ... 9, then the music is
;      stopped.
;==============================================================================
tfmx_fade:
                                move.l  a0,-(a7)
                                and.b   #$1F,d0
                                lea     (tfmx_fade_ctrl,pc),a0
                                move.b  d0,(a0)+                            ; TFMX_FADE_SPEED
                                move.b  d0,(a0)+                            ; TFMX_FADE_COUNT
                                sf.b    (a0)+                               ; high byte of TFMX_FADE_STEP
                                move.l  (a7)+,a0
                                rts

;==============================================================================
; tfmx_playing - retrieve playing state
; out: 0 = playing / 1 = stopped
;==============================================================================
tfmx_playing:
                                move.w  (tfmx_stopped,pc),d0
                                rts

;==============================================================================
; tfmx_sfx - start a sound effect
; in:  d0.b = sound effect number (entry in the module's effect table)
; The effect is played by a 4th voice (tfmx_channel_sfx_dat) on the YM
; channel tfmx_sfx_channel (always A here). It overrides the music on that
; channel until its volume sequence ends.
;==============================================================================
                            IFNE USE_SFX
tfmx_sfx:
                                lea     (tfmx_music_data,pc),a0
                                bsr.b   tfmx_setup_module                   ; find the module tables (once)
                                move.l  (tfmx_sfx_table_ptr,pc),a1
                                and.w   #$FF,d0
                                add.w   d0,d0
                                add.w   d0,d0                               ; 4 bytes per effect
                                add.w   d0,a1
                                lea     (tfmx_sfx_note,pc),a6
                                move.w  (a1)+,(a6)                          ; word 0: note (0 = no effect)
                                move.w  (a1)+,d0                            ; word 1: instrument
                                bra     tfmx_start_sfx
                            ENDC

;==============================================================================
; tfmx_init - start a subsong, or stop the music
; in:  d0.w = subsong number 1..n, or 0 to stop the music and mute the YM
;==============================================================================
tfmx_init:
                                lea     (tfmx_music_data,pc),a0
                                bsr.b   tfmx_setup_module                   ; find the module tables (once)
                                tst.w   d0
                                beq.b   .init_stop
                                move.l  (tfmx_subsongs_ptr,pc),a1
                                and.w   #$FF,d0
                                subq.w  #1,d0                               ; subsongs are numbered from 1
                                mulu.w  #6,d0                               ; 6 bytes per subsong
                                add.w   d0,a1
                                move.w  (a1)+,d0                            ; first track step
                                move.w  (a1)+,d1                            ; last track step
                                lea     (tfmx_song_ctrl,pc),a6
                                move.w  (a1),(a6)+                          ; TFMX_SONG_SPEED_COUNT = speed
                                move.w  (a1)+,(a6)+                         ; TFMX_SONG_SPEED = speed
                                bra     tfmx_start_song                     ; set up the voices for steps d0-d1
.init_stop:
                                lea     (tfmx_stopped,pc),a0
                                move.w  #1,(a0)                             ; music stopped,
                                bra     tfmx_play                           ; and one call mutes the YM now

;==============================================================================
; tfmx_setup_module - compute the addresses of the module tables
; in:  a0 = module
; Done only once (tfmx_module_ready). Keeps d0, trashes d6/d7/a1/a6.
;==============================================================================
tfmx_setup_module:
                                move.w  (tfmx_module_ready,pc),d7
                                bne.b   .setup_done                         ; already done
                                moveq   #0,d7
                                lea     (tfmx_pattern_size,pc),a6
                                move.w  (TFMX_HDR_PATTERN_SIZE,a0),(a6)
                                lea     (TFMX_HDR_SIZE,a0),a1               ; the tables follow the header:
                                lea     (tfmx_fseqs_ptr,pc),a6              ; frequency sequences
                                move.l  a1,(a6)
                                move.w  (TFMX_HDR_NUM_FSEQ,a0),d7
                                addq.w  #1,d7
                                asl.w   #6,d7                               ; * TFMX_SEQ_SIZE
                                add.l   d7,a1
                                lea     (tfmx_vseqs_ptr,pc),a6              ; volume sequences
                                move.l  a1,(a6)
                                move.w  (TFMX_HDR_NUM_VSEQ,a0),d7
                                addq.w  #1,d7
                                asl.w   #6,d7                               ; * TFMX_SEQ_SIZE
                                add.l   d7,a1
                                lea     (tfmx_patterns_ptr,pc),a6           ; patterns
                                move.l  a1,(a6)
                                move.w  (TFMX_HDR_NUM_PATTERNS,a0),d7
                                addq.w  #1,d7
                                move.w  (TFMX_HDR_PATTERN_SIZE,a0),d6
                                mulu.w  d6,d7                               ; * pattern size
                                add.l   d7,a1
                                lea     (tfmx_tracks_ptr,pc),a6             ; track table
                                move.l  a1,(a6)
                                move.w  (TFMX_HDR_NUM_STEPS,a0),d7
                                addq.w  #1,d7
                                mulu.w  #TFMX_TRACK_STEP_SIZE,d7
                                add.l   d7,a1
                                lea     (tfmx_subsongs_ptr,pc),a6           ; subsong table
                                move.l  a1,(a6)+
                                move.w  (TFMX_HDR_NUM_SUBSONGS,a0),d7
                                addq.w  #1,d7
                                mulu.w  #6,d7                               ; * 6 bytes
                                add.w   d7,a1
                                move.l  a1,(a6)+                            ; -> tfmx_sfx_table_ptr
                                move.w  #1,(a6)+                            ; -> tfmx_module_ready
                                clr.w   (a6)                                ; -> tfmx_sfx_channel (0 = sound effects on channel A)
.setup_done:
                                rts

;==============================================================================
; tfmx_play - the replayer: call it once per frame
;==============================================================================
tfmx_play:
                                ;---- fade out (only runs after a call to tfmx_fade) ----
                                lea     (tfmx_fade_ctrl,pc),a0
                                tst.b   (a0)                                ; TFMX_FADE_SPEED: 0 = no fade
                                beq.b   .play_no_fade
                                subq.b  #1,(TFMX_FADE_COUNT,a0)
                                bpl.b   .play_no_fade                       ; not the time for a step yet
                                move.b  (a0),(TFMX_FADE_COUNT,a0)           ; reload with TFMX_FADE_SPEED
                                addq.w  #1,(TFMX_FADE_STEP,a0)              ; next step
                                move.w  (TFMX_FADE_STEP,a0),d0
                                cmp.w   #15,d0
                                bne.b   .play_fade_level
                                clr.l   (a0)                                ; step 10: fade over
                                lea     (tfmx_stopped,pc),a0
                                move.w  #1,(a0)                             ; stop the music
                                bra.b   .play_no_fade
.play_fade_level:
                                lea     (tfmx_fade_table,pc),a0             ; steps 1-9: attenuation of
                                move.b  (a0,d0.w),d0                        ; the 3 music voices
                                lea     (tfmx_channel_a_dat+TFMX_CH_ATTENUATION,pc),a0
                                lea     (tfmx_channel_b_dat+TFMX_CH_ATTENUATION,pc),a1
                                lea     (tfmx_channel_c_dat+TFMX_CH_ATTENUATION,pc),a2
                                move.b  d0,(a0)
                                move.b  d0,(a1)
                                move.b  d0,(a2)
.play_no_fade:
                                lea     (ym_registers_data,pc),a6
                                lea     (tfmx_song_ctrl,pc),a5
                                tst.w   (TFMX_SONG_STOPPED,a5)
                                beq.b   .play_running
                                ;---- music stopped: keep the 3 channels silent ----
                                sf.b    (TFMX_YM_VOL_A,a6)
                                sf.b    (TFMX_YM_VOL_B,a6)
                                sf.b    (TFMX_YM_VOL_C,a6)
                                ; write registers 7 (mixer), 8, 9 and 10 (volumes)
                                movem.l (TFMX_YM_CHANS_ON_OFF-2,a6),d0-d3
                                movem.l d0-d3,(PSG_SEL).w
                                rts
.play_running:
                                ;---- song speed: a new row every TFMX_SONG_SPEED frames ----
                                subq.w  #1,(a5)+                            ; TFMX_SONG_SPEED_COUNT - 1, a5 -> TFMX_SONG_SPEED
                                bne.b   .play_voices
                                move.w  (a5),-(a5)                          ; TFMX_SONG_SPEED_COUNT = TFMX_SONG_SPEED,
                                                                            ; a5 = tfmx_song_ctrl again
                                lea     (tfmx_channel_a_dat,pc),a0
                                bsr     tfmx_read_row
                                lea     (tfmx_channel_b_dat,pc),a0
                                bsr     tfmx_read_row
                                lea     (tfmx_channel_c_dat,pc),a0
                                bsr     tfmx_read_row
.play_voices:
                                ;---- every frame: sequences and effects -> period and volume ----
                                lea     (tfmx_mix_ctrl,pc),a5               ; mixer and noise, built by the voices
                                lea     (tfmx_channel_a_dat,pc),a0
                                bsr     tfmx_voice_update                   ; d0.w = period, d1.b = volume
                                move.w  d0,-(a7)                            ; push the word and pop a byte:
                                move.b  (a7)+,(TFMX_YM_TONE_HI_A,a6)        ; its high byte (a7 stays even)
                                move.b  d0,(TFMX_YM_TONE_LO_A,a6)
                                move.b  d1,(TFMX_YM_VOL_A,a6)
                                lea     (tfmx_channel_b_dat,pc),a0
                                bsr     tfmx_voice_update
                                move.w  d0,-(a7)
                                move.b  (a7)+,(TFMX_YM_TONE_HI_B,a6)
                                move.b  d0,(TFMX_YM_TONE_LO_B,a6)
                                move.b  d1,(TFMX_YM_VOL_B,a6)
                                lea     (tfmx_channel_c_dat,pc),a0
                                bsr     tfmx_voice_update
                                move.w  d0,-(a7)
                                move.b  (a7)+,(TFMX_YM_TONE_HI_C,a6)
                                move.b  d0,(TFMX_YM_TONE_LO_C,a6)
                                move.b  d1,(TFMX_YM_VOL_C,a6)
                                ;---- sound effect: its voice overrides one YM channel ----
                            IFNE USE_SFX
                                move.w  (TFMX_MIX_SFX_ON,a5),d0             ; 0 = none, else channel + 1
                                beq.b   .play_write_ym
                                move.w  d0,-(a7)
                                lea     (tfmx_channel_sfx_dat,pc),a0
                                bsr     tfmx_voice_update                   ; (also sets its mixer bits / noise)
                                ; the effect stops when the volume byte after the next one is the
                                ; end marker: this frame is its last one
                                move.l  (TFMX_CH_VSEQ_PTR,a0),a1
                                add.l   (TFMX_CH_VSEQ_POS,a0),a1            ; -> next volume byte
                                cmp.b   #TFMX_SEQ_END,(1,a1)
                                bne.b   .play_sfx_regs
                                clr.w   (TFMX_MIX_SFX_ON,a5)
.play_sfx_regs:
                                move.w  (a7)+,d7                            ; channel + 1
                                lea     (tfmx_sfx_regmap,pc),a1
                                add.w   d7,d7
                                add.w   d7,d7                               ; 4 bytes per channel
                                add.w   d7,a1
                                moveq   #0,d6
                                move.b  (a1)+,d6                            ; offset of its period low byte
                                move.w  d0,-(a7)
                                move.b  d0,(a6,d6.w)
                                move.b  (a1)+,d6                            ; offset of its period high byte
                                move.b  (a7)+,(a6,d6.w)                     ; (high byte of d0, same trick)
                                move.b  (a1)+,d6                            ; offset of its volume
                                move.b  d1,(a6,d6.w)
.play_write_ym:
                            ENDC
                                ;---- mixer and noise, then all the registers to the YM ----
                                move.b  (a5)+,d7                            ; TFMX_MIX_MIXER: tone/noise bits
                                ori.b   #%11000000,d7                       ; I/O ports A and B = outputs
                                move.b  d7,(TFMX_YM_CHANS_ON_OFF,a6)
                                move.b  (a5)+,(TFMX_YM_NOISE_GEN,a6)        ; TFMX_MIX_NOISE
                                ; 11 longs "register, -, value, -": each long written at $FFFF8800+4n
                                ; selects the register ($FFFF8800) and writes the value ($FFFF8802),
                                ; as the PSG repeats every 4 bytes up to $FFFF88FF. So one movem.l
                                ; programs registers 0 to 10.
                                movem.l (a6),d0-d7/a0-a2
                                movem.l d0-d7/a0-a2,(PSG_SEL).w
                                rts

;==============================================================================
; tfmx_read_row - read the next pattern row of a voice
; in:  a0 = voice, a5 = tfmx_song_ctrl
; When the pattern is over, the voice first reads its next track step.
; A note starts its instrument: volume sequence, frequency sequence, vibrato.
;==============================================================================
tfmx_read_row:
                                moveq   #0,d5                               ; d5 = 0 all along
                                moveq   #6,d6                               ; d6 = shift for * TFMX_SEQ_SIZE
                                move.w  (tfmx_pattern_size,pc),d7
                                move.l  (TFMX_CH_PATTERN_PTR,a0),a1
                                add.l   (TFMX_CH_PATTERN_POS,a0),a1         ; a1 -> row to read
                                move.b  (a1),d0
                                and.w   #$7F,d0
                                cmp.w   #TFMX_NOTE_END_PATTERN,d0           ; "end of pattern" note
                                beq.b   .row_next_step
                                cmp.w   (TFMX_CH_PATTERN_POS+2,a0),d7       ; (low word) past the last row?
                                bne     .row_read_note
.row_next_step:
                                ;---- next track step of this voice ----
                                move.l  (TFMX_CH_TRACK_END,a0),a3
                                move.l  (TFMX_CH_TRACK_START,a0),a2
                                add.l   (TFMX_CH_TRACK_POS,a0),a2           ; a2 -> this voice's column of the step
                                cmp.l   a3,a2
                                bne.b   .row_read_step
                                move.l  d5,(TFMX_CH_TRACK_POS,a0)           ; after the last step, loop to
                                move.l  (a0),a2                             ; the first step of the subsong
.row_read_step:
                                moveq   #0,d1
                                move.b  (a2)+,d1                            ; +0 pattern number
                                move.b  (a2)+,(TFMX_CH_TRANSPOSE,a0)        ; +1 note transpose
                                move.b  (a2)+,(TFMX_CH_SOUND_TRANSPOSE,a0)  ; +2 instrument transpose
                                move.b  (a2),d0                             ; +3 effect
                                move.b  d0,d2
                                and.w   #$F0,d2
                                cmp.b   #TFMX_STEP_FX_VOLUME,d2             ; $Fx: attenuation x
                                bne     .row_not_volume
                                move.b  d0,d2
                                and.b   #$F,d2
                                move.b  d2,(TFMX_CH_ATTENUATION,a0)
                                bra.b   .row_set_pattern
.row_not_volume:
                                cmp.b   #TFMX_STEP_FX_SPEED,d2              ; $Ex: song speed x
                                bne.b   .row_set_pattern
                                move.b  d0,d2
                                and.w   #$F,d2
                                move.w  d2,(TFMX_SONG_SPEED,a5)
.row_set_pattern:
                                move.l  d5,(TFMX_CH_PATTERN_POS,a0)         ; row 0
                                mulu.w  d7,d1                               ; pattern * pattern size
                                move.l  (tfmx_patterns_ptr,pc),a3
                                add.l   d1,a3
                                move.l  a3,(TFMX_CH_PATTERN_PTR,a0)
                                add.l   #TFMX_TRACK_STEP_SIZE,(TFMX_CH_TRACK_POS,a0)
                                move.l  (TFMX_CH_PATTERN_PTR,a0),a1
                                add.l   (TFMX_CH_PATTERN_POS,a0),a1          ; a1 -> row 0
.row_read_note:
                                ;---- the row: note byte, info byte ----
                                move.b  (a1)+,d0                            ; note
                                move.b  d0,d1
                                and.w   #$7F,d1
                                beq     .row_done                           ; 0: empty row
                                move.l  d5,(TFMX_CH_PORTA_ACC,a0)           ; new note: no slide yet
                                move.b  d1,(TFMX_CH_NOTE,a0)
                                move.l  a1,a3                               ; portamento speed = info byte
                                tst.l   (TFMX_CH_PATTERN_POS,a0)            ; of the previous row, or of
                                bne.b   .row_porta                          ; the last row for row 0
                                add.w   d7,a3
.row_porta:
                                move.b  (-2,a3),(TFMX_CH_PORTA_SPEED,a0)
                                move.b  (a1),(TFMX_CH_NOTE_INFO,a0)         ; info
                                tst.b   d0
                                bmi.b   .row_done                           ; note bit 7: pitch change only
                                ;---- start the instrument (volume sequence) ----
                                move.b  (a1),d1
                                and.w   #TFMX_INFO_INSTRUMENT,d1
                                add.b   (TFMX_CH_SOUND_TRANSPOSE,a0),d1
                                move.l  (tfmx_vseqs_ptr,pc),a2
                                asl.w   d6,d1                               ; * TFMX_SEQ_SIZE
                                add.w   d1,a2                               ; a2 -> volume sequence
                                move.l  d5,(TFMX_CH_VSEQ_POS,a0)
                                move.b  (a2),(TFMX_CH_VSEQ_COUNT,a0)        ; +0 speed
                                move.b  (a2)+,(TFMX_CH_VSEQ_SPEED,a0)
                                move.b  (a2)+,d1                            ; +1 frequency sequence
                                and.w   #$FF,d1
                                move.b  (a2)+,(TFMX_CH_VIB_SPEED,a0)        ; +2 vibrato speed
                                move.b  #$40,(TFMX_CH_VIB_FLAGS,a0)         ; vibrato goes down first
                                move.b  (a2)+,d0                            ; +3 vibrato depth
                                move.b  d0,(TFMX_CH_VIB_DEPTH,a0)
                                move.b  d0,(TFMX_CH_VIB_POS,a0)             ; start in the middle
                                move.b  (a2)+,(TFMX_CH_VIB_DELAY,a0)        ; +4 vibrato delay
                                move.l  a2,(TFMX_CH_VSEQ_PTR,a0)            ; +5 the volume bytes
                                move.l  (tfmx_fseqs_ptr,pc),a2
                                asl.w   d6,d1                               ; * TFMX_SEQ_SIZE
                                add.w   d1,a2
                                move.l  a2,(TFMX_CH_FSEQ_PTR,a0)
                                move.l  d5,(TFMX_CH_FSEQ_POS,a0)
                                move.b  d5,(TFMX_CH_FSEQ_WAIT,a0)
                                move.b  d5,(TFMX_CH_VSEQ_WAIT,a0)
.row_done:
                                addq.l  #2,(TFMX_CH_PATTERN_POS,a0)         ; next row
                                rts

;==============================================================================
; tfmx_voice_update - per frame processing of a voice
; in:  a0 = voice, a5 = tfmx_mix_ctrl
; out: d0.w = YM tone period, d1.b = YM volume
;      the voice's tone/noise bits are set in TFMX_MIX_MIXER, and TFMX_MIX_NOISE is
;      updated if the voice sets a noise value
;==============================================================================
tfmx_voice_update:
                                moveq   #0,d7
                                move.b  d7,(TFMX_CH_NOISE,a0)               ; no noise change unless asked
                                ;---- frequency sequence ----
.fseq_wait:
                                tst.b   (TFMX_CH_FSEQ_WAIT,a0)
                                beq.b   .fseq_read
                                subq.b  #1,(TFMX_CH_FSEQ_WAIT,a0)           ; $E8 wait: keep the current value
                                bra     .vseq_wait
.fseq_read:
                                move.l  (TFMX_CH_FSEQ_PTR,a0),a1
                                add.l   (TFMX_CH_FSEQ_POS,a0),a1
.fseq_decode:
                                cmp.b   #TFMX_SEQ_END,(a1)                  ; $E1: keep the current value
                                beq     .vseq_wait
                                cmp.b   #TFMX_SEQ_LOOP,(a1)                 ; $E0,pos: go to pos (0-63)
                                bne.b   .fseq_test_e2
                                move.b  (1,a1),d0
                                and.l   #$3F,d0
                                move.l  d0,(TFMX_CH_FSEQ_POS,a0)
                                move.l  (TFMX_CH_FSEQ_PTR,a0),a1
                                add.l   d0,a1                               ; and decode the byte there
.fseq_test_e2:
                                cmp.b   #TFMX_SEQ_RETRIGGER,(a1)            ; $E2: restart the volume sequence
                                bne.b   .fseq_test_e9
                                clr.l   (TFMX_CH_VSEQ_POS,a0)
                                move.b  #1,(TFMX_CH_VSEQ_COUNT,a0)          ; first volume read in this frame
                                addq.l  #1,(TFMX_CH_FSEQ_POS,a0)
                                bra.b   .fseq_read
.fseq_test_e9:
                                cmp.b   #TFMX_SEQ_BUZZER,(a1)               ; $E9,p: YM hardware envelope
                                bne     .fseq_test_e7
                                move.b  #11,(PSG_SEL).w                     ; envelope period low = p
                                move.b  (1,a1),(PSG_DAT).w
                                move.b  #12,(PSG_SEL).w                     ; envelope period high = 0
                                sf.b    (PSG_DAT).w
                                move.b  #13,(PSG_SEL).w                     ; shape 10 = \/\/\/ triangle
                                move.b  #10,(PSG_DAT).w                     ; (also restarts the envelope)
                                addq.l  #2,(TFMX_CH_FSEQ_POS,a0)
                                bra     .fseq_read
.fseq_test_e7:
                                cmp.b   #TFMX_SEQ_SET,(a1)                  ; $E7,n: frequency sequence n
                                bne.b   .fseq_test_e8
                                move.b  (1,a1),d0
                                and.w   #$FF,d0
                                asl.w   #6,d0                               ; * SEQ_SIZE
                                move.l  (tfmx_fseqs_ptr,pc),a1
                                add.w   d0,a1
                                move.l  a1,(TFMX_CH_FSEQ_PTR,a0)
                                move.l  d7,(TFMX_CH_FSEQ_POS,a0)
                                bra     .fseq_decode
.fseq_test_e8:
                                cmp.b   #TFMX_SEQ_WAIT,(a1)                 ; $E8,n: wait n frames
                                bne.b   .fseq_test_e4
                                move.b  (1,a1),(TFMX_CH_FSEQ_WAIT,a0)
                                addq.l  #2,(TFMX_CH_FSEQ_POS,a0)
                                bra     .fseq_wait                          ; (this frame is the first one)
.fseq_test_e4:
                                cmp.b   #TFMX_SEQ_TONE_NOISE,(a1)           ; $E4,n: tone + noise, noise value n
                                bne.b   .fseq_test_e5
                                move.b  d7,(TFMX_CH_MODE,a0)                ; mode 0
                                move.b  (1,a1),(TFMX_CH_NOISE,a0)
                                addq.l  #2,(TFMX_CH_FSEQ_POS,a0)
                                bra.b   .fseq_value
.fseq_test_e5:
                                cmp.b   #TFMX_SEQ_NOISE,(a1)                ; $E5: noise only
                                bne.b   .fseq_test_e6
                                move.b  #1,(TFMX_CH_MODE,a0)                ; mode 1
                                addq.l  #1,(TFMX_CH_FSEQ_POS,a0)
                                bra     .fseq_wait
.fseq_test_e6:
                                cmp.b   #TFMX_SEQ_TONE,(a1)                 ; $E6: tone only
                                bne.b   .fseq_test_e3
                                move.b  #2,(TFMX_CH_MODE,a0)                ; mode 2
                                addq.l  #1,(TFMX_CH_FSEQ_POS,a0)
                                bra.b   .fseq_value
.fseq_test_e3:
                                cmp.b   #TFMX_SEQ_VIBRATO,(a1)              ; $E3,s,d: vibrato speed s, depth d
                                bne.b   .fseq_value
                                addq.l  #3,(TFMX_CH_FSEQ_POS,a0)
                                move.b  (1,a1),(TFMX_CH_VIB_SPEED,a0)
                                move.b  (2,a1),(TFMX_CH_VIB_DEPTH,a0)
.fseq_value:
                                ; a value byte. After $E3, $E4 and $E6 it is taken without testing
                                ; for commands. $00-$7F = transpose, $80-$FF = fixed note
                                move.l  (TFMX_CH_FSEQ_PTR,a0),a1
                                add.l   (TFMX_CH_FSEQ_POS,a0),a1
                                move.b  (a1),(TFMX_CH_FSEQ_VALUE,a0)
                                addq.l  #1,(TFMX_CH_FSEQ_POS,a0)
                                ;---- volume sequence ----
.vseq_wait:
                                tst.b   (TFMX_CH_VSEQ_WAIT,a0)
                                beq.b   .vseq_speed
                                subq.b  #1,(TFMX_CH_VSEQ_WAIT,a0)           ; $E8 wait: keep the current volume
                                bra.b   .get_period
.vseq_speed:
                                subq.b  #1,(TFMX_CH_VSEQ_COUNT,a0)          ; a new byte every TFMX_CH_VSEQ_SPEED frames
                                bne.b   .get_period
                                move.b  (TFMX_CH_VSEQ_SPEED,a0),(TFMX_CH_VSEQ_COUNT,a0)
.vseq_decode:
                                move.l  (TFMX_CH_VSEQ_PTR,a0),a1
                                add.l   (TFMX_CH_VSEQ_POS,a0),a1
                                move.b  (a1),d0
                                cmp.b   #TFMX_SEQ_WAIT,d0                   ; $E8,n: wait n frames
                                bne.b   .vseq_test_e1
                                addq.l  #2,(TFMX_CH_VSEQ_POS,a0)
                                move.b  (1,a1),(TFMX_CH_VSEQ_WAIT,a0)
                                bra.b   .vseq_wait
.vseq_test_e1:
                                cmp.b   #TFMX_SEQ_END,d0                    ; $E1: keep the current volume
                                beq.b   .get_period
                                cmp.b   #TFMX_SEQ_LOOP,d0                   ; $E0,pos: go to pos
                                bne.b   .vseq_volume
                                move.b  (1,a1),d0
                                and.l   #$3F,d0
                                subq.l  #TFMX_VSEQ_HEADER_SIZE,d0           ; pos counts the header bytes
                                move.l  d0,(TFMX_CH_VSEQ_POS,a0)
                                bra.b   .vseq_decode
.vseq_volume:
                                move.b  (a1),(TFMX_CH_VOLUME,a0)            ; new volume
                                addq.l  #1,(TFMX_CH_VSEQ_POS,a0)
                                ;---- note -> YM tone period ----
.get_period:
                                move.b  (TFMX_CH_FSEQ_VALUE,a0),d0
                                bmi.b   .fixed_note                         ; bit 7: fixed note
                                add.b   (TFMX_CH_NOTE,a0),d0                ; transpose + note
                                add.b   (TFMX_CH_TRANSPOSE,a0),d0           ; + track transpose
.fixed_note:
                                and.w   #$7F,d0
                                lea     (tfmx_ym_frequencies,pc),a1
                                add.w   d0,d0
                                move.w  d0,d1                               ; d1 = note * 2, for the vibrato
                                add.w   d0,a1
                                move.w  (a1),d0                             ; d0 = tone period
                                ;---- mixer bits of this channel (0 = on) ----
                                move.b  (TFMX_CH_YM_CHANNEL,a0),d3          ; tone bit = channel, noise bit = channel + 3
                                move.b  (TFMX_CH_MODE,a0),d2
                                and.l   #$F,d2
                                bne.b   .mode_1_or_2
                                bclr    d3,(a5)                             ; mode 0: tone on
                                addq.w  #3,d3
                                bclr    d3,(a5)                             ;         noise on
                                bra.b   .set_noise
.mode_1_or_2:
                                cmp.b   #1,d2
                                bne.b   .mode_2
                                bset    d3,(a5)                             ; mode 1: tone off
                                addq.w  #3,d3
                                bclr    d3,(a5)                             ;         noise on
                                move.b  (TFMX_CH_NOTE,a0),(TFMX_CH_NOISE,a0); the noise follows the pattern
                                                                            ; note (track transpose ignored)
                                move.b  (TFMX_CH_FSEQ_VALUE,a0),d4
                                bpl.b   .noise_relative
                                and.b   #$7F,d4                             ; bit 7: fixed noise value
                                move.b  d4,(TFMX_CH_NOISE,a0)
                                bra.b   .set_noise
.noise_relative:
                                add.b   d4,(TFMX_CH_NOISE,a0)               ; note + value
                                bra.b   .set_noise
.mode_2:
                                bclr    d3,(a5)                             ; mode 2: tone on
                                addq.w  #3,d3
                                bset    d3,(a5)                             ;         noise off
                                ;---- noise generator (one for the 3 channels) ----
.set_noise:
                                tst.b   (TFMX_CH_NOISE,a0)
                                beq.b   .vibrato                            ; 0: register 6 unchanged
                                move.b  (TFMX_CH_NOISE,a0),d3
                                and.b   #$1F,d3
                                eori.b  #$1F,d3                             ; period = 31 - value: a higher
                                move.b  d3,(TFMX_MIX_NOISE,a5)              ; value gives a higher noise
                                ;---- vibrato: triangle wave, period +/- depth ----
.vibrato:
                                move.b  (TFMX_CH_VIB_FLAGS,a0),d7
                                tst.b   (TFMX_CH_VIB_DELAY,a0)
                                beq.b   .vib_run
                                subq.b  #1,(TFMX_CH_VIB_DELAY,a0)           ; not started yet
                                bra.b   .vib_done
.vib_run:
                                move.b  d1,d5                               ; d5 = note * 2
                                move.b  (TFMX_CH_VIB_DEPTH,a0),d4
                                add.b   d4,d4                               ; d4 = 2 * depth (top of the wave)
                                move.b  (TFMX_CH_VIB_POS,a0),d1
                                tst.b   d7
                                bpl.b   .vib_step                           ; bit 7 clear: move every frame
                                btst    #0,d7                               ; bit 7 set: every other frame
                                bne.b   .vib_apply
.vib_step:
                                btst    #5,d7                               ; bit 5: direction
                                bne.b   .vib_up
                                sub.b   (TFMX_CH_VIB_SPEED,a0),d1           ; down
                                bcc.b   .vib_store
                                bset    #5,d7                               ; below 0: turn up
                                moveq   #0,d1
                                bra.b   .vib_store
.vib_up:
                                add.b   (TFMX_CH_VIB_SPEED,a0),d1           ; up
                                cmp.b   d4,d1
                                bcs.b   .vib_store
                                bclr    #5,d7                               ; reached 2 * depth: turn down
                                move.b  d4,d1
.vib_store:
                                move.b  d1,(TFMX_CH_VIB_POS,a0)
.vib_apply:
                                lsr.b   #1,d4                               ; depth
                                sub.b   d4,d1                               ; position - depth = -depth..+depth
                                bcc.b   .vib_scale
                                subi.w  #$100,d1                            ; negative: sign extend the byte
.vib_scale:                                                                 ; (high byte of d1 was 0)
                                ; periods double at each octave down, so below note 48 (C-5) the
                                ; offset is doubled once per octave: low notes get the same vibrato
                                ; width (in pitch) as the C-5 octave
                                add.b   #$A0,d5                             ; carry if note >= 48
                                bcs.b   .vib_add
.vib_scale_loop:
                                add.w   d1,d1
                                add.b   #$18,d5                             ; one octave (12 notes * 2) lower
                                bcc.b   .vib_scale_loop
.vib_add:
                                add.w   d1,d0                               ; period + vibrato
.vib_done:
                                eori.b  #1,d7                               ; bit 0 toggles every frame
                                move.b  d7,(TFMX_CH_VIB_FLAGS,a0)
                                ;---- portamento (info bit 5 of the note) ----
                                btst    #TFMX_INFO_PORTA_BIT,(TFMX_CH_NOTE_INFO,a0)
                                beq     .volume
                                move.b  (TFMX_CH_PORTA_SPEED,a0),d1
                                ext.w   d1                                  ; signed speed
                                ext.l   d1
                                move.l  (TFMX_CH_PORTA_ACC,a0),d2
                                moveq   #12,d3
                                asl.l   d3,d1                               ; * 4096 = speed/16 in 16.16 format
                                add.l   d1,d2
                                move.l  d2,(TFMX_CH_PORTA_ACC,a0)
                                swap    d2                                  ; integer part
                                sub.w   d2,d0                               ; period - slide: speed > 0 goes up
                                ;---- volume - attenuation, not below 0 ----
.volume:
                                move.b  (TFMX_CH_VOLUME,a0),d1
                                sub.b   (TFMX_CH_ATTENUATION,a0),d1
                                bpl.b   .volume_ok
                                moveq   #0,d1
.volume_ok:
                                rts

;==============================================================================
; tfmx_start_song - set up the 3 music voices for steps d0-d1
; in:  d0.w = first step, d1.w = last step (the song then loops to d0)
; The first step is read here; the first row is played after 'speed' frames.
;==============================================================================
tfmx_start_song:
                                lea     (tfmx_fade_ctrl,pc),a0
                                clr.l   (a0)                                ; cancel a running fade
                                move.w  d0,d7
                                mulu.w  #TFMX_TRACK_STEP_SIZE,d7            ; d7 = offset of the first step
                                move.w  d1,d6
                                addq.w  #1,d6
                                mulu.w  #TFMX_TRACK_STEP_SIZE,d6            ; d6 = offset of the step after the last
                                moveq   #3-1,d0                             ; 3 voices
                                lea     (tfmx_channel_a_dat,pc),a0
                                lea     (tfmx_empty_seq,pc),a1
                                lea     (tfmx_voice_channel,pc),a2
.start_voice:
                                move.l  a1,(TFMX_CH_VSEQ_PTR,a0)            ; silent sequences, no note
                                clr.l   (TFMX_CH_VSEQ_POS,a0)
                                sf.b    (TFMX_CH_VOLUME,a0)
                                sf.b    (TFMX_CH_NOTE,a0)
                                sf.b    (TFMX_CH_NOTE_INFO,a0)
                                move.l  a1,(TFMX_CH_FSEQ_PTR,a0)
                                clr.l   (TFMX_CH_FSEQ_POS,a0)
                                move.b  #1,(TFMX_CH_VSEQ_COUNT,a0)
                                move.b  #1,(TFMX_CH_VSEQ_SPEED,a0)
                                sf.b    (TFMX_CH_VSEQ_WAIT,a0)
                                sf.b    (TFMX_CH_FSEQ_WAIT,a0)
                                sf.b    (TFMX_CH_VIB_SPEED,a0)
                                sf.b    (TFMX_CH_VIB_DEPTH,a0)
                                sf.b    (TFMX_CH_VIB_POS,a0)
                                clr.w   (TFMX_CH_VIB_DELAY,a0)              ; and TFMX_CH_PORTA_SPEED
                                sf.b    (TFMX_CH_NOISE,a0)
                                move.b  (a2),d3                             ; YM channel of the voice,
                                and.l   #$F,d3
                                add.w   d3,d3
                                add.w   d3,d3                               ; * 4 = its column in a track step
                                move.b  (a2)+,(TFMX_CH_YM_CHANNEL,a0)
                                move.l  (tfmx_tracks_ptr,pc),(TFMX_CH_TRACK_START,a0)
                                move.l  (tfmx_tracks_ptr,pc),(TFMX_CH_TRACK_END,a0)
                                add.l   d6,(TFMX_CH_TRACK_END,a0)           ; TFMX_CH_TRACK_END = tracks
                                add.l   d3,(TFMX_CH_TRACK_END,a0)           ;   + (last + 1) * 12 + column
                                add.l   d7,(a0)                             ;   tracks + first * 12
                                add.l   d3,(a0)                             ;   + column
                                move.l  #TFMX_TRACK_STEP_SIZE,(TFMX_CH_TRACK_POS,a0) ; the first step is read now:
                                move.l  (a0),a3
                                move.b  (a3),d1                             ; +0 pattern
                                and.w   #$FF,d1
                                move.w  (tfmx_pattern_size,pc),d2
                                mulu.w  d1,d2
                                move.l  (tfmx_patterns_ptr,pc),a4
                                add.l   d2,a4
                                move.l  a4,(TFMX_CH_PATTERN_PTR,a0)
                                clr.l   (TFMX_CH_PATTERN_POS,a0)
                                move.b  #2,(TFMX_CH_MODE,a0)                ; tone only
                                move.b  (1,a3),(TFMX_CH_TRANSPOSE,a0)       ; +1 note transpose
                                sf.b    (TFMX_CH_FSEQ_VALUE,a0)
                                move.b  (2,a3),(TFMX_CH_SOUND_TRANSPOSE,a0) ; +2 instrument transpose
                                sf.b    (TFMX_CH_ATTENUATION,a0)
                                move.b  (3,a3),d1                           ; +3 effect: only $Fx is
                                and.w   #$F0,d1                             ;    handled here
                                cmp.w   #TFMX_STEP_FX_VOLUME,d1
                                bne     .start_no_volume
                                move.b  (3,a3),d1
                                and.b   #$F,d1
                                move.b  d1,(TFMX_CH_ATTENUATION,a0)
.start_no_volume:
                                sf.b    (TFMX_CH_VOLUME,a0)
                                clr.w   (TFMX_CH_PORTA_ACC,a0)              ; (integer part)
                                lea     (TFMX_CH_SIZE,a0),a0                ; next voice
                                dbra    d0,.start_voice
                                lea     (tfmx_song_ctrl,pc),a0
                                move.w  (TFMX_SONG_SPEED,a0),(a0)           ; TFMX_SONG_SPEED_COUNT = TFMX_SONG_SPEED
                                clr.w   (TFMX_SONG_STOPPED,a0)              ; play
                                rts

;==============================================================================
; tfmx_start_sfx - set up the sound effect voice
; in:  d0.w = instrument, tfmx_sfx_note = note (0: no effect)
; Same instrument start as in tfmx_read_row. TFMX_CH_MODE, TFMX_CH_TRANSPOSE and
; TFMX_CH_NOTE_INFO of this voice are never set: the mode stays 0 (tone + noise)
; or the one left by the previous effect, unless the frequency sequence
; sets it ($E4/$E5/$E6).
;==============================================================================
                            IFNE USE_SFX
tfmx_start_sfx:
                                move.w  (tfmx_sfx_channel,pc),d1            ; YM channel 0-2
                                move.w  (tfmx_sfx_note,pc),d2
                                beq     .sfx_done                           ; note 0: no effect
                                lea     (tfmx_channel_sfx_dat,pc),a0
                                lea     (tfmx_mix_ctrl,pc),a5
                                move.b  d2,(TFMX_CH_NOTE,a0)
                                move.b  d1,(TFMX_CH_YM_CHANNEL,a0)
                                sf.b    (TFMX_CH_SOUND_TRANSPOSE,a0)
                                moveq   #6,d6                               ; shift for * TFMX_SEQ_SIZE
                                moveq   #0,d5
                                and.w   #TFMX_INFO_INSTRUMENT,d0
                                move.l  (tfmx_vseqs_ptr,pc),a2
                                asl.w   d6,d0
                                add.w   d0,a2                               ; a2 -> volume sequence
                                move.l  d5,(TFMX_CH_VSEQ_POS,a0)
                                move.b  (a2),(TFMX_CH_VSEQ_COUNT,a0)        ; +0 speed
                                move.b  (a2)+,(TFMX_CH_VSEQ_SPEED,a0)
                                move.b  (a2)+,d0                            ; +1 frequency sequence
                                and.w   #$FF,d0
                                move.b  (a2)+,(TFMX_CH_VIB_SPEED,a0)        ; +2 vibrato speed
                                moveq   #0,d2
                                move.b  #$40,(TFMX_CH_VIB_FLAGS,a0)
                                move.b  (a2)+,d2                            ; +3 vibrato depth
                                move.b  d2,(TFMX_CH_VIB_DEPTH,a0)
                                move.b  d2,(TFMX_CH_VIB_POS,a0)
                                move.b  (a2)+,(TFMX_CH_VIB_DELAY,a0)        ; +4 vibrato delay
                                move.l  a2,(TFMX_CH_VSEQ_PTR,a0)            ; +5 the volume bytes
                                move.l  (tfmx_fseqs_ptr,pc),a2
                                asl.w   d6,d0
                                add.w   d0,a2
                                move.l  a2,(TFMX_CH_FSEQ_PTR,a0)
                                move.l  d5,(TFMX_CH_FSEQ_POS,a0)
                                sf.b    (TFMX_CH_VSEQ_WAIT,a0)
                                sf.b    (TFMX_CH_FSEQ_WAIT,a0)
                                addq.w  #1,d1
                                move.w  d1,(TFMX_MIX_SFX_ON,a5)             ; effect on: channel + 1
.sfx_done:
                                rts
                            ENDC

;==============================================================================
; REPLAYER DATA
;==============================================================================
; Silent sequence: at song start, both sequences of each voice point here.
; As volumes: one frame at volume 1, then 0. As frequency sequence: +1 then 0.
tfmx_empty_seq:
                                dc.b    1,0,0,0,0,0,0,TFMX_SEQ_END
; YM channel of music voices 0, 1, 2 (+ a pad byte)
tfmx_voice_channel:
                                dc.b    0,1,2,0
; YM register shadow, one long per register for the movem.l in tfmx_play:
;   byte 0 = register number -> select register $FFFF8800
;   byte 2 = value           -> data register   $FFFF8802
;   bytes 1 and 3 go to odd addresses, which the YM ignores (it is wired
;   to the high byte of the data bus). TFMX_YM_* = offsets of the values.
ym_registers_data:
                                dc.b    0,0,0,0                             ; reg 0  channel A period, low 8 bits
                                dc.b    1,1,0,0                             ; reg 1  channel A period, high 4 bits
                                dc.b    2,2,0,0                             ; reg 2  channel B period, low
                                dc.b    3,3,0,0                             ; reg 3  channel B period, high
                                dc.b    4,4,0,0                             ; reg 4  channel C period, low
                                dc.b    5,5,0,0                             ; reg 5  channel C period, high
                                dc.b    6,6,0,0                             ; reg 6  noise period
                                dc.b    7,7,$FF,$FF                         ; reg 7  mixer
                                dc.b    8,8,0,0                             ; reg 8  channel A volume
                                dc.b    9,9,0,0                             ; reg 9  channel B volume
                                dc.b    10,10,0,0                           ; reg 10 channel C volume
; Where the sound effect writes its period and volume, by TFMX_MIX_SFX_ON value:
; offsets in ym_registers_data of period low, period high, volume
                            IFNE USE_SFX
tfmx_sfx_regmap:
                                dc.b    0,0,0,0                                             ; 0 = no effect
                                dc.b    TFMX_YM_TONE_LO_A,TFMX_YM_TONE_HI_A,TFMX_YM_VOL_A,0 ; channel A
                                dc.b    TFMX_YM_TONE_LO_B,TFMX_YM_TONE_HI_B,TFMX_YM_VOL_B,0 ; channel B
                                dc.b    TFMX_YM_TONE_LO_C,TFMX_YM_TONE_HI_C,TFMX_YM_VOL_C,0 ; channel C
                            ENDC
; Song control (offsets TFMX_SONG_*)
tfmx_song_ctrl:
tfmx_speed_count:
                                dc.w    4                                   ; TFMX_SONG_SPEED_COUNT
tfmx_speed:
                                dc.w    4                                   ; TFMX_SONG_SPEED
tfmx_stopped:
                                dc.w    0                                   ; TFMX_SONG_STOPPED
; The voices (offsets TFMX_CH_*).
tfmx_channel_a_dat:
                                dcb.b   TFMX_CH_SIZE,0
tfmx_channel_b_dat:
                                dcb.b   TFMX_CH_SIZE,0
tfmx_channel_c_dat:
                                dcb.b   TFMX_CH_SIZE,0
tfmx_channel_sfx_dat:
                                dcb.b   TFMX_CH_SIZE,0
; Module tables, set by tfmx_setup_module
tfmx_pattern_size:
                                dc.w    64,0                                ; bytes per pattern (+ an unused word)
tfmx_patterns_ptr:
                                dc.l    0
tfmx_fseqs_ptr:
                                dc.l    0                                   ; frequency sequences
tfmx_vseqs_ptr:
                                dc.l    0                                   ; volume sequences
tfmx_tracks_ptr:
                                dc.l    0                                   ; track table
; Mixer and noise shadows + sound effect state (offsets TFMX_MIX_*)
tfmx_mix_ctrl:
                                dc.b    0                                   ; TFMX_MIX_MIXER
                                dc.b    0                                   ; TFMX_MIX_NOISE
                            IFNE USE_SFX
                                dc.w    0                                   ; TFMX_MIX_SFX_ON
tfmx_sfx_note:
                                dc.w    0                                   ; note of the effect being started
                            ENDC
; YM tone periods for notes 0-95 (C-1 to B-8): period = 125000 / frequency
tfmx_ym_frequencies:
                                dc.w    $EEE,$E17,$D4D,$C8E,$BD9,$B2F,$A8E,$9F7,$967,$8E0,$861,$7E8   ; C-1 (32.7 Hz)
                                dc.w    $777,$70B,$6A6,$647,$5EC,$597,$547,$4FB,$4B3,$470,$430,$3F4   ; C-2
                                dc.w    $3BB,$385,$353,$323,$2F6,$2CB,$2A3,$27D,$259,$238,$218,$1FA   ; C-3
                                dc.w    $1DD,$1C2,$1A9,$191,$17B,$165,$151,$13E,$12C,$11C,$10C,$FD    ; C-4
                                dc.w    $EE,$E1,$D4,$C8,$BD,$B2,$A8,$9F,$96,$8E,$86,$7E               ; C-5 (523 Hz)
                                dc.w    $77,$70,$6A,$64,$5E,$59,$54,$4F,$4B,$47,$43,$3F               ; C-6
                                dc.w    $3B,$38,$35,$32,$2F,$2C,$2A,$27,$25,$23,$21,$1F               ; C-7
                                dc.w    $1D,$1C,$1A,$19,$17,$16,$15,$13,$12,$11,$10,$F                ; C-8
; Fade out: attenuation of the 3 voices for fade steps 1 to 15
tfmx_fade_table:
                                dc.b    0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
; Fade control (offsets TFMX_FADE_*)
tfmx_fade_ctrl:
                                dc.b    0                                   ; TFMX_FADE_SPEED
                                dc.b    0                                   ; TFMX_FADE_COUNT
                                dc.w    0                                   ; TFMX_FADE_STEP
tfmx_subsongs_ptr:
                                dc.l    0                                   ; subsong table
tfmx_sfx_table_ptr:
                                dc.l    0                                   ; sound effect table
tfmx_module_ready:
                                dc.w    0                                   ; <> 0: tables found
tfmx_sfx_channel:
                                dc.w    0                                   ; YM channel for the effects (0 = A)

;==============================================================================
; THE MODULE
;==============================================================================
tfmx_music_data:
;                                incbin  "astaroth_ingame.tfmx"
;                                incbin  "astaroth_title.tfmx"
;                                incbin  "big_sprite_demo.tfmx"
;                                incbin  "circus_attractions.tfmx"
;                                incbin  "color_shock_2.tfmx"
;                                incbin  "cuddly_demos_menu.tfmx"
;                                incbin  "equinox.tfmx"
;                                incbin  "equinox_in_transbeauce_1.tfmx"
;                                incbin  "grand_monster_slam.tfmx"
;                                incbin  "lap_00.tfmx"
;                                incbin  "lap_01.tfmx"
;                                incbin  "lap_02.tfmx"
;                                incbin  "lap_03.tfmx"
;                                incbin  "lap_04.tfmx"
;                                incbin  "lap_05.tfmx"
;                                incbin  "lap_06.tfmx"
;                                incbin  "lap_07.tfmx"
;                                incbin  "lap_08.tfmx"
;                                incbin  "lap_09.tfmx"
;                                incbin  "lap_10.tfmx"
;                                incbin  "lap_11.tfmx"
;                                incbin  "lap_12.tfmx"
;                                incbin  "lap_13.tfmx"
;                                incbin  "lap_14.tfmx"
;                                incbin  "lap_15.tfmx"
;                                incbin  "lap_16.tfmx"
                                incbin  "m_demo1_1.tfmx"
;                                incbin  "m_demo1_2.tfmx"
;                                incbin  "m_demo1_3.tfmx"
;                                incbin  "m_demo1_4.tfmx"
;                                incbin  "m_demo1_5.tfmx"
;                                incbin  "maestro_1.tfmx"
;                                incbin  "maestro_2.tfmx"
;                                incbin  "megaball_demo.tfmx"
;                                incbin  "mm_music_demo_charts.tfmx"
;                                incbin  "multi_color_display_1.tfmx"
;                                incbin  "multi_color_display_2.tfmx"
;                                incbin  "reset_demo.tfmx"
;                                incbin  "roll_out.tfmx"
;                                incbin  "sowatt_menu.tfmx"
;                                incbin  "whos_that_girl.tfmx"
;                                incbin  "zarjaz_mamacamel.tfmx"

                                end
