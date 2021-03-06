#include "uart_regs.h"
#include "uart_init.s"

.align 8

// Our interrupt vector table
csd_entry:
	b csd_reset
	b .
	b .
	b .
	b .
	b .
	b .
	b .

.global main
.global csd_entry
csd_reset:
main:

	UART_init     // UART Initialization

	ldr r0, =uart_TX_RX_FIFO0
	ldr r1, =uart_Channel_sts_reg0

recvloop:
	// check empty: bit#1 is Rx FIFO empty or not (1: empty, 0: not empty)
	ldr r2, [r1]
	and r2, r2, #1<<1
	cmp r2, #0

	// read data and transmit it back to sender
	ldreq r3, [r0]
	streq r3, [r0]

	// if you type "return" (it seems like 
	// only 13 is stored in the buffer, which is "carriage return")
	// so, send "line feed" as well
	cmpeq r3, #13   // 0xD (13) is carriage return in ASCII
	moveq r4, #10 // 0xA (10) is linefeed in ASCII
	streq r4, [r0]

	b recvloop

