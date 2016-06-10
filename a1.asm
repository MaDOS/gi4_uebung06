%macro enter
	push ebp
	mov ebp, esp
%endmacro

%macro exit
	mov ebx, 0
	mov eax, 1
	int 0x80
%endmacro

STRUC Darstellung
.hex: RESB 9
.dezimal: RESB 11
.size:
ENDSTRUC

;===================DATA=====================
SECTION .data
msg_in 		DB "Zahl eingeben: ", 0xA, 0x0
msg_in_format 	DB "%d", 0xA, 0x0
msg_out 	DB "Hex: %s ### Dec: %s", 0xA, 0x0

foo: ISTRUC Darstellung
AT Darstellung.hex, DB 0 TIMES 9
AT Darstellung.dezimal, DB 0 TIMES 11
IEND

;===================BSS=======================
SECTION .bss
integer RESD 0x1

;==================TEXT=======================
SECTION .text
global _start
extern scanf
extern printf

_start:
enter

	push msg_in
	call printf
	add esp, 0x4 * 0x1

	push integer
	push msg_in_format
	call scanf
	add esp, 0x4 * 0x2

	push dword [ integer ]
	call integerToString
	add esp, 0x4 * 0x1

	push foo.dec
	push foo.hex
	push msg_out
	call printf
	add esp, 0x4 * 0x3

leave
exit

integerToString:  ;[integerToString(int)] converts any given integer into a string saved in foo formatted as hex or dec
enter
pusha

	mov eax, ebp + 0x4 * 0x2
	mov ecx, 0x0
loop:
	cmp eax, 0x0
	JE intts_end
	div eax, 0xA

	push edx
	call numToDec
	mov dword[foo.dec + 0x1 * ecx], ebx
	call numToHex
	mov dword[foo.hex + 0x1 * ecx], ebx
	add esp, 0x4 * 0x1

	inc ecx
	JMP loop

	mov eax, dword [ foo ]

intts_end:
popa
leave
ret

numToDec: ;[char->ebx numToDec(int)] converts any given single digit number into a char formatted in dec
enter
	mov ebx, ebp + 0x4 * 0x2
	add ebx, 0x30
ntd_end:
leave
ret

numToHex: ;[char->ebx numToHex(int)] converts any given single digit number into a char formatted in hex
enter
	mov ebx, ebp + 0x4 * 0x2
	add ebx, 0x30
	cmp ebx, 0x9
	JLE nth_end
	add ebx, 0x7
nth_end:
leave
ret
