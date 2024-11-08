/*nome: Juan Pablo Rufino Mesquita
 matricula: 509982
 */

.global _start

	/* Clock */
    .equ CM_PER_GPIO1_CLKCTRL, 0x44e000AC

    /* Watch Dog Timer */
    .equ WDT_BASE, 0x44E35000

    /* GPIO */
    .equ GPIO1_OE, 0x4804C134
    .equ GPIO1_SETDATAOUT, 0x4804C194
    .equ GPIO1_CLEARDATAOUT, 0x4804C190

    /*UART0*/
    .equ UART0_BASE, 0x44e09000

_start:
    /* init */
    mrs r0, cpsr
    bic r0, r0, #0x1F @ clear mode bits
    orr r0, r0, #0x13 @ set SVC mode
    orr r0, r0, #0xC0 @ disable FIQ and IRQ
    msr cpsr, r0


    bl .disable_wdt

    adr r0,hello
    bl .print_string

    adr r0, _start
    bl .printcode
    
    .main_loop:
    b .main_loop

/********************************************************
    carrega o valor armaxenado no r0 e inicia o processo
    de indentificação se é o final do código, se sim, 
    encerr, caso contrário, executa a impressao.
********************************************************/
.printcode:
	stmfd sp!,{r0-r2,lr}
	
    0:
	ldr r1,[r0]
    ldr r2,=#0x0000aaaa
	cmp r1,r2
	
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
		bl .uart_putc
	
    	mov r0,#10
		bl .uart_putc
		
		
	ldmfd sp!,{r0-r2,pc}
	
.hex2axcii:
	stmfd sp!,{r1,lr}
	cmp r0,#9
	//se for menor
	addls r0,#0x30
    //se for maior
	subhi r0,#10
	addhi r0,#0x41
	bl .uart_putc
	ldmfd sp!,{r1,pc}

/********************************************************
  WDT disable sequence (see TRM 20.4.3.8):
    1- Write XXXX AAAAh in WDT_WSPR.
    2- Poll for posted write to complete using WDT_WWPS.W_PEND_WSPR. (bit 4)
    3- Write XXXX 5555h in WDT_WSPR.
    4- Poll for posted write to complete using WDT_WWPS.W_PEND_WSPR. (bit 4)
    
  Registers (see TRM 20.4.4.1):
    WDT_BASE -> 0x44E35000
    WDT_WSPR -> 0x44E35048
    WDT_WWPS -> 0x44E35034
********************************************************/
.disable_wdt: 
    /* TRM 20.4.3.8 */
    stmfd sp!,{r0-r1,lr}
    ldr r0, =WDT_BASE
    
    ldr r1, =0xAAAA
    str r1, [r0, #0x48]
    bl .poll_wdt_write

    ldr r1, =0x5555
    str r1, [r0, #0x48]
    bl .poll_wdt_write

    ldmfd sp!,{r0-r1,pc}

.poll_wdt_write:
    ldr r1, [r0, #0x34]
    and r1, r1, #(1<<4)
    cmp r1, #0
    bne .poll_wdt_write
    bx lr
/********************************************************/

/*uart put c char*/
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

.print_string:
 stmfd sp!,{r0-r2,lr} // push
 mov r1,r0

.print:
    ldrb r0,[r1],#1
    and r0,r0,#0xff
    cmp r0,#0
    beq .end_print
    bl .uart_putc 
    b .print

.end_print:
    ldmfd sp!,{r0-r2, pc} // pop

hello: .asciz "hello wolrd! \n\r"



