;printf asm
DEFAULT REL
section .bss
buf resb 64 ;

;----------------------------------
section .text


%macro print_char 1      
        mov     rax, 1   
        mov     rdi, 1   
        lea     rsi, %1   
        mov     rdx, 1    
        syscall 
%endmacro



	;pop     r11
	;mov r9, 18d
	;mov r8, msg3	
	;mov     rcx, '!'
        ;mov     rdx, 100d
        ;mov     rsi, 5516d
        ;mov     rdi, msg
	;push 100d
	;push 3802d
	;push msg2
	;push 'I'	
global printfd:function
	
printfd:
	pop	r11               ; pushing all argumnets to the stack
        push    r9
        push    r8
        push    rcx     
        push    rdx    
        push    rsi
        push    rbp
        push    rbx
        push    r11
        mov     rbp, rsp	  ; changing stack base pointer 

	mov r8, 0		  ; r8 - symbol counter of main str
	mov r9, 0		  ; r9 -arg counter


.main_part:
	mov r10, 0                ; compairing with r10 
	cmp byte [rdi+r8], r10b
	je .return

	mov r10, '%'
	cmp byte [rdi+r8], r10b
	je .formated

	jmp .regular_char	
	
	.return:
	pop r11 
	pop rbx
	pop rbp
	pop rsi
	pop rdx
	pop rcx
	pop r8
	pop r9
	push r11
	ret
;==========================================
.formated:
	inc r8
	
	mov r10, 'd'
	cmp byte [rdi+r8], r10b
	je .decimal			;0
	
	mov r10, 'b'
	cmp byte [rdi+r8], r10b
	je .binary			;1
	
	mov r10, 'o'
	cmp byte [rdi+r8], r10b
	je .octal			;2
	
	mov r10, 'x'
	cmp byte [rdi+r8], r10b
	je .hex				;3

	mov r10, 'c'
	cmp byte [rdi+r8], r10b
	je .char			;4
	
	mov r10, 's'
	cmp byte [rdi+r8], r10b
	je .string			;5

	mov r10, '%'
	cmp byte [rdi+r8], r10b
	je .procent
;===========================================

.procent:
	
	inc r8
	mov rax, '%'
	mov [buf], rax
	
	push rdi 
	push rsi
	push rdx
	
	print_char [buf]
	
	pop rdx
	pop rsi
	pop rdi
	
	jmp .main_part
	
;-------------------------------------------------------
.octal:
	mov rax, [rbp + 24 + r9*8] ; r9- arg num.  moving argument addr to rax
	push r9
	
	mov r9, 0
.loop_oct:
	xor rdx, rdx
	push r8	
	mov r8, 8d
	div r8
	pop r8
	add rdx, '0'
	mov [buf + r9], rdx
	inc r9
	cmp rax, 0
	jne .loop_oct
	dec r9
	jmp .buf_reverse_print 	
;--------------------------------------------------------
.hex:
	mov rax, [rbp + 24 + r9*8] ; r9- arg num.  moving argument addr to rax
	push r9
	
	mov r9, 0
.loop_hex:
	xor rdx, rdx	
	push r8	
	mov r8, 16d
	div r8
	pop r8
	cmp rdx, 10d
	jae .add_letter_hex
	add rdx, '0'
.back_in_hex:
	mov [buf + r9], rdx
	inc r9
	cmp rax, 0
	jne .loop_hex
	dec r9
	jmp .buf_reverse_print 

.add_letter_hex:
	add rdx, 'A'
	sub rdx, 10
	jmp .back_in_hex
;===============================================================
	
.binary:
	mov rax, [rbp + 24 + r9*8] ; r9- arg num.  moving argument addr to rax
	push r9
	
	mov r9, 0
.loop_bin:
	xor rdx, rdx	
	push r8	
	mov r8, 2
	div r8
	pop r8
	add rdx, '0'
	mov [buf + r9], rdx
	inc r9
	cmp rax, 0
	jne .loop_bin
	dec r9
	jmp .buf_reverse_print 
;=================================================================
.decimal:
	mov rax, [rbp + 24 + r9*8] ; r9- arg num.  moving argument addr to rax
	push r9
	mov r9, 0
.loop_dec:

	xor rdx, rdx	
	push r8	
	mov r8, 10
	div r8
	pop r8
	add rdx, '0'
	mov [buf + r9], rdx
	inc r9
	cmp rax, 0
	jne .loop_dec
	dec r9
	jmp .buf_reverse_print

;-----------------------------------------	
.buf_reverse_print:
	
	push rdi 
	push rsi
	push rdx
	
.one_more_char:	
	print_char [buf+r9]
	dec r9
	cmp r9, -1 
	jne .one_more_char	
	
	pop rdx
	pop rsi
	pop rdi	
	
	pop r9
	inc r9			;inc argument(r9) and symbol counter (r8)
	inc r8
	jmp .main_part
;--------------------------------------------		

.string:
	push r8
	push r9
	mov rax, [rbp + 24 + r9*8]
	xor r9, r9
	xor r8, r8
.loop_str:	
	inc r8
	cmp byte [rax + r8], 0 
	jne .loop_str
	
	push rdi 
	push rsi
	push rdx
	
	  
        mov     rdi, 1   
        lea     rsi, [rax]  
	mov     rax, 1  
        mov     rdx, r8   
        syscall 
	
	pop rdx
	pop rsi
	pop rdi	
	pop r9
	pop r8
	inc r8
	inc r9

	jmp .main_part
;================================================
.char:
	push rdi 
	push rsi
	push rdx
	
	print_char [rbp+24+ 8*r9]
	
	pop rdx
	pop rsi
	pop rdi		
	inc r8
	inc r9 
	jmp .main_part
	
.regular_char:		 	  ; print char
	mov r10, [rdi + r8]
	mov [buf], r10	
	push rdi 
	push rsi
	push rdx
	
	print_char [buf]
	
	pop rdx
	pop rsi
	pop rdi	

	inc r8
	jmp .main_part



section .data 
msg     db      `Test, hex, %x %d %c %s %b. %c %s %x %d %% `, 0
msg2    db      'Love', 0
msg3 	db 	'Passion',0
procent db '%'	

