// ------------------------------------------
//  Author: Prof. Taeweon Suh
//          Computer Science & Engineering
//          College of Informatics, Korea Univ.
//  Date:   May 06, 2020
// ------------------------------------------

#include "csd_zynq_peripherals.h"
#include "uart_init.s"

//#define	TIMER_INITIAL   0x000877F7
#define	TIMER_INITIAL   0x0000A298

.align 5

csd_vector_table:
	b .
	b .
	b .//csd_SVC_ISR
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
	cps #0x12               // IRQ mode
	ldr	r13,=irq_stack_top  // Stack pointer setup for IRQ mode

	cps #0x13               // supervisor mode
	ldr	r13,=svc_stack_top  // Stack pointer setup for SVC mode

	cps #0x11               // FIQ mode
	ldr	r13,=fiq_stack_top  // Stack pointer setup for FIQ mode

    cps #0x1F               // SYS mode

	// Set VBAR (Vector Base Address Register) to my vector table
	ldr     r0, =csd_vector_table
	mcr     p15, 0, r0, c12, c0, 0
	dsb		// 因为有周期延迟 所以防止后面指令用的是旧registers 使用dsb, isb确保
	isb

	// Enable interrupt: CPSR'I = 0
	//cpsIE i


// ---------------------------
// UART Initialization - Begin
// ---------------------------

	UART_init

// ----------------------------
// UART Initialization - End
// ----------------------------


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

	/*// Interrupt Set-Enable Register 0
	ldr r0, =GICD_ISENABLER0
	ldr r1, [r0]
	mov r2, #1 << 3	   // Enable #3 (SGI# 3)
	orr r1, r1, r2
	str r1, [r0]
	ldr r3, [r0]*/

	// According to specifications,
	// Cortex-A9 supports 5-bit version of priority format [7:3] in secure world
	// ( 0 -> 8 -> 16 -> 24...)

	// Interrupt Priority Register #7 - Private Timer
	ldr r0, =GICD_PRIOR7
	ldr r1, [r0]
	mov r2, #0x8 << 8    // Priority 8 for ID# 29 (Private Timer)
	orr r1, r1, r2
	str r1, [r0]
	ldr r3, [r0]

	// Interrupt Priority Register #0 - SGI
	ldr r0, =GICD_PRIOR0
	ldr r1, [r0]
	mov r2, #0x8 << 24      // Priority 8 for ID# 3 (SGI# 3)
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
	mov r2, #0xFF     // Lowest 因为cortex A9是5-bit version 所以PMR实际上是被设定成F8即1111 1000
	orr r1, r1, r2
	str r1, [r0]
	ldr r3, [r0]

// ---------------------------
// Generic Interrupt Controller (GIC) setup - End
// ---------------------------


	// Generate SGI
	// GICD_SGIR is Write-Only (WO)
	ldr r0, =GICD_SGIR
	mov r1, #0
	mov r2, #1<<16      // CPUTargetList (CPU Interface 0)
	orr r1, r1, r2
	mov r2, #3          // ID = 3	generated SGI# 3
	orr r1, r1, r2
	str r1, [r0]

	// Enable IRQ and Change to User Mode
	cpsie i, 0x10


waitSGI:

	// SGI配置完之后将openTask的值改为0 如果是0则表示SGI结束了
	ldr	r0, =openTask
	ldr	r1, [r0]
	cmp r1, #0

	bne	waitSGI

runTasks:

	bl	branchToTask1
	bl	branchToTask2
	bl	branchToTask3


branchToTask1:
	ldr	r0, =openTask
	mov	r1, lr
	str	r1, [r0, #4]		// 将open下一个task的pc保存到openTask[1]
	ldr	sp, =task1stack_top
	bl	task1_c

branchToTask2:
	ldr	r0, =openTask
	mov	r1, lr
	str	r1, [r0, #4]		// 将open下一个task的pc保存到openTask[1]
	ldr	sp, =task2stack_top
	//bl	csd_main
	//bl	task3_c
	bl	task2_c

branchToTask3:
	ldr	r0, =openTask
	mov	r1, lr
	str	r1, [r0, #4]		// 将open下一个task的pc保存到openTask[1]
	ldr	sp, =task3stack_top
	bl	task3_c

end:
	nop
	b	end


// ----------------------------
// Interrupt Service Routines (ISRs) - Begin
// ----------------------------

csd_IRQ_ISR:

	stmfd sp!, {r0-r12, lr}

	// Interrupt Ack
  	ldr r0, =GICC_IAR
	ldr r3, [r0]

	// if openTask != 3, tasks are not all open yet
	ldr	r0, =openTask
	ldr	r1, [r0]
	cmp	r1, #2
	bls	openProgram

	// if ID# is 3, it's SGI interrupt
	cmp	r3, #3
	beq	taskScheduling

	// if all tasks have been open, context switch
	cmp	r1, #3
	beq	contextSwitch


taskScheduling:

// ---------------------------
// Set the timer interval to 1ms for task scheduling - Begin
// ---------------------------

 	// Private Timer Load Register
	ldr r0, =PRIVATE_LOAD
 	ldr r1, =TIMER_INITIAL
 	str r1, [r0]

 	// Private Timer Control Register
  	ldr r0, =PRIVATE_CONTROL
 	mov r1, #7 << 8   // Prescalar
 	//mov r1, #63 << 8   // Prescalar
 	orr r1, r1, #7     // IRQ Enable, Auto-Reload, Timer Enable
 	str r1, [r0]

// ----------------------------
// Private Timer setup - End
// ----------------------------

	// openTask[0]改为0用以退出waitSGI
	ldr	r0, =openTask
	mov	r1, #0
	str	r1, [r0]

// SGI配置结束后直接在这里结束interrupt

	// End-of-Interrupt
  	ldr r0, =GICC_EOIR
	str r3, [r0]

	ldmfd sp!, {r0-r12, lr}

	// IRQ sp = task1State_top so program will push data in task1 memory space when next interrupt
	ldr	sp, =task1State_top

	subs pc, lr, #4


openProgram:
// 识别当前task, 保存寄存器数据到TCB并切换到下一个task, openTask自加
// r1 == 0时表示task1要切换到task2 以此类推

	cmp	r1, #0
	beq	afterOpenTask1
	cmp	r1, #1
	beq	afterOpenTask2
	cmp	r1, #2
	beq	afterOpenTask3


afterOpenTask1:
//	在openTask1中
//	openTask自加1,
//	不用ldm, 结束interrupt, 并用movs返回到第二个task的pc而不是lr

	// openTask[0] += 1
	add	r1, #1
	str	r1, [r0]
	ldr	lr, [r0, #4]	// openTask[1] saved the pc of 'bl branchToTask2' instruction

	// save sp, lr, cpsr to task1 memory space
	ldr	r0, =task1register_top
	mrs	r12, spsr
	stmfd	r0!, {r12-lr}^

	// replace task1 sp with task2 sp
	ldr	sp, =task2State_top

	// End-of-Interrupt
  	ldr r0, =GICC_EOIR
	str r3, [r0]

	movs	pc, lr		// go back to 'bl branchToTask3' instruction


afterOpenTask2:
//	和openTask1同理

	// openTask[0] += 1
	add	r1, #1
	str	r1, [r0]
	ldr	lr, [r0, #4]	// openTask[1] saved the pc of 'bl branchToTask3' instruction

	// save sp, lr, cpsr to task2 memory space
	ldr r0, =task2register_top
	mrs	r12, spsr
	stmfd	r0!, {r12-lr}^

	// replace task2 sp with task3 sp
	ldr	sp, =task3State_top

	// End-of-Interrupt
  	ldr r0, =GICC_EOIR
	str r3, [r0]

	movs	pc, lr		// go back to 'bl branchToTask3' instruction



afterOpenTask3:
	// openTask[0] += 1
	add	r1, #1
	str	r1, [r0]

	// save sp, lr, cpsr to task3 memory space
	ldr r0, =task3register_top
	mrs	r12, spsr
	stmfd	r0!, {r12-lr}^
	// read sp, lr, cpsr from task1 memory space
	ldr	r0, =task1register_top
	sub	r0, #12
	ldmfd	r0!, {r12-lr}^
	msr	spsr, r12

	// replace task3 sp with task1 sp
	ldr	sp, =task1State_top
	sub	sp, #0x38

	// End-of-Interrupt
  	ldr r0, =GICC_EOIR
	str r3, [r0]

	ldmfd sp!, {r0-r12, lr}		// pop the registers of task1
	subs	pc, lr, #4			// go back to task1


contextSwitch:

	ldr	r0, =currentTask
	ldr	r1, [r0]
	// if currentTask[0] < 2, it means system should switch to task2
	cmp	r1, #2
	bllo	task1TCB
	// if currentTask[0] == 2, goto task2TCB
	bleq	task2TCB
	// if currentTask[0] > 2, goto task3TCB to switch to task1
	blhi	task3TCB


	// End-of-Interrupt
  	ldr r0, =GICC_EOIR
	str r3, [r0]

	ldmfd sp!, {r0-r12, lr}
	subs	pc, lr, #4


task1TCB:
//	在task1TCB中
//	currentTask的值要变成2, 将sp改成task2的以pop task2的registers
//

	// currentTask[0] = 2
	mov	r1, #2
	str	r1, [r0]

	// save sp, lr, cpsr to task1 memory space
	ldr	r0, =task1register_top
	mrs	r12, spsr
	stmfd	r0!, {r12-lr}^
	// read sp, lr, cpsr from task2 memory space
	ldr	r0, =task2register_top
	sub	r0, #12
	ldmfd	r0!, {r12-lr}^
	msr	spsr, r12


	// replace task1 sp with task2 sp
	ldr	sp, =task2State_top
	sub	sp, #0x38

	mov	pc, lr


task2TCB:
//	同Task2TCB

	// currentTask[0] = 3
	mov	r1, #3
	str	r1, [r0]

	// save sp, lr, cpsr to task2 memory space
	ldr	r0, =task2register_top
	mrs	r12, spsr
	stmfd	r0!, {r12-lr}^
	// read sp, lr, cpsr from task3 memory space
	ldr	r0, =task3register_top
	sub	r0, #12
	ldmfd	r0!, {r12-lr}^
	msr	spsr, r12

	// replace task2 sp with task3 sp
	ldr	sp, =task3State_top
	sub	sp, #0x38

	mov	pc, lr

task3TCB:
//	同Task2TCB

	// currentTask[0] = 1
	mov	r1, #1
	str	r1, [r0]

	// save sp, lr, cpsr to task3 memory space
	ldr	r0, =task3register_top
	mrs	r12, spsr
	stmfd	r0!, {r12-lr}^
	// read sp, lr, cpsr from task1 memory space
	ldr	r0, =task1register_top
	sub	r0, #12
	ldmfd	r0!, {r12-lr}^
	msr	spsr, r12

	// replace task3 sp with task1 sp
	ldr	sp, =task1State_top
	sub	sp, #0x38

	mov	pc, lr


.data
.align 4

irq_stack:     .space 1024
irq_stack_top:	// 表示比irq_stack 1byte above, 因为要先自减再push
fiq_stack:     .space 1024
fiq_stack_top:
svc_stack:     .space 1024
svc_stack_top:


// allocate 14 words size memory space for 14 registers
task1State:	.space 1024
task1State_top:
task2State:	.space 1024
task2State_top:
task3State:	.space 1024
task3State_top:

// 开启一次task则加一, 当变成3时则表示三个task均已open
// 第二个word表示开启task时的pc数据
openTask: .word	0xA, 0x0

// 记录接下来要运行什么task
currentTask: .word	0x1

// taskn的lr
task1register: .space 1024
task1register_top:
task2register: .space 1024
task2register_top:
task3register: .space 1024
task3register_top:

// tskn的stack
task1stack: .space	2048
task1stack_top:
task2stack: .space	2048
task2stack_top:
task3stack: .space	2048
task3stack_top:
