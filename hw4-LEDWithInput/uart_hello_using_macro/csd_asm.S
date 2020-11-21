
#define csd_LED_ADDR	0x41200000

#include "uart_init.s"

.extern csd_main

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
csd_reset:
main:

	UART_init     // UART Initialization

forever:

	bl UART_hello // Print out "Hello World!"
	bl UART_hello // Print out "Hello World!"

	b forever


//
// UART_hello: A simple function to transmit "Hello World!"
//

UART_hello:

	ldr 	r1, =string
	ldr 	r0, =uart_Channel_sts_reg0

TX_loop:
	// ---------  Check to see if the Tx FIFO is empty ------------------------------
	ldr r2, [r0]		// read Channel Status Register
	and	r2, r2, #0x8	// read Transmit Buffer Empty bit(bit[3])
	cmp	r2, #0x8		// check if TxFIFO is empty and ready to receive new data
	bne	TX_loop			// if TxFIFO is NOT empty, keep checking until it is empty
	//------------------------------------------------------------------------------

	ldrb	r3, [r1], #1
	ldr 	r4, =uart_TX_RX_FIFO0
	strb	r3, [r4]	// fill the TxFIFO with 0x48
	cmp     r3, #0x00
	bne		TX_loop

	mov		pc, lr		// return to the caller

	.data
string:
	.ascii "Hello World!"
	.byte 0x0D
	.byte 0x0A
	.byte 0x00

