; SID Sound Samples
; 6/16/25
;

SB = $D400
VIC_RASTER_LINE = $D012

        * = $c000

        lda #147
        jsr $e544
        jsr Panel
        jsr wave_mes
        ;jsr NumValue

        lda #15
        sta SB+24       ; Volume
        lda #119
        sta SB          ; Voice 1 Freq control (low)
        lda #7
        sta SB+1        ; Voice 1 Freq control (high)
        lda #128
        sta SB+2        ; Voice 1 Pulse Waveform width (low)
        lda #10
        sta SB+3        ; Voice 1 Pulse Waveform width (high)
        lda #58
        sta SB+5        ; Voice 1 Attack / Decay
        lda #197
        sta SB+6        ; Voice 1 Sustain control
        lda #129
        sta SB+4        ; Voice 1 Control (waveform bit setting)
        lda #143
        sta SB+7        ; Voice 2 Control (low)
        lda #10
        sta SB+8        ; Voice 2 Control (high)
        lda #128
        sta SB+9        ; Voice 1 Freq control (high)
        lda #10
        sta SB+10       ; Voice 2 Pulse waveform (low)
        lda #58
        sta SB+12       ; Voice 2 Attack / Decay
        lda #48
        sta SB+13       ; Voice 2 Sustain / Release
        lda #116
        sta SB+11       ; Voice 2 Control Register
        
        lda #2
        sta $d020
        lda #0
        sta $d021

        ldx #50
countdown
        jsr WaitFewSecs

        txa
        dex
        bne countdown

        lda #0
        sta SB+24

        jsr TPSounds

        rts
        
WaitFewSecs
        jsr WaitFrame
;        nop     
;        nop
;        nop
        rts

WaitFrame
        lda VIC_RASTER_LINE         ; fetch the current raster line
        cmp #$F8                    ; wait here till l        
        beq WaitFrame           
        
WaitStep2
        lda VIC_RASTER_LINE
        cmp #$F8
        bne WaitStep2
        rts

; Waveform / Triangular / Pulse / Noise
TPSounds
        lda #15
        sta SB+24                   ; Volume
        lda #12
        sta SB+5                    ; Voice 1 Attack / Decay

        ;jsr WaitFrame

        lda #248
        sta SB+6                    ; Voice 1 Sustain / Release

        ldy #100
lp_tpsound
        tya

        sta SB
        sta 53280

        lda #33                     ; Select from 17,33,65, or 12
        sta SB+4                    ; Voice 1 Control Register
        lda #17
        sta SB+11                   ; Voice 2 Control Register

        sty wvresult
        jsr NumValue
        
        iny
        jsr WaitFrame
        ;jsr TreatVolume

        cpy #245
        bne lp_tpsound

        lda #128
        sta SB+5                     ; Voice 1 Attack / Decay
        sta SB+12                    ; Voice 2 Attack / Decay
        ;jsr WaitFrame
        sta SB+6                     ; Voice 1 Sustain / Release
        sta SB+13                    ; Voice 2 Sustain / Release
        rts
        
TreatVolume
        lda #100
        lsr
        lsr
        lsr
        lsr
        sec
        sbc #1
        sta SB+24
        rts

NumValue
        lda #<1198
        sta 251
        lda #>1198
        sta 252

        lda #<55470
        sta 253
        lda #>55470
        sta 254

        sed
        clc
        lda wvnumber                                   ; increase score
        adc #1                                          ; 01,00
        sta wvnumber
        lda wvnumber+1
        adc #0                                          ;00, 00
        sta wvnumber+1
        lda wvnumber+2
        adc #0
        sta wvnumber+2
        cld
        jsr display
        rts

display
        ldy #12          ;screen offset
        ldx #0          ; score byte index
sloop
        lda wvnumber,x
        ;pha
        sta savenum
        and #$0f        ; count between 0-9
        jsr plotdigit

        ;pla
        lda savenum
        lsr a
        lsr a
        lsr a
        lsr a
        jsr plotdigit
        inx
        cpx #3
        bne sloop
        rts

plotdigit
        clc
        adc #48                       ; write '0' zero on screen
        sta (251),y                   ; write the character code
        lda #2                             ; set the color to blue
        sta (253),y                   ; write the color to color ram  
        dey
        rts

Panel
        lda #<1070
        sta 251
        sta loresult
        lda #>1070
        sta 252

        ldx #18                          ; Was 20
start
        ldy #0
draw
        lda #91
        sta (251),y                     ; 1075 ++
        iny
        cpy #26                         ; = 1091
        bne draw
        lda loresult                    ; old = 1075 (51, 4)
        clc
        adc #40                         ; 51 + 40 = 91
        sta 251                         ; value: (251)=91   (91, 4)
        sta loresult

        lda 252                         ; Has the carry bit been
        bcc cont                        ; set in 252?
        inc 252                         ; Yes, increment high byte
cont
        dex
        bne start
        rts

wave_mes
        ldx #0
lp_wave
        lda waveform,x
        sec
        sbc #64
        sta waveform,x
        sta 1195,x
        lda #7
        sta 1195 + 54272,x
        inx
        cpx #8
        bne lp_wave
        rts


loresult  byte 0
wvnumber  byte 0,0,0,0,0
wvresult byte 0

savenum byte 0
        
waveform byte "waveform"

