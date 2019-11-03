
.label scrolltext = $1000
* = scrolltext "scrolltext"
.encoding "screencode_mixed"
.text "moonspire preview was quickly trained by o'dog of laxity!  fast hellos to: no, ons, a4, afl, myd, ata, ex, scs+trc, hf...      "
.byte $00
                
.label charset = $0800
* = charset "charset"
	.import binary "charset.bin"

.label screenmap = $0c00
* = screenmap "screenmap"
	.import binary "screenmap.bin"


* = $0a00 "maincode"

	sei 
	lda #$fe
	sta $0319 
	lda #$c1
	sta $0318 
	sta $d020                          // border color
	sta $d021                          // background color 0
	ldx #$1f
	jsr $e5aa
	sta $02 
	sta Point1+1 
	sta $d011                          // control register 1
//------------------------------
!:
//------------------------------
	sta $d800,x 
	sta $d900,x 
	sta $da00,x 
	sta $db00,x 
	sta $0400,x 
	sta $0500,x 
	sta $0600,x 
	inx 
	bne !-
	bit $1000 
	ldy #$0f
	ldx #$07
//------------------------------
!:
	lda #$00
	sta $d027,x                          // sprite 0 color
	lda #$48
	sta $cfff,y 
	lda SpritePos,x 
	sta $d000,y                          // sprite 0 x pos
	dey 
	dey 
	dex 
	bpl !-
	stx $d010                          // sprites 0-7 msb of x coordinate
	stx $d015                          // sprite display enable
	stx $d01d                          // sprites expand 2x horizontal (x)
	lda #$35
	sta $d018                          // memory control register
	jsr Initscrolltext
//------------------------------
mainloop:
//------------------------------
	lda #$fb
//------------------------------
!:
//------------------------------

	cmp $d012                          // raster position
	bne !-
	lda #$ef
	cmp $dc01                          // data port b (keyboard, joystick, paddles)
	bne notspace
	jmp Exitintro
//------------------------------
notspace:
//------------------------------
	lda #$1b
	sta $d011                          // control register 1
	lda #$32
	ldy #$46
	ldx #$10
	jsr setspritepos
	lda #$40
	ldy #$06
	ldx #$07
	jsr bottomsectionofscroller
	lda #$fe 							//puts the line at top and bottom of the scroller
	sta $0400 
	sta $067c 
	lda #$60
//------------------------------
!:
//------------------------------
	cmp $d012                          // raster position
	bne !-
	bit $1003 
	lda #$d1
	ldy #$e5
	ldx #$18
	jsr setspritepos
	ldy $02 
	dey 
	bpl scrollit
Point1:
	ldy #$00
	beq fetchnextchar 
	lda #$00
	sta Point1+1 
	beq dontchangescrolltexthighpt
//------------------------------
fetchnextchar:
//------------------------------
	lda ($bb),y         //get character
	tay 				 //put in y
	bne dontresetscrolltext  //if 0 reset scrolltext
	jsr Initscrolltext
	bne fetchnextchar
//------------------------------
dontresetscrolltext:
//------------------------------
	inc $bb 				//next character address
	bne dontchangescrolltexthighpt
	inc $bc 				//increase high memory part
//------------------------------
dontchangescrolltexthighpt:
//------------------------------
	ldx #$08
	tya 
	and #$20
	beq itsnotaspace //is it a space?
	ldx #$09
//------------------------------
itsnotaspace:
//------------------------------
	stx $d2 
	tya 
	and #$1f
	asl  
	asl  
	asl  
	sta $d1 
	cpy #$0d
	bne Skip1
	lda #$1e
	sta Point1+1 
//------------------------------
Skip1:
//------------------------------
	cpy #$17
	bne Skip2
	lda #$1f
	sta Point1+1 
//------------------------------
Skip2:
//------------------------------
	tya 
	ldy #$07
	ldx #$0c
//------------------------------
loop1:
//------------------------------
	cmp Table1,x 
	beq Skip3
	dex 
	bpl loop1
	bmi scrollit
//------------------------------
Skip3:
//------------------------------
	lda Table2,x 
	tay 
//------------------------------
scrollit:
//------------------------------
	lda ($d1),y 
	sta $0400 
	sty $02 
	lda #$40
	ldy #$04
	ldx #$01
	jsr bottomsectionofscroller
	jmp mainloop
//------------------------------
Initscrolltext:
//------------------------------
	lda #<scrolltext
	sta $bb 
	lda #>scrolltext
	sta $bc 
	rts 
//------------------------------
setspritepos:
//------------------------------
	stx $0ff8 
	inx 
	stx $0ff9 
	sta $d001                          // sprite 0 y pos
	sty $d003                          // sprite 1 y pos
	rts 
//------------------------------
bottomsectionofscroller:
//------------------------------
	sta $c1 
	ora #$03
	sta $c3 
	sty $c2 
	sty $c4 
//------------------------------
loop2:
//------------------------------
	ldy #$3c
	lda ($c1),y 
	ldy #$40
	sta ($c3),y 
	ldy #$39
//------------------------------
!:
//------------------------------
	lda ($c1),y 
	sta ($c3),y 
	dey 
	dey 
	dey 
	bpl !-
	lda $c1 
	sec 
	sbc #$40
	sta $c1 
	ora #$03
	sta $c3 
	lda $c2 
	sbc #$00
	sta $c2 
	sta $c4 
	dex 
	bpl loop2
	rts 
//------------------------------
Exitintro:
//------------------------------
	lda #$0d
//------------------------------
!:
//------------------------------
	cmp $d012                          // raster position
	bne !-
	lda $d011                          // control register 1
	bmi Exitintro
	lda #$00
	sta $d011                          // control register 1
	sta $d020                          // border color
	sta $d021                          // background color 0
	jsr $e544                         // clear screen
	ldx #$1f
	jsr $e5aa
	ldx #$27
//------------------------------
!:
//------------------------------
	lda #$01
	sta $d9e0,x 
	lda $0bd8,x 
	sta $05e0,x 
	dex 
	bpl !-
	ldx #$34
	stx $01 
//------------------------------
!:
//------------------------------
	lda Codetocopy,x 
	sta $0340,x 
	dex 
	bpl !-
	jmp $0340				//where it jumps on exit

Codetocopy:
	ldx #$00
//------------------------------
Exitcode:
	lda $1200,x 
	sta $0801,x 
	inx 
	bne Exitcode
	inc $0347 
	inc $0344 
	bne Exitcode
	lda #$37
	sta $01 
	cli 
	jmp $fce2                         // power-up reset entry

SpritePos:
        .byte $32,$46,$59,$6d,$81,$95,$a9,$bd

Table1:
            .byte $09,$0a,$1e,$1f,$21,$27,$28,$29,$2c,$2e,$31,$3a,$20

Table2:
			.byte $03,$05,$03,$03,$03,$04,$04,$04,$04,$03,$04,$03,$03                                                        
