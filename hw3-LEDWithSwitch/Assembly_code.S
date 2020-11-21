#define csd_LED_ADDR 0x41200000
#define csd_SW_ADDR 0x41210000

.extern csd_main

.align 8

//Our interrupt vector table
/*csd_asm:
 	b csd_reset
 	b .
 	b .
 	b .
 	b .
 	b .
 	b csd_irq
 	b .*/

.global main
csd_reset:
main:

	ldr r0, =csd_SW_ADDR	//r0 is the switch input address
	ldr r2, =temp			//r2 is the temp address

forever:
	ldr r1, [r0]			//read data from SW
	str r1, [r2]			//write switch input to temp

	//b forever

.data
.align 4

temp:
	.space 1

src:
 	.word 1, 2, 3, 4, 5, 6, 7, 8
 	.word 11, 12, 13, 14, 15, 16, 17, 18

dst:
 	.space 16	//allocate memory for 16 words

//Normal Interrupt Service Routine
csd_irq:
	b .
