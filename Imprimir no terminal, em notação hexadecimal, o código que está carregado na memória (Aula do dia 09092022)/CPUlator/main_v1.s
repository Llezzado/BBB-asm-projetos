.global _start
.equ UART, 0xff201000

_start:
adr r0, _start
bl .printcode
.main:
b .main

.printcode:
	stmfd sp!,{r0-r2,lr}
	0:
	ldr r1,[r0]
	cmp r1,#0
	beq 1f
	bl .print_reg
	add r0,#4
	b 0b
	1:
	ldmfd sp!,{r0-r2,pc}

.print_reg:
	stmfd sp!,{r0-r2,lr}
		mov r0,r1
		mov r2,#0
		
		0:
		
		lsr r0,#28
		bl .hex2axcii
		lsl r1,#4
		mov r0,r1
		add r2,#1
		cmp r2,#7
		bls 0b
		
		//enter_code
		mov r0,#13
		bl .uartputc
		mov r0,#10
		bl .uartputc
		
		
	ldmfd sp!,{r0-r2,pc}
	
.hex2axcii:
	stmfd sp!,{r1,lr}
	cmp r0,#9
	//se for menor
	addls r0,#0x30
	subhi r0,#10
	addhi r0,#0x41
	bl .uartputc
	bl .wait
	ldmfd sp!,{r1,pc}
	
.uartputc:
	stmfd sp!,{r1,lr}
	ldr r1, =UART
	str r0,[r1]
	ldmfd sp!,{r1,pc}
	
.wait:
	stmfd sp!,{r1,lr}
	ldr r1,=#0xf00
	0:
	sub r1,#1
	cmp r1,#0
	bne 0b
	ldmfd sp!,{r1,pc}

andeq r0,r0,#0
	
	