; bcd-addition.asm
; CSC 230: Fall 2022
;
; Code provided for Assignment #1
;
; Mike Zastre (2022-Sept-22)

; This skeleton of an assembly-language program is provided to help you
; begin with the programming task for A#1, part (c). In this and other
; files provided through the semester, you will see lines of code
; indicating "DO NOT TOUCH" sections. You are *not* to modify the
; lines within these sections. The only exceptions are for specific
; changes announced on conneX or in written permission from the course
; instructor. *** Unapproved changes could result in incorrect code
; execution during assignment evaluation, along with an assignment grade
; of zero. ****
;
; In a more positive vein, you are expected to place your code with the
; area marked "STUDENT CODE" sections.

; ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
; Your task: Two packed-BCD numbers are provided in R16
; and R17. You are to add the two numbers together, such
; the the rightmost two BCD "digits" are stored in R25
; while the carry value (0 or 1) is stored R24.
;
; For example, we know that 94 + 9 equals 103. If
; the digits are encoded as BCD, we would have
;   *  0x94 in R16
;   *  0x09 in R17
; with the result of the addition being:
;   * 0x03 in R25
;   * 0x01 in R24
;
; Similarly, we know than 35 + 49 equals 84. If 
; the digits are encoded as BCD, we would have
;   * 0x35 in R16
;   * 0x49 in R17
; with the result of the addition being:
;   * 0x84 in R25
;   * 0x00 in R24
;

; ANY SIGNIFICANT IDEAS YOU FIND ON THE WEB THAT HAVE HELPED
; YOU DEVELOP YOUR SOLUTION MUST BE CITED AS A COMMENT (THAT
; IS, WHAT THE IDEA IS, PLUS THE URL).



    .cseg
    .org 0

	; Some test cases below for you to try. And as usual
	; your solution is expected to work with values other
	; than those provided here.
	;
	; Your code will always be tested with legal BCD
	; values in r16 and r17 (i.e. no need for error checking).

	; 94 + 9 = 03, carry = 1 r25=0x03, r24=1 DONE
	;ldi r16, 0x94
	;ldi r17, 0x09

	 ; 86 + 79 = 65, carry = 1 r25=0x65, r24=1 DONE
	 ldi r16, 0x86
	 ldi r17, 0x79

	; 35 + 49 = 84, carry = 0 r25=0x84, r24=0
	;ldi r16, 0x35
	;ldi r17, 0x49

	; 32 + 41 = 73, carry = 0 r25=0x73, r24=0
	;ldi r16, 0x32
	;ldi r17, 0x41


	ldi r20, 0
	ldi r21, 0
	ldi r22, 0

	ldi r23, 0b00001111 ; mask
	ldi r30, 0 ;placeholder for mask
	ldi r31, 0; placeholder for the first and
	ldi r26, 0 ; placeholder for the second and

	ADDVALUES:
		mov r20, r16 ; r20 and r16 have the same value
		mov r21, r17 ; r21 and r17 have same value
		add r20, r21 ; sum is stored in r20
		mov r22, r20 ; sum is stored in r22 and r20
		mov r20, r16 ; r20 equals initial r16 vlaue
		;r20 and r21 both equal r16 and r17 stil, sum stored in r22

	ISVALID:
		;checks 0000xxxx
		mov r30, r22 ;sum stays in r22 and is unmanipulated
		and r30, r23 ;checks 0000xxxx
		mov r31, r30
		mov r30, r22 ; r30 is value it was before the and

		;rotate to check xxxx0000
		;swap nibbles in r30
		swap r30
		and r30, r23 ; checks 0000xxxx
		mov r26, r30
		mov r30, r22

	GREATERTHAN:
		;check is r35 and r26 are greater than 10
		;r35 is 0000xxxx
		;r26 is xxxx0000
		cpi r31, 9 ;0000xxxx
		brlt TRUE  ;if less than/true branch
		jmp FALSE

	TRUE:
		cpi r26, 9 ;if true/less than go to case 1
		brlt CASE1
		jmp CASE2 ;if false/greater than go to case 2

	FALSE:
		cpi r26, 9 ;if true/less than go to case 3
		brlt CASE3 
		jmp CASE4 ;if false/greater than go to case 4

	CASE1: ;xxxxxxxx is valid
		ldi r24, 0 ;carry = 0
		mov r25, r22 ;for now holds full value
		jmp DONE

	CASE2: ;add 01100000
		ldi  r27, 0b01100000
		add r30, r27
		mov r25, r30 
		brcs ADDCARRY
		ldi r24, 0 ;no carry 
		jmp DONE

	CASE3: ;add 00000110
		ldi r28, 0b00000110
		add r30, r28
		mov r25, r30 
		brcs ADDCARRY
		ldi r24, 0 ;no carry 
		jmp DONE

	CASE4: ;add 01100110
		ldi r29, 0b01100110
		add r30, r29
		mov r25, r30 
		brcs ADDCARRY
		ldi r24, 0 ;no carry
		jmp DONE 

	ADDCARRY:
		ldi r24, 1 ;if carry add one to r24
		jmp DONE

	DONE:
		jmp DONE

; ==== END OF "DO NOT TOUCH" SECTION ==========

; **** BEGINNING OF "STUDENT CODE" SECTION **** 






; **** END OF "STUDENT CODE" SECTION ********** 

; ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
bcd_addition_end:
	rjmp bcd_addition_end



; ==== END OF "DO NOT TOUCH" SECTION ==========
