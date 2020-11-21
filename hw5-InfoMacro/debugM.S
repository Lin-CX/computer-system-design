.macro debugM

//--------------------------------------------------------------------------

 	stmfd	r13!, {r0-r12}
 	stmfd	r13!, {r0-r12}
 	//add		sp, sp, #104
 	mov		r9, sp				//old sp
 	mov		r10, lr				//save old lr
 	mov		r11, pc				//old pc
 	mrs		r12, cpsr			//old cpsr
 	//ldr 	r1, =uart_Channel_sts_reg0
 	ldr 	r5, =uart_TX_RX_FIFO0



	//r0
	ldr 	r1, =string
	ldr 	r0, =uart_Channel_sts_reg0
	bl		TX_loop
	mov		r3, r1
	ldmfd	r13!, {r0}
	bl		regPrint
	//r1
	mov		r1, r3						//continue to print string
	ldr 	r0, =uart_Channel_sts_reg0
	bl		TX_loop
	mov		r3, r1						//save string pointer
	ldmfd	r13!, {r1}
	mov		r0, r1
	bl		regPrint
	//r2
	mov		r1, r3
	ldr 	r0, =uart_Channel_sts_reg0
	bl		TX_loop
	mov		r3, r1
	ldmfd	r13!, {r2}
	mov		r0, r2
	bl		regPrint
	//r3
	mov		r1, r3
	ldr 	r0, =uart_Channel_sts_reg0
	bl		TX_loop
	mov		r4, r1
	ldmfd	r13!, {r3}
	mov		r0, r3
	bl		regPrint
	//r4
	mov		r1, r4
	ldr 	r0, =uart_Channel_sts_reg0
	bl		TX_loop
	mov		r3, r1
	ldmfd	r13!, {r4}
	mov		r0, r4
	bl		regPrint
	//r5
	mov		r1, r3
	ldr 	r0, =uart_Channel_sts_reg0
	bl		TX_loop
	mov		r3, r1
	ldmfd	r13!, {r5}
	mov		r0, r5
	ldr 	r5, =uart_TX_RX_FIFO0
	bl		regPrint
	//r6
	mov		r1, r3
	ldr 	r0, =uart_Channel_sts_reg0
	bl		TX_loop
	mov		r3, r1
	ldmfd	r13!, {r6}
	mov		r0, r6
	bl		regPrint
	//r7
	mov		r1, r3
	ldr 	r0, =uart_Channel_sts_reg0
	bl		TX_loop
	mov		r3, r1
	ldmfd	r13!, {r7}
	mov		r0, r7
	bl		regPrint
	//r8
	mov		r1, r3
	ldr 	r0, =uart_Channel_sts_reg0
	bl		TX_loop
	mov		r3, r1						//string pointer暂时先存到r3
	ldmfd	r13!, {r8}
	mov		r0, r8
	bl		regPrint


	mov		r4, r12		//r4 = old cpsr
	mov		r6, r9		//r6 = old sp
	mov		r7, r10		//r7 = old lr
	mov		r8, r11		//r8 = old pc

	//r9
	mov		r1, r3
	ldr 	r0, =uart_Channel_sts_reg0
	bl		TX_loop
	mov		r3, r1
	ldmfd	r13!, {r9}
	mov		r0, r9
	bl		regPrint
	//r10
	mov		r1, r3
	ldr 	r0, =uart_Channel_sts_reg0
	bl		TX_loop
	mov		r3, r1
	ldmfd	r13!, {r10}
	mov		r0, r10
	bl		regPrint
	//r11
	mov		r1, r3
	ldr 	r0, =uart_Channel_sts_reg0
	bl		TX_loop
	mov		r3, r1
	ldmfd	r13!, {r11}
	mov		r0, r11
	bl		regPrint
	//r12
	mov		r1, r3
	ldr 	r0, =uart_Channel_sts_reg0
	bl		TX_loop
	mov		r3, r1
	ldmfd	r13!, {r12}
	mov		r0, r12
	bl		regPrint
	//sp
	mov		r1, r3
	ldr 	r0, =uart_Channel_sts_reg0
	bl		TX_loop
	mov		r3, r1
	mov		r0, r6
	add		r0, r0, #104				//调用macro之前的sp value
	bl		regPrint
	//lr
	mov		r1, r3
	ldr 	r0, =uart_Channel_sts_reg0
	bl		TX_loop
	mov		r3, r1
	mov		r0, r7
	bl		regPrint
	//pc
	mov		r1, r3
	ldr 	r0, =uart_Channel_sts_reg0
	bl		TX_loop
	mov		r3, r1
	mov		r0, r8
	sub		r0, r0, #24
	bl		regPrint
	//cpsr
	mov		r1, r3					//print "cpsr = "
	ldr 	r0, =uart_Channel_sts_reg0
	bl		TX_loop
	mov		r3, r1
	mov		r0, r4					//reset old cpsr
	bl		cpsrPrint1				//下面改了一下
	mov		r3, r1					//此使r3应该是继续stirng的位置, 因为cpsrPrint1中有用到r3去TX_loop要重置
	mov		r0, r4					//reset old cpsr
	bl		cpsrPrintIF				//print IF mask bit
	mov		r3, r1					//和上面同理
	mov		r0, r4					//reset old cpsr
	bl		cpsrInstSS				//print cpsr instruction set state
	mov		r3, r1					//和上面同理
	mov		r0, r4					//reset old cpsr
	bl		cpsrPrintMode
	mov		r3, r1
	mov		r0, r4
	bl		regPrint				//print cpsr value
	mov		r1, r3					//print end part
	ldr 	r0, =uart_Channel_sts_reg0
	bl		TX_loop					//应该是跳回上面调用处
	msr		cpsr, r4				//reset the cpsr


	b		endmacro




cpsrPrint1:	//use r0, r1, r5

	//N or n
	mov		r1, r0
	ror		r1, #31
	ands	r1, r1, #1
	mov		r1, #78		//'N' ascii
	addeq	r1, r1, #32
	str		r1, [r5]
	//Z or z
	mov		r1, r0
	ror		r1, #30
	ands	r1, r1, #1
	mov		r1, #90		//'Z' ascii
	addeq	r1, r1, #32
	str		r1, [r5]
	//C or c
	mov		r1, r0
	ror		r1, #29
	ands	r1, r1, #1
	mov		r1, #67		//'C' ascii
	addeq	r1, r1, #32
	str		r1, [r5]
	//V or v
	mov		r1, r0
	ror		r1, #28
	ands	r1, r1, #1
	mov		r1, #86		//'V' ascii
	addeq	r1, r1, #32
	str		r1, [r5]
	//print ", " string
	mov		r1, r3
	ldr 	r0, =uart_Channel_sts_reg0
	b		TX_loop					//应该是跳回上面调用处

	//mov		pc, lr

cpsrPrintIF:	//use r0, r1, r3, r5

	mov		r1, r0					//print I mask bit
	ror		r1, #7
	ands	r1, r1, #1				//if r1&1 == 0
	mov		r1, #73
	addeq	r1, r1, #32				//print i
	str		r1, [r5]
	mov		r1, r0					//print F mask bit
	ror		r1, #6
	ands	r1, r1, #1				//if r1&1 == 0
	mov		r1, #70
	addeq	r1, r1, #32				//print f
	str		r1, [r5]

	mov		r1, r3					//print ", ARM mode, current mode = "
	ldr 	r0, =uart_Channel_sts_reg0
	b		TX_loop					//应该是跳回上面调用处

	//mov		pc, lr

cpsrInstSS:

	mov		r1, r0
	ror		r1, #24					//get Jazelle bit
	ands	r1, r1, #1
	movne	r1, #2					//if J bit is 1, r1 = 0b10
	mov		r2, r0
	ror		r2, #5					//get Thumb execution state bit
	ands	r2, r2, #1
	addne	r1, r1, r2				//if T bit is 1, r1 = 0b11
	//ARM mode
	mov		r2, #0
	cmp		r1, r2		//if equal, print ARM
	ldreq	r9, ='A'
	streq	r9, [r5]
	ldreq	r9, ='R'
	streq	r9, [r5]
	ldreq	r9, ='M'
	streq	r9, [r5]
	//Thumb mode
	mov		r2, #1
	cmp		r1, r2		//if equal, print Thumb
	ldreq	r9, ='T'
	streq	r9, [r5]
	ldreq	r9, ='h'
	streq	r9, [r5]
	ldreq	r9, ='u'
	streq	r9, [r5]
	ldreq	r9, ='m'
	streq	r9, [r5]
	ldreq	r9, ='b'
	streq	r9, [r5]
	//Jazelle mode
	mov		r2, #2
	cmp		r1, r2		//if equal, print Jazelle
	ldreq	r9, ='J'
	streq	r9, [r5]
	ldreq	r9, ='a'
	streq	r9, [r5]
	ldreq	r9, ='z'
	streq	r9, [r5]
	ldreq	r9, ='e'
	streq	r9, [r5]
	ldreq	r9, ='l'
	streq	r9, [r5]
	streq	r9, [r5]
	ldreq	r9, ='e'
	streq	r9, [r5]
	//ThumbEE mode
	mov		r2, #3
	cmp		r1, r2		//if equal, print ThumbEE
	ldreq	r9, ='T'
	streq	r9, [r5]
	ldreq	r9, ='h'
	streq	r9, [r5]
	ldreq	r9, ='u'
	streq	r9, [r5]
	ldreq	r9, ='m'
	streq	r9, [r5]
	ldreq	r9, ='b'
	streq	r9, [r5]
	ldreq	r9, ='E'
	streq	r9, [r5]
	streq	r9, [r5]

	mov		r1, r3					//print ", ARM mode, current mode = "
	ldr 	r0, =uart_Channel_sts_reg0
	b		TX_loop					//应该是跳回上面调用处

cpsrPrintMode:		//use r0, r1, r2, r3, r5

	mov		r1, r0
	and		r1, r1, #31
	//user mode
	mov		r2, #16
	cmp		r1, r2		//if equal, print USR
	ldreq	r9, ='U'
	streq	r9, [r5]
	ldreq	r9, ='S'
	streq	r9, [r5]
	ldreq	r9, ='R'
	streq	r9, [r5]
	//FIQ mode
	mov		r2, #17
	cmp		r1, r2		//if equal, print FIQ
	ldreq	r9, ='F'
	streq	r9, [r5]
	ldreq	r9, ='I'
	streq	r9, [r5]
	ldreq	r9, ='Q'
	streq	r9, [r5]
	//IRQ mode
	mov		r2, #18
	cmp		r1, r2		//if equal, print IRQ
	ldreq	r9, ='I'
	streq	r9, [r5]
	ldreq	r9, ='R'
	streq	r9, [r5]
	ldreq	r9, ='Q'
	streq	r9, [r5]
	//SVC mode
	mov		r2, #19
	cmp		r1, r2		//if equal, print SVC
	ldreq	r9, ='S'
	streq	r9, [r5]
	ldreq	r9, ='V'
	streq	r9, [r5]
	ldreq	r9, ='C'
	streq	r9, [r5]
	//MON mode
	mov		r2, #22
	cmp		r1, r2		//if equal, print MON
	ldreq	r9, ='M'
	streq	r9, [r5]
	ldreq	r9, ='O'
	streq	r9, [r5]
	ldreq	r9, ='N'
	streq	r9, [r5]
	//ABT mode
	mov		r2, #23
	cmp		r1, r2		//if equal, print ABT
	ldreq	r9, ='A'
	streq	r9, [r5]
	ldreq	r9, ='B'
	streq	r9, [r5]
	ldreq	r9, ='T'
	streq	r9, [r5]
	//HYP mode
	mov		r2, #26
	cmp		r1, r2		//if equal, print HYP
	ldreq	r9, ='H'
	streq	r9, [r5]
	ldreq	r9, ='Y'
	streq	r9, [r5]
	ldreq	r9, ='P'
	streq	r9, [r5]
	//UND mode
	mov		r2, #27
	cmp		r1, r2		//if equal, print UND
	ldreq	r9, ='U'
	streq	r9, [r5]
	ldreq	r9, ='N'
	streq	r9, [r5]
	ldreq	r9, ='D'
	streq	r9, [r5]
	//SYS mode
	mov		r2, #31
	cmp		r1, r2		//if equal, print SYS
	ldreq	r9, ='S'
	streq	r9, [r5]
	ldreq	r9, ='Y'
	streq	r9, [r5]
	ldreq	r9, ='S'
	streq	r9, [r5]

	mov		r1, r3					//print " ( =0x"
	ldr 	r0, =uart_Channel_sts_reg0
	b		TX_loop					//应该是跳回上面调用处




regPrint:	//use r0, r1, r5

	ldr		r1, ='0'
	str		r1, [r5]
	ldr		r1, ='x'
	str		r1, [r5]
	//28-31
	mov		r1, r0
	ror		r1, #28
	and		r1, r1, #15
	//ascii translate
	add		r1, r1, #48
	cmp		r1, #58
	addhs	r1, #39
	str		r1, [r5]
	//24-27
	mov		r1, r0
	ror		r1, #24
	and		r1, r1, #15
	//ascii translate
	add		r1, r1, #48
	cmp		r1, #58
	addhs	r1, #39
	str		r1, [r5]
	//23-20
	mov		r1, r0
	ror		r1, #20
	and		r1, r1, #15
	//a t
	add		r1, r1, #48
	cmp		r1, #58
	addhs	r1, #39
	str		r1, [r5]
	//16-19
	mov		r1, r0
	ror		r1, #16
	and		r1, r1, #15
	//a t
	add		r1, r1, #48
	cmp		r1, #58
	addhs	r1, #39
	str		r1, [r5]

	mov		r1, #'_'
	str		r1, [r5]

	//12-15
	mov		r1, r0
	ror		r1, #12
	and		r1, r1, #15
	//a t
	add		r1, r1, #48
	cmp		r1, #58
	addhs	r1, #39
	str		r1, [r5]
	//8-11
	mov		r1, r0
	ror		r1, #8
	and		r1, r1, #15
	//a t
	add		r1, r1, #48
	cmp		r1, #58
	addhs	r1, #39
	str		r1, [r5]
	//4-7
	mov		r1, r0
	ror		r1, #4
	and		r1, r1, #15
	//a t
	add		r1, r1, #48
	cmp		r1, #58
	addhs	r1, #39
	str		r1, [r5]
	//0-3
	mov		r1, r0
	and		r1, r1, #15
	//a t
	add		r1, r1, #48
	cmp		r1, #58
	addhs	r1, #39
	str		r1, [r5]

	mov		pc, lr		//return



TX_loop:	//use r0, r1, r2, r5
	// ---------  Check to see if the Tx FIFO is empty ------------------------------
	ldr r2, [r0]		// read Channel Status Register
	and	r2, r2, #0x8	// read Transmit Buffer Empty bit(bit[3])
	cmp	r2, #0x8		// check if TxFIFO is empty and ready to receive new data
	bne	TX_loop			// if TxFIFO is NOT empty, keep checking until it is empty
	//------------------------------------------------------------------------------

	ldrb	r2, [r1], #1
	//ldr 	r4, =uart_TX_RX_FIFO0
	strb	r2, [r5]	// fill the TxFIFO with 0x48
	cmp     r2, #0x00
	bne		TX_loop

	mov		pc, lr		// return to the caller

endmacro:

 	mov		lr, r7
	//ldmfd	r13!, {r0-r12}
	ldmfd	r13!, {r0-r12}
//--------------------------------------------------------------------------

.endm
