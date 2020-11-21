#include "uart_init.s"
#include "csd_zynq_peripherals.h"
#include "debugM.s"

.extern csd_main

#define csd_LED_ADDR	0x41200000
#define TIMER_INITIAL	0x400000

.align 8

//Our interrupt vector table
csd_asm:
 	b csd_reset
 	b .
 	b .
 	b .
 	b .
 	b .
 	//b csd_irq
 	b .
 	b .

.global main
csd_reset:


main:

	UART_init     // UART Initialization

	// --------------------------------------
	//  To distribute the learning burden.
	// -- stack is NOT used in private timer code
	// -- stack will be used in the interrupt code
	// --------------------------------------

	mrs	r0, cpsr			/* get the current PSR */
	mvn	r1, #0x1f			/* To mask out the MODE bits (M[4:0]) in CPSR */
	and	r2, r1, r0
	orr	r2, r2, #0x1F		/* SYS mode 11111*/
	msr	cpsr, r2

 	// Private Timer Load Register
	ldr r0, =PRIVATE_LOAD
 	ldr r1, =TIMER_INITIAL	// 0x400000
 	str r1, [r0]

 	// Private Timer Control Register
  	ldr r0, =PRIVATE_CONTROL
 	mov r1, #79 << 8   // Prescalar
 	orr r1, r1, #7     // IRQ Enable, Auto-Reload, Timer Enable
 	str r1, [r0]

 	// Check out the counter value to make sure the counter is decrementing
  	ldr r0, =PRIVATE_COUNTER
  	ldr r1, [r0]
  	ldr r2, [r0]
  	ldr r3, [r0]
  	ldr r4, [r0]
  	ldr r5, [r0]
  	ldr r6, [r0]
  	ldr r7, [r0]
  	ldr r8, [r0]

  	ldr r0, =PRIVATE_COUNTER
  	ldr r1, =PRIVATE_STATUS

	// Turn on LEDs just for testing
 	ldr  r10, =csd_LED_ADDR
	mov  r11, #0xF
	strb r11, [r10]

forever:	//use r0, r1, r5, r6, r10, r12
/*
  	ldr r5, [r0]   // Read the counter value
  	ldr r6, [r1]   // Read the status register

	// Toggle LEDs if the counter value reaches to 0
	cmp r6, #1
	eoreq  r11, r11, #0xFF	// exclusive or operation
	streqb r11, [r10]		// r10 is LED address

	moveq	r12, #1
	streq	r12, [r1] 		// to clear sticky bit in the status register

	b		forever
*/
	b		csd_main


.data
.align 4

string:
	//.ascii "------------------------------------------------------------------------------"
	.byte 0x0D
	//.byte 0x0A
	//.byte 0x00







src:
 	.word 1, 2, 3, 4, 5, 6, 7, 8
 	.word 11, 12, 13, 14, 15, 16, 17, 18

dst:
 	.space 16	//allocate memory for 16 words

//Normal Interrupt Service Routine
csd_irq:
	b .
