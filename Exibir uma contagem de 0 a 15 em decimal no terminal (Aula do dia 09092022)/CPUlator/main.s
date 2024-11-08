.global _start

.equ UART0_BASE, 0x44e09000
.equ UART_CPU, 0xff201000

_start:
	mov r1,#0
	mov r2,#0
	mov r0,#0

	.mainloop:
	
		cmp r2,#15
		movhi r2,#0
		
		cmp r2,#9
		
		mov r0,#0x30
		
		addhi r0,#1
		
		bl .printc
		
		mov r0, #0x30
		
		add r0,r2
		subhi r0,#10
		bl .printc
		
		add r2,#1
		
		mov r0,#32	
		bl .printc
		
	b .mainloop
	
	.printc:
		ldr r1, =UART_CPU
		str r0,[r1]
	bx lr


.dec: .ascii "0123456789"	
	