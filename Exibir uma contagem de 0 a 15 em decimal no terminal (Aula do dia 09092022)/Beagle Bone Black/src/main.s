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


    bl .gpio_setup
    bl .disable_wdt

    //print hw
    adr r0,hello
    bl .print_string
    mov r1, #0
    mov r2, #0

.main_loop:
    /* logical 1 turns on the led, TRM 25.3.4.2.2.2 */

    cmp r2,#15
    movhi r2,#0
    mov r0,r2
    bl .pnum

    ldr r0, =GPIO1_SETDATAOUT
    mov r1,r2
    lsl r1,#21
    str r1, [r0]
    bl .delay



    ldr r0, =GPIO1_CLEARDATAOUT

    mov r1,r2
    lsl r1,#21
    str r1, [r0]
    add r2,#1

    bl .delay
    b .main_loop    



.delay:
    ldr r1, =0xfffffff
.wait:
    sub r1, r1, #0x1
    cmp r1, #0
    bne .wait
    bx lr

/********************************************************
  Registers (see TRM 20.4.4.1):
    WDT_BASE -> 0x44E35000
    WDT_WSPR -> 0x44E35048
    WDT_WWPS -> 0x44E35034
********************************************************/
.gpio_setup:
    /* set clock for GPIO1, TRM 8.1.12.1.31 */
    ldr r0, =CM_PER_GPIO1_CLKCTRL
    ldr r1, =0x40002
    str r1, [r0]

    /* set pin 21 for output, led USR0, TRM 25.3.4.3 */
    ldr r0, =GPIO1_OE
    ldr r1, [r0]
    bic r1, r1, #(0xf<<21)
    str r1, [r0]
    bx lr

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
    stmfd sp!,{r1-r2,r14} // lr é a msm caisa de r14
    ldr r1,= UART0_BASE

.wait_uart_fifo_empty:

    ldr r2,[r1, #0x14]
    and r2,r2, #(1<<5)
    cmp r2,#0
    beq .wait_uart_fifo_empty

    strb r0,[r1]
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
 
.pnum:

  stmfd sp!,{r0-r2,lr} // push
  
  cmp r0,#9
  
  movhi r2,#0x31
  subhi r0,#0xa
  
  movls r2,#0x30
  
  add r0,#0x30

  ldr r1,= UART0_BASE
  
  strb r2,[r1]
  strb r0,[r1]
  
  mov r0, #0x20
  strb r0,[r1]
  
  ldmfd sp!,{r0-r2, pc}
bx lr



