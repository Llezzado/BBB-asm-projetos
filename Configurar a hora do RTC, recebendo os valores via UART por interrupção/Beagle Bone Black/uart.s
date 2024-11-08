/* Global Symbols */
.global .uart_setup
.global .uart_putc
.global .uart_getc
.global .uart_isr
.global .buffer
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
/********************************************************
.uart_isr: tratador de interrupção*
********************************************************/
.uart_isr:
    stmfd sp!, {r0-r3, lr}
	
    adr r2, .count
	ldrb r3,[r2]
    

    /*caso seja a primeiravez q é escrito*/
    cmp r3,#0
    bleq .rtc_off
    ldreq r0,=trm
    bleq .print_string

    bl .uart_getc
    bl .uart_putc
    
    //se for enter
    cmp r0,#0xd
    moveq r0,#0
    beq 0f
    
    //caso não seja um numero
    cmp r0,#0x30
    blo 1f
    cmp r0,#0x39
    bhi 1f

    0:
    //caso não seja enter//
    ldr r1, =buffer
    strb r0,[r1,r3]
    add r3,#1
	strb r3,[r2]

    cmp r0,#0
    bne 1f
    
    /*caso seja enter*/
    mov r3,#0
    strb r3,[r2] 
    
    //bl .uart_buffer_print
    bl .uart_enter
    bl .uart_to_rtc
    
    bl .rtc_set_timer
    
    bl .rtc_setup
    /**/


    1:
    ldmfd sp!, {r0-r3, pc}
/********************************************************
.uart_to_rtc: 
retorna no r0 todos os 6 numeros armazenados no bufer
********************************************************/

.uart_to_rtc:
    stmfd sp!, {r1-r3, lr}
    ldr r1,=buffer
    mov r2,#0
    mov r3,#0

    0:
    ldrb r0,[r1],#1
    bl .ascii_to_dec
    lsl r3,#4
    orr r3,r0
    cmp r2,#4
    addls r2,#1
    bls 0b

    mov r0,r3
    ldmfd sp!, {r1-r3, pc}


/********************************************************
.uart_buffer_print:
    imprime na tela os valores salvos no buffer
********************************************************/

.uart_buffer_print:

    stmfd sp!, {r0, lr}

    ldr r0, =trm1
    bl .print_string

    ldr r0, =buffer
    bl .print_string

    ldr r0, =nl
    bl .print_string

    ldmfd sp!, {r0, pc}
    
.uart_enter:

    stmfd sp!, {r0, lr}

    ldr r0, =nl
    bl .print_string

    ldmfd sp!, {r0, pc}


trm:                     .asciz "\n\r> "
nl:                     .asciz "\n\r"
trm1:                    .asciz "\n-> "

.global .count 
.count: .word 0

.section .bss
.align 4


.global .buffer
buffer: .fill 8


