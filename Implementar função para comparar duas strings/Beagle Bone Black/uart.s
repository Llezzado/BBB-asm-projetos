/* Global Symbols */
.global .uart_setup
.global .uart_putc
.global .uart_getc
.global .uart_isr
.global .buffer_to_rtc
.type .uart_getc, %function
.type .uart_putc, %function
.type .buffer_to_rtc, %function
//.type .uart_isr, %function


/* Registradores */
.equ UART0_BASE, 0x44E09000
.equ INTC_ILR,  0x48200100
.equ INTC_BASE, 0x48200000

/* Text Section */
.section .text,"ax"
         .code 32
         .align 4
         
/********************************************************
UART0 setup (Default configuration)  
********************************************************/
.uart_setup:
    stmfd sp!,{r0,r1,lr}
    ldr r0, =UART0_BASE
    mov r1,#0x1
    strb r1,[r0,#0x4]

    ldr r0, =INTC_ILR
    ldr r1, =#0    
    strb r1, [r0, #72]

    ldr r0, =INTC_BASE
    ldr r1, =#(1<<8)    
    str r1, [r0, #0xc8] //(72 --> Bit 8 do 3º registrador (MIR CLEAR2))

    ldmfd sp!,{r0,r1,pc}

/********************************************************
UART0 PUTC (Default configuration)  
********************************************************/
.uart_putc:
    stmfd sp!,{r1-r2,lr}
    ldr     r1, =UART0_BASE

.wait_tx_fifo_empty:
    ldr r2, [r1, #0x14] 
    and r2, r2, #(1<<5)
    cmp r2, #0
    beq .wait_tx_fifo_empty

    strb    r0, [r1]
    ldmfd sp!,{r1-r2,pc}

/********************************************************
UART0 GETC (Default configuration)  
********************************************************/
.uart_getc:
    stmfd sp!,{r1-r2,lr}
    ldr     r1, =UART0_BASE

.wait_rx_fifo:
    ldr r2, [r1, #0x14] 
    and r2, r2, #(1<<0)
    cmp r2, #0
    beq .wait_rx_fifo

    ldrb    r0, [r1]
    ldmfd sp!,{r1-r2,pc}
/********************************************************/

/*
buffer_to_rtc:
recebe: 
    r3 = endereço usado do buffer
retorna:
    r0 = val hex
    r3 = endereço usado do buffer atual
*/



/********************************************************/
.uart_isr:
    stmfd sp!, {r0-r5, lr}
	
    bl .uart_getc
    bl .uart_putc
    
    cmp r0,#0xd
    moveq r0,#0

    ldr r4,=idex
    ldrb r5,[r4]
    
    cmp r5,#0
    ldreq r1, =str0
    ldrne r1, =str1

    ldr r2,=count
	ldrb r3,[r2]
    
    strb r0,[r1,r3]
    add r3,#1
	strb r3,[r2]
    
    cmp r0,#0 // caso seja nulo
    bne 1f


    bl .buffer_print
    mov r3,#0
    strb r3,[r2]

    cmp r5,#0

    addeq r5,#1
    streq r5,[r4]

    movne r5,#0
    strne r5,[r4]

    blne cmp_str

    1:
    ldmfd sp!, {r0-r5, pc}


cmp_str:
	stmfd sp!,{r0-r2,lr}
	
	ldr r0, =str0
	ldr r1, =str1
	
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
	bl .print_string

	b 1f

	diferente:
	ldr r0,=netxt
	bl .print_string

	1:
	ldmfd sp!,{r0-r2,pc}


.buffer_print:

    stmfd sp!, {r0-r3, lr}  

    ldr r0, =trm1
    bl .print_string

    cmp r5,#0
        ldreq r0, =str0
        ldrne r0, =str1    
    //

    bl .print_string

    ldr r0, =trm
    bl .print_string

    ldmfd sp!, {r0-r3, pc}

trm:                     .asciz "\n\r> "
trm1:                    .asciz "\n--> "
netxt:                   .ascii " Strings Diferentes! \n\r> "
void:.word 0
eqtxt:                    .ascii " Strings Iguais! \n\r> "


.section .bss
.align 4
count: .word 0
idex: .word 0
str0: .fill 32
str1: .fill 32

