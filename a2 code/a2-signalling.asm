; a2-signalling.asm
; CSC 230: Fall 2022
;
; Student name:
; Student ID:
; Date of completed work:
;
; *******************************
; Code provided for Assignment #2
;
; Author: Mike Zastre (2022-Oct-15)
;
 
; This skeleton of an assembly-language program is provided to help you
; begin with the programming tasks for A#2. As with A#1, there are "DO
; NOT TOUCH" sections. You are *not* to modify the lines within these
; sections. The only exceptions are for specific changes changes
; announced on Brightspace or in written permission from the course
; instructor. *** Unapproved changes could result in incorrect code
; execution during assignment evaluation, along with an assignment grade
; of zero. ****

.include "m2560def.inc"
.cseg
.org 0

; ***************************************************
; **** BEGINNING OF FIRST "STUDENT CODE" SECTION ****
; ***************************************************

	; initializion code will need to appear in this
    ; section
	
	;initializing the sp
	ldi r16, low(0x21ff)
	out SPL, r16
	ldi r17, high(0x21ff)
	out SPH, r17
	
	;initializing the ports
	ldi r19, 0xff
	sts DDRL, r19
	out DDRB, r19 

	



; ***************************************************
; **** END OF FIRST "STUDENT CODE" SECTION **********
; ***************************************************

; ---------------------------------------------------
; ---- TESTING SECTIONS OF THE CODE -----------------
; ---- TO BE USED AS FUNCTIONS ARE COMPLETED. -------
; ---------------------------------------------------
; ---- YOU CAN SELECT WHICH TEST IS INVOKED ---------
; ---- BY MODIFY THE rjmp INSTRUCTION BELOW. --------
; -----------------------------------------------------

	rjmp test_part_e
	; Test code


test_part_a:
	ldi r16, 0b00100001
	rcall set_leds
	rcall delay_long

	clr r16
	rcall set_leds
	rcall delay_long

	ldi r16, 0b00111000
	rcall set_leds
	rcall delay_short

	clr r16
	rcall set_leds
	rcall delay_long

	ldi r16, 0b00100001
	rcall set_leds
	rcall delay_long

	clr r16
	rcall set_leds

	rjmp end


test_part_b:
	ldi r17, 0b00101010
	rcall slow_leds
	ldi r17, 0b00010101
	rcall slow_leds
	ldi r17, 0b00101010
	rcall slow_leds
	ldi r17, 0b00010101
	rcall slow_leds

	rcall delay_long
	rcall delay_long

	ldi r17, 0b00101010
	rcall fast_leds
	ldi r17, 0b00010101
	rcall fast_leds
	ldi r17, 0b00101010
	rcall fast_leds
	ldi r17, 0b00010101
	rcall fast_leds
	ldi r17, 0b00101010
	rcall fast_leds
	ldi r17, 0b00010101
	rcall fast_leds
	ldi r17, 0b00101010
	rcall fast_leds
	ldi r17, 0b00010101
	rcall fast_leds

	rjmp end

test_part_c:
	ldi r16, 0b11111000
	push r16
	rcall leds_with_speed
	pop r16

	ldi r16, 0b11011100
	push r16
	rcall leds_with_speed
	pop r16

	ldi r20, 0b00100000
	test_part_c_loop:
	push r20
	rcall leds_with_speed
	pop r20
	lsr r20
	brne test_part_c_loop

	rjmp end


test_part_d:
	ldi r21, 'E'
	push r21
	rcall encode_letter
	pop r21
	push r25
	rcall leds_with_speed
	pop r25

	rcall delay_long

	ldi r21, 'A'
	push r21
	rcall encode_letter
	pop r21
	push r25
	rcall leds_with_speed
	pop r25

	rcall delay_long


	ldi r21, 'M'
	push r21
	rcall encode_letter
	pop r21
	push r25
	rcall leds_with_speed
	pop r25

	rcall delay_long

	ldi r21, 'H'
	push r21
	rcall encode_letter
	pop r21
	push r25
	rcall leds_with_speed
	pop r25

	rcall delay_long
	
	rjmp end


test_part_e:
	ldi r25, HIGH(WORD02 << 1)
	ldi r24, LOW(WORD02 << 1)
	rcall display_message
	rjmp end

end:
    rjmp end



; ****************************************************
; **** BEGINNING OF SECOND "STUDENT CODE" SECTION ****
; ****************************************************

set_leds:
	push r16
	push r18 ;mask
	push r19 ;copy of r16
	push r20 ;used for comparing
	push r21 
	push r22 ;portb
	push r23 ;portl
	push r24 ;counter

	;turning lights off 
	ldi r23, 0
	sts PORTL, r23
	ldi r22, 0
	out PORTB, r22

	ldi r18, 0b00000001 ;mask
	mov r19, r16 ;copy whats in r16 over 
	ldi r24, 7 ;counter 

	loop:
		mov r20, r19
		and r20, r18
		lsl r18 ;shifts the mask over for when we need to xor it
		dec r24 ;counter goes down each time
		cpi r24, 0x00 ;if counter is 0 then we can turn lights on
		breq LightsOn

		cpi r20, 0x00 ;if bit is a 0 loop thhrough again till we find a 1
		breq loop

		;finds which leds we want to turn on
		;if the number matches whats in register that means that light needs to be turned on
		cpi r20, 0x01 
		breq LED6
		cpi r20, 0x02
		breq LED5
		cpi r20, 0x04
		breq LED4
		cpi r20, 0x08
		breq LED3
		cpi r20, 0x10
		breq LED2
		cpi r20, 0x20
		breq LED1
		
		;sets up the correct bits to turn on lights we wanted

		;xor r22, r21 so r22 will contain bits needed to turn on portb leds
			LED1:
				ldi r21, 0x02 
				eor r22, r21  
				rjmp loop

			LED2:
				ldi r21, 0x08
				eor r22, r21
				rjmp loop
		;xor r23, r21 so r22 will contain bits needed to turn on portl leds
			LED3:
				ldi r20, 0x02
				eor r23, r20
				rjmp loop
	
			LED4:
				ldi r20, 0x08
				eor r23, r20
				rjmp loop

			LED5:
				ldi r20, 0x20
				eor r23, r20
				rjmp loop

			LED6:
				ldi r20, 0x80
				eor r23, r20
				rjmp loop

	LightsOn:
		sts PORTL, r23 ;turns on lights in portl
		out PORTB, r22 ;turns on lighgts in portb
		
		;pop all the registers off so we can use them again later
		pop r24
		pop r23
		pop r22
		pop r21
		pop r20
		pop r19
		pop r18
		pop r16
		ret


slow_leds:
	mov r16, r17 ;moves value to correct register
	rcall set_leds 
	rcall delay_long
	;reset  lights to off
	ldi r23, 0
	sts PORTL, r23
	ldi r22, 0
	out PORTB, r22
	ret


fast_leds:
	mov r16, r17 ;moves value to correct register
	rcall set_leds
	rcall delay_short
	;reset  lights to off
	ldi r23, 0
	sts PORTL, r23
	ldi r22, 0
	out PORTB, r22
	ret


leds_with_speed:
	push ZH ;z register which points to sp
	push ZL
	push r16 ;holds value we get off of the stack
	push r17
	push r25
	push r26
	
	in ZH, SPH ;has z point to the sp
	in ZL, SPL
	 
	ldi r26, 0b11000000 ;mask
	ldd r16, Z+10 ;get value out of stack into r16
	mov r25, r16
	and r25, r26
	cpi r25, 0xC0 ;checks if we should turn on lights for one sec, if not go to quarter sec
	breq OneSec
	
	QuarterSec:
		mov r17, r16 ;moves to correct register for next function
		rcall fast_leds
		rjmp RETURN
	OneSec:
		eor r16, r26  ;if we need to turn for one sec, xor r16
		mov r17, r16  ;moves to correct register for next function
		rcall slow_leds
		rjmp RETURN

	;when we r done pop registers off
	RETURN:
		pop r26
		pop r25
		pop r17
		pop r16
		pop ZL
		pop ZH
		ret


; Note -- this function will only ever be tested
; with upper-case letters, but it is a good idea
; to anticipate some errors when programming (i.e. by
; accidentally putting in lower-case letters). Therefore
; the loop does explicitly check if the hyphen/dash occurs,
; in which case it terminates with a code not found
; for any legal letter.

encode_letter:
	push ZH ;used to go through string
	push ZL
	push YH ;used to point at sp
	push YL
	push r19 ;holding stack value
	push r20 ;low byte
	push r21 ;counter
	push r0 ;srcl
	push r1 ;srch
	push r24
	push r26

	.def srcH=r1
	.def srcL=r0 

	in YH, SPH ;sets up y to point to stack pointer
	in YL, SPL
	ldd r19, Y+15 ;grabs whats off of  stack and puts into r19

	ldi r24, 0b01000000 ;mask
	ldi r21, 0b11000000 ;one second lights
	ldi r26, 0b00000000 ;quarter second lights
	clr r25 ;clearing just incase it had previous values in it

	ldi r20, high(PATTERNS<<1) ;high byte
	mov srcH, r20 ;store high in srch
	ldi r20, low(PATTERNS<<1) ;low byte
	mov srcL, r20 ;store low in srcl

	mov ZH, srcH
	mov ZL, srcL

	StringLoop:
		lpm r20, Z+ ;going through the string
		cp r20, r19 ;comparing the the letter from the stack
		breq SAMELETTER ;if same hex value move to sameletter
		rjmp StringLoop ;else we keep on going through to find the right letter
		 
			SAMELETTER:
				lpm r20, Z+ ;used to go through the string in specific letter we  want
				lsr r24 ;mask
				cpi r20, 0x6F ;compare to ascii value of "o"
				breq LIGHTS ;if its equal we want right bt to turn on that light
				cpi r20, 1 ;if last char is 1 turn lights for one sec
				breq ONESECTIME
				cpi r20, 2;if last cahr is a 2 turn lights on for quarter sec
				breq QUARTERTIME
				rjmp SAMELETTER ;else keep on looping till we find an "o" or "1" or "2"

				LIGHTS:
					eor r25, r24 ;sets correct bits to turn on leds which correspond to the "o"
					rjmp SAMELETTER ;keep on looping to find another "o" or "1" or "2"

				ONESECTIME: 
					eor r25, r21 ;sets bits so correspond to turning on for 1 sec
					rjmp FINISH

				QUARTERTIME:
					eor r25, r26 ;sets bits to turn on for quarter sec
					rjmp FINISH
;pop everything off
	FINISH:
		pop r26
		pop r24
		pop r1
		pop r0
		pop r21
		pop r20
		pop r19
		pop YL
		pop YH
		pop ZL
		pop ZH
		ret


display_message:
	push ZH ;z used to go through the string
	Push ZL
	push r20 ;where we r storing the chars
	push r25;counter

	mov ZH, r25
	mov ZL, r24
	clr r20
		
	BIGLOOP:
		lpm r20, Z+ ;finds the char
		cpi r20, 0 ;if  char is a zero we r finished here
		breq ENDING

		push r20 ;pushing char onto stack
		rcall encode_letter ;encocdes char
		rcall delay_short  ;turns of leds between letters
		rcall delay_short ;turns of leds between letters
		pop r20 ;pop off stack since we use again

		push r25 ;encode returns value into r25 so we push it onto stack for leds with speed
		rcall leds_with_speed
		pop r25 ;pop off stack once we r odne
		 
		rjmp BIGLOOP ;loops until we find a zero 

	;pop off and ret
	ENDING:
		pop r25
		pop r20 
		pop ZL
		pop ZH
		ret


; ****************************************************
; **** END OF SECOND "STUDENT CODE" SECTION **********
; ****************************************************




; =============================================
; ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
; =============================================

; about one second
delay_long:
	push r16

	ldi r16, 14
delay_long_loop:
	rcall delay
	dec r16
	brne delay_long_loop
	pop r16
	ret


; about 0.25 of a second
delay_short:
	push r16

	ldi r16, 4
delay_short_loop:
	rcall delay
	dec r16
	brne delay_short_loop

	pop r16
	ret

; When wanting about a 1/5th of a second delay, all other
; code must call this function
;
delay:
	rcall delay_busywait
	ret


; This function is ONLY called from "delay", and
; never directly from other code. Really this is
; nothing other than a specially-tuned triply-nested
; loop. It provides the delay it does by virtue of
; running on a mega2560 processor.
;
delay_busywait:
	push r16
	push r17
	push r18

	ldi r16, 0x08
delay_busywait_loop1:
	dec r16
	breq delay_busywait_exit

	ldi r17, 0xff
delay_busywait_loop2:
	dec r17
	breq delay_busywait_loop1

	ldi r18, 0xff
delay_busywait_loop3:
	dec r18
	breq delay_busywait_loop2
	rjmp delay_busywait_loop3

delay_busywait_exit:
	pop r18
	pop r17
	pop r16
	ret


; Some tables
.cseg
.org 0x600

PATTERNS:
	; LED pattern shown from left to right: "." means off, "o" means
    ; on, 1 means long/slow, while 2 means short/fast.
	.db "A", "..oo..", 1
	.db "B", ".o..o.", 2
	.db "C", "o.o...", 1
	.db "D", ".....o", 1
	.db "E", "oooooo", 1
	.db "F", ".oooo.", 2
	.db "G", "oo..oo", 2
	.db "H", "..oo..", 2
	.db "I", ".o..o.", 1
	.db "J", ".....o", 2
	.db "K", "....oo", 2
	.db "L", "o.o.o.", 1
	.db "M", "oooooo", 2
	.db "N", "oo....", 1
	.db "O", ".oooo.", 1
	.db "P", "o.oo.o", 1
	.db "Q", "o.oo.o", 2
	.db "R", "oo..oo", 1
	.db "S", "....oo", 1
	.db "T", "..oo..", 1
	.db "U", "o.....", 1
	.db "V", "o.o.o.", 2
	.db "W", "o.o...", 2
	.db "W", "oo....", 2
	.db "Y", "..oo..", 2
	.db "Z", "o.....", 2
	.db "-", "o...oo", 1   ; Just in case!

WORD00: .db "HELLOWORLD", 0, 0
WORD01: .db "THE", 0
WORD02: .db "QUICK", 0
WORD03: .db "BROWN", 0
WORD04: .db "FOX", 0
WORD05: .db "JUMPED", 0, 0
WORD06: .db "OVER", 0, 0
WORD07: .db "THE", 0
WORD08: .db "LAZY", 0, 0
WORD09: .db "DOG", 0

; =======================================
; ==== END OF "DO NOT TOUCH" SECTION ====
; =======================================

