;
; a3part-C.asm
;
; Part C of assignment #3
;
;
; Student name:
; Student ID:
; Date of completed work:
;
; **********************************
; Code provided for Assignment #3
;
; Author: Mike Zastre (2022-Nov-05)
;
; This skeleton of an assembly-language program is provided to help you 
; begin with the programming tasks for A#3. As with A#2 and A#1, there are
; "DO NOT TOUCH" sections. You are *not* to modify the lines within these
; sections. The only exceptions are for specific changes announced on
; Brightspace or in written permission from the course instruction.
; *** Unapproved changes could result in incorrect code execution
; during assignment evaluation, along with an assignment grade of zero. ***
;


; =============================================
; ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
; =============================================
;
; In this "DO NOT TOUCH" section are:
; 
; (1) assembler direction setting up the interrupt-vector table
;
; (2) "includes" for the LCD display
;
; (3) some definitions of constants that may be used later in
;     the program
;
; (4) code for initial setup of the Analog-to-Digital Converter
;     (in the same manner in which it was set up for Lab #4)
;
; (5) Code for setting up three timers (timers 1, 3, and 4).
;
; After all this initial code, your own solutions's code may start
;

.cseg
.org 0
	jmp reset

; Actual .org details for this an other interrupt vectors can be
; obtained from main ATmega2560 data sheet
;
.org 0x22
	jmp timer1

; This included for completeness. Because timer3 is used to
; drive updates of the LCD display, and because LCD routines
; *cannot* be called from within an interrupt handler, we
; will need to use a polling loop for timer3.
;
; .org 0x40
;	jmp timer3

.org 0x54
	jmp timer4

.include "m2560def.inc"
.include "lcd.asm"

.cseg
#define CLOCK 16.0e6
#define DELAY1 0.01
#define DELAY3 0.1
#define DELAY4 0.5

#define BUTTON_RIGHT_MASK 0b00000001	
#define BUTTON_UP_MASK    0b00000010
#define BUTTON_DOWN_MASK  0b00000100
#define BUTTON_LEFT_MASK  0b00001000

#define BUTTON_RIGHT_ADC  0x032
#define BUTTON_UP_ADC     0x0b0   ; was 0x0c3
#define BUTTON_DOWN_ADC   0x160   ; was 0x17c
#define BUTTON_LEFT_ADC   0x22b
#define BUTTON_SELECT_ADC 0x316

.equ PRESCALE_DIV=1024   ; w.r.t. clock, CS[2:0] = 0b101

; TIMER1 is a 16-bit timer. If the Output Compare value is
; larger than what can be stored in 16 bits, then either
; the PRESCALE needs to be larger, or the DELAY has to be
; shorter, or both.
.equ TOP1=int(0.5+(CLOCK/PRESCALE_DIV*DELAY1))
.if TOP1>65535
.error "TOP1 is out of range"
.endif

; TIMER3 is a 16-bit timer. If the Output Compare value is
; larger than what can be stored in 16 bits, then either
; the PRESCALE needs to be larger, or the DELAY has to be
; shorter, or both.
.equ TOP3=int(0.5+(CLOCK/PRESCALE_DIV*DELAY3))
.if TOP3>65535
.error "TOP3 is out of range"
.endif

; TIMER4 is a 16-bit timer. If the Output Compare value is
; larger than what can be stored in 16 bits, then either
; the PRESCALE needs to be larger, or the DELAY has to be
; shorter, or both.
.equ TOP4=int(0.5+(CLOCK/PRESCALE_DIV*DELAY4))
.if TOP4>65535
.error "TOP4 is out of range"
.endif

reset:
; ***************************************************
; **** BEGINNING OF FIRST "STUDENT CODE" SECTION ****
; ***************************************************
.def highdata=r25  
.def lowdata=r24
.def highbound=r1  
.def lowbound=r0
;stack
	ldi temp, low(RAMEND)
	out SPL, temp
	ldi temp, high(RAMEND)
	out SPH, temp

;for initializing the LCD display, 
	rcall lcd_init

;initalization for char/string/index
	ldi temp, ' '
	sts TOP_LINE_CONTENT, temp
	ldi temp, 0
	sts CURRENT_CHARSET_INDEX, temp
	sts CURRENT_CHAR_INDEX, temp

	
; Anything that needs initialization before interrupts
; start must be placed here.

; ***************************************************
; ******* END OF FIRST "STUDENT CODE" SECTION *******
; ***************************************************

; =============================================
; ====  START OF "DO NOT TOUCH" SECTION    ====
; =============================================

	; initialize the ADC converter (which is needed
	; to read buttons on shield). Note that we'll
	; use the interrupt handler for timer 1 to
	; read the buttons (i.e., every 10 ms)
	;
	ldi temp, (1 << ADEN) | (1 << ADPS2) | (1 << ADPS1) | (1 << ADPS0)
	sts ADCSRA, temp
	ldi temp, (1 << REFS0)
	sts ADMUX, r16

	; Timer 1 is for sampling the buttons at 10 ms intervals.
	; We will use an interrupt handler for this timer.
	ldi r17, high(TOP1)
	ldi r16, low(TOP1)
	sts OCR1AH, r17
	sts OCR1AL, r16
	clr r16
	sts TCCR1A, r16
	ldi r16, (1 << WGM12) | (1 << CS12) | (1 << CS10)
	sts TCCR1B, r16
	ldi r16, (1 << OCIE1A)
	sts TIMSK1, r16

	; Timer 3 is for updating the LCD display. We are
	; *not* able to call LCD routines from within an 
	; interrupt handler, so this timer must be used
	; in a polling loop.
	ldi r17, high(TOP3)
	ldi r16, low(TOP3)
	sts OCR3AH, r17
	sts OCR3AL, r16
	clr r16
	sts TCCR3A, r16
	ldi r16, (1 << WGM32) | (1 << CS32) | (1 << CS30)
	sts TCCR3B, r16
	; Notice that the code for enabling the Timer 3
	; interrupt is missing at this point.

	; Timer 4 is for updating the contents to be displayed
	; on the top line of the LCD.
	ldi r17, high(TOP4)
	ldi r16, low(TOP4)
	sts OCR4AH, r17
	sts OCR4AL, r16
	clr r16
	sts TCCR4A, r16
	ldi r16, (1 << WGM42) | (1 << CS42) | (1 << CS40)
	sts TCCR4B, r16
	ldi r16, (1 << OCIE4A)
	sts TIMSK4, r16

	sei

; =============================================
; ====    END OF "DO NOT TOUCH" SECTION    ====
; =============================================

; ****************************************************
; **** BEGINNING OF SECOND "STUDENT CODE" SECTION ****
; ****************************************************

start:	
	timer3:
		;checking if timer has reached top value
		in temp, TIFR3
		sbrs temp, OCF3A
		rjmp timer3  ;loop if not reached top

		;come here if top is reached, reset the bit
		ldi temp, 1<<OCF3A 
		out TIFR3, temp

		;check if button is pressed
		lds temp, BUTTON_IS_PRESSED
		cpi temp, 0x01
		breq star

		;display a - if not pressed
		ldi r16, 1 
		ldi r17, 15
		push r16 
		push r17 
		rcall lcd_gotoxy
		pop r17
		pop r16

		ldi r16, '-'
		push r16
		rcall lcd_putchar
		pop r16
		rjmp start

		;display a * if pressed
		star:
			ldi r16, 1 
			ldi r17, 15
			push r16 
			push r17 
			rcall lcd_gotoxy
			pop r17
			pop r16

			ldi r16, '*'
			push r16
			rcall lcd_putchar
			pop r16

		;clears screen 
		ldi r16, 1 
		ldi r17, 0
		push r16 
		push r17 
		rcall lcd_gotoxy
		pop r17
		pop r16

		ldi r16, ' '
		push r16
		rcall lcd_putchar
		pop r16

		ldi r16, ' '
		push r16
		rcall lcd_putchar
		pop r16

		ldi r16, ' '
		push r16
		rcall lcd_putchar
		pop r16

		ldi r16, ' '
		push r16
		rcall lcd_putchar
		pop r16

		;section which takes stored value and displays corresponding char
			lds temp, LAST_BUTTON_PRESSED
			cpi temp, 2
			breq rightchar

			lds temp, LAST_BUTTON_PRESSED
			cpi temp, 3
			breq upchar

			lds temp, LAST_BUTTON_PRESSED
			cpi temp, 4
			breq downchar

			lds temp, LAST_BUTTON_PRESSED
			cpi temp, 5
			breq leftchar

			rjmp timer3	

		;section to display actual char onto screen
		leftchar:
			ldi r16, 1 
			ldi r17, 0
			push r16 
			push r17 
			rcall lcd_gotoxy
			pop r17
			pop r16

			ldi r16, 'L'
			push r16
			rcall lcd_putchar
			pop r16

			rjmp start
				
		downchar:
			ldi r16, 1 
			ldi r17, 1
			push r16 
			push r17 
			rcall lcd_gotoxy
			pop r17
			pop r16

			ldi r16, 'D'
			push r16
			rcall lcd_putchar
			pop r16

			lds r30, TOP_LINE_CONTENT ;take char out and load into r30
			rcall displayfunction  ;calling function to display
			rjmp start

		upchar:
			ldi r16, 1 
			ldi r17, 2
			push r16 
			push r17 
			rcall lcd_gotoxy
			pop r17
			pop r16

			ldi r16, 'U'
			push r16
			rcall lcd_putchar
			pop r16

			lds r30, TOP_LINE_CONTENT
			rcall displayfunction
			rjmp start

		rightchar:
			ldi r16, 1 
			ldi r17, 3
			push r16 
			push r17 
			rcall lcd_gotoxy
			pop r17
			pop r16

			ldi r16, 'R'
			push r16
			rcall lcd_putchar
			pop r16

			rjmp start

		;display function for chars
		displayfunction:
			push r16
			push r17

			ldi r16, 0
			lds r17, CURRENT_CHAR_INDEX
			push r16 
			push r17 
			rcall lcd_gotoxy
			pop r17
			pop r16

			push r30 ;r30 holds char needed to display
			rcall lcd_putchar
			pop r30
			
			pop r17
			pop r16
			ret

timer1: ;check if button is pushed or not
	push highbound
	push lowbound
	push highdata
	push lowdata
	push temp
	push r23
	push r16
	push r18
	in r18, SREG
	push r18

	;initalize to 0
	ldi r23, 0
	sts BUTTON_IS_PRESSED, r23

	;all buttons to turn on
	ldi r16, low(901)
	mov lowbound, r16
	ldi r16, high(901)
	mov highbound, r16

	;checking ADCSRA
	checking:
		lds	r16, ADCSRA	
		ori r16, 0x40 
		sts	ADCSRA, r16
	
	;busy wait loop
	wait:
		lds r16, ADCSRA
		andi r16, 0x40
		brne wait 
		lds lowdata, ADCL ;contians data from button used for bounds
		lds highdata, ADCH

		clr r23
		cp lowdata, lowbound
		cpc highdata, highbound ;if the value in data is same or higher than 901 (bound) branch
		brsh done		
		ldi r23, 1
		sts BUTTON_IS_PRESSED, r23

		;checking if button was pressed then need to display characters
		clr r23
		lds temp, BUTTON_IS_PRESSED
		cpi temp, 1
		breq down ;start here to figure out which character to display
		rjmp done

		;if button is pressed, check what button
		down:
			;check against the value 352 
			ldi r16, low(BUTTON_DOWN_ADC)
			mov lowbound, r16
			ldi r16, high(BUTTON_DOWN_ADC)
			mov highbound, r16
			cp lowdata, lowbound
			cpc highdata, highbound
			brsh checking555

			;check against value 176 
			ldi r16, low(BUTTON_UP_ADC)
			mov lowbound, r16
			ldi r16, high(BUTTON_UP_ADC)
			mov highbound, r16
			cp lowdata, lowbound
			cpc highdata, highbound
			brsh downvalue 

			;check against value 50 
			ldi r16, low(BUTTON_RIGHT_ADC)
			mov lowbound, r16
			ldi r16, high(BUTTON_RIGHT_ADC)
			mov highbound, r16
			cp lowdata, lowbound
			cpc highdata, highbound
			brsh upvalue
			rjmp rightvalue

			;storing value needed to display 'D'
			downvalue:
			ldi r23, 4
			sts LAST_BUTTON_PRESSED, r23
			rjmp done

			;storing value needed to display 'U'
			upvalue:
			ldi r23, 3
			sts LAST_BUTTON_PRESSED, r23
			rjmp done

			;storing value needed to display 'R'
			rightvalue:
			ldi r23, 2
			sts LAST_BUTTON_PRESSED, r23
			rjmp done

			;checks against value 555
			checking555:
			ldi r16, low(BUTTON_LEFT_ADC)
			mov lowbound, r16
			ldi r16, high(BUTTON_LEFT_ADC)
			mov highbound, r16
			cp lowdata, lowbound
			cpc highdata, highbound
			brsh done ;do not need to display the select button so finish

			;storing value needed to display 'L'
			ldi r23, 5
			sts LAST_BUTTON_PRESSED, r23
			rjmp done

	done:
		pop r18
		out SREG, r18
		pop r18
		pop r16
		pop r23
		pop temp
		pop lowdata
		pop highdata
		pop lowbound
		pop highbound
		reti
	

; timer3:
;
; Note: There is no "timer3" interrupt handler as you must use
; timer3 in a polling style (i.e. it is used to drive the refreshing
; of the LCD display, but LCD functions cannot be called/used from
; within an interrupt handler).


timer4:
	push r20 ;counter for up/down
	push ZH
	push ZL
	push temp
	push r17
	push r19
	push r18
	in r18, SREG
	push r18

	ldi r20, 0 ;counters 
	ldi r19, 0 ;counters
	lds temp, BUTTON_IS_PRESSED
	cpi temp, 0x01 
	breq checkUDLR
	rjmp exit

	;if button is pressed check which one
	checkUDLR:
		lds temp, LAST_BUTTON_PRESSED
		cpi temp, 3 ;check if up 
		breq uploop
		cpi temp, 4 ;check if down
		breq downloop
		cpi temp, 5  ;check if left
		breq leftloop
		cpi temp, 2  ;check if right
		breq rightloop
		rjmp exit 
		
		;enter here to move over one index right on the screen
		rightloop:
		lds r20, CURRENT_CHAR_INDEX
		inc r20
		cpi r20, 16 ;if out of bounds roll over to index 0
		brne setup
		ldi r20, 0
		rjmp setup

		;enter here to move over one index left on the screen
		leftloop:
		lds r20, CURRENT_CHAR_INDEX
		dec r20
		cpi r20, -1 ;if out of bounds roll over to index 15
		brne setup
		ldi r20, 15

		;store new index
		setup:
		sts CURRENT_CHAR_INDEX, r20
		rjmp exit

		;goes up through the string 
		uploop:
		ldi ZH, high(AVAILABLE_CHARSET<<1) 
		ldi ZL, low(AVAILABLE_CHARSET<<1) 
		lds temp, CURRENT_CHARSET_INDEX
		inc temp ;moving to the the next char

		;loops until counter matches index, exit
		miniloop:
			lpm r17, Z+
			inc r19 ;counter
			cp r19, temp ;once counter matches new index, exit
			brne miniloop
		
		;stores char and index
		getout:
			sts CURRENT_CHARSET_INDEX, temp
			sts TOP_LINE_CONTENT, r17

			;checks if out of bounds
			lds temp, TOP_LINE_CONTENT
			cpi temp, 0x00 
			brne exit
		
			;if out of bounds we roll over
			outofbounds:
				ldi temp, 0x30
				sts TOP_LINE_CONTENT, temp
				ldi temp, 0
				sts CURRENT_CHARSET_INDEX, temp
				rjmp exit
			
		;goes down through the string
		downloop:
		ldi ZH, high(AVAILABLE_CHARSET<<1) 
		ldi ZL, low(AVAILABLE_CHARSET<<1) 

		lds temp, CURRENT_CHARSET_INDEX ;moving to the previous char
		dec temp
		;checks if index is out of bounds
		ldi r19, 0
		cpi temp, -1
		brne miniloop2

		;if out of bounds sets to correct char and index
		test:
			ldi temp, 17
			sts CURRENT_CHARSET_INDEX, temp
			ldi temp, 0x5F
			sts TOP_LINE_CONTENT, temp
			rjmp exit

		;loop through each char until we get to the one at the index we want
		miniloop2:
			lpm r17, Z+
			inc r19
			cp r19, temp
			brne miniloop2

		;after leave the loop, store char and the index
		getout2:
			sts CURRENT_CHARSET_INDEX, temp
			sts TOP_LINE_CONTENT, r17

		exit:
			pop r18
			out SREG, r18
			pop r18
			pop r19
			pop r17
			pop temp
			pop ZL
			pop ZH
			pop r20
			reti


; ****************************************************
; ******* END OF SECOND "STUDENT CODE" SECTION *******
; ****************************************************


; =============================================
; ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
; =============================================

; r17:r16 -- word 1
; r19:r18 -- word 2
; word 1 < word 2? return -1 in r25
; word 1 > word 2? return 1 in r25
; word 1 == word 2? return 0 in r25
;
compare_words:
	; if high bytes are different, look at lower bytes
	cp r17, r19
	breq compare_words_lower_byte

	; since high bytes are different, use these to
	; determine result
	;
	; if C is set from previous cp, it means r17 < r19
	; 
	; preload r25 with 1 with the assume r17 > r19
	ldi r25, 1
	brcs compare_words_is_less_than
	rjmp compare_words_exit

compare_words_is_less_than:
	ldi r25, -1
	rjmp compare_words_exit

compare_words_lower_byte:
	clr r25
	cp r16, r18
	breq compare_words_exit

	ldi r25, 1
	brcs compare_words_is_less_than  ; re-use what we already wrote...

compare_words_exit:
	ret

.cseg
AVAILABLE_CHARSET: .db "0123456789abcdef_", 0


.dseg
BUTTON_IS_PRESSED: .byte 1			; updated by timer1 interrupt, used by LCD update loop
LAST_BUTTON_PRESSED: .byte 1        ; updated by timer1 interrupt, used by LCD update loop

TOP_LINE_CONTENT: .byte 16			; updated by timer4 interrupt, used by LCD update loop
CURRENT_CHARSET_INDEX: .byte 16		; updated by timer4 interrupt, used by LCD update loop
CURRENT_CHAR_INDEX: .byte 1			; ; updated by timer4 interrupt, used by LCD update loop


; =============================================
; ======= END OF "DO NOT TOUCH" SECTION =======
; =============================================


; ***************************************************
; **** BEGINNING OF THIRD "STUDENT CODE" SECTION ****
; ***************************************************

.dseg

; If you should need additional memory for storage of state,
; then place it within the section. However, the items here
; must not be simply a way to replace or ignore the memory
; locations provided up above.


; ***************************************************
; ******* END OF THIRD "STUDENT CODE" SECTION *******
; 