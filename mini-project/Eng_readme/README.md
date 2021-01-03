# Mini OS

### Intro.

An embedded miniOS scheduling 3 tasks.

- **Hardware** [Zynq-7000 XC7Z020-CLG484-1](http://www.zedboard.org/product/zedboard)

- **Development Toos**

    - **Vivado** (ver. 19.1)
    - **Xilinx SDK**

- All of 3 tasks run forever.

    - **Task1** Selection Sorting

        	Its outcome is displayed on LEDs.

    - **Task2** DhryStone Benchmark

        	Used to measure the CPU performance
	
        	Some messages will be printed on UART console.

    - **Task3** Hello World

        	Output to UART console.

- **Scheduling Algorithm** Round-Robin