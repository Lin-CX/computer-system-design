// ------------------------------------------
//  Author: Prof. Taeweon Suh
//          Computer Science & Engineering
//          College of Informatics, Korea Univ.
//  Date:   May 06, 2020
// ------------------------------------------

#include "csd_zynq_peripherals.h"
#include "uart_init.s"

#define	TIMER_INITIAL	0x004f64b4

.align 5

csd_vector_table:
	b .
	b .
	b .
	b .
	b .
	b .
	b csd_IRQ_ISR
	b .

.global main
main:

	// Disable interrupt: CPSR'I = 1
	cpsID i

	// if mode is different, r13 is different
	cps #0x12	   	       // IRQ mode
	ldr	r13,=irq_stack_top // Stack pointer setup for IRQ mode

	cps #0x13		          // supervisor mode
	ldr	r13,=svc_stack_top // Stack pointer setup for SVC mode

	cps #0x11		          // FIQ mode
	ldr	r13,=fiq_stack_top // Stack pointer setup for FIQ mode

	cps #0x1F	             // SYS mode

	// Set VBAR (Vector Base Address Register) to my vector table
	ldr     r0, =csd_vector_table
	mcr     p15, 0, r0, c12, c0, 0
	dsb		// 因为有周期延迟 所以防止后面指令用的是旧registers 使用dsb, isb确保
	isb

	// Enable interrupt: CPSR'I = 0
	cpsIE i

// ---------------------------
// Generic Interrupt Controller (GIC) setup - Begin
// ---------------------------

	// CPU Interface ID Register
	ldr r0, =GICC_IIDR
	ldr r3, [r0]

	// CPU Controller Type Register
	ldr r0, =GICD_TYPER
	ldr r3, [r0]

	// CPU Binary Pointer Register
	ldr r0, =GICC_BPR
	ldr r3, [r0]

	// Distributor Control Register
	ldr r0, =GICD_CTLR
	ldr r1, [r0]
	mov r2, #1       // Enable
	orr r1, r1, r2
	str r1, [r0]
	ldr r3, [r0]

	 // Interrupt Set-Enable Register 0
	ldr r0, =GICD_ISENABLER0
	ldr r1, [r0]
	mov r2, #1 << 29   // Enable #29 (Private Timer)
	orr r1, r1, r2
	str r1, [r0]
	ldr r3, [r0]

	// According to specifications,
	// Cortex-A9 supports 5-bit version of priority format [7:3] in secure world
	// ( 0 -> 8 -> 16 -> 24...)

	// Interrupt Priority Register #7
	ldr r0, =GICD_PRIOR7
	ldr r1, [r0]
	mov r2, #0x10 << 8    // Priority 16 for ID# 29 (Private Timer)
	orr r1, r1, r2
	str r1, [r0]
	ldr r3, [r0]

	// CPU Interface Control Register
	ldr r0, =GICC_CTLR
	ldr r1, [r0]
	mov r2, #1        // Enable
	orr r1, r1, r2
	str r1, [r0]
	ldr r3, [r0]

 	// CPU Interface Interrupt Priority Mask Register
	ldr r0, =GICC_PMR
	ldr r1, [r0]
	mov r2, #0xFF     // Lowest
	orr r1, r1, r2
	str r1, [r0]
	ldr r3, [r0]

// ---------------------------
// Generic Interrupt Controller (GIC) setup - End
// ---------------------------


// ---------------------------
// Private Timer setup - Begin
// ---------------------------

	UART_init		// UART Initialization

 	// Private Timer Load Register
	ldr r0, =PRIVATE_LOAD
 	ldr r1, =TIMER_INITIAL
 	str r1, [r0]

 	// Private Timer Control Register
  	ldr r0, =PRIVATE_CONTROL
 	mov r1, #63 << 8   // Prescalar
 	orr r1, r1, #7     // IRQ Enable, Auto-Reload, Timer Enable
 	str r1, [r0]

// ----------------------------
// Private Timer setup - End
// ----------------------------

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
	ldr r2, =GICD_ISPENDR0

forever:
	ldr r5, [r0]
	ldr r6, [r1]
	ldr r7, [r2]
	b forever


// ----------------------------
// Interrupt Service Routines (ISRs) - Begin
// ----------------------------

csd_IRQ_ISR:

	stmfd sp!, {r0-r12, lr}

 	// Interrupt Ack
  	ldr r0, =GICC_IAR
	ldr r3, [r0]

 	// Toggle LEDs
	ldr r0, =csd_LED_ADDR
	ldr r1, =led_value
	ldr r2, [r1]
	eor r2, r2, #0xFF
	str r2, [r0]
	str r2, [r1]

/********************************************************************************/
	// Display time, 可使用r0-r2, r4-r12
	ldr	r10, =uart_TX_RX_FIFO0
	ldr	r11, =time_value
	ldr	r12, =time_value

	ldr	r0, [r11], #4	//hour
	ldr	r1, [r11], #4	//minute
	ldr	r2, [r11]		//second

	cmp	r2, #60		//carry second to minute
	addeq	r1, #1
	moveq	r2, #0
	cmp	r1, #60		//carry minute to hour
	addeq	r0, #1
	moveq	r1, #0

	// display hours
	cmp	r0, #9
	movls	r4, #48
	strls	r4, [r10]
	addls	r4, r0, #48
	strls	r4, [r10]

	movhi	r4, r0			// r4 = r0
	movhi	r7, #0
	movhi	r8, #0
	blhi	getTenOne		// return r5, r6 be ten# and one#
	cmp	r0, #9				// cpsr is changed, cmp again
	strhi	r7, [r10]
	strhi	r8, [r10]
	movhi	r7, #0
	movhi	r8, #0

	// display " : "
	mov	r4, #32
	str	r4, [r10]
	mov	r4, #58
	str	r4, [r10]
	mov	r4, #32
	str	r4, [r10]

	// display minutes
	cmp	r1, #9
	movls	r4, #48
	strls	r4, [r10]
	addls	r4, r1, #48
	strls	r4, [r10]

	movhi	r4, r1			// r4 = r1
	movhi	r7, #0
	movhi	r8, #0
	blhi	getTenOne		// return r7, r8 be ten# and one#
	cmp	r1, #9				// 这里之后要重新cmp 因为cpsr改变了
	strhi	r7, [r10]
	strhi	r8, [r10]
	movhi	r7, #0
	movhi	r8, #0

	// display " : "
	mov	r4, #32
	str	r4, [r10]
	mov	r4, #58
	str	r4, [r10]
	mov	r4, #32
	str	r4, [r10]

	// display seconds
	cmp	r2, #9
	movls	r4, #48
	strls	r4, [r10]
	addls	r4, r2, #48
	strls	r4, [r10]

	movhi	r4, r2			// r4 = r0
	movhi	r7, #0
	movhi	r8, #0
	blhi	getTenOne		// return r7, r8 be ten# and one#
	cmp	r2, #9				// 这里之后要重新cmp 因为cpsr改变了
	strhi	r7, [r10]
	strhi	r8, [r10]

	// carriage return
	mov	r4, #0x0D
	str	r4, [r10]

	// seconds++
	add	r2, #1

	str r0, [r12], #4
	str	r1, [r12], #4
	str	r2, [r12]
/********************************************************************************/

 	// Clear Interrupt Status bit
  	ldr r0, =PRIVATE_STATUS
  	mov r1, #1
	str r1, [r0]

 	// End-of-Interrupt
  	ldr r0, =GICC_EOIR
	str r3, [r0]

	ldmfd sp!, {r0-r12, lr}
	subs pc, lr, #4

getTenOne:
	sub	r4, #10			// r4 = r4 - 10
	add	r7, #1			// r7++
	mov	r8, r4

	cmp	r4, #9			// if (r4 > 9), keep on
	bhi	getTenOne

	add	r7, #48
	add	r8, #48

	mov	pc, lr

// ----------------------------
// Interrupt Service Routines (ISRs) - End
// ----------------------------

.data
.align 4

irq_stack:     .space 1024
irq_stack_top:	// 表示比irq_stack 1byte above, 因为要先自减再push
fiq_stack:     .space 1024
fiq_stack_top:
svc_stack:     .space 1024
svc_stack_top:

led_value: .word 	0xC3
time_value: .word	0x0, 0x0, 0x0
