TITLE Program 6     (Proj6_Morrowj2.asm)

; Author: Jacob Morrow
; Last Modified: 12/8/2020
; OSU email address: Morrowj2@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 6               Due Date: 12/8/2020 (2 Grace Days)
; Description: Program that gets 10 signed 32-bit integers, validates and
; converts from ascii to sdword, to then display array of SDWORDS after converting
; back to ascii alongside sum and floor rounded average.

INCLUDE Irvine32.inc

; Implement 2 macros for string processing, using ReadString & WriteString

; ********************************************************************
; mGetSring: macro to get string from user
; recieves: prompt (reference), string (reference)
; returns: bytesRead (reference)
; registers changed: EAX, ECX, EDX
; ********************************************************************
mGetString MACRO prompt, string, stringLen, bytesRead
  PUSH  EAX
  PUSH	ECX
  PUSH	EDX
  ; Display a prompt
  mDisplayString prompt
  ; Get the user's keyboard input into a memory loacation
  mov	edx, string
  ; Provide a count for the lenth of input string you can accomodate
  mov	ecx, stringLen
  CALL	ReadString
  ; Provide number of bytes read by the macro
  MOV	bytesRead, EAX
  POP	EDX
  POP	ECX
  POP	EAX
ENDM

; ********************************************************************
; mDisplayString: macro to print string stored in memory of aString
; recieves: string (reference) 
; returns: prints aString
; registers changed: EDX
; ********************************************************************
; Print the string which is stored in a specific memory location
mDisplayString MACRO string
  PUSH	EDX
  MOV	EDX, string
  CALL	WriteString
  POP	EDX
ENDM	

.STACK	1024
ARRAYSIZE = 10
LO  = 48	; SDWORD Low Limit
HI = 57		; SDWORD High Limit

.data
; Text
header0		BYTE	"Assignment 6: Designing low-level I/O procedures by Jacob Morrow", 10, 13
			BYTE	"Please provide 10 signed decimal integers.", 10, 13, 10, 13
			BYTE	"Each number needs to be small enough to fit inside a 32 bit register.", 10, 13
			BYTE	"After you have finished inputting the raw numbers, I will display a list", 10, 13
			BYTE	"of integers, their sum, and average value.", 10, 13, 10, 13, 0
prompt0		BYTE	"Enter a signed integer: ", 0
prompt1		BYTE	"Error: Signed Number was not detected or was larger than 32 bits", 10, 13
			BYTE	"Try again: ", 0
comma		BYTE	", ", 0
neg1		BYTE	"-", 0
list		BYTE	"List of entered numbers: ", 0
sum0		BYTE	"Sum of these numbers: ", 0
avg0		BYTE	"Rounded average of these numbers: ", 0
end0		BYTE	'"Wake up, Samurai. We have a city to burn."', 0

array		SDWORD	ARRAYSIZE DUP(?)
buffer		BYTE	12 DUP(?)
bufferCnt	DWORD	?
sum 		SDWORD	?



.code
main PROC
  ; Display header
  push	OFFSET header0	 ; 8
  call	printString
  ; Get and validate user input
  push	HI				 ; 44
  push	LO				 ; 40
  push	ARRAYSIZE		 ; 36
  push	OFFSET sum 		 ; 32
  push	OFFSET prompt0	 ; 28
  push	OFFSET prompt1	 ; 24
  push	OFFSET array	 ; 20
  push  OFFSET bufferCnt ; 16
  push	OFFSET buffer	 ; 12
  push  SIZEOF buffer	 ; 8
  call	readVal
  ; Display array of signed ints
  call	CrLf
  push	OFFSET neg1		; 24
  push	OFFSET comma	; 20
  push	OFFSET list		; 16
  push  OFFSET array	; 12
  push  LENGTHOF array	; 8
  call	writeList	
  ; Display sum of ints
  call	CrLf
  call	CrLf
  push  OFFSET sum0		; 8
  call	printString
  push	OFFSET neg1		; 16
  push	OFFSET buffer	; 12
  push	sum 			; 8
  call	writeVal
  ; Display rounded average
  call	CrLf
  call	CrLf
  push	OFFSET avg0		; 8
  call	printString
  push	ARRAYSIZE		; 16
  push	OFFSET sum  	; 12
  push	sum 			; 8
  call	getAvg
  push	OFFSET neg1		; 16
  push	OFFSET buffer	; 12
  push	sum				; 8
  call	writeVal
  ; Display end
  call	CrLf
  call	CrLf
  PUSH OFFSET end0		; 8
  CALL	printString	

	Invoke ExitProcess,0	; exit to operating system
main ENDP
; ********************************************************************
; printString: procedure to print given string
; recieves: string (reference)
; returns:	macro mDisplayString for string
; registers changed:
; ********************************************************************
printString PROC
  PUSH	EBP
  MOV	EBP, ESP
  mDisplayString [EBP+8]
  POP	EBP
  RET	4
printString ENDP

; ********************************************************************
; ReadVal: procedure to get, validate, and convert ascii input to SDWORD
;		   to store in an array
; recieves:	temp, prompt0, prompt1, array, bufferCnt, buffer (reference),
;			SIZEOF buffer (value)
; returns:	array (reference)
; registers changed: eax ebx ecx esi edi
; ********************************************************************
readVal PROC
  LOCAL neg0:BYTE
  push	ecx
  push	edi
  push	esi
  push	eax
  push	ebx
  push	edx

  mov	ecx, [ebp+36]	; ARRAYSIZE
  mov	edi, [ebp+20]	; Array
  cld	
; Invoke mGetSring to get user input
  jmp	_newInput
_invalid:
  mGetString [EBP+24], [ebp+12], [ebp+8], [EBP+16]
  jmp	_invalidExit
_newInput:
  mGetString [EBP+28], [ebp+12], [ebp+8], [EBP+16]	; mGetString MACRO prompt, string, stringLen, bytesRead
  push	ecx
_invalidExit:
  mov	ecx, [EBP+16]	; LengthOf String
  mov	esi, [EBP+12]	; String
  xor	eax, eax
  xor	ebx, ebx

  mov	neg0, 0		; reset negative num

  cmp	ecx, 0
  je	_invalid
  cmp	ecx, 11
  ja	_invalid

  lodsb
  cmp	eax, 43		; check sign pos
  jz	_pos
  cmp	eax, 45		; check sign neg
  jnz	_validate
  cmp	ecx, 1
  je	_invalid
  mov	neg0, 1		; set negative num
; Convert, using string primitives, the strings of ascii digits to its numeric value
; validating the user's input is a valid number
_pos:
  cmp	ecx, 1
  je	_invalid
_newChar:
  xor	eax, eax
  lodsb
  cmp	eax, 0		; check if string terminated
  je	_check
_validate:
  cmp	eax, [ebp+40]		; check if below ascii 0
  jb	_invalid

  cmp	eax, [ebp+44]		; check if above ascii 9
  ja	_invalid

_calculate:			; ascii to sdword
  sub	eax, 48
  push	eax
  mov	eax, ebx
  mov	ebx, [ebp+36]	; ARRAYSIZE
  mul	ebx
  mov	ebx, eax
  pop	eax
  add	ebx, eax
  xor	eax, eax
  loop	_newChar

_check:
  cmp	neg0, 0
  je	_end
  mov	esi, [ebp+32]		; sum offset
  sub	SDWORD PTR [esi], ebx		;	sub from sum
  neg	ebx
  jmp	_next
; Store this value in a memory variable
_end:
  mov	esi, [ebp+32]		; sum offset
  add	SDWORD PTR [esi], ebx		; add to sum
_next:
  mov	[edi], ebx
  add	edi, 4
  pop	ecx
  dec	ecx
  jnz	_newInput

  pop	edx
  pop	ebx
  pop	eax
  pop	esi
  pop	edi
  pop	ecx
  ret	40
readVal ENDP

; ********************************************************************
; writeVal: procedure to convert SDWORD to ascii string then print
;			with macro mDisplayString
; recieves: anSDWORD (value)
; returns: prints ascii representation
; registers changed: eax ebx ecx edx edi
; ********************************************************************
writeVal PROC	USES	eax	ebx	ecx	edx edi
  LOCAL	char0:SDWORD

  mov	eax, [ebp+8]	; number
  mov	ebx, 10
  mov	ecx, 0
  cld
  cmp	eax, 0
  jge	_newChar
  neg	eax
  mDisplayString	[ebp+16]	; print - if neg
; Convert a numeric SDWORD value to a string of ascii digits
_newChar:
  cdq
  div	ebx
  push	edx
  inc	ecx
  cmp	eax, 0
  jne	_newChar
  mov	edi, [ebp+12]	; buffer

_store:			;reloop to store backwards
  pop	char0
  mov	al, BYTE PTR char0
  add	al, 48
  stosb
  loop	_store

  mov	al, 0
  stosb
  
; Invoke the mDisplayString macro to a string of digits
_print:
  mDisplayString	[ebp+12]	; buffer

  ret	12
writeVal ENDP

; ********************************************************************
; writeList: procedure to print list of SDWORDS
;			with macro mDisplayString
; recieves: comma, list, array (reference), LENGTHOF array (value)
; returns: prints ascii representation
; registers changed: eax ebx ecx edx edi
; ********************************************************************
writeList PROC	USES	eax	ebx ecx	edx edi
  LOCAL buffer0[12]:BYTE
  lea	eax, buffer0		; local: buffer0
  mov	ecx, [ebp+8]		; lengthOf Array
  mov	edi, [ebp+12]		; array
  mov	edx, [ebp+24]
  mDisplayString [ebp+16]	; list
; Iterate through array writing each val
_nextNum:
  mov	ebx, [edi]
  push	edx
  push	eax				
  push	ebx	
  call	writeVal
  cmp	ecx, 1
  je	_end
  mDisplayString [ebp+20]	; comma
  add	edi, 4
_end:
  loop	_nextNum
  ret	20
writeList ENDP

; ********************************************************************
; getAvg: procedure to perform division on sum to get average
; recieves: sum (reference), sum, arraySize (value)
; returns: prints ascii representation
; registers changed: eax ecx ebx edi
; ********************************************************************
getAvg PROC
  push	ebp
  mov	ebp, esp
  push	eax
  push	ebx
  push	edi
  mov	eax, [ebp+8]	; sum
  mov	edi, [ebp+12]	; buffer
  mov	ebx, [ebp+16]	; arraySize
  cdq	
  idiv	ebx
  mov	SDWORD PTR [edi], eax
  pop	edi
  pop	ebx
  pop	eax
  pop	ebp
  ret	12
getAvg ENDP
END main
