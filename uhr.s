;Memory Map muss vor dem Kompilieren auf 0x40000000, 0x47FFFFFF READ WRITE gesetzt werden!
	AREA arrays, READWRITE
tab_reg space 4,0
	AREA MYCODE, CODE		; Bereich f�r den Programmcode
	ENTRY				; Programmstart
	EXPORT main			; main kann von anderem File verwendet werden (von startup_stm32f411xe.s)	

 ;Portdeklarationen - Jeder Port hat 12 Konfigurationsregister -> Offsetadressen
GPIOA equ 0x40020000	; Basisadresse Port A (16 Bit)
GPIOB equ 0x40020400	; Basisadresse Port B (16 Bit)
GPIOC equ 0x40020800	; Basisadresse Port C (16 Bit)
GPIOD equ 0x40020C00	; Basisadresse Port D (16 Bit)
GPIOE equ 0x40021000	; Basisadresse Port E (16 Bit)
GPIOH equ 0x40021C00	; Basisadresse Port H (16 Bit)
	
; Port-Offsetadressen - Adressen f�r je 4 Byte -> Konfigurationsregister
MODER   equ 0x00	; Modifikationsregister - 2 Bit/Portpin {input  ; output ; alternate Funktion ; analog mod}
OTYPER  equ 0x04	; Out-Put-Type-Register nur untere 16 Bit (1 Bit/Portpin) {push-pull ; open-drain}
OSPEEDR equ 0x08	; Out-Put-Speed-Register - 2 Bit/Portpin {low ; medium ; fast ; high } speed
PUPDR   equ 0x0C	; Pull-Up-Down-Register - 2 Bit/Portpin {no pull-up/down ; pull-up ; pull-down ; reserved} 
IDR     equ 0x10	; Input-Data-Register nur untere 16 Bit - read-only
ODR     equ 0x14	; Output-Data-Register nur untere 16 Bit - read and write
BSRR	equ 0x18	; Bit-Set/Reset-Register
LCKR	equ 0x1C	; configuration Lock Register
AFRL    equ 0x20	; Alternate Funktion Register Low
AFRH    equ 0x24	; Alternate Funktion Register High


rcc     equ 0x40023800	; Reset and Clock-Control-Register
RCC_AHB1ENR equ 0x30	; peripheral clock enable register -> Freigabe der Ports 


tab_seg7	DCB	0x3F,0x06,0x5B,0x4F,0x66,0x6D,0x7c,0x07
			DCB	0x7F,0x67,0x77,0x7C,0x39,0x5E,0x79,0x71

tab_str		DCB 0x0E,0x0D,0x0B,0x07

;-------------- Hauptprogramm ----------------------------------------------------------------
main	
	ldr R1,=rcc
	ldr R2,[R1,#RCC_AHB1ENR]
	orr R2,#0x7
	str R2,[R1,#RCC_AHB1ENR]
	
	
;Output-------------------------------------------------------------------
	ldr  R1,=GPIOC				
	mov  R2,#0x55555555			
	str  R2,[R1,#MODER]			
	mov  R2,#0x00000000			
	str  R2,[R1,#OTYPER]		
	
	ldr  R1,=GPIOB				
	mov  R2,#0x000000000    	
	str  R2,[R1,#MODER]			
	mov  R2,#0x00000000			
	str  R2,[R1,#PUPDR]			
	
	
	ldr	R3,=0x0 ;Sec1
	ldr	R4,=0x0 ;Sec10
	ldr	R5,=0x0 ;min1
	ldr	R6,=0x0 ;min10


loop

sec1
	;lsl  R8,R4,#4
	;orr  R8,R3
    ;mov  R9,R5
	;mov  R9,R5,lsl #8 ;min1
	;orr  R8,R9
	;mov  R9,R6,lsl #12 ;min10
	;orr  R8,R9
	

	
;	ldr R1,=GPIOB
;	ldr	R2,[R1,#IDR]
	
;	mov R8,#0x0
;	ands R8,R2,#0x2
;	bne	reset
	
;	mov R8,#0x0
;	and R8,R2,#00000001
;	cmp R8,#0x1
;	bne	sec1
	
	
	
	add  R3,#0x1
	ldr	 R7,=3270
	cmp  R3,#10
	beq	 sec10
	b wait

sec10
	mov R3,#0x0
	add R4,#0x1
	cmp R4,#6
	beq min1
	b	wait
	
min1
	mov R4,#0x0
	add R5,#0x1
	cmp R5,#10
	beq min10
	b	wait

min10
	mov R5,#0x0
	add R6,#0x1
	b	wait
	

wait
	mov R10,#0
	ldr R1,=tab_reg
	strb R3,[R1,#0]
	strb R4,[R1,#1]
	strb R5,[R1,#2]
	strb R6,[R1,#3]
jump
	ldr R1,=tab_str
	ldrb R9,[R1,R10]

	
	ldr R1,=tab_reg
	ldrb R8,[R1,R10]
	
	ldr R1,=tab_seg7
	ldrb R8,[R1,R8]
	
	cmp R10,#2
	bne weiter
	orr R8,#0x80
weiter
	add R8,R9,LSL#8
	
	ldr  R1,=GPIOC
	str  R8,[R1,#ODR]	
	
	ldr	R11,=300
wwait	
	subs R11,#0x1
	bne wwait

	cmp R10,#3
	beq end_wait
	add R10,#0x1
	b 	jump
	
end_wait
	mov R10,#0
	subs R7,#0x1
	bne wait
	b sec1
	
;reset
;	mov	R3,#0x0 ;Sec1
;	mov	R4,#0x0 ;Sec10
;	mov	R5,#0x0 ;min1
;	mov	R6,#0x0 ;min10
;	b sec1

	B loop		; Endlosschleife
	END		; End File

