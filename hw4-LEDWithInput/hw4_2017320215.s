
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

	bl UART_text1 // Print out "Hello World!"
	bl UART_text2
	bl UART_text1

	b	LED


//
// UART_hello: A simple function to transmit "Hello World!"
//

UART_text1:

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

UART_text2:

	ldr 	r0, =uart_Channel_sts_reg0
	ldr 	r4, =uart_TX_RX_FIFO0


RX_loop:
	// --------------receive the data-----------------
	ldr r2, [r0]		// read Channel Status Register
	and	r2, r2, #0x8	// read Transmit Buffer Empty bit(bit[3])
	cmp	r2, #0x8		// check if TxFIFO is empty and ready to receive new data
	bne	RX_loop			// if TxFIFO is NOT empty, keep checking until it is empty
	//---------------------------------------------------

	ldrb	r3, [r4]	//read data from teraterm
	cmp		r3, #0x0
	beq		RX_loop		//keep check until get input

	strb	r3, [r4]	// fill the read data into fifo
	//strb	r3, [r5]
	mov		r5, r3		//r5 = r3

	ldr 	r1, =linefeed	//line feed
	ldr 	r0, =uart_Channel_sts_reg0
	b		TX_loop

	//mov		pc, lr		// return to the caller

/*gtc:
	// ----------go to c code----------
	ldrb	r6, [r5]
	str		r6, [r5]		//for read in c code 为了让c代码更好读取byte值*/




LED:

	//Check for input
	ldr 	r8, =uart_TX_RX_FIFO0
	ldrb	r7, [r8]	//read data from teraterm
	cmp		r7, #0
	strneb	r7, [r8]	//if input new data, fill the data into fifo
	movne	r5, r7

	ldrne 	r1, =linefeed	//line feed
	ldrne 	r0, =uart_Channel_sts_reg0
	blne	TX_loop
	cmp		r7, #0
	ldrne	r1, =string		//print menu
	blne	TX_loop

	//LED operation
	sub		r6, r5, #48		//char type to integer t
	cmp		r6, #8
	moveq	r6, #10			//if input is 8, delay 1 sec

	ldr		r0, =#34000000	//1 msec
	mul		r0, r0, r6		//t msec

	ldr		r1, =csd_LED_ADDR
	mov		r2, #0x1
	mov		r3, #0x8

	//Check for input



	b		LEDLoop


LEDLoop:
	str		r2, [r1]
	mov		r4, r0
	bl		Delay			//delay t msec
	mov		r2, r2, LSL #1	//1, 2, 4, 8, ..., 128

	subs	r3, r3, #1		//loop 8 times
	bne		LEDLoop
	b		LED



Delay:
	subs	r4, r4, #1
	moveq	pc, lr
	b		Delay


	.data
string:
	.ascii "----------------- LED On Duration ----------------"
	.byte 0x0D
	.byte 0x0A
	.ascii "1. 100ms 2. 200ms 3. 300ms 4. 400 ms"
	.byte 0x0D
	.byte 0x0A
	.ascii "5. 500ms 6. 600ms 7. 700ms 8. 1 sec"
	.byte 0x0D
	.byte 0x0A
	.ascii "---------------------------------------------------"
	.byte 0x0D
	.byte 0x0A
	.ascii "Select: "
	.byte 0x00


linefeed:
	.byte 0x0D
	.byte 0x0A
	.byte 0x00
