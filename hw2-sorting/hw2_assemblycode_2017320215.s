#define csd_LED_ADDR 0x41200000

.extern csd_main

.align 8

//Our interrupt vector table
csd_asm:
 	b csd_reset
 	b .
 	b .
 	b .
 	b .
 	b .
 	b csd_irq
 	b .

.global main
csd_reset:
main:
	ldr r0, =Input_data		//r0 is the address of input_data array
	ldr r1, =Output_data	//r1 is the address of output_data array
	mov r2, #32				//32 elements in array

outer:
    mov r3, #31
    bl  inner           //implement inner 32 times
    ldr r0, =Input_data	//reset r0 to be the address of input_data
    subs r2, r2, #1
 	bne outer			//ldr all 32 elements

	ldr r0, =Input_data	//reset r0 to be the address of input_data
    mov r2, #32
    b   loop

inner:
    ldr r4, [r0]            //arr[j]
    ldr r5, [r0, #4]        //arr[j+1]
    cmp r4, r5				//if arr[j] > arr[j+1]

    movge   r6, r4          //temp = arr[j]
    movge   r4, r5          //arr[j] = arr[j+1]
    movge   r5, r6          //arr[j+1] = temp
    strge   r4, [r0]        //if swapped, store the word to Input_data to keep the sorting
    strge   r5, [r0, #4]

    add r0, r0, #4          //j++

 	subs r3, r3, #1
 	bne inner			//ldr all 31 elements

    mov pc, lr          //return to outer

loop:
    ldr r4, [r0], #4		//load a word into r3 and update r0 (= r0 + 4)
 	str r4, [r1], #4		//store the word to memory and update r1 (= r1 + 4)

 	subs r2, r2, #1
 	bne loop			//ldr all 32 elements

 	ldr r0, =csd_LED_ADDR
 	mov r1, #0x5
 	str r1, [r0]

 	bl csd_main

forever:
	nop
 	b forever

.data
.align 4
Input_data:		.word 2, 0, -7, -1, 3, 8, -4, 10
				.word -9, -16, 15, 13, 1, 4, -3, 14
				.word -8, -10, -15, 6, -13, -5, 9, 12
				.word -11, -14, -6, 11, 5, 7, -2, -12

Output_data:	.word 0, 0, 0, 0, 0, 0, 0, 0
				.word 0, 0, 0, 0, 0, 0, 0, 0
				.word 0, 0, 0, 0, 0, 0, 0, 0
				.word 0, 0, 0, 0, 0, 0, 0, 0

src:
 	.word 1, 2, 3, 4, 5, 6, 7, 8
 	.word 11, 12, 13, 14, 15, 16, 17, 18

dst:
 	.space 16	//allocate memory for 16 words

//Normal Interrupt Service Routine
csd_irq:
	b .
