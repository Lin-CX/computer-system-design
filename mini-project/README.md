# Mini-project introduction
Project 内容：  
通过interrupt实现三个tasks的循环不停地运行。  
三个tasks分别实现内容是：  
task1：选择排序。 结果通过LED显示。  
task2：运行DhryStone Benchmark，其中会运行各种functions。运行结束后会在terminal上显示Task2 finished。  
task3：Hello World的显示

# 实现过程
1. 首先设置各个mode下的栈位置(pointer)，即分配栈空间。
2. 设置interrupt各个相关寄存器的信息，如开启，不同interrupt的优先级，timer的间隔等。
3. interrupt的内容，分成两个部分。第一个部分：三个tasks的开启阶段。第二个部分：开启tasks后随设置的timer间隔循环运行。
具体情况可参考项目要求说明文件以及demo视频。
