; Search.asm Peter Dunckel EGR329
; November 20, 2015 California Baptist University
; This assembly language file exercises a sequential
; and a binary search function
;  DATE      ID      CHANGES
; 12-16-15   CFJ     Initial setup of loop through array to store and print array
; 12-19-15   PWD     Completed Sequential Search
; 12-20-15   PWD     Completed Binary Search

%include "io.inc"
LENGTH EQU 200 ; length of the buffer
HALFLENGTH EQU 100 ; this value is always half the value of LENGTH
MULTIPLIER EQU 5
SRCHWORD EQU 75
SRCHWORD2 EQU 135

section .data
section .bss
intBuf: resw LENGTH ; reserve a word

section .text
global CMAIN
CMAIN:
 mov ebp, esp ; for correct debugging
 mov edx, intBuf
 mov ecx, LENGTH
 mov ebx, 1
mulloop:
 dec cl ; cl is the loop counter
 jz mulloopdone ; when the loop ctr reaches zero, we are done
 mov eax, 0
 mov ax, bx ; get the current count
 imul eax, MULTIPLIER ; multiply the current count by MULTIPLIER
 mov [edx], eax ; store in the buffer
 inc bl
 inc edx ; inc by 2 addresses since we are storing 16-bit words
 inc edx
 jmp mulloop
mulloopdone:
 mov edx, intBuf
 mov ecx, LENGTH
outloop:
 dec cl
 jz outloopdone
 mov ax, [edx] ; write the array data out to confirm it’s right
 PRINT_DEC 2, ax
 NEWLINE
 inc edx
 inc edx
 jmp outloop
outloopdone:
 mov ebp, intBuf
 mov edx, 0
 ; try the sequential search routine
 mov dx, LENGTH
 mov eax, 0
 mov ax, SRCHWORD ; set the registers as per the functions’s documentation
 call seqsearch
 call writeresults ; write the results of the search
 mov dx, LENGTH
 mov eax, 0
 mov ax, SRCHWORD2
 call seqsearch
 call writeresults ; write the results of the search
 ; now try the binary search routine
 mov dx, LENGTH
 mov eax, 0
 mov ax, SRCHWORD ; set the registers as per the functions’s documentation
 call binarysearch
 call writeresults ; write the results of the search
 mov dx, LENGTH
 mov eax, 0
 mov ax, SRCHWORD2
 call binarysearch
 call writeresults ; write the results of the search
 xor eax, eax
 ret
; writes the results of a search
; assumptions:
; the value searched for is in ax (16-bit)
; the count into the array where found is returned in dx
writeresults:
 PRINT_STRING "SEARCH WORD "
 PRINT_DEC 2, ax
 PRINT_STRING " AT "
 PRINT_DEC 2, dx
 NEWLINE
 ret
; Sequential search routine
; assumptions:
; the array to be searched is in memory - pointed to in EBP
; the length of the array is in dx (16-bit)
; the value to search for is in ax (16-bit)
; when done, the count into the array where found is returned in dx
; the array is composed of 32-bit words
seqsearch:
 mov dx,0 ; set dx to 0
 mov cx, LENGTH
seqloop:
 dec cl ; cl is the loop counter
 jz notInArray ; when the loop ctr reaches zero, we are done and the value has not been found
 inc dx ;inc value to be returned as the 
 cmp [ebp], ax ;compare the value stored in the array to the value desired
 je loopdone ;if they are equal jump out of seqloop 
 inc ebp ; inc by 2 addresses since we are storing 16-bit words
 inc ebp
 jmp seqloop

; Binary search routine
; assumptions:
; the array to be searched is in memory - pointed to in EBP
; the length of the array is in dx (16-bit)
; the value to search for is in ax (16-bit)
; when done, the count into the array where found is returned in dx
; the array is composed of 32-bit words
binarysearch: 
 mov esi, 0 ; set value of min to be the minimum length of array
 mov edi, LENGTH ; set value of max to be the length of array
 mov edx, HALFLENGTH ; set dx to mid point area 
 jmp setArrayPosition ; set value to be searched in memory to middle value
 
binaryloop:
 sub di, 1
 cmp si, di    ; compare min to max
 je loopdone ; if min is equal to max end loop
 add di, 1
 cmp ax, [ebp] ;compare the value stored in the array to the value desired
 je loopdone ;if the value is equal to the value desired end the loop
 cmp ax, [ebp] ;compare the value stored in the array to the value desired
 jl gotolowerportion ;if the value stored is less than the value desired go to set max to current value stored
 cmp ax, [ebp] ;compare the value stored in the array to the value desired
 jg gotohigherportion ;if the value stored is greater than the value desired go to set min to current value stored
 jmp seqloop
 
gotohigherportion: 
 mov si, dx ; set min to midpt value
 add si, di ; start of finding new midpt value 
 mov cx, si
 and cx, 1 ;check if the value is odd or even
 jz minIsEven
 sub si, 1 ; make sure that si is even number, so that we can divide by 2
minIsEven:
 xchg dx, si ;exhange values in order to have midpoint set and 
 mov bx,ax ; store original value of ax
 mov ax, dx ; give ax the value of dx
 mov cl, 2 ; temporarily user cl to divide ax by 2
 idiv cl
 mov dx,ax ;set dx to new midpt
 mov ax,bx ;give ax the value to be searched back
 mov bx, 0 
 jmp setArrayPosition
 
gotolowerportion:  
 mov di, dx ; set the max di to have the midpt value
 add di, si ; start of finding new midpt value
 mov cx, di
 and cx, 1 ;check if the value is odd or even
 jz maxIsEven
 sub di, 1 ;add one so it is divisble by 2
maxIsEven:
 xchg dx, di ;exhange values in order to have midpoint set and 
 mov bx,ax ; store original value of ax
 mov ax, dx ; give ax the value of dx
 mov cl, 2 ; temporarily user cl to divide ax by 2
 idiv cl
 mov dx,ax ;set dx to new midpt
 mov ax,bx ;give ax the value to be searched back
 mov bx, 0
 jmp setArrayPosition
 
setArrayPosition: 
 mov ebp, intBuf    ;go to the start of array
 mov ecx, edx ; set cx with the position the array stop
 imul ecx, 2    ; multiply position desired by 2 because we are storing 16-bit addresses
 sub ecx, 2     ; subtract 2 addresses to get to correct address in the array
 add ebp, ecx   ; add position desired to the array to go to the value stored in desired position
 jmp binaryloop
 
loopdone:
 mov ebp, intBuf    ;go to the start of array
 mov ecx, LENGTH    ;reset length of counter
 dec dx ;value to be returned is one value to high because array was thought to start at 1 not 0
 ret
 
notInArray:
 PRINT_STRING "SEARCH WORD "
 PRINT_DEC 2, ax
 PRINT_STRING " NOT IN ARRAY! "
 NEWLINE
 mov dx, 0
 jmp loopdone
 