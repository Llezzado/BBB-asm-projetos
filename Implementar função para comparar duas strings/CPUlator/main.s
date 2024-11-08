.global _start
_start:

main:
ldr r0, =str1
bl get_str
ldr r0, =str2
bl get_str

bl cmp_str

b main

get_str:
	stmfd sp!,{r0-r2,lr}
	mov r1,r0
	0:
	bl getc
	bl putc
	
	cmp r0,#0xa
	moveq r0, #0
	
	strb r0,[r1],#1
	cmp r0,#0
	bne 0b
	
	
	ldmfd sp!,{r0-r2,pc}

put_str:
	stmfd sp!,{r0-r2,lr}
	mov r1,r0
	0:
	ldrb r0,[r1],#1
	cmp r0,#0
	blne putc
	bne 0b
	
	
	ldmfd sp!,{r0-r2,pc}

getc:
stmfd sp!,{r1,lr}
	ldr r1,=#0xff201000
	ldrb r0,[r1]
ldmfd sp!,{r1,pc}
putc:
stmfd sp!,{r1,lr}
	ldr r1,=#0xff201000
	strb r0,[r1]
ldmfd sp!,{r1,pc}

/*
r0 adr str 1 r2 char x
r1 adr str 2 r3 char y
r4 contador

se igual 1, se n 0

*/

cmp_str:
	stmfd sp!,{r0-r2,lr}
	
	ldr r0, =str1
	ldr r1, =str2
	mov r4,#0
	0:
	ldrb r2,[r0],#1
	ldrb r3,[r1],#1
	
	cmp r2,r3
	bne diferente
	cmp r2,#0
	beq iguais
	bne 0b
	
	iguais:
	ldr r0,=eqtxt
	bl put_str
	b 1f
	diferente:
	ldr r0,=netxt
	bl put_str
	1:
	ldmfd sp!,{r0-r2,pc}

str1: .fill 16
str2: .fill 16
eqtxt: .ascii "iguais! "
s:.fill 1
netxt: .ascii "diferentes! "
